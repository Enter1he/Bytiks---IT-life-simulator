print"Sim.root Start"
local Collide = Collision


-- for i = 1, 100000000 do
    
-- end
local  screen = _en.screen
local w, h = screen.asize()
local sw, sh = screen.w, screen.h
local ax, ay = (sw/w), (sh/h)
local flowers = 50; local flocount = flowers;
local humans = 10
local deaths = 0
local npc = {} 
local top = {max = 0, far = 500}
local objs = {}  -- individual obj and npc tables
local flosprite = {}
local humarite = {} 
local Npc_Update, Obj_Update;
local fmt = string.format
local chosen = 1

local music = Sound.new{
        pos = {0,0,0};
        pitch =3;
        max_distance = 30;
        rolloff = 0;
    }; -- sprites and music files


local Listener = Audio.Listener

local text = Text.newText(
    { 
        value = "frame:";
        pos = {10, 50};
        -- font = "Teletactile-3zavL.ttf";
        size = 14;
        color = {1,1,1,1};
        alpha = 1;
        
    }
)

local player = new(
        {
            speed = 150;
            Stop = Mob.Stop;
            pos = {0,0,0};
            vel = {0,0}
        }, Mob)

local interface = Layer.new{}


local Sim = NewScene{
    
    name = "Sim"

}

Controls.AddCommand(B.esc, LE.Close)

Controls.AddCommand(B.space, function()
    paused = not paused and true or false
end)

Controls.AddCommand(B.t, function()
    local pos = npc[chosen].pos
    player.pos[1], player.pos[2] = pos[1]-screen.w * 0.5, pos[2]-screen.h * 0.5
end)
local centre = {screen.w * 0.5, screen.h * 0.5}
Controls.AddCommand(B.x, function()
    local pos = centre
    player.pos[1], player.pos[2] = pos[1]-screen.w * 0.5, pos[2]-screen.h * 0.5
end)

