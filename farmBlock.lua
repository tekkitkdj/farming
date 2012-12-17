-- How many times to loop? (-1 means loop forever)
local loopCount = -1
-- How long to wait between loops (90 seconds seems pretty good for sugarcane)
local sleepSecs = 90
-- Pattern to skip over water row(s)
local skipRows = { 1, 0 }


local progArgs = { ... }

if #progArgs < 1 then
    print("Usage: farmBlock <length> [<width>]")
    return
end

local length = tonumber(progArgs[1])
local width = length

if #progArgs > 1 then
    width = tonumber(progArgs[2])
end

if length < 1 then
    print("farmBlock: length must be positive")
    return
elseif width < 1 then
    print("farmBlock: width must be positive")
    return
end

print("farmBlock: Farming " .. length .. "x" .. width .. " area")

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

-- Assume starting on (already dug) bottom-left corner
local function mineLevel()
    -- Next direction to turn
    local nextLeft = false

    -- For each column in block
    for y = 1, width do
        -- For each row in block
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

    -- Return and re-orient forward
    turtle.forward()
    aboutFace()
end

-- Program mainline
local done = false
while not done do
    -- Dig 1st block and move to bottom-left
    digForward()
    -- Mine whole block (and return to starting point)
    mineLevel()
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
            print("farmBlock: " .. loopCount .. " loops to go")
        end
    end

    -- Have a little break
    if done == false then
        sleep(sleepSecs)
    end
end
