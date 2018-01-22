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
};
Queue = {};
Events = {};
}

local TaskScheduler do
	local taskMeta = {__tostring = function(s) return s.name end,__index function(s, k)
		if k:lower() == "start" then return Scheduler:Start(...) end
		if k:lower() == "stop" then return Scheduler:Stop(...) end
		return rawget(s, k:lower())
		end}
	function Task(Name, Func, ...)
		local Task = setmetatable({
			name = Name;
			c = false;
			status = "new", args = Tuple(...),
			thread = coroutine.create(Func)
			}, taskMeta)
			local function Wait(Time)
				local start, yes = tick()
				Scheduler.Threads.Waiting[Task] = true
				Task.status = "waiting"
					repeat local cy = coroutine.yield()
							yes = tick() - start
					until not cy and (Time or 0) < yes
					Task.status = "running"
					Scheduler.Threads.Waiting[Task] = nil
						return Time, elapsedtime()
					end
					setfenv(Func, setmetatable({wait = Wait, Wait = Wait}, {__index = getfenv(Func)}))
					return Task
			end
end

function Scheduler:CreateEvent(EventInfo)
local BEvent = Instance.new("BindableEvent")
self.Events[EventInfo] = BEvent.Event
self.Queue[EventInfo] = function(...) BEvent:Fire(...) end
end

function Scheduler:Update(EventInfo, ...)
self.Queue[EventInfo](...)
end

function Scheduler:Start(Task, ...)
if self.Threads.Running[Task] then warn(Task.." has already been started...") end
self.Threads.Running[Task] = Tuple(...)
Scheduler:Update("Started", Task)
end

function Scheduler:Stop(Task)
if self.Threads.Running[Task] then
  self.Threads.Running[Task] = nil
  Scheduler:Update("Stopped", Task, false)
	end
end

Scheduler:CreateEvent("Started")
Scheduler:CreateEvent("Stopped")
Scheduler:CreateEvent("Ran")

--[[
	Started: Fired whenever a task is started
			 Result: Started(Task)
	Stopped: Fired whenever someone stopped a task, or if the task ended.
			 When you stop a task it'll take a tick because it fires the event.
			 Result: Stopped(Task, ended)
	Ran: Fired when the task runs for the first time with the args that were passed along with it.
		 Result: Ran(Task, ...)
-]]


spawn(function()
	while true do
		for i,v in pairs(Scheduler.Threads.Running) do
			if coroutine.status(i.thread) == "dead" then
				Scheduler:Update("Stopped", i, true)
				Scheduler.Threads.Running[i] = nil
			elseif i.status == "running" then
				if not i.cy then i.cy = true
						print(tick(), "~Thread"..i.." is yielding C-sided")
					end
				else
						if i.status == "new" then
							i.status = "running"
							coroutine.resume(i.thread, v())
						else
							coroutine.resume(i.thread)
							end
							i.cy = false
						end
					end
				end
			wait()
		end
	end)
	