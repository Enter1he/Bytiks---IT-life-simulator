-- Training for NNs

local Train = NewScene{

}
local Collide = Collision
local screen = _en.screen
local w, h = screen.asize()
local sw, sh = screen.w, screen.h
local ax, ay = (sw/w), (sh/h)
local flowers = 50; local flocount = flowers;
local humans = 10
local deaths = 0
local paused = false
local npc = {} 
local objs = {}  -- individual obj and npc tables
local humarite, flosprite = require "Scenes/Sim/res/Human/Human", require "Scenes/Sim/res/Plants/Flower"
humarite.scale = {humarite.w, humarite.h}
flosprite.scale = {flosprite.w, flosprite.h}
local Npc_Update, Obj_Update, Npc_Controls;
local fmt = string.format
local alive = humans
local deaths = 0
local Human = require "Scenes/Sim/classes/Human"
local Flower = require"Scenes/Sim/classes/Flower"
local chosen = 1

Controls.AddCommand(B.e, function()
    if chosen < humans then
        chosen = chosen + 1
    else
        chosen = 1
    end
end)
local L1 = Layer.new()
local text = Text.newText
    { 
        value = "frame:";
        pos = {10, 50};
        -- font = "Teletactile-3zavL.ttf";
        size = 14;
        color = {1,1,1,1};
        alpha = 1;
    }

