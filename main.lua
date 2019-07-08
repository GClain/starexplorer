-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

-- Initialize variables
local lives = 3
local score = 0
local died = false
local asteroidTable = {}
local ship
local gameLoopTimer
local livesText
local scoreText

-- Set up display groups
-- Plus ous moins equivalent a des layers
local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()


local physics = require ("physics")
physics.start()
physics.setGravity(0,0)

-- seed thez random number generator
math.randomseed(os.time())


-- Configure image sheet for animations
local sheetOptions = {
    frames = 
    {
        {   -- 1) asteroid 1
            x = 0,
            y = 0,
            width = 102,
            height = 85
        },
        {   -- 2) asteroid 2
            x = 0,
            y = 85,
            width = 90,
            height = 83
        },
        {   -- 3) asteroid 3
            x = 0,
            y = 168,
            width = 100,
            height = 97
        },
        {   -- 4) ship
            x = 0,
            y = 265,
            width = 98,
            height = 79
        },
        {   -- 5) laser
            x = 98,
            y = 265,
            width = 14,
            height = 40
        },
    },
}
local objecSheet = graphics.newImageSheet ("gameObjects.png", sheetOptions)

