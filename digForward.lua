-- Helper routine :- digForward
turtle.dig()
-- Keep trying (i.e. digging) until we can move forward
-- to support falling blocks (gravel, sand, etc) and/or blocking mobs
while not turtle.forward() do
    turtle.dig()
    sleep(1)
end
