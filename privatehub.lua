local json = require('json')
local bint = require('.bint')(256)
local utils = require(".utils")

-- Private Velocity Protocol Hub - Owner Only
-- Only accepts messages from the process owner for personal/private use

-- Message Kinds (VIP-01 through VIP-08)
Kinds = {
  PROFILE_UPDATE = "0",  -- VIP-01
  NOTE = "1",           -- VIP-01  
  REPLY = "1",          -- VIP-03
  FOLLOW = "3",         -- VIP-02
  REACTION = "7",       -- VIP-04
  AI_MEMORY = "10",     -- VIP-08
  MEMORY_RELATION = "11", -- VIP-08
  REASONING_CHAIN = "23", -- VIP-08
  MEMORY_CONTEXT = "40",  -- VIP-08
  HUB_GOSSIP = "1000"   -- VIP-06
}

-- Private Hub State
State = {
  Events = Events or {},
  Owner = Owner or ao.id,
  
  -- Hub specification - Private mode
  Spec = {
    type = "hub",
    description = "Private Velocity Protocol Hub - Owner Only Access",
    version = "1.1.0",
    processId = ao.id,
    kinds = {"0", "1", "3", "7", "10", "11", "23", "40", "1000"},
    features = {
      ai_memory = true,
      ai_reasoning = true,
      ai_relationships = true,
      ai_contexts = true,
      ai_analytics = true,
      private_mode = true
    },
    supportedProtocols = {"velocity"},
    isPublic = false,
    acceptsAllEvents = false,
    ownerOnly = true
  },
  
  -- Security - Owner only
  Security = {
    ownerOnly = true,
    allowedUsers = {}, -- Can be extended if needed
    maxEvents = 10000, -- Private hubs can have higher limits
    rateLimitDisabled = true -- No rate limiting for owner
  },
  
  -- Performance indexes
  Indexes = {
    byAuthor = {},     -- author -> array of event indices
    byId = {},         -- event ID -> event index
    byKind = {},       -- kind -> array of event indices  
    byTag = {},        -- tag -> array of event indices
    byTimestamp = {},  -- sorted array of {timestamp, index}
    byAIType = {},     -- AI type -> array of event indices (VIP-08)
    byContext = {},    -- context -> array of event indices (VIP-08)
    relationships = {} -- memory relationships graph (VIP-08)
  },
  
  -- Enhanced statistics for private use
  Stats = {
    totalEvents = 0,
    eventsByKind = {},
    aiMemoryStats = {
      totalMemories = 0,
      averageImportance = 0,
      typeDistribution = {},
      contextCount = 0,
      relationshipCount = 0
    },
    lastUpdated = 0,
    ownerEventCount = 0
  }
}

-- Private hub utility functions
function isOwner(author)
  return author == State.Owner
end

function isAuthorizedUser(author)
  -- Check if user is owner or in allowed list
  if isOwner(author) then
    return true, "Owner access"
  end
  
  if State.Security.allowedUsers[author] then
    return true, "Authorized user"
  end
  
  return false, "Access denied - private hub"
end

function validateBasicEvent(event)
  -- Basic ANS-104 validation
  if not event.Kind or not event.Content then
    return false, "Missing required fields: Kind or Content"
  end
  
  if not event.author then
    return false, "Missing author field"
  end
  
  -- Validate kind is supported
  local validKind = false
  for _, kind in ipairs(State.Spec.kinds) do
    if tostring(event.Kind) == kind then
      validKind = true
      break
    end
  end
  
  if not validKind then
    return false, "Unsupported message kind: " .. tostring(event.Kind)
  end
  
  return true, "Valid event"
end

function validateAIMemory(event)
  -- VIP-08 AI Memory validation for Kind 10
  if event.ai_importance then
    local importance = tonumber(event.ai_importance)
    if not importance or importance < 0 or importance > 1 then
      return false, "ai_importance must be float between 0-1"
    end
  end
  
  if event.ai_type then
    local validTypes = {conversation = true, reasoning = true, knowledge = true, procedure = true}
    if not validTypes[event.ai_type] then
      return false, "Invalid ai_type. Must be: conversation, reasoning, knowledge, or procedure"
    end
  end
  
  return true, "Valid AI memory"
end

