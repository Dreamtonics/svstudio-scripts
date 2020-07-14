function getClientInfo()
  return {
    name = "Test Project (Lua)",
    category = "Tests",
    author = "Dreamtonics",
    versionNumber = 1,
    minEditorVersion = 65536
  }
end

foobar = {"foo", "bar"}

function checkNotes(notes)
  for i = 1, #notes do
    local ithNote = notes[i]
    local lyrics = ithNote:getLyrics()
    local pitch = ithNote:getPitch()
    local onset = ithNote:getOnset()
    local duration = ithNote:getDuration()
    assert(lyrics == foobar[(i - 1) % 2 + 1])
    assert(pitch == 60 + (i - 1) % 6)
    assert(onset == SV.QUARTER * ((i - 1) % 12))
    assert(duration == SV.QUARTER)
  end
end

function main()
  local notes = {}
  local numTracks = 3
  local numGroupRefsPerTrack = 2
  local numGroups = 3
  local numNotesPerGroup = 6
  
  for i = 1, numGroups * numNotesPerGroup do
    local ithNote = SV:create("Note")
    ithNote:setLyrics(foobar[(i - 1) % 2 + 1])
    ithNote:setPitch(60 + (i - 1) % 6)
    ithNote:setTimeRange(SV.QUARTER * ((i - 1) % 12), SV.QUARTER)
    ithNote:setAttributes({
      tF0Offset = (math.random() - 0.5) * 0.2,
      dF0Vbr = math.random() * 2 + 0.3,
      tF0VbrStart = math.random() * 0.4 + 0.1
    })
    if ithNote:getLyrics() == "foo" then
      ithNote:setAttributes({
        dur = {1.5, 0.8}
      })
    end
    notes[#notes + 1] = ithNote
  end

  checkNotes(notes)

  local noteGroups = {}
  for i = 1, numGroups do
    noteGroups[i] = SV:create("NoteGroup")
    noteGroups[i]:setName("My Group " .. i)
    for j = 1, numNotesPerGroup do
      noteGroups[i]:addNote(notes[(i - 1) * numNotesPerGroup + j])
    end
    SV:getProject():addNoteGroup(noteGroups[i])
  end

  local notesFromGroups = {}
  for i = 1, numGroups do
    for j = 1, numNotesPerGroup do
      notesFromGroups[#notesFromGroups + 1] = noteGroups[i]:getNote(j)
    end
  end
  checkNotes(notesFromGroups)

  local tracks = {}
  for i = 1, numTracks do
    tracks[i] = SV:create("Track")
    -- Unnamed tracks will get auto-assigned names when added to a project.
    if i % 2 == 0 then
      tracks[i]:setName("Named Track " .. i)
    end
    for j = 1, numGroupRefsPerTrack do
      local index = (i - 1) * numGroupRefsPerTrack + j
      -- Test two different ways of setting the target for a group ref.
      local groupRef
      if i % 2 == 1 then
        groupRef = SV:create("NoteGroupReference")
        groupRef:setTarget(noteGroups[(index - 1) % numGroups + 1])
        tracks[i]:addGroupReference(groupRef)
      else
        groupRef = SV:create("NoteGroupReference",
          noteGroups[(index - 1) % numGroups + 1])
        tracks[i]:addGroupReference(groupRef)
      end
    end
    SV:getProject():addTrack(tracks[i])
  end

  for i = 1, numTracks do
    for j = 2, tracks[i]:getNumGroups() do
      local groupRef = tracks[i]:getGroupReference(j)
      groupRef:setTimeOffset((j - 1) * SV.QUARTER * 10)
      groupRef:setPitchOffset(i + j - 1)
    end
  end

  SV:finish()
end
