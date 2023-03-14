-- local dt = 1/64
local Sprite = require "classes.Sprite"
local Mob = require "classes.Mob"
local Net = require "Scenes/Sim/classes/Neuronet"
local T = require"Scenes/Sim/lib/TimeInterface"

local time = T.time
local Human;
local screen = _en.screen
local Collide = Collision
local CtC = Collide.CtC
Human = {

}
local stopmut = false
local IDs = {
    unknown = 0,
    Human = 1,
    Flower = 2,
}
IDs.len = 3
IDs.part = 1/(IDs.len)

local brain_tick = 0.01
local muscle_cons = 0.4
local muscle_mass = 0.4;
local bone_mass = 0.1;

Human.genes = {
    rot = 2;
    acc = 0;
    speed = 2.5;
    force = 30;
    sight  = 400;
    n_cost = 0.05;
    s_cost = 0.02;
    stamina = 100;
    p_bone = 985;
    mass = 50;
    p_muscle = 1090;
    p_fat = 950;
    heigth = 1.7;
}

function Human.ancestry(h, prec)
    local genes = {}
    local pgen = Human.genes
    if prec then
        pgen = prec
    end 
    for k,v in pairs(Human.genes) do
        genes[k] = pgen[k]
    end
    genes.prec = pgen
    h.rot_max = pgen.rot;
    h.acc_max = pgen.acc;
    h.speed_max = pgen.speed;
    h.width = h.heigth*0.2;
    h.depth = h.heigth*0.15;
    h.vol = h.width*h.heigth*h.depth*0.8
    h.mass = h.vol*muscle_mass*h.p_muscle + bone_mass*h.vol*h.p_bone
    h.fat = h.mass*0.1
    h.weight = h.mass + h.fat*h.p_fat
    h.acc_max = h.force/h.weight
    h.idle_consum = h.vol*h.p_muscle*muscle_mass*muscle_cons
    h.stamina_max = 3000/(h.mass+40) + 10
    h.stamina = h.stamina_max
    h.alltime = 0
    h.genes = genes
end

function Human.new(x,y, prec)
    local h = {
        rot = 0;
        rot_max = 2;
        acc = 0;
        acc_max = 0;
        speed_max = 2.5;
        force = 30;
        sight  = 400;
        n_cost = 0.05;
        s_cost = 0.02;
        dir = 1;
        time_alive = time();
        score = 0;
        stamina = 100;
        tick = brain_tick;
        mass = 50;
        p_bone = 985;
        p_muscle = 1090;
        p_fat = 950;
        heigth = 1.7;
        fat = 0;
        rad = math.rad(math.random(0,360));
        id = IDs.Human;
        Act = Human.Act;
        reset = Human.reset;
        drawBrain = Human.drawBrain;
        newBrain = Human.newBrain;
        gen = 0;
    };
    Human.ancestry(h, prec)

    Sprite.newSheet(h)
    Mob.newMob(h, x, y, 0)
    h.Vel_Move = Human.Vel_Move
    Human.newBrain(h)
    return h;
end


function Human.reset(h, x, y, prec)
    if type(h) ~= "table" then
        print(type(h))
        error"Human must be table!"
    end
    h.pos[1] = x or h.pos[1] or 0; h.pos[2] = y or h.pos[2] or 0
    h.vel[1] = 0
    h.vel[2] = 0
    h.speed = 0
    h.tick = brain_tick
    h.score = 0
    Human.ancestry(h, prec)
    h.fat = h.mass*0.1
    h.weight = h.mass + h.fat*h.p_fat
    h.time_alive = time();
    h.alltime = 0
    h.stamina = h.stamina_max
    -- h:newBrain()
end

Human.fields = {
    gen = 0;
    rad = 0;
    rot = 0;
    rot_max = 0;
    acc = 0;
    acc_max = 0;
    speed =  0;
    speed_max = 0;
    stamina = 0;
    stamina_max = 0;
    force = 0;
    sight  = 0;
    n_cost = 0;
    s_cost = 0;
    dir = 0;
    time_alive = 0;
    score = 0;
    tick = 0;
    mass = 0;
    p_bone = 0;
    p_muscle = 0;
    p_fat = 0;
    weight = 0;
    heigth = 0;
    width = 0;
    depth = 0;
    vol = 0;
    fat = 0;
    id = 0;
    idle_consum = 0;
}

function Human.save(h, folder, life)
    local ret ="local function brain()"
    ..(h.brain:save())
    .."end\n"
    .."return {\n"
        .."pos = {"..tostring(h.pos[1])..", "..tostring(h.pos[2]).."};"
        .."vel = {"..tostring(h.vel[1])..", "..tostring(h.vel[2]).."};"
        .."alltime = "..tostring(life)..";"
        for key in pairs(Human.fields) do
            ret = ret .. tostring(key).." = ".. tostring(h[key])..";\n"
        end

        ret = ret.."brain = brain();\n"
    .."}"
    if not folder then
        return ret
    end
    if type(folder) ~= 'string' then
        error"Human folder must be string!"
    end
    local f = io.open(folder,"w+")
    f:write(ret)
    f:close()
    return ret
