function getClientInfo() {
  return {
    "name" : "Hello World (Javascript)",
    "category" : "Examples",
    "author" : "Dreamtonics",
    "versionNumber" : 0,
    "minEditorVersion" : 0
  };
}

function main() {
  SV.showMessageBoxAsync("Hello", "Hello, world!",
    function() {
      SV.showInputBoxAsync("Create Group",
        "Please tell me the group name", "FooBar Group", next);
    });
}

function next(groupName) {
  if(groupName == "") {
    SV.finish();
    return;
  }

  var mainProject = SV.getProject();
  var newGroup = SV.create("NoteGroup");
  newGroup.setName(groupName);
  mainProject.addNoteGroup(newGroup, 0);

  onNextFrame();
}

function onNextFrame() {
  var newGroup = SV.getProject().getNoteGroup(0);
  var lyricsOptions = ["foo", "bar"];
  var scale = [60, 62, 64, 67, 69];

  var i = newGroup.getNumNotes();
  if(i < 9)
    SV.setTimeout(100, onNextFrame);
  else {
    SV.showMessageBoxAsync("Hello", "Done!", function() { SV.finish(); });
  }
  
  var n = SV.create("Note");
  var onset = i * SV.QUARTER;
  n.setTimeRange(onset, SV.QUARTER);
  n.setPitch(scale[i % 5]);
  n.setLyrics(lyricsOptions[i % 2]);
  newGroup.addNote(n);
}
