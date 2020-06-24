var SCRIPT_TITLE = "Scale Selected Notes";

function getClientInfo() {
  return {
    "name": SV.T(SCRIPT_TITLE),
    "author": "Dreamtonics",
    "versionNumber": 1,
    "minEditorVersion": 65537
  }
}

function getTranslations(langCode) {
  if(langCode == "ja-jp") {
    return [
      ["Scale Selected Notes", "読み込まれたノートを拡大縮小"],
      ["Enter scaling factor (Default: cancel truncation loss).",
        "拡大縮小係数を入力してください（既定：切り捨て誤差打ち消し）。"]
    ];
  }
  return [];
}

function main() {
  var selection = SV.getMainEditor().getSelection();
  var selectedNotes = selection.getSelectedNotes();

  var N = selectedNotes.length;

  var start = selectedNotes[0].getOnset();
  var end = selectedNotes[N - 1].getEnd();

  var trueDurationEstimate = end - start + 0.5 * N * SV.QUARTER / 480;
  var truncatedDurationEstimate = end - start;
  var scale = trueDurationEstimate / truncatedDurationEstimate;

  scale = SV.showInputBox(SV.T(SCRIPT_TITLE),
    SV.T("Enter scaling factor (Default: cancel truncation loss)."), scale);

  var prevEnd = -1;
  for(var i = 0; i < N; i ++) {
    var currOnset = selectedNotes[i].getOnset();
    var currEnd = selectedNotes[i].getEnd();

    if(currOnset == currEnd) {
      selectedNotes.removeNote(i);
      break;
    }

    if(i > 0 && prevEnd == currOnset)
      selectedNotes[i].setOnset(selectedNotes[i - 1].getEnd());
    else
      selectedNotes[i].setOnset(scale * currOnset);

    selectedNotes[i].setDuration(scale * currEnd - selectedNotes[i].getOnset());
    prevEnd = currEnd;
  }

  SV.finish();
}
