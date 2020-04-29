function getClientInfo()
  return {
    name = "Test Playback (Lua)",
    author = "Dreamtonics",
    versionNumber = 0,
    minEditorVersion = 0
  }
end

function main()
  local playback = SV:getPlayback()

  playback:seek(2.0)
  playback:loop(1.5, 3.0)

  SV:setTimeout(5000, function()
    playback:stop()
    SV:finish()
  end)
end
