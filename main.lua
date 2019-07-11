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


-- Configure image sheet 
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
local objectSheet = graphics.newImageSheet ("gameObjects.png", sheetOptions)

-- Load de background
local background = display.newImageRect(backGroup, "background.png", 800, 1400)
background.x = display.contentCenterX
background.y = display.contentCenterY

ship = display.newImageRect(mainGroup, objectSheet, 4, 98, 79)
-- On place le ship dans le mainGroup
-- le second parametre est la reference de l'image sheet plus haut, 4 étant le numero de frame
-- les 2 derniers parametres sont la longueur et hauteur du sheet
ship.x = display.contentCenterX
ship.y = display.contentHeight -100
physics.addBody(ship, { radius = 30, isSensor= true})
-- sensor = detect collision mais sans reponse physique (genre de trigger dans unity)
ship.myName ="ship"


-- Display lives and score
livesText = display.newText(uiGroup, "Lives: ".. lives, 200, 80, native.systemFont, 36)
scoreText = display.newText(uiGroup, "Score: ".. score, 400, 80, native.systemFont, 36)

-- Hide the status bar
display.setStatusBar (display.HiddenStatusBar)

local function updateText()
    livesText.text = "Lives: ".. lives
    scoreText.text = "Score: ".. lives
end

local function createAsteroid()
    local newAsteroid = display.newImageRect(mainGroup, objectSheet, 1, 102, 85)
    table.insert (asteroidTable, newAsteroid)
    physics.addBody(newAsteroid, "dynamic", { radius=40, bounce=0.8 })
    newAsteroid.myName ="asteroid"

    local whereFrom = math.random (3)
    if (whereFrom == 1) then
        -- from left
        newAsteroid.x = -60
        newAsteroid.y = math.random (500)
        newAsteroid:setLinearVelocity(math.random (40,120), math.random (20,60))

    elseif (whereFrom == 2) then    
        -- from top
        newAsteroid.x = math.random(display.contentWidth)
        newAsteroid.y = -60
        newAsteroid:setLinearVelocity(math.random (40,40), math.random (40,120))

    elseif (whereFrom == 3) then    
        -- from right
        newAsteroid.x = display.contentWidth + 60
        newAsteroid.y = math.random (500)
        newAsteroid:setLinearVelocity(math.random (-120,-40), math.random (20,60))
    end

    newAsteroid:applyTorque (math.random(-6,6))
end

local function fireLaser()
    local newLaser = display.newImageRect (mainGroup, objectSheet, 5, 14, 40 )
    physics.addBody( newLaser, "dynamic", { isSensor = true })
    newLaser.isBullet = true
    newLaser.myName = "laser"
    newLaser.x = ship.x
    newLaser.y = ship.y
    newLaser:toBack()

    transition.to (newLaser, { y=-40, time=500,
        onComplete = function() display.remove(newLaser  ) end
    })
end

ship:addEventListener ("tap", fireLaser)

local function dragShip (event)
    local ship = event.target
    -- Gestion des touch mobile
    local phase = event.phase 

    if ("began" == phase) then
        -- Set touch focus on the ship
        display.currentStage:setFocus (ship)
        -- Store initial offset position
        ship.touchOffset = event.x - ship.x
    elseif ("moved" == phase)   then
        -- Move the ship to the new touch position
        -- On restreint mouvement vaisseau pour l'axe X seulement, on ne gere pas axe Y
        ship.x = event.x - ship.touchOffset 
    elseif ("ended" == phase or "cancelled" == phase) then
        -- Release touch ocus on the ship
        display.currentStage:setFocus(nil)

    end
    return true -- Prevents touch propagation to underlying objects
end

ship: addEventListener ("touch", dragShip)

local function gameLoop()
    -- create new asteroid
    createAsteroid()

    -- remove asteriods which have drifted off screen
    for i = #asteroidTable, 1, -1 do
        local thisAsteroid = asteroidTable[i]
        if ( thisAsteroid.x < -100 or
             thisAsteroid.x > display.contentWidth +100 or
             thisAsteroid.y < -100 or
             thisAsteroid.y > display.contentHeight +100)
        then
            display.remove (thisAsteroid)
            table.remove (asteroidTable,i)
        end    
    end
end

-- fonction pour ne pas appeler gameloop toutes les secondes
-- Dernier parametre = est le nombre de fois que le looptimer est lancé
-- 0 = infini
gameLoopTimer = timer.performWithDelay(500, gameLoop,0)


-- gestion restore ship
local function restoreShip()
    ship.isBodyActive = false
    ship.x = display.contentCenterX
    ship.y = display.contentHeight -100

    -- Fade the ship
    transition.to (ship, {
        alpha = 1,
        time = 4000,
        onComplete = function () -- callback function
            ship.isBodyActive = true
            died = false
        end
    })

end