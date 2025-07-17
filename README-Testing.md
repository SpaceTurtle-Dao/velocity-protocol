# Velocity Protocol Enhanced Hub Testing

This directory contains enhanced implementations of the Velocity Protocol hub with VIP-08 AI Memory support and comprehensive testing tools.

## Files

### Hub Implementations
- **`enhanced-openhub.lua`** - Enhanced public hub with VIP-08 AI features
- **`private-hub.lua`** - Private hub (owner-only access) with AI features
- **`simple-test.lua`** - Lua test script for AO processes
- **`test-enhanced-hub.js`** - JavaScript test suite using AO Lite

### Documentation Improvements
- **`vips/01.md`** - Enhanced with Quick Start guide and examples

## Features

### Enhanced Public Hub (`enhanced-openhub.lua`)
- ✅ Full VIP-01 compliance (Event/FetchEvents handlers)
- ✅ VIP-08 AI Memory support (Kinds 10, 11, 23, 40)
- ✅ Advanced indexing and filtering
- ✅ Rate limiting and security
- ✅ AI analytics endpoint
- ✅ Performance optimizations

### Private Hub (`private-hub.lua`)
- ✅ Owner-only access control
- ✅ All enhanced hub features
- ✅ Private AI memory storage
- ✅ Authorized user management
- ✅ Enhanced privacy and security

## Testing with AO Lite

### Setup
1. Clone AO Lite:
   ```bash
   git clone https://github.com/perplex-labs/aolite.git
   cd aolite
   npm install
   ```

2. Run the test suite:
   ```bash
   node test-enhanced-hub.js
   ```

### Test Options
- **Spawn Enhanced Hub** - Deploy public hub process
- **Spawn Private Hub** - Deploy private hub process  
- **Test Enhanced Hub** - Run comprehensive tests on public hub
- **Test Private Hub** - Run tests on private hub
- **Test Both Hubs** - Full test suite for both implementations

## Testing with AO Processes

### Load Test Script
1. Start an AO process
2. Load the test script:
   ```lua
   .load simple-test.lua
   ```

3. Run tests:
   ```lua
   runAllTests('your-hub-process-id')
   ```

### Individual Tests
```lua
-- Test basic messaging
testBasicMessage('hub-id')

-- Test AI Memory (VIP-08)
testAIMemory('hub-id')

-- Test queries
testQuery('hub-id')
testAIQuery('hub-id')

-- Test hub information
testHubInfo('hub-id')
testAIAnalytics('hub-id')
```

## VIP-08 AI Memory Features

### Kind 10 - Enhanced AI Memory
```lua
ao.send({
  Target = hub_id,
  Action = "Event",
  Kind = "10",
  Content = "User prefers TypeScript for new projects",
  ai_importance = "0.8",
  ai_type = "knowledge",
  ai_context = '{"sessionId":"setup"}',
  ai_topic = "preferences",
  ai_domain = "programming"
})
```

### Kind 11 - Memory Relationships
```lua
ao.send({
  Target = hub_id,
  Action = "Event", 
  Kind = "11",
  sourceId = "memory_1",
  targetId = "memory_2",
  relationshipType = "supports",
  strength = "0.9"
})
```

### Kind 23 - Reasoning Chains
```lua
local steps = json.encode({
  {stepType = "observation", content = "User needs auth", confidence = 0.95},
  {stepType = "thought", content = "JWT is stateless", confidence = 0.8},
  {stepType = "action", content = "Implement JWT", confidence = 0.9}
})

ao.send({
  Target = hub_id,
  Action = "Event",
  Kind = "23", 
  chainId = "auth_decision_001",
  steps = steps,
  outcome = "Implemented JWT system"
})
```

### Kind 40 - Memory Contexts
```lua
ao.send({
  Target = hub_id,
  Action = "Event",
  Kind = "40",
  contextName = "Authentication Project",
  description = "Memories for auth implementation",
  contextType = "project"
})
```

## Advanced Filtering

### AI-Specific Queries
```lua
-- Filter by AI importance
ao.send({
  Target = hub_id,
  Action = "FetchEvents",
  Filters = '[{"kinds": [10], "ai_importance_min": 0.8}]'
})

-- Filter by AI type
ao.send({
  Target = hub_id,
  Action = "FetchEvents", 
  Filters = '[{"ai_type": "knowledge", "limit": 10}]'
})
```

### Time-based Queries
```lua
ao.send({
  Target = hub_id,
  Action = "FetchEvents",
  Filters = '[{"since": 1640995200, "until": 1640998800}]'
})
```

## Hub Analytics

### Get AI Analytics
```lua
ao.send({
  Target = hub_id,
  Action = "AIAnalytics"
})
```

Returns:
- Memory statistics
- Type distribution
- Relationship counts
- Context counts
- Average importance scores

## Private Hub Usage

### Owner-Only Access
The private hub only accepts messages from the process owner:

```lua
-- Only works if sent from owner's wallet
ao.send({
  Target = private_hub_id,
  Action = "Event",
  Kind = "10", 
  Content = "Private AI memory",
  ai_importance = "0.95"
})
```

### Add Authorized Users (Owner Only)
```lua
ao.send({
  Target = private_hub_id,
  Action = "AddAuthorizedUser",
  User = "user-wallet-address"
})
```

## Error Handling

Both hubs provide detailed error responses:
- Invalid message validation
- Access control violations
- Rate limiting messages
- Storage limit warnings

## Performance

### Indexing
- Multi-dimensional indexes for fast queries
- Optimized timestamp sorting
- AI-specific metadata indexing

### Memory Management
- Configurable storage limits
- Event pruning capabilities
- Efficient relationship graphs

## Security

### Enhanced Hub
- Rate limiting (100 messages/hour per author)
- Spam filtering
- Author banning capabilities
- ANS-104 signature validation

### Private Hub  
- Owner-only access by default
- Authorized user management
- No rate limiting for owner
- Enhanced storage limits

## Next Steps

1. Deploy hubs to AO mainnet
2. Integrate with AI agent frameworks
3. Add persistence layer
4. Implement hub discovery (VIP-06)
5. Add encrypted messaging (VIP-07)

## Contributing

To improve the hubs:
1. Test with various message types
2. Optimize performance
3. Add new VIP features
4. Enhance security measures
5. Improve error handling

The enhanced implementations maintain full backward compatibility while adding powerful AI memory capabilities for next-generation decentralized applications.