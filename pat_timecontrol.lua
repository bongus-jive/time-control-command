function init()
  if not chat.command or not chat.parseArguments then
    sb.logWarn("Time Control requires StarExtensions or OpenStarbound")
    script.setUpdateDelta(0)
    return
  end
  
  -- OpenStarbound currently returns a table instead of multiple values like in StarExtensions
  chat_parseArguments = chat.parseArguments
  if type(chat.parseArguments("meow")) == "table" then
    chat_parseArguments = function(...)
      return table.unpack(chat.parseArguments(...))
    end
  end

  self = root.assetJson("/pat_timecontrol.sussy")
  message.setHandler("/time", time)
end

local function getString(key, ...)
  return string.format(self.strings[key], ...)
end

function time(_, localMsg, stringArgs)
  if not localMsg then
    return
  end

  local arg, arg2 = chat_parseArguments(stringArgs)
  local timeOfDay = world.timeOfDay()
  local currentTime = timeOfDay * self.dayTime

  if arg == "query" then
    return getString("currentTime", currentTime)
  end

  if arg == "set" then
    arg = arg2
    arg2 = nil
  end

  local newTime

  if arg == "add" and arg2 then
    newTime = tonumber(arg2) + currentTime
  elseif self.timeNames[arg] then
    newTime = self.timeNames[arg] * self.dayTime
  else
    newTime = tonumber(arg)
  end

  if type(newTime) ~= "number" then
    return getString("help")
  end

  local dayLength = world.dayLength()
  local warpAmount = dayLength * ((newTime / self.dayTime % 1) - timeOfDay)

  if warpAmount < 0 then
    warpAmount = warpAmount + dayLength
  end

  chat.command("/timewarp " .. warpAmount)
  return getString("setTime", newTime % self.dayTime)
end
