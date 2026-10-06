--[[
	Runs every offline suite (README-Technical → Offline Test Suites), each in its own
	interpreter and from the folder it expects: Features/Tests/ from the add-on root,
	Features/Restocker/Tests/ from Features/Restocker/. Exits 1 if any suite fails.

	Dev-only, like the suites: no TOC lists it and .pkgmeta strips Tests/.
	Run from the add-on root with Lua 5.1, the version WoW embeds: lua5.1 Tests/Run.lua
]]

-- The interpreter running this file, so every suite runs on the same Lua.
local LUA = arg and arg[-1] or "lua5.1"

local FOLDERS = {
	{ cwd = ".", folder = "Features/Tests" },
	{ cwd = "Features/Restocker", folder = "Tests" },
}

local function listSuites(cwd, folder)
	local suites = {}
	local pipe = assert(io.popen("cd " .. cwd .. " && ls " .. folder .. "/*-Test.lua"))
	for path in pipe:lines() do
		suites[#suites + 1] = path
	end
	pipe:close()
	return suites
end

-- os.execute answers 0 on Lua 5.1 and true on 5.2 and later.
local function succeeded(status)
	return status == 0 or status == true
end

local failed, ran = {}, 0
for _, entry in ipairs(FOLDERS) do
	for _, suite in ipairs(listSuites(entry.cwd, entry.folder)) do
		ran = ran + 1
		print(("== %s/%s"):format(entry.cwd, suite))
		if not succeeded(os.execute("cd " .. entry.cwd .. " && " .. LUA .. " " .. suite)) then
			failed[#failed + 1] = entry.cwd .. "/" .. suite
		end
	end
end

print()
if #failed > 0 then
	print(("%d of %d suites failed:"):format(#failed, ran))
	for _, suite in ipairs(failed) do
		print("  " .. suite)
	end
	os.exit(1)
end
print(("ALL %d SUITES PASSED"):format(ran))
