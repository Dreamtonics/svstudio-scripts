function getClientInfo() {
  return {
    "name" : "Test Custom Dialog (Javascript)",
    "category" : "Tests",
    "author" : "Dreamtonics",
    "versionNumber" : 1,
    "minEditorVersion" : 65537
  };
}

function main() {
  var myForm = {
    "title" : "Form Title",
    "message" : "This is just some dummy text.",
    "buttons" : "YesNoCancel",
    "widgets" : [
      {
        "name" : "sl1", "type" : "Slider",
        "label" : "My Slider 1",
        "format" : "%1.0f",
        "minValue" : -10,
        "maxValue" : 10,
        "interval" : 0.5,
        "default" : 3
      },
      {
        "name" : "cb1", "type" : "ComboBox",
        "label" : "My ComboBox 1",
        "choices" : ["Choice A", "Choice B", "Choice C"],
        "default" : 0
      },
      {
        "name" : "cb2", "type" : "ComboBox",
        "label" : "My ComboBox 2",
        "choices" : ["Choice A", "Choice B", "Choice C"],
        "default" : 2
      },
      {
        "name" : "tb1", "type" : "TextBox",
        "label" : "Enter some text here",
        "default" : "Hello, world!"
      },
      {
        "name" : "ta1", "type" : "TextArea",
        "label" : "My TextArea",
        "height" : 100,
        "default" : "Enter some more text here.\nAnother line.\nYet another line!",
      },
      {
        "name" : "check1", "type" : "CheckBox",
        "text" : "Check this option (CheckBox 1)",
        "default" : false
      },
      {
        "name" : "check2", "type" : "CheckBox",
        "text" : "Another option just for instance (CheckBox 2)",
        "default" : false
      }
    ]
  };

  var result = SV.showCustomDialog(myForm);
  
  if(result.status == "Yes") {
    SV.showMessageBox("Filled Form", "Slider value: " + result.answers.sl1);
    SV.showMessageBox("Filled Form", "ComboBox values: " +
      result.answers.cb1 + " and " + result.answers.cb2);
    SV.showMessageBox("Filled Form", "TextBox value: " + result.answers.tb1);
    SV.showMessageBox("Filled Form", "TextArea value: " + result.answers.ta1);
    SV.showMessageBox("Filled Form", "CheckBox1: " + result.answers.check1);
    SV.showMessageBox("Filled Form", "CheckBox2: " + result.answers.check2);
  } else if(result.status == "No") {
    SV.showMessageBox("Filled Form", "The form returned \"No\".");
  }
  SV.finish();
}
