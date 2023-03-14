local Neuron;
local Synapse;
--activation functions' prototypes
local sigmoid, square, linear, tanh, gaussian, ReLU;

-- loading math
local random = math.random;
local sqrt =  math.sqrt;
local cos = math.cos;
local log = math.log;
local exp = math.exp;
local pi = math.pi;
local abs = math.abs;
local rdm = require"Scenes.Sim.lib.ranDOOM"

local function array(a)
    local i = 1
    return function()
        return a[i]
    end
end

function table.print(t)
    print(t)
    print()
    for k,v in  pairs(t) do
        print(k, v)
    end
end
local rand_100 = rdm.makeRand(rdm.genTable(1,100), math.random(1,100))


local ranT = rdm.genTableNV{[1] = 16, [2] = 17, [3] = 17, [4] = 17, [5] = 16, [6] = 17}
rdm.ShuffleTable(ranT, rand_100)
local choose_6 = rdm.makeRand(ranT, rand_100())

local p4_t = rdm.genTableNV{[1] = 25, [2] = 25, [3] = 25, [4] = 25}
rdm.ShuffleTable(p4_t, rand_100)
local choose_4 = rdm.makeRand(p4_t, rand_100())

local p10_abs = rdm.genTableNV{
    [-10] = 9, [-9] = 10, [-8] = 9, [-7] = 10, [-6] = 10, [-5] = 9, [-4] = 10, [-3] = 10, [-2] = 10, [-1] = 10,
    [10] = 9,   [9] = 9,   [8] = 10, [7] = 9,   [6] = 10,  [5] = 10, [4] = 10,  [3] = 9,   [2] = 9,   [1] = 9, [0] = 9}
rdm.print(p10_abs)
local rand_10abs = rdm.makeRand(p10_abs, rand_100())

local p4_abs = rdm.genTableNV{
    [-4] = 11, [-3] = 11, [-2] = 11, [-1] = 11,
    [4] = 11,  [3] = 11,   [2] = 11,   [1] = 11, [0] = 12,
}
local rand_4abs = rdm.makeRand(p4_abs, rand_100())

local possib_3 = {[1] = 33, [2] = 33, [3] = 34}
local p3_t = rdm.genTableNV(possib_3)
rdm.ShuffleTable(p3_t, rand_100)
local choose_3 = rdm.makeRand(p3_t, rand_100())

local possib_l = {inp = 33, out = 33, hid = 34}
local l_t = rdm.genTableNV(possib_l)
rdm.ShuffleTable(l_t, rand_100)
local rand_l = rdm.makeRand(l_t, choose_3())

local memChoice;
local memChoiceS;
local memChoiceStr;

local listn, locan = tostring(function() end), tostring(function() end) -- name of object in the net's list and name of object in some local lists 
local layn = tostring(function() end)

-- math.randomseed(os.time())

local Net = {
    list = {};
    inp = {};
    out = {};
    hid = {};
    syns = {};
}

function Net.addInput(N, n)
    n[listn] = #N.list+1
    n[locan] = #N.inp+1
    n[layn] = "inp"
    N.inp[n[locan]] = n
    N.list[n[listn]] = n
end

function Net.addOutput(N, n)
    n[listn] = #N.list+1
    n[locan] = #N.out+1
    n[layn] = "out"
    N.out[n[locan]] = n
    N.list[n[listn]] = n
end

function Net.addHidden(N, n)
    n[listn] = #N.list+1
    n[locan] = #N.hid+1
    n[layn] = "hid"
    N.hid[n[locan]] = n
    N.list[n[listn]] = n
end