function validateMemoryRelation(event)
  -- VIP-08 Memory Relationship validation for Kind 11
  if not event.sourceId or not event.targetId or not event.relationshipType or not event.strength then
    return false, "Missing required fields for memory relationship"
  end
  
  local validTypes = {causes = true, supports = true, contradicts = true, extends = true, references = true}
  if not validTypes[event.relationshipType] then
    return false, "Invalid relationship type"
  end
  
  local strength = tonumber(event.strength)
  if not strength or strength < 0 or strength > 1 then
    return false, "Strength must be float between 0-1"
  end
  
  return true, "Valid memory relationship"
end

function addToIndexes(event, eventIndex)
  local author = event.author
  local kind = tostring(event.Kind)
  
  -- Author index
  if not State.Indexes.byAuthor[author] then
    State.Indexes.byAuthor[author] = {}
  end
  table.insert(State.Indexes.byAuthor[author], eventIndex)
  
  -- Kind index
  if not State.Indexes.byKind[kind] then
    State.Indexes.byKind[kind] = {}
  end
  table.insert(State.Indexes.byKind[kind], eventIndex)
  
  -- ID index
  if event.id then
    State.Indexes.byId[event.id] = eventIndex
  end
  
  -- Timestamp index (keep sorted)
  table.insert(State.Indexes.byTimestamp, {event.timestamp or os.time() * 1000, eventIndex})
  table.sort(State.Indexes.byTimestamp, function(a, b) return a[1] > b[1] end)
  
  -- AI-specific indexes (VIP-08)
  if kind == "10" and event.ai_type then
    if not State.Indexes.byAIType[event.ai_type] then
      State.Indexes.byAIType[event.ai_type] = {}
    end
    table.insert(State.Indexes.byAIType[event.ai_type], eventIndex)
  end
  
  if event.ai_context then
    if not State.Indexes.byContext[event.ai_context] then
      State.Indexes.byContext[event.ai_context] = {}
    end
    table.insert(State.Indexes.byContext[event.ai_context], eventIndex)
  end
  
  -- Memory relationships (VIP-08)
  if kind == "11" then
    if not State.Indexes.relationships[event.sourceId] then
      State.Indexes.relationships[event.sourceId] = {}
    end
    table.insert(State.Indexes.relationships[event.sourceId], {
      target = event.targetId,
      type = event.relationshipType,
      strength = tonumber(event.strength),
      eventIndex = eventIndex
    })
  end
end

function updateStats(event)
  State.Stats.totalEvents = State.Stats.totalEvents + 1
  State.Stats.lastUpdated = os.time() * 1000
  
  if isOwner(event.author) then
    State.Stats.ownerEventCount = State.Stats.ownerEventCount + 1
  end
  
  local kind = tostring(event.Kind)
  if not State.Stats.eventsByKind[kind] then
    State.Stats.eventsByKind[kind] = 0
  end
  State.Stats.eventsByKind[kind] = State.Stats.eventsByKind[kind] + 1
  
  -- AI Memory stats (VIP-08)
  if kind == "10" then
    State.Stats.aiMemoryStats.totalMemories = State.Stats.aiMemoryStats.totalMemories + 1
    
    if event.ai_importance then
      local importance = tonumber(event.ai_importance)
      local total = State.Stats.aiMemoryStats.totalMemories
      local current = State.Stats.aiMemoryStats.averageImportance
      State.Stats.aiMemoryStats.averageImportance = ((current * (total - 1)) + importance) / total
    end
    
    if event.ai_type then
      if not State.Stats.aiMemoryStats.typeDistribution[event.ai_type] then
        State.Stats.aiMemoryStats.typeDistribution[event.ai_type] = 0
      end
      State.Stats.aiMemoryStats.typeDistribution[event.ai_type] = 
        State.Stats.aiMemoryStats.typeDistribution[event.ai_type] + 1
    end
  elseif kind == "11" then
    State.Stats.aiMemoryStats.relationshipCount = State.Stats.aiMemoryStats.relationshipCount + 1
  elseif kind == "40" then
    State.Stats.aiMemoryStats.contextCount = State.Stats.aiMemoryStats.contextCount + 1
  end
end

