SCRIPT_TITLE = "Randomize Parameters"

paramDispNames = {
  "Pitch Deviation", "Vibrato Envelope", "Loudness", "Tension",
  "Breathiness", "Voicing", "Gender"
}

paramTypeNames = {
  "pitchDelta", "vibratoEnv", "loudness", "tension",
  "breathiness", "voicing", "gender"
}

function getClientInfo()
  return {
    name = SV:T(SCRIPT_TITLE),
    author = "Dreamtonics",
    versionNumber = 1,
    minEditorVersion = 65537
  }
end

function getTranslations(langCode)
  if langCode == "ja-jp" then
    return {
      {"Randomize Parameters", "パラメータの乱数化"},
      {"Parameter Type", "パラメータタイプ"}
    }
  end
  if langCode == "zh-cn" then
    return {
      {"Randomize Parameters", "参数随机化"},
      {"Parameter Type", "参数类型"},
      {"Speed", "速度"},
      {"Points per quarter", "每四分音符的控制点数量"},
      {"Replace existing control points.", "替换既有的控制点。"}
    }
  end
  return {}
end

function main()
  local paramNameTranslated = {}
  for i = 1, #paramDispNames do
    paramNameTranslated[i] = SV:T(paramDispNames[i])
  end

  local form = {
    title = SV:T(SCRIPT_TITLE),
    message = "",
    buttons = "OkCancel",
    widgets = {
      {
        name = "paramType",
        type = "ComboBox",
        label = SV:T("Parameter Type"),
        choices = paramNameTranslated,
        default = 0
      },
      {
        name = "strength",
        type = "Slider",
        label = SV:T("Strength"),
        format = "%1.2f",
        minValue = 0,
        maxValue = 1,
        interval = 0.05,
        default = 0.25
      },
      {
        name = "speed",
        type = "Slider",
        label = SV:T("Speed"),
        format = "%1.2f",
        minValue = 0.01,
        maxValue = 1,
        interval = 0.01,
        default = 0.2
      },
      {
        name = "density",
        type = "Slider",
        label = SV:T("Points per quarter"),
        format = "%3.0f",
        minValue = 1,
        maxValue = 64,
        interval = 1,
        default = 16
      },
      {
        name = "overwrite",
        type = "CheckBox",
        text = SV:T("Replace existing control points."),
        default = false
      }
    }
  }

  local results = SV:showCustomDialog(form)
  if results.status then
    randomize(results.answers)
  end

  SV:finish()
end

-- Get an array of blick ranges for connected notes in the selection
function getSelectedRanges()
  local selection = SV:getMainEditor():getSelection()
  local selectedNotes = selection:getSelectedNotes()
  if #selectedNotes == 0 then
    return {}
  end
  table.sort(selectedNotes, function(noteA, noteB)
    return noteA:getOnset() < noteB:getOnset()
  end)
  
  local ranges = {}
  local bStart = selectedNotes[1]:getOnset()
  local bEnd = selectedNotes[1]:getEnd()
  for i = 2, #selectedNotes do
    if selectedNotes[i]:getOnset() > bEnd then
      ranges[#ranges + 1] = {bStart, bEnd}
      bStart = selectedNotes[i]:getOnset()
    end
    bEnd = selectedNotes[i]:getEnd()
  end
  ranges[#ranges + 1] = {bStart, bEnd}
  return ranges
end

-- Gaussian noise generator with mean = 0, variance = 1.
function randn()
  if _randn_queued ~= nil then
    ret, _randn_queued = _randn_queued, nil
    return ret
  else
    local u1 = math.random()
    local u2 = math.random()
    local scale = math.sqrt(-2 * math.log(u1))
    _randn_queued = scale * math.sin(2 * math.pi * u2)
    return scale * math.cos(2 * math.pi * u2)
  end
end
_randn_queued = nil

-- Design a smoothing filter with an auto-makeup gain.
-- Return a filter function.
function makeSmoothingFilter(options)
  local a = 1 - options.speed
  local densityScale = 16 / options.density

  -- The smoothing filter's -6dB crossing point.
  local omega6dB = math.acos(
    math.min(1, math.max(0, - (3 * a * a - 8 * a + 3) / 2 / a)))

  -- Adjust the decay rate against point density to keep -6dB crossing point.
  omega6dB = math.min(math.pi, math.max(0, omega6dB * densityScale))
  local inverseOmega = math.min(1 - 1e-7, math.cos(omega6dB))
  -- Solve for a new decay rate that keeps the -6dB crossing frequency.
  -- This has a closed-form solution.
  local delta = math.sqrt((2 * inverseOmega - 8) ^ 2 - 36)
  a = (8 - 2 * inverseOmega - delta) / 6

  -- Integration of the smoothing filter's power response.
  local powerIntegral = function(omega)
    return 2 * (a - 1) / (a + 1) *
      math.atan((a + 1) / (a - 1) * math.tan(omega / 2))
  end
  -- Calculate the power gain of the smoothing filter.
  powerGain = powerIntegral(math.pi) - powerIntegral(0)

  local y = 0
  return function(x)
    y = y * a + x * options.strength * (1 - a)
    -- Compensate for the power gain.
    return y / math.sqrt(powerGain)
  end
end

function randomize(options)
  local scope = SV:getMainEditor():getCurrentGroup()
  local group = scope:getTarget()
  local ranges = getSelectedRanges()

  local am = group:getParameter(paramTypeNames[options.paramType + 1])
  local step = math.floor(SV.QUARTER / options.density)

  local scale = 1
  local center = am:getDefinition().defaultValue
  if options.paramType == 0 then
    scale = 100
  elseif options.paramType == 2 then
    scale = 12
  end

  -- Make a copy of all the points in the selected ranges.
  local amCopy = SV:create("Automation", paramTypeNames[options.paramType + 1])
  if not options.overwrite then
    for i, r in ipairs(ranges) do
      local points = am:getPoints(r[1], r[2])
      for _, p in ipairs(points) do
        amCopy:add(p[1], p[2])
      end
    end
  end
  
  local filter = makeSmoothingFilter(options)
  for i, r in ipairs(ranges) do
    local origLeft, origRight = am:get(r[1] - step), am:get(r[2] + step)
    am:add(r[1] - step, origLeft)
    am:add(r[2] + step, origRight)
    am:remove(r[1], r[2])
    local b = r[1]
    while b < r[2] do
      local v = filter(randn() * scale)
      if options.overwrite then
        am:add(b, center + v)
      else
        am:add(b, amCopy:get(b) + v)
      end
      b = b + step
    end
  end
end
