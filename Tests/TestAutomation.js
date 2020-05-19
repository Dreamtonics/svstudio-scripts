function getClientInfo() {
  return {
    "name" : "Test Automation (Javascript)",
    "author" : "Dreamtonics",
    "versionNumber" : 0,
    "minEditorVersion" : 65537
  };
}

function main() {
  var mainRef = SV.getProject().getTrack(0).getGroupReference(0);
  var mainGroup = mainRef.getTarget();
  
  var myPitchBend = mainGroup.getParameter("PitchDelta");
  var myTension = mainGroup.getParameter("Tension");

  var numPoints = 1024;
  var y = 0, yPrev = 0;
  for(var i = 0; i < numPoints; i ++) {
    var x = i * SV.QUARTER / 8;
    y = (Math.random() - 0.5) * 500;
    y = (yPrev * 0.9 + y * 0.1) * 0.99;
    yPrev = y;
    myPitchBend.add(x, y);
  }

  y = 0;
  yPrev = 0;
  for(var i = 0; i < numPoints; i ++) {
    var x = i * SV.QUARTER / 8;
    y = (Math.random() - 0.5) * 5;
    y = (yPrev * 0.97 + y * 0.03) * 0.98;
    yPrev = y;
    myTension.add(x, y);
  }

  SV.finish();
}
