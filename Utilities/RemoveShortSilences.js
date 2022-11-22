var SCRIPT_TITLE = "Remove Short Silences";

function getClientInfo() {
  return {
    "name": SV.T(SCRIPT_TITLE),
    "author": "Dreamtonics",
    "versionNumber": 1,
    "minEditorVersion": 66048
  }
}

function getTranslations(langCode) {
  if(langCode == "ja-jp") {
    return [
      ["Remove Short Silences", "短い無声区間を取り除く"],
      ["Threshold", "しきい値"],
      ["Scope", "スコープ"],
      ["Selected Notes", "選択されたノート"],
      ["Current Track", "現在のトラック"],
      ["Entire Project", "プロジェクト全体"]
    ];
  }
  if(langCode == "zh-cn") {
    return [
      ["Remove Short Silences", "移除短的无声间隙"],
      ["Threshold", "阈值"],
      ["Scope", "作用范围"],
      ["Selected Notes", "所选音符"],
      ["Current Track", "当前音轨"],
      ["Entire Project", "整个项目"]
    ];
  }
  return [];
}

function sortNotes(arr_notes) {
  return arr_notes.sort(function(a,b) {
    if(a.getOnset() < b.getOnset()) return -1;
    if(a.getOnset() > b.getOnset()) return 1;
    return 0;
  });
}

function noteGetter(arr_like, index) {
  if(Array.isArray(arr_like)) {
    return arr_like[index];
  } else {
    // the input is a NoteGroup
    return arr_like.getNote(index);
  }
}

function processNoteSequence(arr_like, N, threshold) {
  for(var i = 1; i < N; i ++) {
    var currOnset = noteGetter(arr_like, i).getOnset();
    var prevEnd = noteGetter(arr_like, i - 1).getEnd();
    if(currOnset != prevEnd && 
      currOnset - prevEnd < SV.QUARTER * threshold) {
      var prevOnset = noteGetter(arr_like, i - 1).getOnset();
      noteGetter(arr_like, i - 1).setDuration(currOnset - prevOnset);
    }
  }
}

function main() {
  var myForm = {
    "title" : SV.T("Remove Short Silences"),
    "buttons" : "OkCancel",
    "widgets" : [
      {
        "name" : "threshold", "type" : "Slider",
        "label" : SV.T("Threshold"),
        "format" : "%.0f/32 Quarters",
        "minValue" : 1,
        "maxValue" : 32,
        "interval" : 1,
        "default" : 2
      },
      {
        "name" : "scope", "type" : "ComboBox",
        "label" : SV.T("Scope"),
        "choices" : [SV.T("Selected Notes"), SV.T("Current Track"), 
          SV.T("Entire Project")],
        "default" : 0
      },
    ]
  };

  var result = SV.showCustomDialog(myForm);
  var threshold = result.answers.threshold / 32.0;

  if(result.status == 1) {
    if(result.answers.scope == 0) {
      var selection = SV.getMainEditor().getSelection();
      var selectedNotes = sortNotes(selection.getSelectedNotes());
      processNoteSequence(selectedNotes, selectedNotes.length, threshold);
    } else if(result.answers.scope == 1) {
      var track = SV.getMainEditor().getCurrentTrack();
      var trackGroupN = track.getNumGroups();
      var visited = [];
      for(var i = 0; i < trackGroupN; i ++) {
        var group = track.getGroupReference(i).getTarget();
        if(visited.indexOf(group.getUUID()) < 0) {
          processNoteSequence(group, group.getNumNotes(), threshold);
          visited.push(group.getUUID());
        }
      }
    } else if(result.answers.scope == 2) {
      var project = SV.getProject();
      for(var i = 0; i < project.getNumNoteGroupsInLibrary(); i ++) {
        var group = project.getNoteGroup(i);
        processNoteSequence(group, group.getNumNotes(), threshold);
      }
      for(var i = 0; i < project.getNumTracks(); i ++) {
        var track = project.getTrack(i);
        var mainGroup = track.getGroupReference(0).getTarget();
        processNoteSequence(mainGroup, mainGroup.getNumNotes(), threshold);
      }
    }
  } 
  SV.finish();
}
