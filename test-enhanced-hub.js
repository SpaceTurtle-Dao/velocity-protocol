#!/usr/bin/env node

/**
 * Test Script for Enhanced Velocity Protocol Hub
 * Tests both public enhanced hub and private hub implementations
 */

const { connect } = require('./aolite');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// Hub process IDs (will be set when processes are spawned)
let ENHANCED_HUB_ID = null;
let PRIVATE_HUB_ID = null;

async function question(prompt) {
  return new Promise((resolve) => {
    rl.question(prompt, resolve);
  });
}

async function testEnhancedHub() {
  console.log('\n🔧 Testing Enhanced Public Hub...\n');
  
  if (!ENHANCED_HUB_ID) {
    console.log('❌ Enhanced Hub ID not set. Please spawn the process first.');
    return;
  }

  try {
    const ao = await connect();
    
    // Test 1: Send a basic text note (Kind 1)
    console.log('📝 Test 1: Sending basic text note...');
    const noteResult = await ao.message({
      process: ENHANCED_HUB_ID,
      tags: {
        Action: 'Event',
        Kind: '1',
        Content: 'Hello Enhanced Velocity Protocol! This is a test message.'
      }
    });
    console.log('✅ Note sent:', noteResult);

    // Test 2: Send AI Memory (Kind 10) - VIP-08
    console.log('\n🧠 Test 2: Sending AI Memory...');
    const memoryResult = await ao.message({
      process: ENHANCED_HUB_ID,
      tags: {
        Action: 'Event',
        Kind: '10',
        Content: 'User prefers TypeScript over JavaScript for new projects',
        ai_importance: '0.8',
        ai_type: 'knowledge',
        ai_context: '{"sessionId":"test_session","topic":"preferences"}',
        ai_session: 'test_session',
        ai_topic: 'language_preferences',
        ai_domain: 'programming'
      }
    });
    console.log('✅ AI Memory sent:', memoryResult);

    // Test 3: Send Memory Relationship (Kind 11) - VIP-08
    console.log('\n🔗 Test 3: Sending Memory Relationship...');
    const relationResult = await ao.message({
      process: ENHANCED_HUB_ID,
      tags: {
        Action: 'Event',
        Kind: '11',
        sourceId: 'memory_typescript_pref',
        targetId: 'memory_project_setup',
        relationshipType: 'supports',
        strength: '0.9',
        description: 'TypeScript preference supports better project setup'
      }
    });
    console.log('✅ Memory Relationship sent:', relationResult);

    // Test 4: Send Reasoning Chain (Kind 23) - VIP-08
    console.log('\n🤔 Test 4: Sending Reasoning Chain...');
    const reasoningSteps = JSON.stringify([
      {
        stepType: "observation",
        content: "User needs secure authentication",
        confidence: 0.95,
        timestamp: new Date().toISOString()
      },
      {
        stepType: "thought",
        content: "JWT provides stateless authentication",
        confidence: 0.8,
        timestamp: new Date().toISOString()
      },
      {
        stepType: "action",
        content: "Implement JWT-based auth system",
        confidence: 0.9,
        timestamp: new Date().toISOString()
      }
    ]);

    const reasoningResult = await ao.message({
      process: ENHANCED_HUB_ID,
      tags: {
        Action: 'Event',
        Kind: '23',
        chainId: 'auth_decision_test_001',
        steps: reasoningSteps,
        outcome: 'Implemented JWT authentication system',
        confidence: '0.88',
        domain: 'security',
        method: 'chain-of-thought'
      }
    });
    console.log('✅ Reasoning Chain sent:', reasoningResult);

    // Test 5: Query recent events
    console.log('\n📊 Test 5: Querying recent events...');
    const queryResult = await ao.message({
      process: ENHANCED_HUB_ID,
      tags: {
        Action: 'FetchEvents',
        Filters: JSON.stringify([{
          limit: 10
        }])
      }
    });
    console.log('✅ Query result:', queryResult);

    // Test 6: Query AI memories specifically
    console.log('\n🧠 Test 6: Querying AI memories...');
    const aiQueryResult = await ao.message({
      process: ENHANCED_HUB_ID,
      tags: {
        Action: 'FetchEvents',
        Filters: JSON.stringify([{
          kinds: [10],
          limit: 5
        }])
      }
    });
    console.log('✅ AI Memory query result:', aiQueryResult);

    // Test 7: Get hub info
    console.log('\n📋 Test 7: Getting hub info...');
    const infoResult = await ao.message({
      process: ENHANCED_HUB_ID,
      tags: {
        Action: 'Info'
      }
    });
    console.log('✅ Hub info:', infoResult);

    // Test 8: Get AI analytics
    console.log('\n📈 Test 8: Getting AI analytics...');
    const analyticsResult = await ao.message({
      process: ENHANCED_HUB_ID,
      tags: {
        Action: 'AIAnalytics'
      }
    });
    console.log('✅ AI Analytics:', analyticsResult);

    console.log('\n✅ Enhanced Hub tests completed successfully!');

  } catch (error) {
    console.error('❌ Enhanced Hub test failed:', error);
  }
}

