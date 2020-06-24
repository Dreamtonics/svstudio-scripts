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

  var project = SV.getProject();
  var timeAxis = project.getTimeAxis();

  function getNewPos() {
    var skip = true;
    var position = playback.getPlayhead();
    // SV.showMessageBox(SV.T("Debugging"), position);
    var foundClosest = false;
    for(var i = 0; i < N; i++) {
      if(!foundClosest && position < timeAxis.getSecondsFromBlick(group.getNote(i).getOnset())) {
        closestOnset = group.getNote(i).getOnset();
        foundClosest = true;
      }
      var checkLeft = position >= timeAxis.getSecondsFromBlick(group.getNote(i).getOnset());
      var checkRight = position <= timeAxis.getSecondsFromBlick(group.getNote(i).getEnd());
      if(checkLeft && checkRight) {
        skip = false;
        break;
      }
    }
    if(skip) {
      playback.seek(timeAxis.getSecondsFromBlick(closestOnset));
    }
    if(position > timeAxis.getSecondsFromBlick(group.getNote(N - 1).getEnd())) {
      playback.stop();
      SV.finish();
    } else {
      SV.setTimeout(100, getNewPos);
    }

  }

  SV.setTimeout(100, getNewPos);
}