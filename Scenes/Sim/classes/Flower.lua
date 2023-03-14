-- Flower.lua

local Flower;

Flower = {}

function Flower.new(x,y)
    local f = {
        pos = {x or 0, y or 0};
        __name = 'flower';
        id = 2;
    }

    Sprite.newSimple(f)
    return f
end

function Flower.save(f, folder)
    local ret = "return {\n"
    .."pos = {"..tostring(f.pos[1])..", "..tostring(f.pos[2]).."}\n"
    .."}"
    if not folder then
        return ret
    end
    if type(folder) ~= 'string' then
        error"Flower can't be saved in a folder that is not string"
    end
    local f = io.open(folder)
    f:write(ret)
    f:close()
    return ret
end

function Flower.loadT(f)
    f.__name = 'flower'
    f.id = 2;
    Sprite.newSimple(f)
end

function Flower.loadF(folder)
    if type(folder) ~= 'string' then
        error"Flower can't be loaded from a folder that is not string"
    end
    local t = require(folder)
    t.id = 2;
    Sprite.newSheet(t)
    return t
end


return Flower