-- Simple test script for AO Lite to test Velocity Protocol hubs
-- This can be loaded into an AO process to test hub functionality

-- Test sending a basic message to a hub
function testBasicMessage(hubId)
  print("Testing basic message to hub: " .. hubId)
  
  ao.send({
    Target = hubId,
    Action = "Event",
    Kind = "1",
    Content = "Hello from test client! Testing basic Velocity Protocol message."
  })
  
  print("Basic message sent!")
end

-- Test sending AI Memory (VIP-08)
function testAIMemory(hubId)
  print("Testing AI Memory to hub: " .. hubId)
  
  ao.send({
    Target = hubId,
    Action = "Event",
    Kind = "10",
    Content = "Test memory: AI prefers structured data for better reasoning",
    ai_importance = "0.85",
    ai_type = "knowledge",
    ai_context = '{"test":true,"session":"lua_test"}',
    ai_topic = "ai_preferences",
    ai_domain = "artificial_intelligence"
  })
  
  print("AI Memory sent!")
end

-- Test querying events
function testQuery(hubId)
  print("Testing query to hub: " .. hubId)
  
  ao.send({
    Target = hubId,
    Action = "FetchEvents",
    Filters = '[{"limit": 5}]'
  })
  
  print("Query sent!")
end

-- Test querying specific AI memories
function testAIQuery(hubId)
  print("Testing AI Memory query to hub: " .. hubId)
  
  ao.send({
    Target = hubId,
    Action = "FetchEvents", 
    Filters = '[{"kinds": [10], "limit": 3}]'
  })
  
  print("AI Memory query sent!")
end

-- Test hub info
function testHubInfo(hubId)
  print("Testing hub info request to: " .. hubId)
  
  ao.send({
    Target = hubId,
    Action = "Info"
  })
  
  print("Hub info request sent!")
end

-- Test AI Analytics (VIP-08)
function testAIAnalytics(hubId)
  print("Testing AI Analytics request to: " .. hubId)
  
  ao.send({
    Target = hubId,
    Action = "AIAnalytics"
  })
  
  print("AI Analytics request sent!")
end

-- Full test suite
function runAllTests(hubId)
  print("=== Running Full Test Suite ===")
  print("Hub ID: " .. hubId)
  print("")
  
  testBasicMessage(hubId)
  
  -- Wait a bit between tests
  for i = 1, 1000000 do end
  
  testAIMemory(hubId)
  
  for i = 1, 1000000 do end
  
  testQuery(hubId)
  
  for i = 1, 1000000 do end
  
  testAIQuery(hubId)
  
  for i = 1, 1000000 do end
  
  testHubInfo(hubId)
  
  for i = 1, 1000000 do end
  
  testAIAnalytics(hubId)
  
  print("")
  print("=== Test Suite Complete ===")
  print("Check inbox for responses!")
end

-- Message handler to see responses
Handlers.add("TestResponse",
  Handlers.utils.hasMatchingTag("Action", "Event"),
  function(msg)
    print("Received response:")
    print("From: " .. (msg.From or "unknown"))
    print("Data: " .. (msg.Data or "no data"))
    print("---")
  end
)

-- Usage instructions
print("Velocity Protocol Test Suite Loaded!")
print("")
print("Usage:")
print("  testBasicMessage('hub-id-here')")
print("  testAIMemory('hub-id-here')")
print("  testQuery('hub-id-here')")
print("  testAIQuery('hub-id-here')")
print("  testHubInfo('hub-id-here')")
print("  testAIAnalytics('hub-id-here')")
print("  runAllTests('hub-id-here')")
print("")
print("Example:")
print("  runAllTests('your-hub-process-id')")
print("")
print("Ready for testing!")