async function testPrivateHub() {
  console.log('\n🔒 Testing Private Hub...\n');
  
  if (!PRIVATE_HUB_ID) {
    console.log('❌ Private Hub ID not set. Please spawn the process first.');
    return;
  }

  try {
    const ao = await connect();
    
    // Test 1: Send event as owner
    console.log('👤 Test 1: Sending event as owner...');
    const ownerResult = await ao.message({
      process: PRIVATE_HUB_ID,
      tags: {
        Action: 'Event',
        Kind: '1',
        Content: 'This is a private message from the owner'
      }
    });
    console.log('✅ Owner event sent:', ownerResult);

    // Test 2: Send AI Memory in private hub
    console.log('\n🧠 Test 2: Sending private AI memory...');
    const privateMemoryResult = await ao.message({
      process: PRIVATE_HUB_ID,
      tags: {
        Action: 'Event',
        Kind: '10',
        Content: 'Private thought: Consider implementing zero-knowledge proofs for enhanced privacy',
        ai_importance: '0.95',
        ai_type: 'reasoning',
        ai_context: '{"private":true,"confidential":true}',
        ai_topic: 'privacy_enhancement',
        ai_domain: 'cryptography'
      }
    });
    console.log('✅ Private AI Memory sent:', privateMemoryResult);

    // Test 3: Query private events
    console.log('\n📊 Test 3: Querying private events...');
    const privateQueryResult = await ao.message({
      process: PRIVATE_HUB_ID,
      tags: {
        Action: 'FetchEvents',
        Filters: JSON.stringify([{
          limit: 5
        }])
      }
    });
    console.log('✅ Private query result:', privateQueryResult);

    // Test 4: Get private hub info
    console.log('\n📋 Test 4: Getting private hub info...');
    const privateInfoResult = await ao.message({
      process: PRIVATE_HUB_ID,
      tags: {
        Action: 'Info'
      }
    });
    console.log('✅ Private hub info:', privateInfoResult);

    console.log('\n✅ Private Hub tests completed successfully!');

  } catch (error) {
    console.error('❌ Private Hub test failed:', error);
  }
}

async function spawnHubProcess(hubType) {
  const ao = await connect();
  const hubFile = hubType === 'enhanced' ? 'enhanced-openhub.lua' : 'private-hub.lua';
  
  console.log(`🚀 Spawning ${hubType} hub process...`);
  
  try {
    const fs = require('fs');
    const hubCode = fs.readFileSync(hubFile, 'utf8');
    
    const result = await ao.spawn({
      module: "your-module-id-here", // You'll need to specify the appropriate AO module
      scheduler: "your-scheduler-here", // You'll need to specify the scheduler
      data: hubCode
    });
    
    console.log(`✅ ${hubType} hub spawned with ID:`, result.id);
    return result.id;
    
  } catch (error) {
    console.error(`❌ Failed to spawn ${hubType} hub:`, error);
    return null;
  }
}

async function interactiveMenu() {
  console.log('\n🚀 Velocity Protocol Hub Tester\n');
  console.log('Available options:');
  console.log('1. Spawn Enhanced Hub');
  console.log('2. Spawn Private Hub');
  console.log('3. Test Enhanced Hub');
  console.log('4. Test Private Hub');
  console.log('5. Test Both Hubs');
  console.log('6. Set Hub IDs manually');
  console.log('7. Exit');
  
  const choice = await question('\nSelect option (1-7): ');
  
  switch (choice) {
    case '1':
      ENHANCED_HUB_ID = await spawnHubProcess('enhanced');
      break;
    case '2':
      PRIVATE_HUB_ID = await spawnHubProcess('private');
      break;
    case '3':
      await testEnhancedHub();
      break;
    case '4':
      await testPrivateHub();
      break;
    case '5':
      await testEnhancedHub();
      await testPrivateHub();
      break;
    case '6':
      ENHANCED_HUB_ID = await question('Enter Enhanced Hub ID: ');
      PRIVATE_HUB_ID = await question('Enter Private Hub ID: ');
      console.log('✅ Hub IDs set manually');
      break;
    case '7':
      console.log('👋 Goodbye!');
      rl.close();
      return;
    default:
      console.log('❌ Invalid option');
  }
  
  // Continue with menu
  setTimeout(interactiveMenu, 1000);
}

// Start the interactive menu
interactiveMenu().catch(console.error);

// Handle graceful shutdown
process.on('SIGINT', () => {
  console.log('\n👋 Shutting down...');
  rl.close();
  process.exit(0);
});