function getClientInfo()
  return {
    name = "Test Selection (Lua)",
    author = "Dreamtonics",
    versionNumber = 0,
    minEditorVersion = 0
  }
end

foobar = {"foo", "bar"}

function main()
  local myNoteGroup = SV:create("NoteGroup")
  myNoteGroup:setName("FooBar Palindrome")

  local pitches = {}
  for i = 60, 71 do
    if not SV:blackKey(i) then
      pitches[#pitches + 1] = i
    end
  end

  local palindrome = {}
  for i = 1, #pitches do
    palindrome[#palindrome + 1] = pitches[i]
  end
  palindrome[#palindrome + 1] = 72
  for i = #pitches, 1, -1 do
    palindrome[#palindrome + 1] = pitches[i]
  end

  for i = 1, #palindrome do
    local myNote = SV:create("Note")
    myNote:setPitch(palindrome[i])
    myNote:setTimeRange(i * SV.QUARTER / 2, SV.QUARTER / 2)
    myNote:setLyrics(foobar[(i - 1) % 2 + 1])
    myNoteGroup:addNote(myNote)
  end

  SV:getProject():addNoteGroup(myNoteGroup)
  local firstTrack = SV:getProject():getTrack(1)
  local mainGroup = firstTrack:getGroupReference(1):getTarget()

  while firstTrack:getNumGroups() > 1 do
    firstTrack:removeGroupReference(2)
  end
  while mainGroup:getNumNotes() > 0 do
    mainGroup:removeNote(1)
  end
  
  for i = 1, #palindrome do
    local myNote = SV:create("Note")
    myNote:setPitch(72 - palindrome[i] + 60)
    myNote:setTimeRange(SV.QUARTER * 4 + i * SV.QUARTER / 2, SV.QUARTER / 2)
    myNote:setLyrics(foobar[(i - 1) % 2 + 1])
    mainGroup:addNote(myNote)
  end

  for i = 1, 3 do
    local offset = SV.QUARTER * 4 + SV.QUARTER * 8 * i
    local myGroupRef = SV:create("NoteGroupReference", myNoteGroup)
    myGroupRef:setTimeOffset(offset)
    myGroupRef:setPitchOffset(pitches[i] - 60)
    firstTrack:addGroupReference(myGroupRef)
  end

  local mainEditorSelection = SV:getMainEditor():getSelection()
  for i = 1, mainGroup:getNumNotes() do
    mainEditorSelection:selectNote(mainGroup:getNote(i))
  end
  for i = 2, firstTrack:getNumGroups() do
    mainEditorSelection:selectGroup(firstTrack:getGroupReference(i))
  end

  local allNotesSelected = mainEditorSelection:getSelectedNotes()
  for i = 1, #allNotesSelected, 2 do
    local note = allNotesSelected[i]
    mainEditorSelection:unselectNote(note)
    note:setPitch(note:getPitch() - 3)
  end
  local allGroupsSelected = mainEditorSelection:getSelectedGroups()
  for i = 1, #allGroupsSelected, 2 do
    mainEditorSelection:unselectGroup(allGroupsSelected[i])
  end

  SV:finish()
end
