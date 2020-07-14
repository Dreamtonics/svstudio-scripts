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

function bisectionMethod(f, xmin, xmax, numIter)
  if numIter == nil then
    numIter = 100
  end
  local xmean = (xmin + xmax) * 0.5
  local ymean = f(xmean)
  if math.abs(ymean) < 1e-5 or numIter == 0 then
    return xmean
  end
  local ymax = f(xmax)
  if (ymax > 0) ~= (ymean > 0) then
    return bisectionMethod(f, xmean, xmax, numIter - 1)
  else
    return bisectionMethod(f, xmin, xmean, numIter - 1)
  end
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

  local v, vPrev = 0, 0
  local a = 1 - options.speed
  local densityScale = 16 / options.density

  -- The smoothing filter's -6dB crossing point.
  local omega6dB = math.acos(- (3 * a * a - 8 * a + 3) / 2 / a)

  -- Adjust the decay rate against point density to keep -6dB crossing point.
  omega6dB = math.min(math.pi, math.max(0, omega6dB * densityScale))
  local inverseOmega = math.cos(omega6dB)
  a = bisectionMethod(function(x)
    return - (3 * x * x - 8 * x + 3) / 2 / x - inverseOmega
  end, 0, 1)

  -- Integration of the smoothing filter's power response.
  local powerIntegral = function(omega)
    return 2 * (a - 1) / (a + 1) *
      math.atan((a + 1) / (a - 1) * math.tan(omega / 2))
  end
  -- Calculate the power gain of the smoothing filter.
  powerGain = powerIntegral(math.pi) - powerIntegral(0)

  for i, r in ipairs(ranges) do
    local b = r[1]
    while b < r[2] do
      v = randn() * scale * options.strength
      v = vPrev * a + v * (1.0 - a)
      vPrev = v

      -- Compensate for the power gain.
      am:add(b, center + v / math.sqrt(powerGain))
      b = b + step
    end
  end
end
