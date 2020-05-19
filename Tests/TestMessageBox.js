var SCRIPT_TITLE = "Test Message Boxes";

function getClientInfo() {
  return {
    "name" : "Test Message Boxes (Javascript)",
    "author" : "Dreamtonics",
    "versionNumber" : 0,
    "minEditorVersion" : 65537
  };
}

function main() {
  SV.showMessageBox(SCRIPT_TITLE, "An example of a sync message box.");
  var result = SV.showOkCancelBox(SCRIPT_TITLE,
    "An example of a sync okay-cancel box.");
  SV.showMessageBox("Okay-cancel box", "Result: " + result);
  result = SV.showInputBox(SCRIPT_TITLE,
    "An example of a sync input box.", "default text");
  SV.showMessageBox("Input box", "Result: " + result);

  SV.showMessageBoxAsync(SCRIPT_TITLE,
    "An example of an async message box.", next);
}

var step = 0;

function next(result) {
  if(step == 0) {
    SV.showOkCancelBoxAsync(SCRIPT_TITLE,
      "An example of an async okay-cancel box.", next);
  } else if(step == 1) {
    SV.showInputBoxAsync(SCRIPT_TITLE,
      "An example of an async input box.",
      "Previous result: " + result, next);
  } else if(step == 2) {
    SV.showMessageBoxAsync(SCRIPT_TITLE,
      "Previous result: " + result, finish);
  }
  step += 1;
}

function finish(result) {
  SV.finish();
}
