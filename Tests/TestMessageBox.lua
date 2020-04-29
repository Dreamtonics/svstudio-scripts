SCRIPT_TITLE = "Test Message Boxes"

function getClientInfo()
  return {
    name = "Test Message Boxes (Lua)",
    author = "Dreamtonics",
    versionNumber = 0,
    minEditorVersion = 0
  }
end

function main()
  SV:showMessageBox(SCRIPT_TITLE, "An example of a sync message box.")
  local result = SV:showOkCancelBox(SCRIPT_TITLE,
    "An example of a sync okay-cancel box.")
  SV:showMessageBox("Okay-cancel box", "Result: " .. tostring(result))
  result = SV:showInputBox(SCRIPT_TITLE,
    "An example of a sync input box.", "default text")
  SV:showMessageBox("Input box", "Result: " .. tostring(result))

  SV:showMessageBoxAsync(SCRIPT_TITLE,
    "An example of an async message box.", next)
end

step = 0

function next(result)
  if step == 0 then
    SV:showOkCancelBoxAsync(SCRIPT_TITLE,
      "An example of an async okay-cancel box.", next)
  elseif step == 1 then
    SV:showInputBoxAsync(SCRIPT_TITLE,
      "An example of an async input box.",
      "Previous result: " .. tostring(result), next)
  elseif step == 2 then
    SV:showMessageBoxAsync(SCRIPT_TITLE,
      "Previous result: " .. tostring(result), finish)
  end
  step = step + 1
end

function finish(result)
  SV:finish()
end
