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
  if(langCode == "zh-cn") {
    return [
      ["Silence Skipping Play", "跳过无声部分进行播放"]
    ];
  }
  return [];
}

function setInterval(t, callback) {
  callback();
  SV.setTimeout(t, setInterval.bind(null, t, callback));
}

function findSortedNote(group, pos) {
  var idxMin = 0; var idxMax = group.getNumNotes() - 1;
  var idxMid = Math.floor((idxMin + idxMax) / 2);
  while(idxMid != idxMin) {
    if(group.getNote(idxMid).getOnset() > pos)
      idxMax = idxMid;
    else
      idxMin = idxMid;
    idxMid = Math.floor((idxMin + idxMax) / 2);
  }
  if(idxMin < group.getNumNotes() - 1 &&
     group.getNote(idxMin).getEnd() <= pos)
    idxMin ++;
  return group.getNote(idxMin);
}

function getNewPos() {
  var scope = SV.getMainEditor().getCurrentGroup();
  var group = scope.getTarget();
  var offset = scope.getTimeOffset();
  var timeAxis = SV.getProject().getTimeAxis();

  var playback = SV.getPlayback();
  var position = timeAxis.getBlickFromSeconds(playback.getPlayhead());
  
  var N = group.getNumNotes();
  if(N == 0)
    return SV.finish();

  if(position > group.getNote(N - 1).getEnd() + offset || 
    playback.getStatus() == "stopped") {
    playback.pause();
    SV.finish();
  }
  
  var note = findSortedNote(group, position - offset);
  var padding = SV.QUARTER;
  var onset = note.getOnset() + offset;
  if(position + padding >= onset &&
     position - padding <= note.getEnd() + offset) {
    // inside a note now
  } else {
    playback.seek(timeAxis.getSecondsFromBlick(onset - padding));
  }
}

function main() {
  SV.getPlayback().play();
  setInterval(200, getNewPos);
}