end

function Human.load(str)
    local h = load(str)()
    h.Act = Human.Act
    h.reset = Human.reset;
    h.drawBrain = Human.drawBrain;
    h.newBrain = Human.newBrain;
    Sprite.newSheet(h)
    h.id = IDs.Human;
    h.Vel_Move = Human.Vel_Move
    h.brain = Net.loadT(h.brain)
    for i = 1, #h.brain.inp do
        h.brain.inp[i].func = Net.funcs[7]
    end
    h.brain.out[1].func = Net.funcs[4]
    h.brain.out[2].func = Net.funcs[4]
end

function Human.loadT(h)
    h.Act = Human.Act
    h.reset = Human.reset;
    h.drawBrain = Human.drawBrain;
    h.newBrain = Human.newBrain;
    h.id = IDs.Human;
    Sprite.newSheet(h)
    h.Vel_Move = Human.Vel_Move
    h.brain = Net.loadT(h.brain)
end

function Human.stopmut()
    stopmut = true
end

gaussT = 0
 function gaussrnd(u, d)
    local x, w1, w2, r;
 
    repeat
        w1 = 2.0 * math.random() - 1.0
        w2 = 2.0 * math.random() - 1.0
        r = w1 * w1 + w2 * w2
    until( r >= 1.0 or r == 0)
    r = math.sqrt( -2.0*math.log(r)/ r )
    return( u + w1 * r * d )
end

local function round(x)
    local i, f = math.modf(x)
    if f < 0.5 then
        return i
    else
        return i + 1
    end
