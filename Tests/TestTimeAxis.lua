function getClientInfo()
  return {
    name = "Test Time Axis (Lua)",
    author = "Dreamtonics",
    versionNumber = 0,
    minEditorVersion = 2034
  }
end

function resetTimeAxis(dst)
  local allTempoMarks = dst:getAllTempoMarks()
  local allMeasureMarks = dst:getAllMeasureMarks()

  for i = 2, #allTempoMarks do
    dst:removeTempoMark(allTempoMarks[i].position)
  end
  for i = 2, #allMeasureMarks do
    dst:removeMeasureMark(allMeasureMarks[i].position)
  end

  local baseBPM = allTempoMarks[1].bpm

  dst:addTempoMark(0, baseBPM)
  dst:addMeasureMark(0, 4, 4)

  return baseBPM
end

function main()
  local timeAxis = SV:getProject():getTimeAxis()

  local baseBPM = resetTimeAxis(timeAxis)
  for i = 1, 20 do
    local b = SV.QUARTER / 2 * math.floor(4 * i ^ 1.2)
    timeAxis:addTempoMark(b, baseBPM * (1 + 0.25 * math.sin(i)))
  end

  local measure = 0
  for i = 1, 10 do
    local denom = 2 ^ math.ceil(math.random() * 3)
    local numer = math.ceil(math.random() * denom * 2)
    measure = measure + math.ceil(math.random() * 4)
    timeAxis:addMeasureMark(measure, numer, denom)
  end

  SV:finish()
end
