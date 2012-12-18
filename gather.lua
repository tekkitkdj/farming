--
-- START Cage-specific settings
--

-- How many times to loop? (-1 means loop forever)
local loopCount = -1

-- How long to wait between gathering (in seconds)
local sleepSecs = 90

-- Starting position:
-- bottom right: startPos = "right"
-- bottom left: startPos = "left"
local startPos = "right"

--
-- END Farm-specific settings
--


local progArgs = { ... }

if #progArgs < 1 then
    print("Usage: gather <length> [<width>]")
    return
end

local length = tonumber(progArgs[1])
local width = length

if #progArgs > 1 then
    width = tonumber(progArgs[2])
end

if length < 1 then
    print("gather length must be positive")
    return
elseif width < 1 then
    print("gather width must be positive")
    return
end

print("Gathering " .. length .. "x" .. width .. " area")

-- Helper functions
local function gatherForward()
    turtle.suck()
    while not turtle.forward() do
        sleep(1)
    end
end

local function dropAll()
    -- Dig through wall (place dug block in slot 9)
    turtle.select(9)
    digForward
    -- and replace block to ensure nothing escapes
    aboutFace
    turtle.place()
    aboutFace

    -- Drop load
    dropAll

    -- Return, digging through wall again
    aboutFace
    digForward
    aboutFace
    turtle.place()
end

-- Assume starting on (already gathered) corner
local function gatherGrid()
    local nextLeft = (startPos == "right")
    -- For each column in square
    for y = 1, width do
        -- For each row in square
        for x = 1, length - 1 do
            gatherForward()
        end
        -- Turn to next column - if not just done last column
        if y < width then
            if nextLeft == true then
                turtle.turnLeft()
                gatherForward()
                turtle.turnLeft()
                nextLeft = false
            else
                turtle.turnRight()
                gatherForward()
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
                gatherForward()
            end
            turtle.turnRight()
            for x = 1, length - 1 do
                gatherForward()
            end
        else
            -- Currently at bottom-left - facing down
            turtle.turnLeft()
            for y = 1, width - 1 do
                gatherForward()
            end
            turtle.turnRight()
        end
    else
        if nextLeft == true then
            -- Currently at bottom-right - facing down
            turtle.turnRight()
            for y = 1, width - 1 do
                gatherForward()
            end
            turtle.turnLeft()
        else
            -- Currently at top-right - facing up
            turtle.turnLeft()
            for y = 1, width - 1 do
                gatherForward()
            end
            turtle.turnLeft()
            for x = 1, length - 1 do
                gatherForward()
            end
        end
    end

    -- Re-orient forward
    aboutFace
end

-- Program mainline
local done = false
while not done do
    -- Gather the whole square (and return to starting point)
    gatherGrid()
    -- Drop anything collected
    aboutFace
    dropAll()
    -- Re-orient turtle to starting position
    aboutFace

    -- Non-infinite mode?
    if loopCount > 0 then
        loopCount = loopCount - 1
        if loopCount == 0 then
            done = true
        else
            print("gather: " .. loopCount .. " loops to go")
        end
    end

    -- Have a little break
    if done == false then
        sleep(sleepSecs)
    end
end
