local gpg = { key = 0 }

local function splitext(file)
	if file == nil then return nil, nil end
	local i = file:reverse():find('%.')
	if i == nil then return file, nil end
	return file:sub(0, -(i + 1)), file:sub(-i)
end

local function errpipe(file, cmd, p)
	local r = {start = 0, finish = 0}
	if file ~= nil then
		r = {start = 0, finish = file.size}
	else
		file = vis.win.file
	end

	local err, ostr, estr = vis:pipe(file, r, cmd)
	if p == true and err ~= 0 and estr ~= nil then
		vis:message(estr)
	end

	return err, ostr, estr
end

local function decrypt(file)
	local f, e = splitext(file.name)
	if e ~= '.gpg' then return end

	local err, ostr, estr = errpipe(file, "gpg -d", false)
	if err ~= 0 then return false end

	local i = estr:find("ID")
	local j = estr:find(",", i)
	local keyid = estr:sub(i+3, j-1)
	if keyid ~= gpg.key then
		vis:info(estr:gsub("\n[ ]*", " "))
		gpg.key = keyid
	end

	file:delete(0, file.size)
	file:insert(0, ostr)
	file.modified = false
	return true
end
vis.events.subscribe(vis.events.FILE_OPEN, decrypt)
vis.events.subscribe(vis.events.FILE_SAVE_POST, decrypt)

local function encrypt(file)
	local f, e = splitext(file.name)
	if e ~= '.gpg' then return end

	if gpg.key == 0 then
		vis:info('encrypt: keyid not found. file not saved.')
		return false
	end

	local tfn = os.tmpname()
	local cmd = "gpg --yes -o " .. tfn .. " -e -r " .. gpg.key
	local err = errpipe(file, cmd, true)
	if err ~= 0 then return false end

	local tf = io.open(tfn, 'rb')
	file:delete(0, file.size)
	file:insert(0, tf:read("a"))
	tf:close()
	os.remove(tfn)

	return true
end
vis.events.subscribe(vis.events.FILE_SAVE_PRE, encrypt)

vis:command_register("gpg-key", function()
	vis:info("gpg-key: " .. gpg.key)
end, "Echo the currently set key ID")

return gpg