function filterEvents(filters)
  local results = {}
  local processedEventIds = {}
  
  for _, filter in ipairs(filters) do
    local candidates = {}
    
    -- Get candidates based on filter criteria
    if filter.authors then
      for _, author in ipairs(filter.authors) do
        if State.Indexes.byAuthor[author] then
          for _, idx in ipairs(State.Indexes.byAuthor[author]) do
            candidates[idx] = true
          end
        end
      end
    elseif filter.kinds then
      for _, kind in ipairs(filter.kinds) do
        if State.Indexes.byKind[tostring(kind)] then
          for _, idx in ipairs(State.Indexes.byKind[tostring(kind)]) do
            candidates[idx] = true
          end
        end
      end
    else
      -- No specific filter, consider all events
      for i = 1, #State.Events do
        candidates[i] = true
      end
    end
    
    -- Apply additional filters
    for idx, _ in pairs(candidates) do
      local event = State.Events[idx]
      local matches = true
      
      -- Time range filters
      if filter.since and event.timestamp and event.timestamp < filter.since then
        matches = false
      end
      if filter["until"] and event.timestamp and event.timestamp > filter["until"] then
        matches = false
      end
      
      -- Kind filter
      if filter.kinds then
        local kindMatch = false
        for _, kind in ipairs(filter.kinds) do
          if tostring(event.Kind) == tostring(kind) then
            kindMatch = true
            break
          end
        end
        if not kindMatch then matches = false end
      end
      
      -- Author filter
      if filter.authors then
        local authorMatch = false
        for _, author in ipairs(filter.authors) do
          if event.author == author then
            authorMatch = true
            break
          end
        end
        if not authorMatch then matches = false end
      end
      
      -- AI-specific filters (VIP-08)
      if filter.ai_type and event.ai_type ~= filter.ai_type then
        matches = false
      end
      
      if filter.ai_importance_min then
        if not event.ai_importance or tonumber(event.ai_importance) < filter.ai_importance_min then
          matches = false
        end
      end
      
      if matches and not processedEventIds[event.id or idx] then
        table.insert(results, event)
        processedEventIds[event.id or idx] = true
      end
    end
  end
  
  -- Sort by timestamp (newest first)
  table.sort(results, function(a, b)
    local tsA = a.timestamp or 0
    local tsB = b.timestamp or 0
    return tsA > tsB
  end)
  
  return results
end

-- Private Event Handler - Owner Only
Handlers.add("Event",
  Handlers.utils.hasMatchingTag("Action", "Event"),
  function(msg)
    print("Processing private Event from: " .. (msg.From or "unknown"))
    
    -- STRICT: Only owner can send events
    local authorized, authMsg = isAuthorizedUser(msg.From)
    if not authorized then
      print("Access denied for: " .. (msg.From or "unknown"))
      ao.send({
        Target = msg.From, 
        Data = json.encode({
          status = "error",
          message = authMsg,
          hubType = "private",
          owner = State.Owner
        })
      })
      return
    end
    
    -- Parse event from message
    local event = {
      id = msg.Id,
      author = msg.From,
      timestamp = msg.Timestamp,
      Kind = msg.Tags.Kind,
      Content = msg.Data or msg.Tags.Content or "",
    }
    
    -- Copy all tags as event properties
    for name, value in pairs(msg.Tags or {}) do
      if name ~= "Action" then
        event[name] = value
      end
    end
    
    -- Basic validation
    local valid, errorMsg = validateBasicEvent(event)
    if not valid then
      ao.send({Target = msg.From, Data = json.encode({status = "error", message = errorMsg})})
      return
    end
    
    -- Kind-specific validation
    if event.Kind == "10" then
      local aiValid, aiError = validateAIMemory(event)
      if not aiValid then
        ao.send({Target = msg.From, Data = json.encode({status = "error", message = aiError})})
        return
      end
    elseif event.Kind == "11" then
      local relValid, relError = validateMemoryRelation(event)
      if not relValid then
        ao.send({Target = msg.From, Data = json.encode({status = "error", message = relError})})
        return
      end
    end
    
    -- Check storage limits
    if #State.Events >= State.Security.maxEvents then
      ao.send({
        Target = msg.From, 
        Data = json.encode({
          status = "error", 
          message = "Storage limit reached (" .. State.Security.maxEvents .. " events)"
        })
      })
      return
    end
    
    -- Store event
    table.insert(State.Events, event)
    local eventIndex = #State.Events
    
    -- Update indexes
    addToIndexes(event, eventIndex)
    
    -- Update statistics
    updateStats(event)
    
    print("Private event stored successfully. Total events: " .. State.Stats.totalEvents)
    
    -- Send confirmation
    ao.send({
      Target = msg.From,
      Data = json.encode({
        status = "success",
        eventId = event.id,
        eventIndex = eventIndex,
        totalEvents = State.Stats.totalEvents,
        message = "Event stored in private hub"
      })
    })
  end
)

