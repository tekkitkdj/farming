--
-- START Farm-specific settings
--

-- How many times to loop? (-1 means loop forever)
local loopCount = -1

-- How long to wait between harvesting (in seconds)
local sleepSecs = 900

-- Starting position:
-- bottom right: startPos = "right"
-- bottom left: startPos = "left"
local startPos = "right"

-- Describe the pattern of rows to skip
-- skipRows = { 3, 0 } means:
-- 1) Go up harvesting row 1
-- 2) Turn (left or right) and skip over 3 rows (e.g. seed row, water row, seed row)
-- 3) Go down harvesting row 5
-- 4) Turn (left or right) and skip 0 rows
-- 5) Go up harvesting row 6
-- ... and repeat
local skipRows = { 3, 0 }

--
-- END Farm-specific settings
--


local progArgs = { ... }

if #progArgs < 1 then
    print("Usage: harvest <length> [<width>]")
    return
end

local length = tonumber(progArgs[1])
local width = length

if #progArgs > 1 then
    width = tonumber(progArgs[2])
end

if length < 1 then
    print("harvest length must be positive")
    return
elseif width < 1 then
    print("harvest width must be positive")
    return
end

print("Harvesting " .. length .. "x" .. width .. " area")

-- Helper functions
local function aboutFace()
    turtle.turnLeft()
    turtle.turnLeft()
end
local function digForward()
    turtle.dig()
    turtle.forward()
end

local skipIndex = 0
local function skipForward()
    local numSkip = 0
    if #skipRows > 0 then
        skipIndex = skipIndex + 1
        if skipIndex > #skipIndex then
            skipIndex = 1
        end
        numSkip = skipRows[skipIndex]
        for skip = 1, numSkip do
            digForward()
        end
    end
    return numSkip
end

local nextLeft = (startPos == "right")

-- Assume starting on (already dug) corner
local function harvestGrid()

    -- For each column in square
    for y = 1, width do
        -- For each row in square
        for x = 1, length - 1 do
            digForward()
        end
        -- Turn to next column - if not just done last column
        if y < width then
            if nextLeft == true then
                turtle.turnLeft()
                y = y + skipForward()
                digForward()
                turtle.turnLeft()
                nextLeft = false
            else
                turtle.turnRight()
                y = y + skipForward()
                digForward()
                turtle.turnRight()
                nextLeft = true
            end
        end
    end

    -- Return to home position
    if startPos == "right" then
        if nextLeft == true then
            -- Currently at top-left - facing up
            turtle.turnRight()
            for y = 1, width - 1 do
                digForward()
            end
            turtle.turnLeft()
            for x = 1, length - 1 do
                digForward()
            end
        else
            -- Currently at bottom-right - facing down
            turtle.turnLeft()
            for y = 1, width - 1 do
                digForward()
            end
            turtle.turnLeft()
        end
    else
        if nextLeft == true then
            -- Currently at bottom-right - facing down
            turtle.turnRight()
            for y = 1, width - 1 do
                digForward()
            end
            turtle.turnLeft()
        else
            -- Currently at top-right - facing up
            turtle.turnLeft()
            for y = 1, width - 1 do
                digForward()
            end
            turtle.turnLeft()
            for x = 1, length - 1 do
                digForward()
            end
        end
    end

    -- Return and re-orient forward
    turtle.forward()
    aboutFace()
end

-- Program mainline
local done = false
while not done do
    -- Dig 1st block and move to starting position
    digForward()
    -- Harvest the whole square (and return to starting point)
    harvestGrid()
    -- Drop anything collected
    aboutFace()
    turtle.drop()
    -- Re-orient turtle to starting position
    aboutFace()

    -- Non-infinite mode?
    if loopCount > 0 then
        loopCount = loopCount - 1
        if loopCount == 0 then
            done = true
        else
            print("harvest: " .. loopCount .. " loops to go")
        end
    end

    -- Have a little break
    if done == false then
        sleep(sleepSecs)
    end
end
