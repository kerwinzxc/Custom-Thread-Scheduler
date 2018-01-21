local function Tuple(...)
	local r,n = {...},select("#",...)
	return function()
		return unpack(r, 1 ,n)
	end
end


local Scheduler = {
        Threads = {
                Running = {};
                Waiting = {};
        }; Fire = {};
        Events = {};
}