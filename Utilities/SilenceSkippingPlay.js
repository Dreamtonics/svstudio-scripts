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
  var offset = scope.getTimeOffset();
  var closestOnset = group.getNote(0).getOnset() + offset;
  playback.play();

  var project = SV.getProject();
  var timeAxis = project.getTimeAxis();

  function getNewPos() {
    var skip = true;
    var position = timeAxis.getBlickFromSeconds(playback.getPlayhead());
    var foundClosest = false;
    for(var i = 0; i < N; i++) {
      var onset = group.getNote(i).getOnset() + offset;
      if(!foundClosest && position < onset) {
        closestOnset = onset;
        foundClosest = true;
      }
      var checkLeft = position >= onset;
      var checkRight = position <= group.getNote(i).getEnd() + offset;
      if(checkLeft && checkRight) {
        skip = false;
        break;
      }
    }
    if(skip) {
      playback.seek(timeAxis.getSecondsFromBlick(closestOnset));
    }
    if(position > group.getNote(N - 1).getEnd() + offset || 
      playback.getStatus() == "stopped") {
        
      playback.stop();
      SV.finish();
      return;
    } else {
      SV.setTimeout(200, getNewPos);
    }

  }

  SV.setTimeout(200, getNewPos);
}