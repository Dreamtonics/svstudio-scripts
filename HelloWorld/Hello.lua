function getClientInfo()
  return {
    name = "Hello World (Lua)",
    category = "Examples",
    author = "Dreamtonics",
    versionNumber = 0,
    minEditorVersion = 0
  }
end

function main()
  SV:showMessageBox("Hello", "Hello, world!")
  SV:showInputBoxAsync("Create Group",
    "Please tell me the group name", "FooBar Group", next)
end

function next(groupName)
  if groupName == "" then
    SV:finish()
    return
  end

  local mainProject = SV:getProject()
  local newGroup = SV:create("NoteGroup")
  newGroup:setName(groupName)
  mainProject:addNoteGroup(newGroup, 1)

  onNextFrame()
end

function onNextFrame()
  local newGroup = SV:getProject():getNoteGroup(1)
  local lyricsOptions = {"foo", "bar"}
  local scale = {60, 62, 64, 67, 69}

  local i = newGroup:getNumNotes()
  if i < 9 then
    SV:setTimeout(100, onNextFrame)
  else
    SV:showMessageBoxAsync("Hello", "Done!", function() SV:finish() end)
  end

  local n = SV:create("Note")
  local onset = i * SV.QUARTER
  n:setTimeRange(onset, SV.QUARTER)
  n:setPitch(scale[i % 5 + 1])
  n:setLyrics(lyricsOptions[i % 2 + 1])
  newGroup:addNote(n)
end