-- Private FetchEvents Handler - Owner Only
Handlers.add("FetchEvents",
  Handlers.utils.hasMatchingTag("Action", "FetchEvents"),
  function(msg)
    print("Processing private FetchEvents request from: " .. (msg.From or "unknown"))
    
    -- STRICT: Only owner can query events
    local authorized, authMsg = isAuthorizedUser(msg.From)
    if not authorized then
      print("Query access denied for: " .. (msg.From or "unknown"))
      ao.send({
        Target = msg.From, 
        Data = json.encode({
          status = "error",
          message = authMsg,
          hubType = "private",
          owner = State.Owner
        })
      })
      return
    end
    
    local filtersStr = msg.Tags.Filters or msg.Data
    if not filtersStr then
      ao.send({Target = msg.From, Data = json.encode({status = "error", message = "No filters provided"})})
      return
    end
    
    local success, filters = pcall(json.decode, filtersStr)
    if not success then
      ao.send({Target = msg.From, Data = json.encode({status = "error", message = "Invalid JSON in filters"})})
      return
    end
    
    if type(filters) ~= "table" then
      filters = {filters}
    end
    
    -- Filter events
    local results = filterEvents(filters)
    
    -- Apply limit if specified
    if filters[1] and filters[1].limit then
      local limit = tonumber(filters[1].limit)
      if limit and limit > 0 and #results > limit then
        local limited = {}
        for i = 1, limit do
          table.insert(limited, results[i])
        end
        results = limited
      end
    end
    
    print("Returning " .. #results .. " events from private hub")
    
    -- Send results
    ao.send({
      Target = msg.From,
      Data = json.encode({
        status = "success",
        events = results,
        count = #results,
        totalEvents = State.Stats.totalEvents,
        hubType = "private"
      })
    })
  end
)

-- Private Hub Info Handler
Handlers.add("Info",
  Handlers.utils.hasMatchingTag("Action", "Info"),
  function(msg)
    -- Anyone can check info, but limited details for non-owners
    local isOwnerRequest = isOwner(msg.From)
    
    local response = {
      spec = State.Spec,
      hubType = "private",
      owner = State.Owner,
      isOwnerRequest = isOwnerRequest
    }
    
    if isOwnerRequest then
      response.stats = State.Stats
      response.uptime = os.time() * 1000 - (State.Stats.lastUpdated or 0)
      response.memoryAnalytics = {
        totalMemories = State.Stats.aiMemoryStats.totalMemories,
        averageImportance = State.Stats.aiMemoryStats.averageImportance,
        typeDistribution = State.Stats.aiMemoryStats.typeDistribution,
        relationshipCount = State.Stats.aiMemoryStats.relationshipCount,
        contextCount = State.Stats.aiMemoryStats.contextCount
      }
    else
      response.publicInfo = "This is a private hub. Only the owner can access stored data."
    end
    
    ao.send({
      Target = msg.From,
      Data = json.encode(response)
    })
  end
)

-- Owner Management Handler
Handlers.add("AddAuthorizedUser",
  Handlers.utils.hasMatchingTag("Action", "AddAuthorizedUser"),
  function(msg)
    if not isOwner(msg.From) then
      ao.send({Target = msg.From, Data = json.encode({status = "error", message = "Owner only"})})
      return
    end
    
    local user = msg.Tags.User or msg.Data
    if not user then
      ao.send({Target = msg.From, Data = json.encode({status = "error", message = "No user specified"})})
      return
    end
    
    State.Security.allowedUsers[user] = true
    
    ao.send({
      Target = msg.From,
      Data = json.encode({
        status = "success",
        message = "User " .. user .. " added to authorized list"
      })
    })
  end
)

Handlers.add("RemoveAuthorizedUser",
  Handlers.utils.hasMatchingTag("Action", "RemoveAuthorizedUser"),
  function(msg)
    if not isOwner(msg.From) then
      ao.send({Target = msg.From, Data = json.encode({status = "error", message = "Owner only"})})
      return
    end
    
    local user = msg.Tags.User or msg.Data
    if not user then
      ao.send({Target = msg.From, Data = json.encode({status = "error", message = "No user specified"})})
      return
    end
    
    State.Security.allowedUsers[user] = nil
    
    ao.send({
      Target = msg.From,
      Data = json.encode({
        status = "success",
        message = "User " .. user .. " removed from authorized list"
      })
    })
  end
)

print("Private Velocity Protocol Hub initialized (Owner Only)")
print("Process ID: " .. ao.id)
print("Owner: " .. State.Owner)
print("Supported kinds: " .. json.encode(State.Spec.kinds))
print("Private mode: Only owner can send/query events")