function Net.addNeuronR(N, n)
    n = n or Neuron.new(Net.funcs[choose_6()])
    if #N.syns < 1 then
        return 
    end
    local choice = math.random(#N.syns)
    local s1 = N.syns[choice]
    if not s1 then
        return
    end
    local n2 = s1.neur[2]
    if not n2 then
        return
    end
    N:addHidden(n)
    s1:connect(n, 2)
    Net.addSynapse(N, n, n2)
    
end

function Net.addNeuronA(N, n)

end


function Net.new(ins, hids, outs)
    ins = ins or 1
    hids = hids or 0
    outs = outs or 1
    local N = {
        list = {};
        inp = {};
        out = {};
        hid = {};
        syns = {};
        addInput = Net.addInput;
        addOutput = Net.addOutput;
        addHidden = Net.addHidden;
        addSynapseR = Net.addSynapseR;
        addNeuronR = Net.addNeuronR;
        copy = Net.copy;
        print = Net.print;
        save = Net.save;
    }
    for i = 1, ins do
        N:addInput(Neuron.new(sigmoid))
    end

    for i = 1, outs do
        N:addOutput(Neuron.new(sigmoid));
    end

    for i = 1, hids do
        N:addHidden(Neuron.new(sigmoid))
    end
    return N;
end

function Net.cross(N, cN)
    local rN = Net.new(#N.inp, 0, #N.out)
    local rNl = rN.list
    local cNl = cN.list
    local Nlen, cNlen = #N.list, #cN.list 
    local len = Nlen > cNlen and Nlen or cNlen
    local Slen, cSlen = #N.syns, #cN.syns
    local C = N
    
    for i = 1, len do
        if math.random(0,1) > 0 then
            C = N
        else
            C = cN
        end
        if i > cNlen then
            C = N
        else
            C = cN
        end
        local l = C.list[i]
        local o = rNl[i];
        if l then
            o = o or Neuron.new(l.func, l.bias)
            o[listn] = i
            o[locan] = l[locan]
            o[layn] = l[layn]
            rN[l[layn]][l[locan]] = o
            rNl[i] = o
        end
    end
    local len = Slen > cSlen and Slen or cSlen
    for i = 1, len do
        if math.random(0,1) > 0 then
            C = N
        else
            C = cN
        end
        if i > cNlen then
            C = N
        else
            C = cN
        end
        local l = C.syns[i]
        local o = rN.syns[i];
        if l then
            o = o or Synapse.new(l.weight)
            local n1, n2;
            if l.neur[1] then
                n1 = rNl[l.neur[1][listn]]
            end
            if l.neur[2] then
                n2 = rNl[l.neur[2][listn]]
            end
            o.weight = l.weight
            if n1 then
                o:connect(n1, 1)
            end
            if n2 then
                o:connect(n2, 2)
            end
            if n1 and n2 then
                o[locan] = l[locan]
                rN.syns[o[locan]] = o
            end
        end
    end
    return rN
end

function Net.clone(N)
    local rN = Net.new(#N.inp, 0, #N.out)
    local rNl = rN.list

    for i = 1, #N.list do
        local l = N.list[i]
        local o = rNl[i];
        if l then
            if l.bias then
                o = o or Neuron.new(l.func, l.bias)
                o[listn] = i
                o[locan] = l[locan]
                o[layn] = l[layn]
                rN[l[layn]][l[locan]] = o
                rNl[i] = o
            end
        end
    end
    for i = 1, #N.syns do
        local l = N.syns[i]
        local o = rN.syns[i];
        if l then
            if l.weight then
                o = o or Synapse.new(l.weight)
                local n1, n2;
                if l.neur[1] then
                    n1 = rNl[l.neur[1][listn]]
                end
                if l.neur[2] then
                    n2 = rNl[l.neur[2][listn]]
                end
                o.weight = l.weight
                if n1 then
                    o:connect(n1, 1)
                end
                if n2 then
                    o:connect(n2, 2)
                end
                if n1 or n2 then
                    o[locan] = i
                    rN.syns[o[locan]] = o
                end
            end
        end
    end
    return rN
end

function Net.save(N, folder)
    
    local ret = ""
    .."return {\n"
    ..("inp = "..tostring(#N.inp)..";")
    ..("out = "..tostring(#N.out)..";")
    .."list = {\n"
    for i = 1, #N.list do
        local n = N.list[i]
        ret = ret..("["..tostring(i).."] = {\n bias = "..tostring(n.bias).."; layn = '"..tostring(n[layn]).."';")
        ..("inps = {\n")
        table.print(n)
        table.print(n.inps)
        for j = 1, #n.inps do
            local s = n.inps[j]
            ret = ret..(tostring(s[locan])..";")
        end
        ret = ret.."};\n"
        .."outs = {\n"
        for j = 1, #n.outs do
            local s = n.outs[j]
            ret = ret..(tostring(s[locan])..";")
        end
        ret = ret.."};\n"
        .."};\n"
    end
    ret = ret.."};\n"
    .."syns = {\n"
    for i = 1, #N.syns do
        local s = N.syns[i]
        ret = ret..("["..tostring(i).."] = {\n weight = "..tostring(s.weight)..";")
        ..("n1 = "..tostring(s.neur[1][listn])..";")
        ..("n2 = "..tostring(s.neur[2][listn])..";")
        ..("};\n")
    end
    ret = ret.."};\n"
    .."};\n"
    if not folder then
        return ret
    end
    if type(folder) ~= "string" then
        error"folder should be a string"
    end
    local f = io.open(folder..".lua", "w+")
    if not f then
        error("fail to open file "..folder.."!")
    end
    f:write(ret)
    f:close()
    return ret
end

function Net.load(folder)
    if type(folder) ~= "string" then
        debug.traceback()
        error"folder should be a string"
    end
    local N = require(folder)
    if (type(N) ~= "table") then
        error("failed to load file "..folder.."! Module should return table.")
    end
    if type(N.list) ~= 'table' or type(N.syns) ~= 'table' then
        error("Something wrong with a save file "..folder.."!")
    end
    local rN = Net.new(N.inp,0,N.out)
    for i = 1, #N.list do
        local n = rN.list[i]
        local ln = N.list[i]
        if not n then
            n = Neuron.new()
            rN:addHidden(n)
        end
        n.bias = ln.bias
    end

    for i = 1, #N.syns do
        local ns = N.syns[i]
        local s = Synapse.new(N.syns[i].weight)
        if rN.list[ns.n1] then
            s:connect(rN.list[ns.n1], 1)
        end
        if rN.list[ns.n2] then
            s:connect(rN.list[ns.n2], 2)
        end
        rN.syns[i] = s
    end
    return rN
end

function Net.loadT(N)

    if type(N) ~= "table" then
        debug.traceback()
        error"Net should be a table"
    end
    if type(N.list) ~= 'table' or type(N.syns) ~= 'table' then
        error("Something wrong with a save table !")
    end
    local rN = Net.new(N.inp,0,N.out)
    for i = 1, #N.list do
        local n = rN.list[i]
        local ln = N.list[i]
        if not n then
            n = Neuron.new()
            rN:addHidden(n)
        end
        n.bias = ln.bias
    end

    for i = 1, #N.syns do
        local ns = N.syns[i]
        local s = Synapse.new(N.syns[i].weight)
        if rN.list[ns.n1] then
            s:connect(rN.list[ns.n1], 1)
        end
        if rN.list[ns.n2] then
            s:connect(rN.list[ns.n2], 2)
        end
        s[locan] = i
        rN.syns[i] = s
    end
    return rN
end

local _traversable = {"inp", "hid", "out"}
function Net.traverse(N)
    local type = 0
    return function ()
        type = type + 1
        return N[_traversable[type]]
    end
end

function Net.next_l(N)
    local typ = 0
    return function()
        typ = typ + 1
        return _traversable[typ]
    end
end

local _connectable = {"hid", "out"}
function Net.addSynapseR(N, s, l)
    if not s then
        s = Synapse.new()
    end
    s.weight = 0 
    -- math.random()
    -- if math.random(1,2) == 1 then
    --     s.weight = -s.weight
    -- end
    local n1, n2;
    if #N.hid < 1 then
        n1 = N.inp[math.random(1,#N.inp)]
        n2 = N.out[math.random(1,#N.out)]
    else
        local ninp = #N.inp
        local nhid = #N.hid
        local nout = #N.out
        local hinp = nhid + ninp
        local choice = math.random(1,hinp)
        
        if choice <= ninp then
            n1 = N.inp[math.random(1, ninp)]
        else
            n1 = N.hid[math.random(1, nhid)]
        end
        local choice2 = math.random(1, nout + nhid)
        if choice2 <= nhid then
            n2 = N.hid[math.random(1, nhid)]
        else
            n2 = N.out[math.random(1,nout)]
        end
    end

    Net.addSynapse(N, n1, n2)
end

function Net.addSynapse(N, n1, n2)
    local s = Synapse.new()
    s.weight = math.random(-1, 1) * math.random()
    s[locan] = #N.syns+1
    N.syns[s[locan]] = s
    s:connect(n1, 1)
    s:connect(n2, 2)
end

function Net.randomSynapses(N)
    for layer in Net.traverse(N) do
        if layer == N.out then
            break;
        end
        local num = math.random(3,7)
        for i = 1, #layer do
            local n = layer[i]
            if num > 0 then
                N:addSynapseR(nil)
            end
            num = num - 1
        end    
    end
end

local laynames = {"inp", "out", "hid"}

function chooseNeur(N, ign)
    local choice = memChoiceStr(laynames, ign or "out")
    local layer = N[choice]
    local neur, idx;
    if #layer < 1 then
        layer = N.inp
    end
    idx = memChoice(#layer)
    neur = layer[idx]
    if not ign then
        return neur, choice
    end
    return neur
end
function Net.randomizeSynapses(N)
    for i = 1, #N.syns do
        local a = N.syns[i]
        local neur, lname = chooseNeur(N)
        a:connect(neur, 1)
        neur = chooseNeur(N, lname)
        a:connect(neur, 2)
    end
end

local mem = {[3] = {rand = choose_3}, [4] = {rand = choose_4}, [6] = {rand = choose_6} }
function memChoice(ls)
    local args;
    local r = mem[ls] 
    if not r then
        r = {}
        r[mem] = rdm.genTable(1, ls)
        rdm.ShuffleTable(r[mem])
        r.rand = rdm.makeRand(r[mem], 1)
        if not mem[ls] then
            mem[ls] = r
        end
    end
    return r.rand()
end
function memChoiceS(ls, skip)
    local args;
    local key = (tostring(ls).."_"..tostring(skip))
    local r = mem[key]
    if not r then
        local ch = 100//(ls)
        args = {}
        for i = 1, ls do
            if i ~= skip then
                args[i] = ch   
            end
        end
        r = {}
        r[mem] = rdm.genTableNV(args)
        
        r.rand = rdm.makeRand(r[mem], 1)
        mem[key] = r
    end
    return r.rand()
end

-- gets array of strings returns choice
function memChoiceStr(args, skip)
    local ls = #args
    local key = (tostring(ls).."_"..skip)
    local r = mem[key]
    if not r then
        local ch = 100//ls
        local t = {}
        for i = 1, ls do
            if args[i] ~= skip then
                t[args[i]] = ch
            end
        end
        r = {}
        t = rdm.genTableNV(t)
        rdm.ShuffleTable(t)
        r.rand = rdm.makeRand(t,1)
        mem[key] = r
    end
    return r.rand()
end

local function xdel(a, x)
    local f = #a
    if not x then
        print(debug.traceback())
        error"x is nil!"
    end
    a[x].deleted = true
    a[f], a[x] = a[x], a[f]
    a[f] = nil
end
local function xchf(a, x)
    local f = #a
    if not x then
        print(debug.traceback())
        error"x is nil!"
    end
    a[f][listn], a[x][listn] = a[x][listn], a[f][listn]
    a[f][locan], a[x][locan] = a[x][locan], a[f][locan]
    a[f][layn], a[x][layn] = a[x][layn], a[f][layn]
end
local function xchH(a, x)
    local f = #a
    if not x then
        print(debug.traceback())
        error"x is nil!"
    end
    if not a[f] or not a[x] then
        print(f, x)
        print(a[f], a[x])
        print(debug.traceback())
    end
    a[x][locan], a[f][locan] = f, x
end
local function xchL(a, x)
    local f = #a
    if not x then
        print(debug.traceback())
        error"x is nil!"
    end
    a[x][listn], a[f][listn] = a[f][listn], a[x][listn]
end

local function removeSynapse(N,s)
    if not s or #N.syns < 1 then
        return
    end
    
    local choice = s[locan]
    if not choice then
        print(debug.traceback())
        error"choice can't be nil in removing synapses"
    end
    if choice > #N.syns then
        for i=1, #N.syns do
            if s[locan] == i then
                print("There's some "..tostring(i).."in brain")
                break
            end
        end
        return
    end
    local n1, n2 = s.neur[1], s.neur[2]
    if not n1 or not n2 then
        table.print(s)
        table.print(s.neur)
    end
    if n1[locan] > #N.list then
        table.print(n1)
        print(debug.traceback())
    end
    if n2[locan] > #N.list then
        table.print(n2)
        print(debug.traceback())
    end
    
    -- if not n1 then
    --     goto n1_skip
    -- end 
    
    for i = 1, #n1.outs do 
        if n1.outs[i] == s then
            xdel(n1.outs, i)
        end
    end
    for i = 1, #n1.inps do
        if n1.outs[i] == s then
            xdel(n1.outs, i)
        end
    end
    ::n1_skip::
    -- if not n2 then
    --     goto n2_skip
    -- end
    for i = 1, #n2.inps do
        if n2.inps[i] == s then
            xdel(n2.inps, i)
        end
    end
    for i = 1, #n2.outs do
        if n2.outs[i] == s then
            xdel(n2.inps, i)
        end
    end
    ::n2_skip::
    
    xchH(N.syns, choice)
    xdel(N.syns, choice)
end

local chances = {[1] = 15, [2] = 15, [3] = 15, [4] = 15, [5] = 15}
local syn_chances = rdm.makeRand(rdm.genTableNV(chances), rand_100())
local new_chances = {[1] = 34, [2] = 33, [3] = 33}
local neur_chances = rdm.makeRand(rdm.genTableNV(new_chances), rand_100())
function Net.mutate(N)
    local action;
    if math.random(1,100) < 50 then -- Synapse mut
        action = syn_chances()
        if action == 1 then -- reweight
            if #N.syns < 1 then
                return
            end
            local choice = memChoice(#N.syns)
            local exp = math.random(-10, 10)*0.001
            local s = N.syns[choice]
            if not s then
                return
            end
            s:reweight(exp)
        elseif action == 2 then -- add Synapse
            if #N.syns > 10 then
                return 
            end
            N:addSynapseR(nil)
        elseif action == 3 then -- remove Synapse
            if #N.syns < 1 then
                return
            end
            local choice = memChoice(#N.syns)
            removeSynapse(N, N.syns[choice])
        elseif action == 4 then -- reweight neuron synapses
            local choice = memChoice(#N.list)
            local n = N.list[choice]
            local exp = rand_10abs()*0.001
            n:reweight(exp)
        elseif action == 5 then --flip synapse
            if #N.syns < 1 then
                return
            end
            local choice = memChoice(#N.syns)
            local s = N.syns[choice]
            if not s then
                return
            end
            s.weight = -s.weight
        end
    else
        action = neur_chances()
        if action == 1 then -- add Neuron
            if #N.hid > 10 then
                return
            end
            N:addNeuronR()
        elseif action == 2 then -- remove neuron
            if #N.hid < 1 then
                return
            end
            local choice = memChoice(#N.hid)
            local n = N.hid[choice]
            local num = 0
            local pos = {}
            for i,s  in pairs (N.syns) do
                if num > 3 then
                    return
                end
                if s.neur[1]==n or s.neur[2]==n then
                    num = num + 1
                    pos[num] = s
                end
            end            
            for i = 1, #pos do
                removeSynapse(N,pos[i])
            end

            local pos = n[locan]
            local lpos = n[listn]
            xchH(N.hid, pos)
            xdel(N.hid, pos)
            xchL(N.list, lpos)
            xdel(N.list, lpos)
        elseif action == 3 then -- change function
            if #N.hid < 1 then
                return
            end
            local choice = memChoice(#N.hid)
            local n = N.hid[choice]
            n.func = Net.funcs[memChoice(6)]
        end   
    end
end


function Net.print(N)
    
end

function Net.count(N)
    for i = 1, #N.syns do
        local s = N.syns[i]
        if s then
            if not s.neur[2] or not s.neur[1] then
                table.print(s)
                table.print(s.neur)
                print(debug.traceback())
                error"neur 2 error on Net.count"
            end 
            s.neur[2]:count()
        end
    end           
end

function Net.visual(N)
    for i = 1, #N.list do
        local n = N.list[i]
        n.y = n[locan]*12 + 200
        n.x = 10
        if n[layn] == 'inp' then
            n.x = 10
        elseif n[layn] == 'hid' then
            n.x = 60
        elseif n[layn] == 'out' then
            n.x = 110
        end
    end
    -- for i = 1, #N.syns do
    --     local s = N.syns[i]
    --     if not s then
    --         goto skip
    --     end
    --     local n = s.neur[1]
    --     if n then
    --         n.y = n[locan]*12 + 200
    --         n.x = 10
    --         if n[layn] == 'inp' then
    --             n.x = 10
    --         elseif n[layn] == 'hid' then
    --             n.x = 60
    --         elseif n[layn] == 'out' then
    --             n.x = 110
    --         end
    --     end
    --     n = s.neur[2]
    --     if n then
    --         n.y = n[locan]*12 + 200
    --         n.x = 10
    --         if n[layn] == 'inp' then
    --             n.x = 10
    --         elseif n[layn] == 'hid' then
    --             n.x = 60
    --         elseif n[layn] == 'out' then
    --             n.x = 110
    --         end
    --     end
    --     ::skip::
    -- end
end

function Net.spike(N)
    for layer in Net.traverse(N) do
        for i = 1, #layer do
            local neur = layer[i]
            if neur then
                neur:spike()
            end
        end
    end
end

Neuron = {
    inps = {};
    outs = {};
    bias = 0;
    out = 0;
}


function sigmoid(x)
    return 1/(1+exp(-x))
end

function square(x)
    return sigmoid(x*x)
end

function absolute(x)
    return sigmoid(x > 0 and x or -x)
end

function sine(x)
    return sigmoid(x > 0 and x or -x)
end

function linear(x)
    return x
end

function tanh(x)
    return (math.exp(x) - math.exp(-x)) / (math.exp(x) + math.exp(-x))
end

function ReLU(x)
    return sigmoid(x < 0 and 0 or x)
end

function Latch(x)
    return x == 0 and x or 0
end

function gaussian(mean)
    return sigmoid(sqrt(-2 * log(random()))*cos(2 * pi * random()) + mean)
end

Net.funcs = {
    [1] = sigmoid;
    [2] = Latch;
    [3] = sine;
    [4] = tanh;
    [5] = ReLU;
    [6] = gaussian;
    [7] = linear;
}



function Neuron.new(func, bias)
    return {
        inps = {};
        outs = {};
        active = true;
        out = 0;
        bias = bias or 0;
        func = func or sigmoid;
        x = 0;  -- for visual representations
        y = 0;
        count = Neuron.count;
        rebias = Neuron.rebias;
        reweight = Neuron.reweight;
        pushvalue = Neuron.pushvalue;
        spike = Neuron.spike;
    }
end

Neuron.decay = 0.9
Neuron.threshold = 0.2

function Neuron.copy(n, rn)
    rn = rn or Neuron.new(n.func, n.bias)
    return rn
end

function Neuron.rebias(a, v)
    local out = v
    a.bias = a.func(out)
end
local step = 0.25*Neuron.threshold
function Neuron.spike(a)
    local out = a.out
    if out > Neuron.threshold then
        out = out - step
    elseif out < Neuron.threshold then
        out = out + step
    else
        out = 0
    end
    a.out = out*Neuron.decay
end

function Neuron.pushvalue(n, v)
    n.bias = v
end

function Neuron.reweight(a, val)
    local inps = a.inps
    local out = 0
    for i = 1,  #inps do
        local syn = inps[i]
        syn:reweight(val)
    end
end

function Neuron.count(a)
    local inps = a.inps
    local out = 0
    for i = 1, #inps do
        local syn = inps[i]
        if syn.neur[1] then
            out = out + syn.neur[1].bias*syn.weight
        end
    end
    a.bias = a.func(out)
end



Synapse = {
    neur = {
        [1] = false;
        [2] = false;
    };
    weight = 0;
}

function Synapse.new(w)
    return {
        neur = {};
        weight = w or 1;
        connect = Synapse.connect;
        reweight = Synapse.reweight;
    }
end

function Synapse.copy(s, rs)
    rs = rs or Synapse.new()
    local n1, n2 = rs.neur[1] or Neuron.copy(s.neur[1]), r.neur[2] or Neuron.copy(s.neur[2])
    if n1 == nil then
        rs.neur[1] = n1
    end
    if n2 == nil then
        rs.neur[2] = n2
    end
    return rs
end

function Synapse.print(s)
    print(neur)
    print(s.neur[1], s.neur[2], s.weight)
end

function Synapse.reweight(s, val)
    s.weight = s.weight + val
end

function Synapse.connect(a, n, f)
    if type(n) ~= 'table' then
        print(debug.traceback())
        error"Neuron must be table!"
    end
    
    -- if a.neur[1] == n and a.neur[2] == n then
    --     print(debug.traceback())
    --     error("Neuron can't link to itself!")
    -- end
    -- if a.neur[1] == n or a.neur[2] == n then
    --     print(debug.traceback())
    --     error("Neuron already linked!")
    -- end
    a.neur[f] = n
    if f == 1 then
        n.outs[#n.outs+1] = a
    elseif f == 2 then
        n.inps[#n.inps+1] = a
    end
end



return Net;