Controls.AddCommand(B.n, function()
    print(#npc)
    for i = 1, #npc do
        print(i..":"..npc[i].pos[1].." "..npc[i].pos[2])
        -- if npc[i].brain then
        --     npc[i].brain:print()
        -- end
    end
    
end)

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

local green = {0,1,0,1}
local blue = {0,0,1,1}
local red = {1,0,0,1}



local main = Layer.new{blend = 0}


local Human = require"Scenes/Sim/classes/Human"
local Flower = require"Scenes/Sim/classes/Flower"
local Net = require"Scenes/Sim/classes/Neuronet"
local T = require"Scenes/Sim/lib/TimeInterface"

local time = T.time

function Sim.reset()
    Sim.alltime = 0
    Sim.start = time()
    if flowers > 0  then
        for i = 1, flowers do
            local x, y = randFlowers()
            local a = objs[i]
            flosprite:CopySprite(a)
            a.pos = {x, y};
            
        end

    end
    if humans > 0 then

        for i = 1, humans do
            local a = npc[i]
            local x, y = randHumans() --math.random(dx[1],dx[2]), math.random(dy[1],dy[2])
            a.alltime = 0
            a:reset(x,y)
            humarite:CopySprite(a)
        end
        
    end
end

function Sim.save(objs, folder)
    local ret = "return {\n"
    ret = ret .."deaths = ".. tostring(deaths)..";"
    .."alltime = "..tostring(Sim.alltime + time() - Sim.start)..";"
    for i = 1, flowers do
        ret = ret.."function()\n"
        ..Flower.save(objs[i])
        .."end,\n"
    end
    for i = flowers+1, flowers+humans do
        ret = ret.."function()\n"
       ..Human.save(objs[i], nil, Sim.alltime + time() - objs[i].time_alive)
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

function Sim.loadFile(folder)
    local t = loadfile (folder..".lua")()
    deaths = t.deaths
    Sim.alltime = t.alltime
    Sim.start = time()

    if flowers > 0 then
        for i = 1, flowers do
            local a = t[i]()
            Flower.loadT(a)
            main:RemoveDrawable(objs[i])
            flosprite:CopySprite(a) -- need to copy Sprite to object for that to be used
            a.scale = flosprite.scale
            main:AddDrawable(a)
            objs[i] = a
        end
    end
    if humans > 0 then
        for i = 1, humans do
            main:RemoveDrawable(npc[i])
            local a = t[flowers+i]()
            Human.loadT(a)
            humarite:CopySprite(a)
            a.time_alive = a.alltime - Sim.alltime + Sim.start
            a.scale = humarite.scale
            main:AddDrawable(a)
            objs[flowers+i] = a
            npc[i] = a
        end
    end
end

Controls.AddCommand(B.r, 
    Sim.reset
)

Controls.AddCommand(B.p, function()
    Sim.saveF = true
    print"save"
    Sim.save(objs, "save1")
    Sim.saveF = false
end)

Controls.AddCommand(B.o, function()
    Sim.loadF = true
    print"load"
    Sim.loadFile("save1")
    Sim.loadF = false
end)



local pi = math.pi
local Npc_Controls;


local int = LE.int
local DrawSprite = Graphics.DrawSprite
local DrawSpriteSheet = Graphics.DrawSpriteSheet
local DrawCircle = Graphics.DrawCircle
local osize = {}
local function drawobj(a)
    local ax, ay = a.pos[1] + a.scale[1], a.pos[2]
    DrawCircle(false, ax, ay, 10)
    DrawSprite(a)
end

local function drawnpc(a)
    local ax, ay = a.pos[1], a.pos[2]
    DrawSpriteSheet(a)
    DrawCircle(false, ax+humarite.scale[1], ay, 20)
end 

function Sim.Load(Sim)
    
    print"Load Start"
    
    text:Load(true)
    main.pos = player.pos
    -- interface.pos = player.pos
    interface:AddDrawable(text)
    local seed = os.time() --1678645598
    print(seed)
    math.randomseed(seed) --initialize randomness
    
        
    ----------------------------------------------ADDING TEXTURES----------------------------------------------------------------
    flosprite, humarite = {}, {}
    Sprite.newSimple(flosprite)
    flosprite:Load("Scenes/Sim/res/Plants/Wheat.png",true)
    flosprite.color = Colors.yellow
    flosprite.scale = Graphics.GetSize(flosprite)
    flosprite.Draw = drawobj
    

    Sprite.newSheet(humarite)
    humarite:Load("Scenes/Sim/res/Human/Human", false)
    humarite.scale = {humarite.src.w, humarite.src.h}
    
    humarite.color = blue
    humarite.w, humarite.h = humarite.src.w, humarite.src.h
    humarite.Draw = drawnpc

--------------------------------------------------CREATING MOBS-------------------------------------------------------------------
    Sim.start = time()
    Sim.alltime = 0
    if flowers > 0 then
        for i = 1, flowers do
            local x, y = randFlowers()
            local a = Flower.new(x,y)
            flosprite:CopySprite(a) -- need to copy Sprite to object for that to be used
            a.scale = flosprite.scale
            main:AddDrawable(a)
            objs[i] = a
        end
        print"flowers"
    end
    if humans > 0 then
        for i = 1, humans do
            local x, y = randHumans() --math.random(dx[1],dx[2]), math.random(dy[1],dy[2])
            local a = Human.new(x,y)
            humarite:CopySprite(a)
            a.scale = humarite.scale
            main:AddDrawable(a)
            objs[flowers+i] = a
            npc[i] = a
        end
    end

    
    Listener.pos = player.pos
    print"Load End"
    
end

function Sim:Delete()
    Graphics.DestroySpriteSheet(humarite)
end

local alive = 10
function Sim.AddNpc(x,y, prec)
    local a, n;
    for i = 1, humans do
        if not npc[i].Draw then
            a = npc[i]
            a.Draw = humarite.Draw

            a:reset(x,y, prec)
            n = i
            break
        end
    end
    
    if not a then
        if humans + 1 > 50 then
            return 
        end
        a = Human.new(x,y, prec)
        humans = humans + 1
        n = humans
    end
    alive = alive + 1
    a.time_alive = Sim.alltime + time()
    
    if n == humans then
        humarite:CopySprite(a)
        a.w, a.h = humarite.w, humarite.h
        a.scale = humarite.scale
        main:AddDrawable(a)
    end
    a.Draw = humarite.Draw
    objs[flowers+n] = a
    npc[n] = a
    return a
end
Controls.AddCommand(B.e, function()
    if chosen < humans then
        chosen = chosen + 1
    else
        chosen = 1
    end
end)
Controls.AddCommand(B.q, function()
    if chosen > 1 then
        chosen = chosen - 1
    else
        chosen = humans
    end
end)

function Sim:Update()

    -- print"Update"
    if not paused then
        
        Npc_Update()
        Obj_Update()
    end
    local i = chosen
    local simtime, npctime = Sim.alltime + time() - Sim.start, npc[i].alltime - npc[i].time_alive + time()
    if npc[i].Draw then
        npctime = npctime
    end
    text.value = 
    fmt("fps %2.4f \nalive: %d on board %d\ndeath: %d simtime %d's life span: %d's\ni:%d, score: %d, gen: %d\n rad: %2.4f\nspeed: %2.4f\nv1: %2.4f\n v2: %2.4f\nstamina: %2.4f \nfat: %2.4f output2: %f \nsyns: %d neurs: %d",
        fps, alive, humans, deaths, simtime, npctime, chosen, npc[i].score, npc[i].gen, math.deg(npc[i].rad), npc[i].speed, npc[i].vel[1], npc[i].vel[2], npc[i].stamina, tonumber(npc[i].fat), npc[i].brain.out[1].bias, #npc[i].brain.syns, #npc[i].brain.hid)
end
local D_offset = 150
local function dist(posA, posB)
    local dx, dy = posA[1] - posB[1], posA[2] - posB[2]
    return dx*dx + dy*dy
end

function Npc_Update()
    local len = #npc
    local a;
    
    for i = 1, len do
        a = npc[i]
        
        if a.Draw then 
            a:Act(objs, Sim.AddNpc)
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
            a:reset(randHumans(), Sim.alltime + time() - Sim.start)
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
        npc:PlayAnim(npc.dir, true, 20, 4)
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


local cur = {0,0}
function Sim.Button(x, y, status)
    x = player.pos[1] + x * ax
    y = player.pos[2] + y * ay
    cur[1] = x
    cur[2] = y
    for i = 1, #npc do
        local n = npc[i]
        if n.Draw then
            if CtC(x, y, 12, n.pos[1]+humarite.scale[1], n.pos[2]+0.1*humarite.scale[2], 20) then
                chosen = i
                break
            end
        end
    end
end


function Sim:KeyPress(key, down)
    player:Stop()
    if key[B.w] then
        player.vel[2] = -1
    end
    if key[B.s] then
        player.vel[2] = 1
    end
    if key[B.a] then
        player.vel[1] = -1
    end
    if  key[B.d] then
        player.vel[1] = 1
    end
    if key[B.m] then
        music:Play()
    end



    if player:isMoving() then
        player:Vel_Move()

        Listener:Update()
    end
end
local line = {120,45, 34,56, 300, 230}

function Sim:Draw()
    if not paused then
        T.Update()
    end
    main:Draw()
    interface:Draw()
    -- Graphics.DrawLines(line)
    npc[chosen]:drawBrain()
    Graphics.SetColor(1,0,0,1)
    DrawCircle(false, centre[1]-player.pos[1], centre[2]-player.pos[2], screen.w*2 )
    DrawCircle(false, npc[chosen].pos[1] + npc[chosen].scale[1]-player.pos[1], npc[chosen].pos[2]-player.pos[2], 20)
    Graphics.SetColor(1,1,1,1)
    DrawCircle(false, cur[1]-player.pos[1], cur[2]-player.pos[2], 12)
end


print"Sim.root End"

return Sim