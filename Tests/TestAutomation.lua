function getClientInfo()
  return {
    name = "Test Automation (Lua)",
    author = "Dreamtonics",
    versionNumber = 0,
    minEditorVersion = 0
  }
end

function main()
  local mainRef = SV:getProject():getTrack(1):getGroupReference(1)
  local mainGroup = mainRef:getTarget()
  
  local myPitchBend = mainGroup:getParameter("PitchDelta")
  local myTension = mainGroup:getParameter("Tension")

  local numPoints = 1024
  local y, yPrev = 0, 0
  for i = 1, numPoints do
    local x = i * SV.QUARTER / 8
    y = (math.random() - 0.5) * 500
    y = (yPrev * 0.9 + y * 0.1) * 0.99
    yPrev = y
    myPitchBend:add(x, y)
  end

  y, yPrev = 0, 0
  for i = 1, numPoints do
    local x = i * SV.QUARTER / 8
    y = (math.random() - 0.5) * 5
    y = (yPrev * 0.97 + y * 0.03) * 0.98
    yPrev = y
    myTension:add(x, y)
  end

  SV:finish()
end
