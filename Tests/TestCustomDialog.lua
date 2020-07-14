function getClientInfo()
  return {
    name = "Test Custom Dialog (Lua)",
    category = "Tests",
    author = "Dreamtonics",
    versionNumber = 1,
    minEditorVersion = 65537
  }
end

function main()
  local myForm = {
    title = "Form Title",
    message = "This is just some dummy text.",
    buttons = "YesNoCancel",
    widgets = {
      {
        name = "sl1", type = "Slider",
        label = "My Slider 1",
        format = "%1.0f",
        minValue = -10,
        maxValue = 10,
        interval = 0.5,
        default = 3
      },
      {
        name = "cb1", type = "ComboBox",
        label = "My ComboBox 1",
        choices = {"Choice A", "Choice B", "Choice C"},
        default = 0
      },
      {
        name = "cb2", type = "ComboBox",
        label = "My ComboBox 2",
        choices = {"Choice A", "Choice B", "Choice C"},
        default = 2
      },
      {
        name = "tb1", type = "TextBox",
        label = "Enter some text here",
        default = "Hello, world!"
      },
      {
        name = "ta1", type = "TextArea",
        label = "My TextArea",
        height = 100,
        default = "Enter some more text here.\nAnother line.\nYet another line!",
      },
      {
        name = "check1", type = "CheckBox",
        text = "Check this option (CheckBox 1)",
        default = false
      },
      {
        name = "check2", type = "CheckBox",
        text = "Another option just for instance (CheckBox 2)",
        default = false
      }
    }
  }

  local result = SV:showCustomDialog(myForm)
  
  if result.status == "Yes" then
    SV:showMessageBox("Filled Form",
      "Slider value: " .. tostring(result.answers.sl1))
    SV:showMessageBox("Filled Form",
      "ComboBox values: " .. tostring(result.answers.cb1) ..
      " and " .. tostring(result.answers.cb2))
    SV:showMessageBox("Filled Form",
      "TextBox value: " .. tostring(result.answers.tb1))
    SV:showMessageBox("Filled Form",
      "TextArea value: " .. tostring(result.answers.ta1))
    SV:showMessageBox("Filled Form",
      "CheckBox1: " .. tostring(result.answers.check1))
    SV:showMessageBox("Filled Form",
      "CheckBox2: " .. tostring(result.answers.check2))
  elseif result.status == "No" then
    SV:showMessageBox("Filled Form", "The form returned \"No\".")
  end
  SV:finish();
end
