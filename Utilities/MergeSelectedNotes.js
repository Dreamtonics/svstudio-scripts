var SCRIPT_TITLE = "Merge Selected Notes";

function getClientInfo() {
  return {
    "name" : SV.T(SCRIPT_TITLE),
    "author" : "Dreamtonics",
    "versionNumber" : 1,
    "minEditorVersion" : 65537
  };
}

function getTranslations(langCode) {
  if(langCode == "ja-jp") {
    return [
      ["Merge Selected Notes", "選択したノートをマージ"],
      ["Can't merge selected notes.", "選択したノートをマージできません。"]
    ];
  }
  if(langCode == "zh-cn") {
    return [
      ["Merge Selected Notes", "合并所选音符"],
      ["Can't merge selected notes.", "无法合并所选音符。"]
    ];
  }
  return [];
}

function main() {
  // Get the current selection, scope (group reference) and its target group.
  var selection = SV.getMainEditor().getSelection();
  var selectedNotes = selection.getSelectedNotes();
  var scope = SV.getMainEditor().getCurrentGroup();
  var group = scope.getTarget();
  
  // No note or only one note is selected.
  if(selectedNotes.length <= 1) {
    SV.finish();
    return;
  }

  var first = selectedNotes[0];
  var lyricsMerged = first.getLyrics();

  var lastEnd = first.getEnd();
  for(var i = 1; i < selectedNotes.length; i ++) {
    var note = selectedNotes[i];
    var currOnset = note.getOnset();
    if(currOnset != lastEnd) {
      SV.showMessageBox(
        SV.T(SCRIPT_TITLE), SV.T("Can't merge selected notes."));
      SV.finish();
      return;
    }
    
    var currLyrics = note.getLyrics();
    if(currLyrics.length > 0) {
      // Handle special cases.
      if(currLyrics[0] == ".") {
        // Phonetic input.
        lyricsMerged += " " + currLyrics.substring(1);
      } else if(currLyrics == "-") {
        // Legato - do nothing
      } else if(currLyrics == "+") {
        // Syllable break - do nothing
      } else {
        lyricsMerged += " " + currLyrics;
      }
    }
    lastEnd = note.getEnd();
  }

  // Lengthen the first note.
  first.setLyrics(lyricsMerged);
  first.setDuration(lastEnd - first.getOnset());

  // Remove the following notes.
  for(var i = 1; i < selectedNotes.length; i ++) {
    group.removeNote(selectedNotes[i].getIndexInParent());
  }

  SV.finish();
}
