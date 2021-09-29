-- * Global Var
-- counters
counter = 0 
debugCount = 0
--Local positions for each pile of object
pos_Center_In = {1.3, 0.1, -0.8}
pos_Center_Out = {1.3, 0.05, 0.8}
--How large that Zone is
radiusInZone = 0.7
radiusOutZone = 0.7
-- index values
inputIndex = {}
labelName = "Name"
labelDis = "Dis"
--This is which way is face down for a card or deck relative to the tool
rot_offset = {x=0, y=0, z=180}
-- last Ids
lastInGUID = nil
lastOutGUID = nil



-- * onLoad : 
-- Creates invisible button onload, hidden under the "REFILL" on the deck pad
function onLoad()
-- ** createButton : 
-- *** comment
    -- self.createButton({
    --     click_function="click_refillDeck", function_owner=self,
    --     position={0,0.1,-1.12}, height=200, width=620, color={1,1,1,0}
    -- })
	-- local data = {click_function = "INSERT_FUNCTION", function_owner = self, label = "In", position = {0.3, 0.05, -1.3}, scale = {0.5, 0.5, 0.5}, width = 700, height = 700, font_size = 300, color = {0, 1, 0.0632, 1}, font_color = {0.7573, 0.7573, 0.7573, 1}}
	-- local data = {click_function = "INSERT_FUNCTION", function_owner = self, label = "In", position = {0.3, 0.05, -1.3}, scale = {0.5, 0.5, 0.5}, width = 700, height = 700, font_size = 300, color = {0.8484, 0.6339, 0, 0.4}, font_color = {0, 0, 0, 10}}
-- *** createButton In : 
	local data = {  click_function = "printFunction", 
					function_owner = self,
					label = "In",
					position = {0.3, 0.05, -1.3},
					scale = {0.5, 0.5, 0.5},
					width = 700, height = 700,
					color={1,1,1,0},
					font_size = 300,
					}
    self.createButton(data)
-- *** createButton Out : 
	local data = {  click_function = "printFunction", 
					function_owner = self, 
					label = "Out", 
					position = {0.3, 0.05, 1.3}, 
					scale = {0.5, 0.5, 0.5},
					width = 700,
					height = 700,
					color={1,1,1,0},
					font_size = 300
					}
    self.createButton(data)
-- ** createInput Name : 
  local data = {
					input_function = "nilFunction", 
					function_owner = self, 
					label = label, 
					position = {-1, 0.05, -1.5}, 
					scale = {0.2, 0.2, 0.2}, 
					width = 5000, height = 500, 
					font_size = 400, 
					color={0.8, 0.6, 0, 0.4},
					font_color = {0, 0, 0, 10},
					tooltip = "Name", 
					value = "Name"
					}
  nameFilde = self.createInput(data)
	setInputIndex(labelName)
-- ** createInput Dis : 
  local data = {
					input_function = "nilFunction", 
					function_owner = self, 
					label = label, 
					position = {-1, 0.05, 0.1}, 
					scale = {0.2, 0.2, 0.2}, 
					width = 5000, 
					height = 7000, 
					font_size = 200, 
					color={0.8, 0.6, 0, 0.4},
					font_color = {0, 0, 0, 10},
					value = "Discription go Here"
					}					
    discField = self.createInput(data)
		setInputIndex(labelDis)
    --This is how I found the positions to check for cards
    --That GUID was a card I put on it
    --local pos = self.positionToLocal(getObjectFromGUID("a6b1bd").getPosition())
    --print(pos.x)
    --print(pos.y)
    --print(pos.z)

-- ** end : 
end


-- * nilFunction : 
function nilFunction() return end
-- * printFunction : 
function printFunction(text)
	print("hi! - ", text )
	end
-- * onCollisionEnter : 
function onCollisionEnter(collision_info)
-- ** comment
  -- collision_info table:
  --   collision_object    Object
  --   contact_points      Table     {Vector, ...}
  --   relative_velocity   Vector
-- ** if nil : 
  if collision_info.collision_object == nil
  or collision_info.collision_object == self
  or collision_info.collision_object.getGUID() == nil
  or collision_info.collision_object.tag == "Surface"
  or objectLoaded
  then
    return
		end
-- ** debugPrint : 
	 -- debugPrint()
	-- visulZonsDebug(collision_info)
-- ** isInZone : 
	local contactLocalPos = toLocalInvertXAverPoint(collision_info.contact_points)
	if isInZone(contactLocalPos) then
		local update = {value = collision_info.collision_object.getName()}
		updateInput("Name", update)
		local update = {value = collision_info.collision_object.getDescription()}
		updateInput("Dis", update)
		lastInGUID = collision_info.collision_object.getGUID()
		-- print ("In Zone!!!")
		return
-- ** isOutZone : 
	elseif isOutZone(contactLocalPos)  then
		-- print ("OUT!!!")
		collision_info.collision_object.setName(self.getInputs()[inputIndex[labelName]+1].value)
		collision_info.collision_object.setDescription(self.getInputs()[inputIndex[labelDis]+1].value)
		lastOutGUID = collision_info.collision_object.getGUID()
		return
		end
-- ** function 	end : 
	end

-- * Zone Functions : 
-- ** isInZone : 
function isInZone(point)
	 if getDistant(point, pos_Center_In) < radiusInZone then
		 return true	
	 end
	 return false
