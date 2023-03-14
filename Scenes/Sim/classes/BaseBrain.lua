-- BaseBrain.lua
Net = require"Scenes/Sim/classes/Neuronet"
local brain = Net.new(7,0,4)

for i = 1, #brain.inp do
    brain.inp[i].func = Net.funcs[1]
end
brain.out[1].func = Net.funcs[4]
brain.out[2].func = Net.funcs[4]
-- brain.out[3].func = Net.funcs[1]

Net.addSynapse(brain, brain.inp[2], brain.out[1])
Net.addSynapse(brain, brain.inp[3], brain.out[2])
Net.addSynapse(brain, brain.inp[7], brain.out[1])

brain.syns[1].weight = 0.5
brain.syns[2].weight = 1.5

return brain