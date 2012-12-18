-- Helper routine :- dropAll
local moveExtra = turtle.forward()

for slot = 1, 9 do
    if turtle.getItemCount(slot) > 0 then
        turtle.select(slot)
        turtle.drop()
        sleep(0.5)
    end
end
turtle.select(1)

if moveExtra then
    if not turtle.back() then
        aboutFace
        digForward
        aboutFace
    end
end
