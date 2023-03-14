local Network = {
	mat = {}
}

function Network.new(inp, hid, out)
	local N = {
		mat = {};
	}
	for i = 1, inp + out do
		mat[i] = {}
	end
	mat.len = inp + out
	mat.inp = inp
	mat.out = out
	return N
end

function Network.addSynapse(N, weight)
	local mat = N.mat
	local arr = mat
	if mat.len <= #mat then
		mat.len = mat.len + 1
		mat[mat.len] = {}
	else
		mat[#mat+1] = {}
	end
end