function getClientInfo()
  return {
    name = "Test Navigation (Lua)",
    author = "Dreamtonics",
    versionNumber = 0,
    minEditorVersion = 0
  }
end

function main()
  local navMain = SV:getMainEditor():getNavigation()

  navMain:setTimeScale(50 / SV.QUARTER)

  intervalCallback()
end

local count = 0
function intervalCallback()
  count = count + 1

  local navMain = SV:getMainEditor():getNavigation()
  local tLeft = navMain:getTimeViewRange()[1]
  navMain:setTimeScale(navMain:getTimePxPerUnit() *
    (1 + 0.02 * math.sin(count * 0.1)))
  navMain:setTimeLeft(tLeft + SV.QUARTER / count)

  if count < 100 then
    SV:setTimeout(50, intervalCallback)
  else
    SV:finish()
  end
end