humarite.Draw = true
flosprite.Draw = true
local function randFlowers()
    return math.random(0.2*screen.w//1, screen.w*0.8//1), math.random(0.2*screen.h//1, screen.h*0.8//1)
end
local function randHumans()
    local choice = math.random(1,4)
    if choice == 1 then
        return math.random(0,screen.w), math.random(0, 0.3*screen.h//1)
    elseif choice == 2 then
        return math.random(0,screen.w), math.random(0.6*screen.h//1, screen.h)
    elseif choice == 3 then 
        return math.random(0,0.3*screen.w//1), math.random(0.3*screen.h//1, 0.6*screen.h//1)
    elseif choice == 4 then
        return math.random(0.6*screen.w//1, screen.w), math.random(0.3*screen.h//1, 0.6*screen.h//1)
    end
end

Controls.AddCommand(B.space, function()
    paused = not paused and true or false
end)

Controls.AddCommand(B.r, function()
    LE.ResumeLoading()
end)

Controls.AddCommand(B.p, function()
    Train.saveF = true
    print"save"
    Train.save(objs, "save1")
    Train.saveF = false
end)

Controls.AddCommand(B.o, function()
    Train.loadF = true
    print"load"
    Train.loadFile("save1")
    Train.loadF = false
end)

Controls.AddCommand(B.esc, LE.Close)
local T = 0
local tt = 1
function time()
    return T
end
function Train.save(objs, folder)
    local ret = "return {\n"
    ret = ret .."deaths = ".. tostring(deaths)..";"
    .."alltime = "..tostring(Train.alltime + time() - Train.start)..";"
    for i = 1, flowers do
        ret = ret.."function()\n"
        ..Flower.save(objs[i])
        .."end,\n"
    end
    for i = flowers+1, flowers+humans do
        ret = ret.."function()\n"
       ..Human.save(objs[i], nil, Train.alltime + time() - objs[i].time_alive)
        .."end,\n"
    end
    ret = ret.."}\n"
    if not folder then
        return ret
    end
    if type(folder) ~= 'string' then
        error "Sim can't be saved in file that doesn't have string folder!"
    end
    local f = io.open(folder..".lua", "w+")
    f:write(ret)
    f:close()
    return ret
end

function Train.loadFile(folder)
    local t = loadfile (folder..".lua")()
    deaths = t.deaths
    Train.alltime = t.alltime
    Train.start = time()

    if flowers > 0 then
        for i = 1, flowers do
            local a = t[i]()
            Flower.loadT(a)
            flosprite:CopySprite(a) -- need to copy Sprite to object for that to be used
            a.scale = flosprite.scale
            objs[i] = a
        end
    end
    if humans > 0 then
        for i = 1, humans do
            local a = t[flowers+i]()
            Human.loadT(a)
            a.w, a.h = humarite.w, humarite.h
            a.time_alive = a.alltime - Train.alltime + Train.start
            objs[flowers+i] = a
            npc[i] = a
        end
    end
end

function Train.Load(train)
    
    text:Load(true)
    L1:AddDrawable(text)
    Train.start = time()
    Train.alltime = 0
    if flowers > 0 then
        for i = 1, flowers do
            local x, y = randFlowers()
            local a = Flower.new(x,y)
            a.scale = flosprite.scale
            objs[i] = a
        end
    end
    if humans > 0 then
        for i = 1, humans do
            local x, y = randHumans() --math.random(dx[1],dx[2]), math.random(dy[1],dy[2])
            local a = Human.new(x,y)
            a.scale = humarite.scale
            objs[flowers+i] = a
            npc[i] = a
        end        
    end
    coroutine.yield()
    while true do
    -- dt = 0.016
        tt = tt + 1
        if tt >= 60 then
            T = T + 1
            tt = 1
        end
        
        if closed then
            break
        end
        if not paused then
            Npc_Update()
            Obj_Update()
        end
    end
end

function Train:Update()
    
end


function Train.AddNpc(x,y)
    local a, n;
    for i = 1, humans do
        if not npc[i].Draw then
            a = npc[i]
            a.Draw = humarite.Draw

            a:reset(x,y)
            n = i
            break
        end
    end
    
    if not a then
        if humans + 1 > 50 then
            return 
        end
        a = Human.new(x,y)
        humans = humans + 1
        n = humans
    end
    
    a.time_alive = Train.alltime + time()
    
    if n == humans then
        a.w, a.h = humarite.w, humarite.h
        a.scale = humarite.scale
    end
    a.Draw = humarite.Draw
    objs[flowers+n] = a
    npc[n] = a
    return a
end

function Npc_Update()
    local len = #npc
    local a;
    
    for i = 1, len do
        a = npc[i]
        if a.Draw then 
            a:Act(objs, Train.AddNpc)
            Npc_Controls(a)
            
            if not a.Draw then
                deaths = deaths + 1
                alive = alive - 1
            end
        end
    end
    if alive < 10 then
        for i = 1, #npc do
            local a = npc[i]
            if a.Draw then
                goto next
            end
            a:reset(randHumans(), Train.alltime + time() - Train.start)
            a.pos[1], a.pos[2] = randHumans()
            a.gen = 0
            a.Draw = humarite.Draw
            a:newBrain()
            alive = alive + 1
            if alive >= 10 then
                break
            end
            ::next::
        end
    end
    local i = chosen
    local simtime, npctime = Train.alltime + time() - Train.start, npc[i].alltime - npc[i].time_alive + time()
    if npc[i].Draw then
        npctime = npctime
    end
    text.value = 
    fmt("fps %f alive: %d on board %2.4f\ndeath: %d simtime %d's life span: %d's\ni:%d, score: %d, gen: %d\n rad: %2.4f\nspeed: %2.4f\nv1: %2.4f\n v2: %2.4f\nstamina: %2.4f \nfat: %2.4f output2: %f",
        fps, alive, humans, deaths, simtime, npctime, chosen, npc[i].score, npc[i].gen, math.deg(npc[i].rad), npc[i].speed, npc[i].vel[1], npc[i].vel[2], npc[i].stamina, tonumber(npc[i].fat), npc[i].brain.out[2].bias)
end

function Npc_Controls(npc) -- adjusting directions for moving mobs
    local vel = npc.vel
    local deg = math.deg(npc.rad)
    
    if deg < 205 and (deg > 155) then
        npc.dir = 4
    end
    if deg < 65 or deg > 295 then
        npc.dir = 2
    end

    if deg < 295 and deg > 205 then
        npc.dir = 3
    end 
    if deg < 155 and (deg > 65) then
        npc.dir = 1
    end
    if npc.speed > 0 then
        -- npc:PlayAnim(npc.dir, true, 20, 4)
    else
        npc.anim = npc.dir
    end
end

local CtC = Collide.CtC
local dx, dy = {50,screen.w-50}, {60,screen.h-60}


function Obj_Update()
    local len = flowers
    for i = 1, len do
        local a = objs[i]
        if not a.Draw then
            a.pos[1], a.pos[2] = randFlowers()
            a.Draw = flosprite.Draw
        end
    end
end

function Train.Draw()
    L1:Draw()
end

return Train