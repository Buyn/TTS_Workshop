-- * Global Var
counter = 0 
--Local positions for each pile of object
pos_inZone = {-0.957, 0.178, 0.222}
pos_outZone = {0.957, 0.178, 0.222}
pos_Zone_In = {1.3, 0.05, -0.9}
pos_Center_In = {1.3, 0.1, -0.8}
pos_Center_Out = {1.3, 0.05, 0.8}
zoneSize={2,2,2} --How large that Zone sphere is
-- index values
inputIndex = {}
labelName = "Name"
labelDis = "Dis"
--This is which way is face down for a card or deck relative to the tool
rot_offset = {x=0, y=0, z=180}



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
-- * findObjectsAtPosition : 
-- This is used by another function to locate information on what is in an area
function findObjectsAtPosition(localPos, poSize)
-- ** We convert that local position to a global table position
    local globalPos = self.positionToWorld(localPos)
-- ** list of hits raycast of a sphere : 
    --We then do a raycast of a sphere on that position to find objects there
    --It returns a list of hits which includes references to what it hit
    local objList = Physics.cast({
        origin=globalPos, --Where the cast takes place
        direction={0,1,0}, --Which direction it moves (up is shown)
        type=2, --Type. 2 is "sphere"
        -- size={2,2,2}, --How large that sphere is
				size= poSize,
        max_distance=1, --How far it moves. Just a little bit
        -- debug=false --If it displays the sphere when casting.
        debug=true --If it displays the sphere when casting.
    })
-- ** Now we return this to where it was called with the information
    return objList
-- ** end : 
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
-- ** objGuid : 
  local objGuid = collision_info.collision_object.getGUID()
	print(objGuid)
-- ** del
	-- print("colisen len =", #collision_info.contact_points) 
	-- print("zone IN coordinat")
	-- for k,v in pairs(self.positionToWorld(pos_inZone)) do
	-- 	print(k .. '=' .. v) 
	-- 	end
	-- spawnButton(pos_inZone)
	-- print("zone IN = ", counter)
-- ** spawnButton : 
	spawnButton(pos_Center_In)
	print("zone pos_Center_In = ", counter)
	spawnButton(pos_Center_Out)
	print("zone pos_Center_Out = ", counter)
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
-- ** contact_points : 
	-- spawnButton(self.positionToLocal(collision_info.contact_points[1]))
	local posL = {}
  for i=1,#collision_info.contact_points do
		posL = self.positionToLocal(collision_info.contact_points[i])
		-- print('Collision point G:', i, " = ", counter) 
		-- for k,v in pairs(collision_info.contact_points[i]) do
		-- 		print(k .. '=' .. v) 
		-- 		end
		-- for k,v in pairs(self.positionToLocal(collision_info.contact_points[i])) do
		-- 		print(k .. '=' .. v) 
		-- 		end
		posL.x = posL.x * (-1)
		-- posL.y = posL.y * (-1)
		-- posL.z = posL.z * (-1)
		spawnButton(posL)
		print('Collision point L:', i, " = ", counter) 
		end
-- ** updateInput : 
	local update = {value = collision_info.collision_object.getName()}
	updateInput("Name", update)
	local update = {value = collision_info.collision_object.getDescription()}
	updateInput("Dis", update)
-- ** function 	end : 
	end

function toLocalInvertXAverPoint(contactRec)
	 local posLT = {}
	 posLT.x = (contactRec[1].x + contactRec[2].x + contactRec[3].x + contactRec[4].x ) / 4
	 posLT.y = (contactRec[1].y + contactRec[2].y + contactRec[3].y + contactRec[4].y ) / 4
	 posLT.z = (contactRec[1].z + contactRec[2].z + contactRec[3].z + contactRec[4].z ) / 4
	local posLT = self.positionToLocal(collision_info.contact_points[i])
	return point 
end

-- * spawnButton : 
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

-- * spawnTest : 
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

-- * updateInput : 
function updateInput(index,update)
  if not inputIndex[index] then
    print("[ff0000]<Error>[ffffff] Can't toggle input [" .. index .. "] = ", inputIndex[index],"." )
		return
		end
  update.index = inputIndex[index]
  self.editInput(update)
  -- self.editInput({index = inputIndex[index], scale = {show and 0.5 or 0,show and 0.5 or 0,show and 0.5 or 0}})
	end

-- * setInputIndex : 
function setInputIndex (index)
	if not inputIndex[index] then
		-- self.createInput(input_parameters)
		inputIndex[index] = #self.getInputs() - 1
	else
		return inputIndex[index]
		end
	end
-- * getAllIn : 
function getAllIn()
	local objList = findObjectsAtPosition(pos_inZone, zoneSize)
	print(objList)
	end

-- * filterCardsDecks : 
function filterCardsDecks(objList)
    --Now we have objList which contains any and all objects in that area.
    --But we only want decks and cards. So we will create a new list
    local decksAndCards = {}
    --Then go through objList adding any decks/cards to our new list
    for _, obj in ipairs(objList) do
        if obj.hit_object.tag == "Deck" or obj.hit_object.tag == "Card" then
            table.insert(decksAndCards, obj.hit_object)
			end
		end
	end
