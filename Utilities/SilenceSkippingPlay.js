function getClientInfo() {
  return {
    "name": SV.T("Silence Skipping Play"),
    "author": "Dreamtonics",
    "versionNumber": 1,
    "minEditorVersion": 65537
  };
}

function getTranslations(langCode) {
  if(langCode == "ja-jp") {
    return [
      ["Silence Skipping Play", "無音区間を飛ばして再生"]
    ];
  }
  return [];
}

function main() {
  // SV.showMessageBox(SV.T("Debugging"), SV.QUARTER);
  var playback = SV.getPlayback();
  var scope = SV.getMainEditor().getCurrentGroup();
  var group = scope.getTarget();
  var N = group.getNumNotes();
  var closestOnset = group.getNote(0).getOnset();
  playback.play();

  function getNewPos() {
    var skip = true;
    var position = playback.getPlayhead();
    // SV.showMessageBox(SV.T("Debugging"), position);
    var foundClosest = false;
    for(var i = 0; i < N; i++) {
      if(!foundClosest && position < group.getNote(i).getOnset() / SV.QUARTER / 2) {
        closestOnset = group.getNote(i).getOnset();
        foundClosest = true;
      }
      var checkLeft = position >= group.getNote(i).getOnset() / SV.QUARTER / 2;
      var checkRight = position <= group.getNote(i).getEnd() / SV.QUARTER / 2;
      if(checkLeft && checkRight) {
        skip = false;
        break;
      }
    }
    if(skip) {
      playback.seek(closestOnset / SV.QUARTER / 2);
    }
    if(position > group.getNote(N - 1).getEnd() / SV.QUARTER / 2) {
      playback.stop();
      SV.finish();
    } else {
      SV.setTimeout(100, getNewPos);
    }

  }

  SV.setTimeout(100, getNewPos);
}