**What is this?**
This is a custom Roblox Lua thread scheduler. (Uses functions from Roblox)

**Notes**
None of this is tested and I'm not finished with it.

**Examples**

> local TaskExample = Task("Example", function(...) print(...) end end)
> 	Scheduler:Start(TaskExample, "Example") 	
>   Scheduler:Stop(TaskExample)
