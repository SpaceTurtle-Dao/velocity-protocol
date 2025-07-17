-- Comprehensive Filter Testing Suite for Velocity Protocol Hubs
-- Tests all filter combinations, edge cases, and validation scenarios

print("🧪 Comprehensive Filter Testing Suite")
print("====================================")

-- Test data setup - create diverse events for testing
local testEvents = {
  -- Basic text notes
  {Kind = "1", Content = "Basic message 1", author = "user1", timestamp = 1640995200000},
  {Kind = "1", Content = "Basic message 2", author = "user2", timestamp = 1640995300000},
  {Kind = "1", Content = "Basic message 3", author = "user1", timestamp = 1640995400000},
  
  -- AI Memories with different types and importance
  {Kind = "10", Content = "High importance knowledge", author = "user1", timestamp = 1640995500000, 
   ai_importance = "0.9", ai_type = "knowledge", ai_context = "project_setup"},
  {Kind = "10", Content = "Medium importance conversation", author = "user2", timestamp = 1640995600000, 
   ai_importance = "0.6", ai_type = "conversation", ai_context = "daily_standup"},
  {Kind = "10", Content = "Low importance reasoning", author = "user3", timestamp = 1640995700000, 
   ai_importance = "0.3", ai_type = "reasoning", ai_context = "debugging"},
  {Kind = "10", Content = "Procedure without importance", author = "user1", timestamp = 1640995800000, 
   ai_type = "procedure", ai_context = "deployment"},
   
  -- Memory relationships
  {Kind = "11", sourceId = "mem1", targetId = "mem2", relationshipType = "supports", 
   strength = "0.8", author = "user1", timestamp = 1640995900000},
  {Kind = "11", sourceId = "mem2", targetId = "mem3", relationshipType = "contradicts", 
   strength = "0.7", author = "user2", timestamp = 1640996000000},
   
  -- Reasoning chains
  {Kind = "23", chainId = "chain1", steps = '[]', outcome = "Success", 
   author = "user1", timestamp = 1640996100000},
   
  -- Different kinds
  {Kind = "0", Content = "Profile update", author = "user3", timestamp = 1640996200000},
  {Kind = "3", Content = "Follow event", author = "user2", timestamp = 1640996300000},
  {Kind = "7", Content = "Reaction event", author = "user1", timestamp = 1640996400000},
  
  -- Edge case timestamps
  {Kind = "1", Content = "Very old message", author = "user1", timestamp = 1540995200000},
  {Kind = "1", Content = "Future message", author = "user2", timestamp = 1740995200000}
}

-- Helper function to send test event to hub
function sendTestEvent(hubId, event)
  print("📤 Sending test event: Kind " .. event.Kind .. " from " .. event.author)
  
  local tags = {
    Action = "Event",
    Kind = event.Kind,
    Content = event.Content
  }
  
  -- Add all event properties as tags
  for key, value in pairs(event) do
    if key ~= "Content" and key ~= "author" then
      tags[key] = tostring(value)
    end
  end
  
  ao.send({
    Target = hubId,
    Tags = tags,
    Data = event.Content or ""
  })
end

