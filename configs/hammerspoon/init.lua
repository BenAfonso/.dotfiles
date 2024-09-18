hs.loadSpoon("EmmyLua")
require("./AppSwitcher/app_switcher")

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

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "C", function()
  hs.application.open("WezTerm")
  hs.window.focusedWindow():maximize()
end)

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "B", function()
  hs.application.open("Arc")
  hs.window.focusedWindow():maximize()
end)

local chooser = hs.chooser.new(function(choice)
  if choice ~= nil then
    local layout = {}
    local focused = hs.window.focusedWindow()
    local toRead = hs.window.find(choice.id)
    if hs.eventtap.checkKeyboardModifiers()["alt"] then
      hs.layout.apply({
        { nil, focused, focused:screen(), hs.layout.left70, 0, 0 },
        { nil, toRead, focused:screen(), hs.layout.right30, 0, 0 },
      })
    else
      hs.layout.apply({
        { nil, focused, focused:screen(), hs.layout.left50, 0, 0 },
        { nil, toRead, focused:screen(), hs.layout.right50, 0, 0 },
      })
    end
    toRead:raise()
  end
end)

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "O", function()
  local windows = hs.fnutils.map(hs.window.filter.new():getWindows(), function(win)
    if win ~= hs.window.focusedWindow() then
      return {
        text = win:title(),
        subText = win:application():title(),
        image = hs.image.imageFromAppBundle(win:application():bundleID()),
        id = win:id(),
      }
    end
  end)

  chooser
    :placeholderText("Choose window for 50/50 split. Hold ⎇ for 70/30.")
    :searchSubText(true)
    :choices(windows)
    :show()
end)
