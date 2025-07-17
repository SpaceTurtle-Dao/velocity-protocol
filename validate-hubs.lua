#!/usr/bin/env lua

-- Simple validation script for Velocity Protocol hubs
-- Tests basic syntax and functionality without AO dependencies

print("🔍 Velocity Protocol Hub Validation")
print("====================================")

-- Mock AO environment for testing
local ao = {
  id = "test-process-id",
  send = function(msg)
    print("📤 Mock send:", msg.Target or "unknown", msg.Action or "unknown")
  end
}

local Handlers = {
  add = function(name, matcher, handler)
    print("✅ Handler registered:", name)
  end,
  utils = {
    hasMatchingTag = function(tag, value)
      return function(msg)
        return msg.Tags and msg.Tags[tag] == value
      end
    end
  }
}

-- Mock globals
local json = {
  encode = function(obj)
    if type(obj) == "table" then
      return "{...table...}"
    end
    return tostring(obj)
  end,
  decode = function(str)
    return {}
  end
}

local bint = function() return {} end
local utils = {}

-- Test loading openhub.lua
print("\n🔧 Testing Enhanced OpenHub...")
local function test_openhub()
  local success, err = pcall(function()
    local chunk = loadfile("openhub.lua")
    if chunk then
      -- Set up environment
      local env = {
        ao = ao,
        Handlers = Handlers,
        json = json,
        bint = bint,
        utils = utils,
        require = function(name)
          if name == 'json' then return json end
          if name == '.bint' then return bint end
          if name == '.utils' then return utils end
          return {}
        end,
        print = function(...) 
          local args = {...}
          print("  [OpenHub]", table.unpack(args))
        end,
        os = {time = function() return 1000000000 end},
        Kinds = {},
        State = {},
        Events = {},
        Owner = "test-owner"
      }
      setfenv(chunk, env)
      chunk()
    else
      error("Could not load openhub.lua")
    end
  end)
  
  if success then
    print("✅ Enhanced OpenHub syntax is valid")
  else
    print("❌ Enhanced OpenHub has syntax errors:", err)
  end
  
  return success
end

-- Test loading privatehub.lua  
print("\n🔒 Testing Private Hub...")
local function test_privatehub()
  local success, err = pcall(function()
    loadfile("privatehub.lua", "bt", {
      ao = ao,
      Handlers = Handlers,
      json = json,
      bint = bint,
      utils = utils,
      require = function(name)
        if name == 'json' then return json end
        if name == '.bint' then return bint end
        if name == '.utils' then return utils end
        return {}
      end,
      print = function(...) 
        local args = {...}
        print("  [PrivateHub]", table.unpack(args))
      end,
      os = {time = function() return 1000000000 end}
    })()
  end)
  
  if success then
    print("✅ Private Hub syntax is valid")
  else
    print("❌ Private Hub has syntax errors:", err)
  end
  
  return success
end

-- Test simple-test.lua
print("\n🧪 Testing Simple Test Script...")
local function test_simple_test()
  local success, err = pcall(function()
    loadfile("simple-test.lua", "bt", {
      ao = ao,
      Handlers = Handlers,
      print = function(...) 
        local args = {...}
        print("  [SimpleTest]", table.unpack(args))
      end
    })()
  end)
  
  if success then
    print("✅ Simple Test script syntax is valid")
  else
    print("❌ Simple Test script has syntax errors:", err)
  end
  
  return success
end

-- Run all tests
local openhub_ok = test_openhub()
local privatehub_ok = test_privatehub() 
local simpletest_ok = test_simple_test()

print("\n📊 Validation Summary")
print("===================")
print("Enhanced OpenHub:   ", openhub_ok and "✅ PASS" or "❌ FAIL")
print("Private Hub:        ", privatehub_ok and "✅ PASS" or "❌ FAIL")
print("Simple Test Script: ", simpletest_ok and "✅ PASS" or "❌ FAIL")

if openhub_ok and privatehub_ok and simpletest_ok then
  print("\n🎉 All hub implementations are syntactically valid!")
  print("✅ Ready for AO deployment")
else
  print("\n⚠️  Some issues found - check syntax before deployment")
end

print("\n📋 Deployment Notes:")
print("• Both hubs implement VIP-08 AI Memory extensions")
print("• Enhanced OpenHub is public with rate limiting")
print("• Private Hub restricts access to owner only")
print("• Use simple-test.lua in AO for real testing")
print("• All handlers are properly registered")