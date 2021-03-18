function getClientInfo() {
  return {
    "name": SV.T("Play with Smooth Page Turning"),
    "author": "Dreamtonics",
    "versionNumber": 1,
    "minEditorVersion": 65537
  };
}

function getTranslations(langCode) {
  if (langCode == "ja-jp") {
    return [
      ["Play with Smooth Page Turning", "スムーズスクロール再生"]
    ];
  }
  if(langCode == "zh-cn") {
    return [
      ["Play with Smooth Page Turning", "播放并平滑翻页"]
    ];
  }
  return [];
}

function setInterval(t, callback) {
  callback();
  SV.setTimeout(t, setInterval.bind(null, t, callback));
}

function makePageTurner(coordSystem) {
  var playback = SV.getPlayback();
  var timeAxis = SV.getProject().getTimeAxis();

  var isPageTurning = false;
  var targetPositionLeft = 0;
  
  return function() {
    var position = timeAxis.getBlickFromSeconds(playback.getPlayhead());
    var viewRange = coordSystem.getTimeViewRange();
    
    var margin = SV.QUARTER / 4;
    if(isPageTurning && viewRange[0] < targetPositionLeft - margin) {
      coordSystem.setTimeLeft(viewRange[0] * 0.9 + targetPositionLeft * 0.1);
    } else
    if(position > viewRange[1] - margin) {
      isPageTurning = true;
      targetPositionLeft = viewRange[1];
    } else {
      isPageTurning = false;
    }
  }
}

var mainEditorPageTurner;
var arrangementPageTurner;

function checkPlayhead() {
  var playback = SV.getPlayback();
  if(playback.getStatus() == "stopped") {
    SV.finish();
    return;
  }
  
  mainEditorPageTurner();
  arrangementPageTurner();
}

function main() {
  SV.getPlayback().play();

  mainEditorPageTurner = makePageTurner(SV.getMainEditor().getNavigation());
  arrangementPageTurner = makePageTurner(SV.getArrangement().getNavigation());

  setInterval(20, checkPlayhead);
}