end
local angle_part = 1/(math.pi*2)
local id_part = 1/(2^32)
local none_obj = {color = {0,0,0,0},id = 0; pos={screen.w*0.5, screen.h*0.5}, nx = 0, ny = 0}
function Human.Act(a, objs, spawnFunc)
    if a.stamina <= 0 then
        a.Draw = false
        return
    end
    if not a.brain then
        error"Humans without brain can't act!"
    end
    local fAngle = 0;
    local nFlower = 0;
    local hScore = a.score;
    local pos, vel = a.pos, a.vel
    local brain = a.brain
    local min = a.sight*a.sight;
    local flo = none_obj
    local lid = round(brain.out[3].bias*IDs.len)
    local action = round(brain.out[4].bias*2)
    if flo then
        flo.nx = pos[1] - flo.pos[1]
        flo.ny = pos[2] - flo.pos[2]
        for i = 1, #objs do
            local f = objs[i]
            if f == a or not f then
                goto skip
            end
            if f.id ~= lid then
                goto skip
            end
            f.ny = 0
            f.nx = 0
            local dx, dy = pos[1] - f.pos[1], pos[2] - f.pos[2]
            local r2 = dx*dx + dy*dy
            local p4 = math.pi*0.25
            local ang = math.atan2(dx, dy)
            if ang < 0 then
                ang = ang + math.pi*2
            end
            if r2 < a.sight*a.sight then
                if ang < a.rad + p4 and ang > a.rad - p4  then
                    if r2 < min then
                        min = r2
                        f.nx = dx
                        f.ny = dy
                        flo = f
                    end
                    nFlower = nFlower + 1
                end
            end
            ::skip::
        end
        fAngle = math.atan2(flo.ny, flo.nx)
        if fAngle < 0 then
            fAngle = fAngle + math.pi*2
        end
        for j = 1, #objs do
            b = objs[j]
            if not b.__name then
                break;
            end
            if b.Draw and a.speed > 0 then
                if CtC(a.pos[1] + a.scale[1], a.pos[2] + 0.1*a.scale[2], 20, b.pos[1] + b.scale[1], b.pos[2], 10) then
                    local n = #objs
                    a.stamina = a.stamina + 1
                    a.score = a.score + 1
                    if a.stamina > a.stamina_max then
                        local fat = (a.stamina - a.stamina_max)*dt
                        a.stamina = a.stamina_max
                        local sdt = a.speed*dt
                        if a.speed <= 0 then
                            a.speed = 1
                        end
                        fat = 2*fat*sdt*sdt
                        a.fat = a.fat + fat
                        a.weight = a.mass + a.fat*a.p_fat
                    end
                    b.Draw = false
                    break
                end
            end
            
        end
        
    end
    brain.inp[1]:pushvalue(1.0)
    brain.inp[2]:pushvalue(fAngle*angle_part)
    brain.inp[3]:pushvalue(nFlower/#objs)
    brain.inp[4]:pushvalue(a.stamina/a.stamina_max)
    brain.inp[5]:pushvalue(1-(min/(a.sight*a.sight)))
    brain.inp[6]:pushvalue(id_part*Color.tohex(flo.color))
    brain.inp[7]:pushvalue(flo.id/IDs.len)

    if a.tick >= brain_tick then

        if math.random(1,100) > 90 then
            Net.mutate(brain)
        end
        a.tick = 0
    end
    Net.count(brain)
    a.tick = a.tick + dt
    
    a.rot = brain.out[1].bias*a.rot_max
    a.acc = brain.out[2].bias*a.acc_max
    
    a.stamina = a.stamina - Human.costBrain(a)
    a:Vel_Move()
    local consum = a.idle_consum*dt
    if a.stamina < a.stamina_max*0.55 then
        if a.fat > 0 then
            a.fat = a.fat - consum
            consum = 0
        else
            a.fat = 0
        end
    end
    a.stamina = a.stamina - consum
    if a.score >= 10 and a.stamina > 30 then
        a.stamina = a.stamina - 30
        
        local x,y = a.pos[1], a.pos[2]
    -- 2 right 3 up 4 left 1 down
        local b = spawnFunc(x, y, a.genes)
        if not b then
            goto skip
        end
        b.brain = Net.clone(a.brain)
        local off = 20
        if a.dir == 1 then
            y = y - off
            b.dir = 3
        elseif a.dir == 2 then
            x = x - off
            b.dir = 4
        elseif a.dir == 3 then
            y = y + off
            b.dir = 1
        elseif a.dir == 4 then
            x = x + off
            b.dir = 2
        end
        b.pos[1], b.pos[2] = x, y
        b.rad = math.rad(90 *(b.dir-1))
        b.gen = a.gen + 1
    end
    ::skip::
end

local hlfv = 0.70710678118655
local w, h = 640, 320
function Human.Vel_Move(a)
    
    local pos, vel = a.pos, a.vel

    a.speed = a.speed + a.acc
    if a.speed > a.speed_max then
        a.speed = a.speed_max
    elseif a.speed < -a.speed_max then
        a.speed = -a.speed_max
    end
    local spd = a.speed
    local sdt = spd*dt
    
    local energy = sdt*sdt*a.weight*0.5
    
    energy = energy
    a.stamina = a.stamina - energy 
    local ox, oy = pos[1], pos[2]
    vel[1] = math.cos(a.rad)
    vel[2] = math.sin(a.rad)
    
    if a.stamina < a.stamina_max*0.3 then
        spd = spd*0.5
    end
    
    a.rad = a.rad + math.rad(a.rot)
    if a.rad > math.pi*2 then
        a.rad = a.rad - math.pi*2
    elseif a.rad < 0 then
        a.rad = math.pi*2-a.rad
    end
    pos[1] = pos[1] + vel[1] * spd
    pos[2] = pos[2] + vel[2] * spd
    
end
local BaseBrain = require"Scenes/Sim/classes/BaseBrain"
function Human.newBrain(h)
    local brain = Net.clone(BaseBrain)
    h.brain = brain
end

function Human.costBrain(h)
    local brain = h.brain
    local neuron_cost, syn_cost = h.n_cost,h.s_cost
    local sum = #brain.syns*syn_cost*dt + #brain.list*neuron_cost*dt
    return sum
end

local function Positive(v)
    if v > 0 then
        Graphics.SetColor(0, 1, 0, 1)
    elseif v == 0 then
        Graphics.SetColor(0, 0, 1, 1)
    else
        Graphics.SetColor(1, 0, 0, 1)
    end
end
function Human.drawBrain(h)
    if not h.brain then
        error "No human brain to draw!"
    end
    local N = h.brain
    local oy = 200
    local x, y = 10, oy

    Net.visual(N)
    for i = 1, #N.list do
        local n = N.list[i]
        Graphics.SetColor(n.bias,n.bias,0,1)
        Graphics.DrawCircle(false, n.x, n.y, 7)
    end

    for i = 1, #N.syns do
        local s = N.syns[i]
        if s then
            local n1 = s.neur[1]
            local n2 = s.neur[2]
            
            if n1 and n2 then
                if n1.y < oy or n2.y < oy then
                    print(n1.y, n2.y, n1, n2)
                    
                    for i,v in pairs(N.list) do
                        print(i,v)
                    end
                    
                    for i,v in pairs(N.syns) do
                        print(i,v)
                    end
                    
                    for k,v in pairs(s.neur) do
                        print(k,v)
                        for k,v in pairs(v) do
                            print(k,v)
                        end
                    end
                    for k,v in pairs(s) do
                        print(k,v)
                    end
                end
                
                n1.checked = false
                n2.checked = false
                Positive(s.weight)
                Graphics.DrawLine(n1.x, n1.y, n2.x, n2.y)
            end
        end
    end
    Graphics.SetColor(1, 1, 1, 1)
end



return OOP.class("Human", Human) ;