--# selene: allow(unused_variable)
---@diagnostic disable: unused-local

-- Cherry tomato (a tiny Pomodoro) -- a Pomodoro Timer for the menubar
--
-- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/Cherry.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/Cherry.spoon.zip)
-- 
---@class spoon.Cherry
local M = {}
spoon.Cherry = M

-- Binds hotkeys for Cherry
--
-- Parameters:
--  * mapping - A table containing hotkey details for the following items:
--   * start - start the pomodoro timer (Default: cmd-ctrl-alt-C)
function M:bindHotkeys(mapping, ...) end

-- Popup an alert or notification when time is up.
--
-- Parameters:
--  * None
--
-- Returns:
--  * None
function M:popup() end

-- Starts the timer and displays the countdown in a menubar item
--
-- Parameters:
--  * resume - boolean when true resumes countdown at current value of self.timeLeft
--
-- Returns:
--  * None
function M:start() end

