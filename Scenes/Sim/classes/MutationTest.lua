-- MutationTest.lua

local Net = require"Scenes/Sim/classes/Neuronet"

local Bb = require"Scenes/Sim/classes/BaseBrain"
math.randomseed(os.time())
local t = Net.clone(Bb)
local a = {}
for i = 1, 100 do
    a[i] = Net.clone(t)
    Net.randomSynapses(t)
end
while true do
    for i = 1, 100 do
        Net.mutate(a[i])
        for j = 1, 7 do 
            a[i].inp[j]:pushvalue(math.random())
        end
        Net.count(a[i])
    end
end