end

-- ** isOutZone : 
function isOutZone(point)
	 if getDistant(point, pos_Center_Out) < radiusOutZone then
		 return true	
	 end
	 return false
end

-- ** getDistant : 
function getDistant(point1, point2)
	-- print("Distance in")
	local xDistance = math.abs(point1[1] - point2[1])
	local zDistance = math.abs(point1[3] - point2[3])
	local distance = xDistance^2 + zDistance^2
	-- print("Distance out")
	return math.sqrt(distance)
end

-- ** toLocalInvertXAverPoint : 
function toLocalInvertXAverPoint(contactRec)
	local point = contactRec[1]
  for i=1 , 3 do
		local sum = 0
		for y = 1 ,#contactRec do
			 sum = sum + contactRec[y][i]
				end
		point[i] = sum / 4 
		end
	point = self.positionToLocal(point)
	point[1] = point[1] * (-1)
	return point
end

-- * Debug Functions : 
-- ** debugPrint : 
function debugPrint()
	print("function #", debugCount)
	debugCount = debugCount + 1
	-- print( debug.traceback("Stack trace"))
	end

-- ** spawnButton : 
function spawnButton(pos)
	counter = counter + 1
	local data = {    click_function = "+", 
										function_owner = self,
										label = counter,
										position = pos,
										scale = {0.5, 0.5, 0.5},
										width = 100, height = 100,
										-- color={1,1,1,0},
										font_size = 300,
										}
  self.createButton(data)
	end

-- ** spawnTest : 
function spawnTest(pos)
	local params = {} 
	params.type = '3DText' 
	-- params.type = 'go_game_piece_black' 
	params.position = pos 
	params.rotation = {0, 0, 0} 
	params.scale = {0, 0, 0} 
	-- params.callback = 'myCallbackFunction' 
	params.callback_owner = Global
	params.snap_to_grid = false
  params.params = {  
							-- sPlayer = sPlayer,
							-- iFontSize = 110,
							-- vRotation = vRot
								sText = 'HI!'
	    	}
	-- params.params = {'myCallbackParams1', 'myCallbackParams2'}
	spawnObject(params)
	end

-- ** visulZonsDebug : 
function visulZonsDebug(collision_info)
-- *** objGuid : 
  local objGuid = collision_info.collision_object.getGUID()
	print(objGuid)
-- *** del
	-- print("colisen len =", #collision_info.contact_points) 
	-- print("zone IN coordinat")
	-- for k,v in pairs(self.positionToWorld(pos_inZone)) do
	-- 	print(k .. '=' .. v) 
	-- 	end
	-- spawnButton(pos_inZone)
	-- print("zone IN = ", counter)
-- *** spawnButton : 
	spawnButton(pos_Center_In)
	print("zone pos_Center_In = ", counter)
	spawnButton(pos_Center_Out)
	print("zone pos_Center_Out = ", counter)
-- ***  del : 
	-- findObjectsAtPosition(pos_inZone, zoneSize)
	-- print("zone OUT coordinat")
	-- for k,v in pairs(self.positionToWorld(pos_outZone)) do
	-- 	print(k .. '=' .. v) 
	-- 	end
	-- spawnButton(pos_outZone)
	-- print("zone pos_outZone = ", counter)
	-- print('Collision point:') 
	-- for k,v in pairs(collision_info.contact_points[1]) do
	-- 	print(k .. '=' .. v) 
	-- 	end
	-- spawnButton(self.positionToLocal(collision_info.contact_points[1]))
	-- local posL = {}
  -- for i=1,#collision_info.contact_points do
	-- 	posL = self.positionToLocal(collision_info.contact_points[i])
		-- print('Collision point G:', i, " = ", counter) 
		-- for k,v in pairs(collision_info.contact_points[i]) do
		-- 		print(k .. '=' .. v) 
		-- 		end
		-- for k,v in pairs(self.positionToLocal(collision_info.contact_points[i])) do
		-- 		print(k .. '=' .. v) 
		-- 		end
		-- posL.x = posL.x * (-1)
		-- posL.y = posL.y * (-1)
		-- posL.z = posL.z * (-1)
		-- spawnButton(posL)
		-- print('Collision point L:', i, " = ", counter) 
		-- end
-- *** toLocalInvertXAverPoint : 
	local contactLocalPos = toLocalInvertXAverPoint(collision_info.contact_points)
	spawnButton(contactLocalPos)
	print('Collision point = ', counter) 
	print('Distant to In zone ', getDistant(contactLocalPos, pos_Center_In)) 
	print('Distant to Out zone ', getDistant(contactLocalPos, pos_Center_Out)) 
end

-- * Input fild Functions : 
-- ** updateInput : 
function updateInput(index,update)
  if not inputIndex[index] then
    print("[ff0000]<Error>[ffffff] Can't toggle input [" .. index .. "] = ", inputIndex[index],"." )
		return
		end
  update.index = inputIndex[index]
  self.editInput(update)
  -- self.editInput({index = inputIndex[index], scale = {show and 0.5 or 0,show and 0.5 or 0,show and 0.5 or 0}})
	end

-- ** setInputIndex : 
function setInputIndex (index)
	if not inputIndex[index] then
		-- self.createInput(input_parameters)
		inputIndex[index] = #self.getInputs() - 1
	else
		return inputIndex[index]
		end
	end