-- Helper function to test filter
function testFilter(hubId, testName, filterJson)
  print("\n🔍 Testing: " .. testName)
  print("Filter: " .. filterJson)
  
  ao.send({
    Target = hubId,
    Action = "FetchEvents",
    Filters = filterJson
  })
  
  -- Wait for response (in real AO, you'd handle this in message handler)
  print("✅ Filter test sent")
end

-- Test suite functions
function testBasicFilters(hubId)
  print("\n=== BASIC FILTER TESTS ===")
  
  -- Test 1: Filter by single kind
  testFilter(hubId, "Single Kind Filter (Kind 1)", 
    '[{"kinds": ["1"], "limit": 10}]')
  
  -- Test 2: Filter by multiple kinds  
  testFilter(hubId, "Multiple Kinds Filter", 
    '[{"kinds": ["1", "10"], "limit": 10}]')
  
  -- Test 3: Filter by author
  testFilter(hubId, "Single Author Filter", 
    '[{"authors": ["user1"], "limit": 10}]')
  
  -- Test 4: Filter by multiple authors
  testFilter(hubId, "Multiple Authors Filter", 
    '[{"authors": ["user1", "user2"], "limit": 10}]')
  
  -- Test 5: No filters (all events)
  testFilter(hubId, "No Filters (All Events)", 
    '[{"limit": 20}]')
end

function testTimeRangeFilters(hubId)
  print("\n=== TIME RANGE FILTER TESTS ===")
  
  -- Test 1: Since filter
  testFilter(hubId, "Since Filter (after 1640995500)", 
    '[{"since": 1640995500000, "limit": 10}]')
  
  -- Test 2: Until filter  
  testFilter(hubId, "Until Filter (before 1640996000)", 
    '[{"until": 1640996000000, "limit": 10}]')
  
  -- Test 3: Time range (since + until)
  testFilter(hubId, "Time Range Filter", 
    '[{"since": 1640995400000, "until": 1640996000000, "limit": 10}]')
  
  -- Test 4: Very narrow time range
  testFilter(hubId, "Narrow Time Range", 
    '[{"since": 1640995500000, "until": 1640995600000, "limit": 10}]')
  
  -- Test 5: Time range with no results
  testFilter(hubId, "Empty Time Range", 
    '[{"since": 1640990000000, "until": 1640990100000, "limit": 10}]')
end

function testAISpecificFilters(hubId)
  print("\n=== AI-SPECIFIC FILTER TESTS ===")
  
  -- Test 1: Filter by AI type
  testFilter(hubId, "AI Type Filter (knowledge)", 
    '[{"kinds": ["10"], "ai_type": "knowledge", "limit": 10}]')
  
  -- Test 2: Filter by AI importance minimum
  testFilter(hubId, "AI Importance Filter (min 0.7)", 
    '[{"kinds": ["10"], "ai_importance_min": 0.7, "limit": 10}]')
  
  -- Test 3: Combined AI filters
  testFilter(hubId, "Combined AI Filters", 
    '[{"kinds": ["10"], "ai_type": "knowledge", "ai_importance_min": 0.8, "limit": 10}]')
  
  -- Test 4: Filter AI memories by author
  testFilter(hubId, "AI Memories by Author", 
    '[{"kinds": ["10"], "authors": ["user1"], "limit": 10}]')
  
  -- Test 5: Filter different AI types
  testFilter(hubId, "Conversation AI Type", 
    '[{"kinds": ["10"], "ai_type": "conversation", "limit": 10}]')
  
  testFilter(hubId, "Reasoning AI Type", 
    '[{"kinds": ["10"], "ai_type": "reasoning", "limit": 10}]')
  
  testFilter(hubId, "Procedure AI Type", 
    '[{"kinds": ["10"], "ai_type": "procedure", "limit": 10}]')
end

function testCombinationFilters(hubId)
  print("\n=== COMBINATION FILTER TESTS ===")
  
  -- Test 1: Kind + Author + Time
  testFilter(hubId, "Triple Combination (Kind+Author+Time)", 
    '[{"kinds": ["1"], "authors": ["user1"], "since": 1640995200000, "limit": 10}]')
  
  -- Test 2: AI filters + Time + Author
  testFilter(hubId, "AI + Time + Author", 
    '[{"kinds": ["10"], "authors": ["user1"], "ai_importance_min": 0.5, "since": 1640995000000, "limit": 10}]')
  
  -- Test 3: Multiple kinds + Multiple authors + Time range
  testFilter(hubId, "Complex Multi-filter", 
    '[{"kinds": ["1", "10"], "authors": ["user1", "user2"], "since": 1640995200000, "until": 1640996000000, "limit": 10}]')
  
  -- Test 4: Memory relationships with time
  testFilter(hubId, "Memory Relations + Time", 
    '[{"kinds": ["11"], "since": 1640995800000, "limit": 10}]')
end

function testLimitAndPagination(hubId)
  print("\n=== LIMIT AND PAGINATION TESTS ===")
  
  -- Test 1: Small limit
  testFilter(hubId, "Small Limit (3)", 
    '[{"limit": 3}]')
  
  -- Test 2: Medium limit
  testFilter(hubId, "Medium Limit (10)", 
    '[{"limit": 10}]')
  
  -- Test 3: Large limit
  testFilter(hubId, "Large Limit (50)", 
    '[{"limit": 50}]')
  
  -- Test 4: No limit
  testFilter(hubId, "No Limit", 
    '[{}]')
  
  -- Test 5: Zero limit (edge case)
  testFilter(hubId, "Zero Limit (Edge Case)", 
    '[{"limit": 0}]')
end

function testEdgeCasesAndValidation(hubId)
  print("\n=== EDGE CASES AND VALIDATION TESTS ===")
  
  -- Test 1: Empty filter array
  print("\n🔍 Testing: Empty Filter Array")
  ao.send({
    Target = hubId,
    Action = "FetchEvents",
    Filters = "[]"
  })
  
  -- Test 2: Invalid JSON
  print("\n🔍 Testing: Invalid JSON")
  ao.send({
    Target = hubId,
    Action = "FetchEvents", 
    Filters = "invalid json"
  })
  
  -- Test 3: Non-existent kind
  testFilter(hubId, "Non-existent Kind", 
    '[{"kinds": ["999"], "limit": 10}]')
  
  -- Test 4: Non-existent author
  testFilter(hubId, "Non-existent Author", 
    '[{"authors": ["nonexistent"], "limit": 10}]')
  
  -- Test 5: Invalid AI importance (> 1)
  testFilter(hubId, "Invalid AI Importance", 
    '[{"kinds": ["10"], "ai_importance_min": 1.5, "limit": 10}]')
  
  -- Test 6: Invalid AI type
  testFilter(hubId, "Invalid AI Type", 
    '[{"kinds": ["10"], "ai_type": "invalid_type", "limit": 10}]')
  
  -- Test 7: Future timestamp
  testFilter(hubId, "Future Timestamp Filter", 
    '[{"since": 2000000000000, "limit": 10}]')
  
  -- Test 8: Negative timestamp
  testFilter(hubId, "Negative Timestamp", 
    '[{"since": -1000000, "limit": 10}]')
end

function testMultipleFiltersArray(hubId)
  print("\n=== MULTIPLE FILTERS ARRAY TESTS ===")
  
  -- Test 1: Two separate filters (OR logic)
  testFilter(hubId, "Two Separate Filters (OR)", 
    '[{"kinds": ["1"], "authors": ["user1"]}, {"kinds": ["10"], "authors": ["user2"]}]')
  
  -- Test 2: Three filters with different criteria
  testFilter(hubId, "Three Different Filters", 
    '[{"kinds": ["1"]}, {"authors": ["user2"]}, {"ai_type": "knowledge"}]')
  
  -- Test 3: Overlapping filters
  testFilter(hubId, "Overlapping Filters", 
    '[{"authors": ["user1"]}, {"kinds": ["1"], "authors": ["user1"]}]')
end

function testPerformanceFilters(hubId)
  print("\n=== PERFORMANCE TESTS ===")
  
  -- Test 1: All events (stress test)
  testFilter(hubId, "All Events (No Filters)", 
    '[{}]')
  
  -- Test 2: Very specific filter (should be fast)
  testFilter(hubId, "Very Specific Filter", 
    '[{"kinds": ["10"], "authors": ["user1"], "ai_type": "knowledge", "ai_importance_min": 0.9, "limit": 1}]')
  
  -- Test 3: Large limit with filters
  testFilter(hubId, "Large Limit with Filters", 
    '[{"kinds": ["1", "10"], "limit": 100}]')
end

-- Setup test data
function setupTestData(hubId)
  print("\n📋 Setting up test data...")
  
  for i, event in ipairs(testEvents) do
    sendTestEvent(hubId, event)
    -- Small delay between events
    for j = 1, 100000 do end
  end
  
  print("✅ Test data setup complete")
  -- Wait for events to be processed
  for i = 1, 1000000 do end
end

-- Main test runner
function runAllFilterTests(hubId)
  print("🧪 Starting Comprehensive Filter Test Suite")
  print("Hub ID: " .. hubId)
  print("=====================================")
  
  -- Setup test data first
  setupTestData(hubId)
  
  -- Run all test categories
  testBasicFilters(hubId)
  testTimeRangeFilters(hubId)
  testAISpecificFilters(hubId)
  testCombinationFilters(hubId)
  testLimitAndPagination(hubId)
  testEdgeCasesAndValidation(hubId)
  testMultipleFiltersArray(hubId)
  testPerformanceFilters(hubId)
  
  print("\n🎉 Comprehensive Filter Test Suite Complete!")
  print("============================================")
  print("📊 Test Summary:")
  print("• Basic filters (kinds, authors)")
  print("• Time range filters (since, until)")
  print("• AI-specific filters (type, importance)")
  print("• Complex combination filters")
  print("• Limit and pagination")
  print("• Edge cases and validation")
  print("• Multiple filters arrays")
  print("• Performance tests")
  print("")
  print("📝 Check your inbox for filter responses!")
  print("🔍 Look for patterns in response times and result accuracy")
end

-- Quick individual test functions
function testKindFilter(hubId, kind)
  testFilter(hubId, "Kind " .. kind .. " Filter", 
    '[{"kinds": ["' .. kind .. '"], "limit": 10}]')
end

function testAuthorFilter(hubId, author)
  testFilter(hubId, "Author " .. author .. " Filter", 
    '[{"authors": ["' .. author .. '"], "limit": 10}]')
end

function testAIImportanceFilter(hubId, minImportance)
  testFilter(hubId, "AI Importance >= " .. minImportance, 
    '[{"kinds": ["10"], "ai_importance_min": ' .. minImportance .. ', "limit": 10}]')
end

-- Response handler for filter test results
Handlers.add("FilterTestResponse",
  Handlers.utils.hasMatchingTag("Action", "Response"),
  function(msg)
    print("\n📥 Filter Test Response:")
    print("From: " .. (msg.From or "unknown"))
    
    local success, data = pcall(json.decode, msg.Data or "{}")
    if success and data.events then
      print("✅ Events returned: " .. #data.events)
      if data.count then print("📊 Total count: " .. data.count) end
      if data.totalEvents then print("🗃️ Hub total: " .. data.totalEvents) end
      
      -- Show first few events for verification
      for i, event in ipairs(data.events) do
        if i <= 3 then
          print("  " .. i .. ". Kind " .. (event.Kind or "?") .. 
                " from " .. (event.author or "?") .. 
                (event.ai_type and (" [" .. event.ai_type .. "]") or ""))
        end
      end
      if #data.events > 3 then
        print("  ... and " .. (#data.events - 3) .. " more")
      end
    else
      print("📄 Raw response: " .. (msg.Data or "no data"))
    end
    print("---")
  end
)

print("\n🚀 Comprehensive Filter Testing Suite Loaded!")
print("")
print("Available Commands:")
print("  runAllFilterTests('hub-id')           - Run complete test suite")
print("  setupTestData('hub-id')               - Set up test events only")
print("  testBasicFilters('hub-id')            - Test basic kind/author filters")
print("  testTimeRangeFilters('hub-id')        - Test time-based filters")
print("  testAISpecificFilters('hub-id')       - Test AI memory filters")
print("  testCombinationFilters('hub-id')      - Test complex combinations")
print("  testEdgeCasesAndValidation('hub-id')  - Test edge cases")
print("  testKindFilter('hub-id', 'kind')      - Test specific kind")
print("  testAuthorFilter('hub-id', 'author')  - Test specific author")
print("  testAIImportanceFilter('hub-id', 0.8) - Test AI importance threshold")
print("")
print("Example: runAllFilterTests('your-hub-process-id')")
print("")
print("🧪 Ready for comprehensive filter testing!")