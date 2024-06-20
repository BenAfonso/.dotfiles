hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "W", function()
	hs.alert.show("Hello World!")
end)

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "H", function()
	local win = hs.window.focusedWindow()
	local f = win:frame()

	f.x = f.x - 10
	win:setFrame(f)
end)


hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "F", function()
	local win = hs.window.focusedWindow()
  win:maximize()
end)

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "B", function()
  hs.application.open("WezTerm")
  hs.window.focusedWindow():maximize()
end)
