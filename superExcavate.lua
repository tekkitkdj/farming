--
-- Expand excavate to drop load when chest is full
-- and keep mining until we hit something we can't dig.
--

local tArgs = { ... }
if #tArgs ~= 1 then
    print( "Usage: superExcavate <diameter>" )
    return
end

-- Mine in a quarry pattern until we hit something we can't dig
local size = tonumber( tArgs[1] )
if size < 1 then
    print( "Excavate diameter must be positive" )
    return
end

local depth = 0
local collected = 0

local fullLoad = false

local xPos, zPos = 0, 0
local xDir, zDir = 0, 1

local function collect()
    collected = collected + 1
    if math.fmod(collected, 25) == 0 then
        print( "Mined "..collected.." blocks." )
    end

    for n = 1, 9 do
        if turtle.getItemCount(n) == 0 then
            return true
        end
    end

    fullLoad = true
    print( "No empty slots left." )
    return false
end

local function tryForwards()
    while not turtle.forward() do
        if turtle.dig() then
            if not collect() then
                return false
            end
        else
            -- give sand a chance to fall
            sleep(0.8)
            if turtle.dig() then
                if not collect() then
                    return false
                end
            else
                return false
            end
        end
    end
    xPos = xPos + xDir
    zPos = zPos + zDir
    return true
end

local function tryDown()
    if not turtle.down() then
        if turtle.digDown() then
            if not collect() then
                return false
            end
        end
        if not turtle.down() then
            return false
        end
    end
    depth = depth + 1
    if math.fmod( depth, 10 ) == 0 then
        print( "Descended " .. depth .. " metres." )
    end
    return true
end

local function aboutFace()
    turnLeft()
    turnLeft()
end

local function turnLeft()
    turtle.turnLeft()
    xDir, zDir = -zDir, xDir
end

local function turnRight()
    turtle.turnRight()
    xDir, zDir = zDir, -xDir
end

local allDone = false
while not allDone do
    print( "Excavating..." )

    local reseal = false
    if turtle.digDown() then
        reseal = true
    end

    local alternate = 0
    local done = false
    while not done do
        -- Loop to mine each "column"
        for n = 1, size do

            -- Loop to mine each "row"
            for m = 1, size - 1 do
                if not tryForwards() then
                    done = true
                    break
                end
            end
            if done then
                break
            end

            -- Determine direction to turn
            -- (and perform turn if not just done last column)
            if n < size then
                if math.fmod(n + alternate, 2) == 0 then
                    turnLeft()
                    if not tryForwards() then
                        done = true
                        break
                    end
                    turnLeft()
                else
                    turnRight()
                    if not tryForwards() then
                        done = true
                        break
                    end
                    turnRight()
                end
            end
        end

        -- Completed 1 level; are we full (or done)?
        if done then
            break
        end

        -- Re-orient turtle to face forward
        if size > 1 then
            if math.fmod(size, 2) == 0 then
                turnRight()
            else
                if alternate == 0 then
                    turnLeft()
                else
                    turnRight()
                end
                alternate = 1 - alternate
            end
        end

        -- Descend to next level (if possible)
        if not tryDown() then
            done = true
            break
        end

    end

    -- We are either completed or full
    -- Either way, return to surface to dump load

    print( "Returning to surface..." )

    -- Return to starting depth
    local mineDepth = depth
    while mineDepth > 0 do
        if turtle.up() then
            mineDepth = mineDepth - 1
        elseif turtle.digUp() then
            collect()
        else
            sleep( 0.5 )
        end
    end

    -- Return to starting position
    if xPos > 0 then
        while xDir ~= -1 do
            turnLeft()
        end
        while xPos > 0 do
            if turtle.forward() then
                xPos = xPos - 1
            elseif turtle.dig() then
                collect()
            else
                sleep( 0.5 )
            end
        end
    end
    if zPos > 0 then
        while zDir ~= -1 do
            turnLeft()
        end
        while zPos > 0 do
            if turtle.forward() then
                zPos = zPos - 1
            elseif turtle.dig() then
                collected = collected + 1
            else
                sleep( 0.5 )
            end
        end
    end

    -- Face forward
    while zDir ~= 1 do
        turnLeft()
    end

    -- Seal the hole
    if reseal then
        turtle.placeDown()
    end

    -- Dump Load
    print( "Dropping load..." )
    -- TODO: Check if we need to move back a square
    aboutFace()
    for slot = 1, 9 do
        turtle.select(slot)
        turtle.drop()
    end
    turtle.select(1)
    aboutFace()

    if fullLoad then
        fullLoad = false
    else
        allDone = true
    end

end

print( "Mined " .. collected .. " blocks total." )
