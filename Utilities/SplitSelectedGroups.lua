paramTypeNames = {
  "pitchDelta", "vibratoEnv", "loudness", "tension",
  "breathiness", "voicing", "gender"
}

function getClientInfo()
  return {
    name = SV:T("Split Selected Groups"),
    author = "Dreamtonics",
    versionNumber = 1,
    minEditorVersion = 65537
  }
end

function getTranslations(langCode)
  if langCode == "ja-jp" then
    return {
      {"Split Selected Groups", "選択したグループの分割"}
    }
  end
  if langCode == "zh-cn" then
    return {
      {"Split Selected Groups", "分割所选音符组"}
    }
  end
  return {}
end

function main()
  local mGroupRefs = SV:getMainEditor():getSelection():getSelectedGroups()
  local aGroupRefs = SV:getArrangement():getSelection():getSelectedGroups()
  for i, r in ipairs(mGroupRefs) do
    attemptToSplitGroup(r)
  end
  for i, r in ipairs(aGroupRefs) do
    attemptToSplitGroup(r)
  end
end

-- Return the index of the note if pos is within a note.
-- Return the index of the previous note if there's no note at pos.
function findSortedNote(group, pos)
  local idxMin, idxMax = 1, group:getNumNotes() + 1
  local idxMid = math.floor((idxMin + idxMax) / 2)
  while idxMid ~= idxMin do
    if group:getNote(idxMid):getOnset() > pos then
      idxMax = idxMid
    else
      idxMin = idxMid
    end
    idxMid = math.floor((idxMin + idxMax) / 2)
  end
  return idxMin
end

-- Check if a group is used more than once in the project.
function isGroupUnique(group)
  local useCount = 0
  local project = SV:getProject()
  for i = 1, project:getNumTracks() do
    local track = project:getTrack(i)
    for j = 1, track:getNumGroups() do
      local ref = track:getGroupReference(j)
      if ref:getTarget():getUUID() == group:getUUID() then
        useCount = useCount + 1
      end
    end
  end
  return useCount <= 1
end

function copyToNewGroup(src, indexBegin, indexEnd, removeFromSrc)
  if removeFromSrc == nil then
    removeFromSrc = false
  end

  local ret = SV:create("NoteGroup")
  local offset = src:getNote(indexBegin):getOnset()
  local blickBegin = 0
  if indexBegin ~= 0 then
    blickBegin = offset
  end
  blickEnd = src:getNote(indexEnd):getEnd()
  
  for i = indexBegin, indexEnd do
    local note = src:getNote(i):clone()
    note:setOnset(note:getOnset() - offset)
    ret:addNote(note)
  end
  
  for i, typeName in ipairs(paramTypeNames) do
    local srcAM = src:getParameter(typeName)
    local dstAM = ret:getParameter(typeName)
    local points = srcAM:getPoints(
      blickBegin - SV.QUARTER, blickEnd + SV.QUARTER)
    for j, p in ipairs(points) do
      dstAM:add(p[1] - offset, p[2])
    end
    if removeFromSrc then
      srcAM:remove(blickBegin, blickEnd)
    end
  end

  if removeFromSrc then
    for i = indexEnd, indexBegin, -1 do
      src:removeNote(i)
    end
  end

  return ret, offset
end

function attemptToSplitGroup(ref)
  local playhead = SV:getPlayback():getPlayhead()
  local timeAxis = SV:getProject():getTimeAxis()
  playhead = timeAxis:getBlickFromSeconds(playhead)

  if playhead < ref:getOnset() or playhead >= ref:getEnd() then
    return
  end

  local offset = ref:getTimeOffset()
  local pitchOffset = ref:getPitchOffset()
  local voiceProps = ref:getVoice()

  -- force voiceProps to be recongized as an object as opposed to
  --   an array when it's empty
  voiceProps._ = ""

  local track = ref:getParent()
  local group = ref:getTarget()
  local index = findSortedNote(group, playhead - offset)
  local unique = isGroupUnique(group)
  
  -- Everything in [1, index] go to the left group;
  if not unique then
    local newGroupLeft, newGroupOffset = copyToNewGroup(group, 1, index, false)
    newGroupLeft:setName(group:getName() .. "_L")
    SV:getProject():addNoteGroup(newGroupLeft)

    track:removeGroupReference(ref:getIndexInParent())
    local newRef = SV:create("NoteGroupReference", newGroupLeft)
    newRef:setTimeOffset(offset + newGroupOffset)
    newRef:setPitchOffset(pitchOffset)
    newRef:setVoice(voiceProps)
    track:addGroupReference(newRef)
  end

  -- Everything in (index, last] go to the right group.
  local newGroupRight, newGroupOffset = copyToNewGroup(
    group, index + 1, group:getNumNotes(), unique)
  newGroupRight:setName(group:getName() .. "_R")
  SV:getProject():addNoteGroup(newGroupRight)

  local newRef = SV:create("NoteGroupReference", newGroupRight)
  newRef:setTimeOffset(offset + newGroupOffset)
  newRef:setPitchOffset(pitchOffset)
  newRef:setVoice(voiceProps)
  track:addGroupReference(newRef)
end
