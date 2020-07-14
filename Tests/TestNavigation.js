function getClientInfo() {
  return {
    "name" : "Test Navigation (Javascript)",
    "category" : "Tests",
    "author" : "Dreamtonics",
    "versionNumber" : 0,
    "minEditorVersion" : 65537
  };
}

function main() {
  var navMain = SV.getMainEditor().getNavigation();

  navMain.setTimeScale(50 / SV.QUARTER);

  intervalCallback();
}

var count = 0;
function intervalCallback() {
  count += 1;

  var navMain = SV.getMainEditor().getNavigation();
  var tLeft = navMain.getTimeViewRange()[0];
  navMain.setTimeScale(navMain.getTimePxPerUnit() *
    (1 + 0.02 * Math.sin(count * 0.1)));
  navMain.setTimeLeft(tLeft + SV.QUARTER / count);

  if(count < 100)
    SV.setTimeout(50, intervalCallback);
  else
    SV.finish();
}
