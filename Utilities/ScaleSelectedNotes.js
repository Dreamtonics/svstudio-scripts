var SCRIPT_TITLE = "Scale Selected Notes";

function getClientInfo() {
  return {
    "name": SV.T(SCRIPT_TITLE),
    "author": "Dreamtonics",
    "versionNumber": 2,
    "minEditorVersion": 65537
  }
}

function getTranslations(langCode) {
  if(langCode == "ja-jp") {
    return [
      ["Scale Selected Notes", "読み込まれたノートを拡大縮小"],
      ["Upscaling factor", "拡大係数"],
      ["Downscaling factor", "縮小係数"],
      ["Relative to the selection start", "選択範囲の開始を基準とする"]
    ];
  }
  if(langCode == "zh-cn") {
    return [
      ["Scale Selected Notes", "缩放所选音符"],
      ["Upscaling factor", "放大系数"],
      ["Downscaling factor", "缩小系数"],
      ["Relative to the selection start", "基于选择范围的开始位置"]
    ];
  }
  return [];
}

function scale(options) {
  var selection = SV.getMainEditor().getSelection();
  var selectedNotes = selection.getSelectedNotes();
  if(selectedNotes.length == 0)
    return;
  
  selectedNotes.sort(function(noteA, noteB) {
    return noteA.getOnset() - noteB.getOnset();
  });
  
  var firstOnset = options.relative ? selectedNotes[0].getOnset() : 0;
  var prevEnd = -1;
  for(var i = 0; i < selectedNotes.length; i ++) {
    var currOnset = selectedNotes[i].getOnset() - firstOnset;
    var currEnd = selectedNotes[i].getEnd() - firstOnset;

    if(currOnset == currEnd) {
      selectedNotes.removeNote(i);
      break;
    }

    if(i > 0 && prevEnd == currOnset)
      selectedNotes[i].setOnset(selectedNotes[i - 1].getEnd());
    else {
      selectedNotes[i].setOnset(firstOnset +
        currOnset * options.upscale / options.downscale);
    }

    selectedNotes[i].setDuration(
      currEnd * options.upscale / options.downscale -
      (selectedNotes[i].getOnset() - firstOnset));
    prevEnd = currEnd;
  }
}

function main() {
  var form = {
    "title"   : SV.T(SCRIPT_TITLE),
    "message" : "",
    "buttons" : "OkCancel",
    "widgets" : [
      {
        "name"     : "upscale",
        "type"     : "Slider",
        "label"    : SV.T("Upscaling factor"),
        "format"   : "%1.0f",
        "minValue" : 1,
        "maxValue" : 8,
        "interval" : 1,
        "default"  : 1
      },
      {
        "name"     : "downscale",
        "type"     : "Slider",
        "label"    : SV.T("Downscaling factor"),
        "format"   : "%1.0f",
        "minValue" : 1,
        "maxValue" : 8,
        "interval" : 1,
        "default"  : 1
      },
      {
        "name"     : "relative",
        "type"     : "CheckBox",
        "text"     : SV.T("Relative to the selection start"),
        "default"  : true
      }
    ]
  };

  var results = SV.showCustomDialog(form);
  if(results.status)
    scale(results.answers);

  SV.finish();
}
