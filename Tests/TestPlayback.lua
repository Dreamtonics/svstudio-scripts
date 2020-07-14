function getClientInfo()
  return {
    name = "Test Playback (Lua)",
    category = "Tests",
    author = "Dreamtonics",
    versionNumber = 1,
    minEditorVersion = 65536
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
