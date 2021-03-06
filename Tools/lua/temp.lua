-- * onLoad :
function onLoad()
	il = {
		url = "https://infinitylayout.herokuapp.com/",
		grid = {
			base_y = 0.96,
			data = {},
			size = {
				24,
				24,
			},
			scale = {
				2,
				2,
				2,
			}
		},
		blocks = {
			["0"] = {
				name  = "Ground",
				color = {1, 1, 1},
				scale = {1, 0.1, 1}
			},
			["1"] = {
				name  = "Short Building",
				color = {0.7, 0.7, 0.7},
				scale = {1, 1, 1}
			},
			["2"] = {
				name  = "Tall Building",
				color = {0.55, 0.55, 0.55},
				scale = {1, 2, 1}
			},
			["s"] = {
				name  = "Scatter Terrain",
				color = {0.3, 0.3, 0.3},
				text  = "S",
				scale = {1, 0.1, 1}
			},
			["t"] = {
				name  = "Special Terrain",
				color = {0, 0.8, 0.1},
				text  = "T",
				scale = {1, 0.1, 1}
			},
			["1t"] = {
				name  = "Rooftop Vis Blocker",
				color = {0.45, 0.45, 0.45},
				scale = {1, 1.5, 1}
			},
			["2t"] = {
				name  = "Rooftop Vis Blocker",
				color = {0.35, 0.35, 0.35},
				scale = {1, 2.5, 1}
			},

		},
		objs = {},
	}
	drawGui()
end


-- * drawGui : 
function drawGui()
	self.clearButtons()
	self.createButton({
		click_function = "destroyGridObjects",
		function_owner = self,
		label          = "Clear",
		position       = {0, 0.1, 0.5},
		width          = 1500,
		height         = 300,
		font_size      = 280,
		color          = {0, 0, 0},
		font_color     = {1, 1, 1},
	})
	self.createButton({
		click_function = "getHtmlData",
		function_owner = self,
		label          = "Spawn Map",
		position       = {0, 0.1, -0.5},
		width          = 1500,
		height         = 300,
		font_size      = 280,
		color          = {0, 0, 0},
		font_color     = {1, 1, 1},
	})
end

-- * getHtmlData : 
function getHtmlData()
    WebRequest.get(il.url, function(request) 
    	if request.is_done then
    		il.grid.data = parseHtml(request.text)
    		startLuaCoroutine(self, "spawnGridObjects")
    	end
    end
    )
end
-- * parseHtml : 
	function parseHtml(html)
		--using string.gmatch was thrtowing an error about being too complex, so instead we
		--resorting to some hot-fudgery to extract the table from the returned html
		--log("Parsing html...")
		local t, f, r, c = {}, false, 0, 0
		for line in html:gmatch("([^\r\n]*)[\r\n]") do
			if string.match(line, "class=\"map\"") then f = true end
			if f then
				if string.match(line, "<tr") then
					--found a row, increment row count and reset cell count
					r = r + 1
					c = 0
					t[r] = {}
				end
				if string.match(line, "<td ") then
					--found a cell, add value
					c = c + 1
					t[r][c] = string.match(line, ">(.-)<"):lower()
				end
				if string.match(line, "</table>") then f = false end
			end
		end
		--log(t)
		return t
	end
	
-- * destroyGridObjects : 
function destroyGridObjects()
	if table.count(il.objs) > 0 then
		broadcastToAll("Clearing map...", "Orange")
		--log("Removing old objects")
		for _,obj in pairs(il.objs) do
			obj.destruct()
		end
		il.objs = {}
	end
	return true
end
-- * spawnGridObjects : 
function spawnGridObjects()
	local d = destroyGridObjects()
	for rk, r in ipairs(il.grid.data) do
		for ck, c in ipairs(r) do
			--log("Spawning tile type "..c.." at cell "..ck..":"..rk)
			spawnTile(c, {ck, rk})
			if ck % 2 == 0 then
				coroutine.yield(0)
			end
		end
	end
	broadcastToAll("Map spawned!", "Green")
	return 1
end

-- * spawnTile : 
function spawnTile(id, cell)
	local pos = cellToPosition(cell)
		  pos[2] = il.grid.base_y+((il.blocks[id].scale[2]*il.grid.scale[2])/2)
	local scale = {
		il.blocks[id].scale[1]*il.grid.scale[1],
		il.blocks[id].scale[2]*il.grid.scale[2],
		il.blocks[id].scale[3]*il.grid.scale[3],
	}

	--set cell color
	local color = il.blocks[id].color
	if cell[2] < 7 and (id == "0" or id == "s") then
		color = {1, 0, 0}
	elseif cell[2] > 18 and (id == "0" or id == "s") then
		color = {0, 0, 1}
	end

	local p = {
        type 			  = "BlockSquare",
        position          = pos,
        scale             = scale,
        sound             = false,
        callback_function = function(obj) 
        	--object spawn callback
        	
        	il.objs[obj.guid] = obj
        	obj.setLock(true)
        	obj.setColorTint(color)
        	obj.setName(il.blocks[id].name)

        	
        	--create button for tiles with text
        	if il.blocks[id].text then
        		obj.createButton({
					click_function = "btn_foo",
					function_owner = self,
					label          = il.blocks[id].text,
					position       = {0, 0.5+(0.1/il.blocks[id].scale[2]), 0},
					width          = 400,
					height         = 400,
					font_size      = 280,
					color          = {0.7,0.7,0.7,1},
					font_color     = {1, 1, 1},
					tooltip        = il.blocks[id].name,
        		})
        	end
        end
    }
    local o = spawnObject(p)
end
-- * btn_foo : 
function btn_foo(obj, color, alt)
	log(obj.guid)
	local cell = positionToCell(obj.getPosition())
	print("Cell "..cell[1]..":"..cell[2].." clicked")
end
-- * cellToPosition : 
function cellToPosition(c)
	if type(c)~="table" then return false end
	--log("coordsToPos({"..table.concat(c, ", ").."}, "..tostring(corner)..")")
	local start_x = 0 - (il.grid.size[1] * il.grid.scale[1]) / 2
	local start_z = 0 - (il.grid.size[2] * il.grid.scale[3]) / 2
	local pos_x   = start_x + (c[1] * il.grid.scale[1]) - (il.grid.scale[1]/2)
	local pos_z   = start_z + (c[2] * il.grid.scale[3]) - (il.grid.scale[3]/2)
	return {
		pos_x, il.grid.base_y, pos_z,
		x = pos_x, y = c[3], z = pos_z
	}
end
-- * positionToCell : 
function positionToCell(pos)
	if type(pos)~="table" then return false end
	local start_x = 0 - (il.grid.size[1] * il.grid.scale[1]) / 2
	local start_z = 0 - (il.grid.size[2] * il.grid.scale[3]) / 2
	local pos_x = math.floor((pos[1] - start_x) / il.grid.scale[1]) + 1
	local pos_z = math.floor((pos[3] - start_z) / il.grid.scale[3]) + 1
	return {pos_x, pos_z}
end
function table.count(t)
	local c = 0
	for _,_ in pairs(t) do
		c = c + 1
	end
	return c
end
