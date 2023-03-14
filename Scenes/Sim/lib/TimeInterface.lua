-- TimeInterface.lua

local Time = {
}

local T = 0
local tt = 0
function Time.time()
    return T
end
local f = 30
function Time.Update()
    tt = tt + 1
    if tt >= f then
        T = T + 1
        tt = 0
    end
end

return Time