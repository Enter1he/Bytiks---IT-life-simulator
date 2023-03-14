require("modules/OOP")
local function round(x)
    local i, f = math.modf(x)
    if f < 0.5 then
        return i
    else
        return i + 1
    end
end
local function tohexF(r,g,b)
   r,g,b = round(r*255), round(g*255), round(b*255)
   return ((r & 0xff) << 16) + ((g & 0xff) << 8) + b
end

local Color = {
   __add = function(a,b)
      return Color{a[1]+b[1], a[2]+b[2], a[3]+b[3], a[4]+b[4] }
   end,
   __sub = function(a,b)
      return Color{a[1]+b[1], a[2]+b[2], a[3]+b[3], a[4]+b[4] }
   end,
   tohex = function(c)
      local r,g,b,a = round(c[1]*255), round(c[2]*255), round(c[3]*255), round(c[4]*255)
      return ((r & 0xff) << 24) + ((g & 0xff) << 16) + ((b & 0xff) << 8) + a
   end
};



OOP.makeCallable("Color", Color)

Colors = {
   white = Color{ 1, 1, 1, 1 },
   black = { 0, 0, 0, 1 },
   red = { 1, 0, 0, 1 },
   green = { 0, 1, 0, 1 },
   blue = { 0, 0, 1, 1 },
   yellow = { 1, 1, 0, 1 },
   purple = { 1, 0, 1, 1 },
   none = { 0, 0, 0, 0 },
}



return Color
