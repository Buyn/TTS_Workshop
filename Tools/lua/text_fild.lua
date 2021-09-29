-- * global vars
dev = false

local editingObject = nil

local savedButtons = {}
local buttonIndex = {}
local inputIndex = {}
local currentEdit = 0
local totalButtons = 0
local default_values = {
  type = "Button",
  input_function = "nilFunction",
  click_function = "nilFunction",
  function_owner = self,
  label = "Ipso Facto",
  position = {0,0,0},
  rotation = {0,0,0},
  scale = {0.5,0.5,0.5},
  width = 2000,
  height = 400,
  font_size = 400,
  color = {1,1,1,1},
  font_color = {0,0,0,1},
  tooltip = "",
  alignment = 1,
  value = "",
  validation = 1
}
local increment_value = {
  position = 0.1, rotation = 10, scale = 0.1, dimension = 100
}

-- * onLoad : 
function onLoad(save_state)
  local button = {click_function = 'devFunction', function_owner = self,
  label = 'Ipso Facto', position = {x = 0, y = 1, z = 4},
  scale = {x = 0.5, y = 1, z = 0.5}, width = 2000, height = 400, font_size = 400}
  self.createButton(button)

  button = {click_function = 'devFunction2', function_owner = self,
  label = 'Ipso Facto', position = {x = 0, y = 1, z = 5},
  scale = {x = 0.5, y = 1, z = 0.5}, width = 2000, height = 400, font_size = 400}
  self.createButton(button)

  mainMenu()
end

-- * newButton : 
function newButton()
  totalButtons = totalButtons + 1
  currentEdit = totalButtons
  savedButtons[currentEdit] = table.clone(default_values)
  savedButtons[currentEdit].index = currentEdit - 1
end
-- * onCollisionEnter : 
function onCollisionEnter(collision_info)
  -- collision_info table:
  --   collision_object    Object
  --   contact_points      Table     {Vector, ...}
  --   relative_velocity   Vector
  if collision_info.collision_object == nil
  or collision_info.collision_object == self
  or collision_info.collision_object.getGUID() == nil
  or collision_info.collision_object.tag == "Surface"
  or objectLoaded
  then
    return
	end
  local objGuid = collision_info.collision_object.getGUID()
  editInput("guid_input", {value = objGuid})
  GUIDInput(objGuid)
end
-- * copyExistingValues : 
function copyExistingValues(v)

  if v.label ~= nil then
    savedButtons[currentEdit].label = v.label
  else
    savedButtons[currentEdit].label = " "
  end

  if v.click_function ~= nil then
    savedButtons[currentEdit].click_function = v.click_function
  end
  if v.input_function ~= nil then
    savedButtons[currentEdit].input_function = v.input_function
  end

  savedButtons[currentEdit].position[1] = v.position[1]
  savedButtons[currentEdit].position[2] = v.position[2]
  savedButtons[currentEdit].position[3] = v.position[3]

  savedButtons[currentEdit].rotation[1] = v.rotation[1]
  savedButtons[currentEdit].rotation[2] = v.rotation[2]
  savedButtons[currentEdit].rotation[3] = v.rotation[3]

  savedButtons[currentEdit].scale[1] = v.scale[1]
  savedButtons[currentEdit].scale[2] = v.scale[2]
  savedButtons[currentEdit].scale[3] = v.scale[3]

  savedButtons[currentEdit].width = v.width
  savedButtons[currentEdit].height = v.height
  savedButtons[currentEdit].font_size = v.font_size

  savedButtons[currentEdit].color = v.color

  savedButtons[currentEdit].font_color = v.font_color

  savedButtons[currentEdit].tooltip = v.tooltip
  savedButtons[currentEdit].alignment = v.alignment
  if v.validation ~= nil then
    savedButtons[currentEdit].validation = v.validation
  end
  if v.value ~= nil then
    savedButtons[currentEdit].value = v.value
  end
end
-- * loadObject : 
function loadObject()
  self.clearInputs()
  self.clearButtons()

  editingObject.highlightOn({1,1,0})
  local buttons = editingObject.getButtons()
  if buttons ~= nil then
    for k,v in pairs(buttons) do
      newButton()
      copyExistingValues(v)
    end
  end

  local inputs = editingObject.getInputs()
  if inputs ~= nil then
    for k,v in pairs(inputs) do
      newButton()
      copyExistingValues(v)
    end
  end

  if currentEdit == 0 then
    newButton()
  end

  createLabelButtons({-6.5,0.15,-2.5})

  buttonSelection({-6.5,0.15,2.25})

  createPositionButtons({-5.5,0.15,-0.5})
  createRotationButtons({-5.5+4,0.15,-0.5})
  createScaleButtons({-5.5+8,0.15,-0.5})

  createDimensionButtons({-3.5,0.15,1})

  createColorButton({0.5,0.15,1})
  createFontColorButton({3.5,0.15,1})

  exitButton({7.3,0.15,-2.5})

  updateValues()

  updateObject()
  objectLoaded = true
end
-- * updateObject : 
function updateObject()
  editingObject.clearButtons()
  editingObject.clearInputs()

  for k,v in pairs(savedButtons) do
    if v.type == "Button" then
      editingObject.createButton(v)
    else
      editingObject.createInput(v)
    end
  end
end

-- * exitButton : 
function exitButton(pos)
  if not pos.x then pos.x = pos[1] end
  if not pos.y then pos.y = pos[2] end
  if not pos.z then pos.z = pos[3] end

  createButton("exit_label", "X", {pos.x,pos.y,pos.z}, {font_color = {1,0,0}})

  createButton("exit_button", "X", {pos.x,pos.y,pos.z}, {color = {0,0,0,0}, width=400, height=400, tooltip="Exit and Clear Object", click_function = dynamicFunction("exitClick", function()
    exit()
  end)})
end
-- * mainMenu : 
-- ** mainMenu : 
function mainMenu()
  self.clearInputs()
  self.clearButtons()

  createButton("name_label", "Button Visualizer", {0,0.15,-1.2}, {font_size = 1000, scale = {1,1,1}})
  createButton("author_label", "By GiantDwarf01", {0,0.15,0}, {scale = {1,1,1}})

  createInput("guid_input", "GUID", {0,0.15,2}, {input_function = dynamicFunction("setGUID", function(obj, player, input_value, sel)
    GUIDInput(input_value)
  end), width = 2000})
end

-- ** GUIDInput : 
function GUIDInput(guid)
  if string.sub(guid,-string.len('\n')) == '\n' then
    local trueGUID = string.sub(guid,0,6)
    if getObjectFromGUID(trueGUID) ~= nil and getObjectFromGUID(trueGUID) ~= self then
      setObject(trueGUID)
      return
    end
  end
  if getObjectFromGUID(guid) == nil or getObjectFromGUID(guid) == self then
    createButton("load_label", "Edit Object", {0,0.15,2.5}, {scale = {0,0,0}})
  else
    createButton("load_label", "Edit Object", {0,0.15,2.5}, {font_color = {0,0,0,1}, scale = {0.5,0.5,0.5}, width = 2000, height = 400, click_function = dynamicFunction("setObjectGUID", function()
      setObject(guid)
    end)})
  end
end

-- ** setObject : 
function setObject(guid)
  if getObjectFromGUID(guid) == nil then
    return
  end

  editingObject = getObjectFromGUID(guid)
  loadObject()
end

-- ** exit : 
function exit()
  if editingObject ~= nil then
    editingObject.clearButtons()
    editingObject.clearInputs()
    editingObject.highlightOff()
  end
  editingObject = nil
  savedButtons = {}
  buttonIndex = {}
  inputIndex = {}
  currentEdit = 0
  totalButtons = 0
  if colorItem ~= nil then
    colorItem.destruct()
    colorItem = nil
  end
  if colorFontItem ~= nil then
    colorFontItem.destruct()
    colorFontItem = nil
  end
  objectLoaded = false
  mainMenu()
end

-- * update : 
-- ** updateValues : 
function updateValues()
  local curButton = savedButtons[currentEdit]
  if curButton.label ~= getInputValue('input_label') then
    local fixedString = string.gsub(curButton.label, "(\n)", " ")
    if string.len(fixedString) > 34 then
      fixedString = string.sub(fixedString, 0, 31) .. "..."
    end
    editInput("input_label", {label = fixedString, value = fixedString, position = {-2.5,0.15,-2.5}, height = 380})
  end
  if curButton.tooltip ~= getInputValue('tooltip_input') then
    editInput('tooltip_input',{value = curButton.tooltip})
  end

  if curButton.position[1] ~= tonumber(getInputValue('position_x_input')) then
    editInput('position_x_input',{value = curButton.position[1]})
  end
  if curButton.position[2] ~= tonumber(getInputValue('position_y_input')) then
    editInput('position_y_input',{value = curButton.position[2]})
  end
  if curButton.position[3] ~= tonumber(getInputValue('position_z_input')) then
    editInput('position_z_input',{value = curButton.position[3]})
  end


  if curButton.rotation[1] ~= tonumber(getInputValue('rotation_x_input')) then
    editInput('rotation_x_input',{value = curButton.rotation[1]})
  end
  if curButton.rotation[2] ~= tonumber(getInputValue('rotation_y_input')) then
    editInput('rotation_y_input',{value = curButton.rotation[2]})
  end
  if curButton.rotation[3] ~= tonumber(getInputValue('rotation_z_input')) then
    editInput('rotation_z_input',{value = curButton.rotation[3]})
  end


  if curButton.scale[1] ~= tonumber(getInputValue('scale_x_input')) then
    editInput('scale_x_input',{value = curButton.scale[1]})
  end
  if curButton.scale[2] ~= tonumber(getInputValue('scale_y_input')) then
    editInput('scale_y_input',{value = curButton.scale[2]})
  end
  if curButton.scale[3] ~= tonumber(getInputValue('scale_z_input')) then
    editInput('scale_z_input',{value = curButton.scale[3]})
  end

  if curButton.width ~= tonumber(getInputValue('dimension_x_input')) then
    editInput('dimension_x_input',{value = curButton.width})
  end
  if curButton.height ~= tonumber(getInputValue('dimension_y_input')) then
    editInput('dimension_y_input',{value = curButton.height})
  end
  if curButton.font_size ~= tonumber(getInputValue('dimension_z_input')) then
    editInput('dimension_z_input',{value = curButton.font_size})
  end

  selectValidation(curButton.validation)
  selectAlignment(curButton.alignment)
  toggleType(curButton.type)

  local fixedString = string.gsub(savedButtons[currentEdit].label, "(\n)", " ")
  if string.len(fixedString) > 22 then
    fixedString = string.sub(fixedString, 0, 19) .. "..."
  end
  editButton("select_button", {label = currentEdit ..' - '.. fixedString})
  updateObject()
end

local dropPos = nil
-- ** buttonSelection : 
function buttonSelection(pos)
  if not pos.x then pos.x = pos[1] end
  if not pos.y then pos.y = pos[2] end
  if not pos.z then pos.z = pos[3] end

  dropPos = pos

  createButton("select_label", "Editing:", {pos.x,pos.y,pos.z})
  createButton("select_button",currentEdit ..' - '..savedButtons[currentEdit].label, {pos.x+3.5,pos.y,pos.z}, {font_color={0,0,0},width=5000, height=400, click_function=dynamicFunction("showButton", function()
    showButtonSelect()
  end)})

  createButton("add_new_button","+", {pos.x+6.5,pos.y,pos.z}, {tooltip="Add New", font_color={0,0,0},width=400, height=400, click_function=dynamicFunction("addButton", function()
    if selectionShown then
      hideButtonSelect()
    end
    newButton()
    updateValues()
  end)})
  createButton("remove_button","Reset", {pos.x+7.4,pos.y,pos.z}, {tooltip = "Reset Current Values", font_color={0,0,0},width=1000, height=400, click_function=dynamicFunction("deleteButton", function()
    savedButtons[currentEdit] = table.clone(default_values)
    savedButtons[currentEdit].index = currentEdit - 1
    updateValues()
  end)})

  createButton("export_button","Export Data", {pos.x+12.5,pos.y,pos.z+0.2}, {tooltip="Export Current Data", font_color={0,0,0},width=2500, height=400, click_function=dynamicFunction("exportButton", function()
    local pos = self.getPosition()
    pos.x = pos.x+15
    exportData(pos,currentEdit)
  end)})
  createButton("export_all_button","Export All", {pos.x+12.5,pos.y,pos.z-0.2}, {tooltip="Export All Data", font_color={0,0,0},width=2500, height=400, click_function=dynamicFunction("exportAllButton", function()
    local pos = self.getPosition()
    pos.x = pos.x+15
    local center = pos.z
    for k,v in pairs(savedButtons) do
      pos.z = center - (k - math.ceil(totalButtons/2))
      pos.y = pos.y + 0.15
      exportData(pos, k)
    end
  end)})

  createButton("copy_button","Copy Data", {pos.x+9.5,pos.y,pos.z+0.2}, {font_color={0,0,0},width=2500, height=400, click_function=dynamicFunction("copyButton", function()
    copyData()
  end)})
  createButton("paste_button","Paste Data", {pos.x+9.5,pos.y,pos.z-0.2}, {font_color={0,0,0},width=2500, height=400, click_function=dynamicFunction("pasteButton", function()
    pasteData()
  end)})

  clipboard = table.clone(default_values)
end

local clipboard = {}
-- ** copyData : 
function copyData()
 clipboard = table.clone(savedButtons[currentEdit])
 printToAll("Saved to clipboard", {1,1,0})
end
-- ** pasteData : 
function pasteData()
  savedButtons[currentEdit] = table.clone(clipboard)
  printToAll("Pasted from clipboard", {1,1,0})
  updateValues()
end

local default_data = {
  width=100,
  height=100,
  font_size=100,
  position={0,0,0},
  rotation={0,0,0},
  scale={1,1,1},
  color={1,1,1,1},
  font_color={0,0,0,1},
  tooltip="",
  alignment=1,
  value="",
  validation=1
}
-- ** exportData : 
function exportData(pos,card)
  local data = savedButtons[card]
  local note = spawnObject({type = 'Notecard'})
  note.setPosition(pos)
  note.setName("("..data.type..") " .. card .. " - " .. string.gsub(data.label, "(\n)", "\\n"))

  local str = "local data = {"
  if data.type == "Button" then
    str = str .. "click_function = \"INSERT_FUNCTION\""
  elseif data.type == "Input" then
    str = str .. "input_function = \"INSERT_FUNCTION\""
  end
  str = str .. ", function_owner = self"
  str = str .. ", label = \"" .. string.gsub(data.label, "(\n)", "\\n") .. '"'

  if not table.equals(data.position,default_data.position) then
    str = str .. ", position = {" .. data.position[1]
    str = str .. ", " .. data.position[2]
    str = str .. ", " .. data.position[3] .. "}"
  end

  if not table.equals(data.rotation,default_data.rotation) then
    str = str .. ", rotation = {" .. data.rotation[1]
    str = str .. ", " .. data.rotation[2]
    str = str .. ", " .. data.rotation[3] .. "}"
  end

  if not table.equals(data.scale,default_data.scale) then
    str = str .. ", scale = {" .. data.scale[1]
    str = str .. ", " .. data.scale[2]
    str = str .. ", " .. data.scale[3] .. "}"
  end

  if tonumber(data.width) ~= tonumber(default_data.width) then
    str = str .. ", width = " .. data.width
  end
  if tonumber(data.height) ~= tonumber(default_data.height) then
    str = str .. ", height = " .. data.height
  end
  if tonumber(data.font_size) ~= tonumber(default_data.font_size) then
    str = str .. ", font_size = " .. data.font_size
  end

  if not table.equals(data.color,default_data.color) then
    str = str .. ", color = {" .. roundValue(data.color[1])
    str = str .. ", " .. roundValue(data.color[2])
    str = str .. ", " .. roundValue(data.color[3])
    str = str .. ", " .. roundValue(data.color[4]) .. "}"
  end

  if not table.equals(data.font_color,default_data.font_color) then
    str = str .. ", font_color = {" .. roundValue(data.font_color[1])
    str = str .. ", " .. roundValue(data.font_color[2])
    str = str .. ", " .. roundValue(data.font_color[3])
    str = str .. ", " .. roundValue(data.font_color[4]) .. "}"
  end

  if data.tooltip ~= default_data.tooltip then
    str = str .. ", tooltip = \"" .. string.gsub(data.label, "(\n)", "\\n") .. "\""
  end

  if data.alignment ~= default_data.alignment then
    str = str .. ", alignment = " .. data.alignment
  end

  if data.type == "Input" then
    if data.value ~= default_data.value then
      str = str .. ", value = \"" .. string.gsub(data.label, "(\n)", "\\n") .. "\""
    end
    if data.validation ~= default_data.validation then
      str = str .. ", validation = " .. data.validation
    end
  end

  str = str .. "}"
  note.setDescription(str)
end
-- ** table.equals : 
function table.equals(a,b)
  if a[1] ~= b[1] then return false end
  if a[2] ~= b[2] then return false end
  if a[3] ~= b[3] then return false end
  if a[4] ~= b[4] then return false end
  return true
end


colorItem = nil
colorFontItem = nil
-- ** createColorButton : 
function createColorButton(pos)
  if not pos.x then pos.x = pos[1] end
  if not pos.y then pos.y = pos[2] end
  if not pos.z then pos.z = pos[3] end

  createButton("color_label", "Color", {pos.x,pos.y,pos.z})
  createButton("color_alpha_label", "Alpha", {pos.x-0.3,pos.y,pos.z+0.3}, {scale = {0.2,0.2,0.2}})
  createInput("color_alpha_input", "100%", {pos.x+0.4,pos.y,pos.z+0.3}, {scale = {0.2,0.2,0.2}, validation = 3, input_function = dynamicFunction("setAlphaColor", function(obj, player, input_value)
    if input_value == "" then
      input_value = 100
    end
    savedButtons[currentEdit].color[4] = tonumber(input_value)/100
  end)})

  colorItem = spawnObject({type = 'reversi_chip'})
  colorItem.setName("Color")
  colorItem.setRotation(self.getRotation())
  colorItem.setPosition(self.positionToWorld({pos.x*-1-1.2, pos.y+0.1, pos.z + 0.1}))
  local sca = self.getScale()
  colorItem.setScale({sca.x*0.5,0.1,sca.z*0.5})

  local button = {}
  button.click_function = "applyColor"
  button.function_owner = self
  button.width = 1200
  button.height = 400
  button.font_size = 400
  button.scale = {0.5,0.5,0.5}
  button.font_color = {0,0,0}
  button.label = 'Apply'
  button.position = {0,0.1,0}
  colorItem.createButton(button)
end
-- ** applyColor : 
function applyColor()
  local color = colorItem.getColorTint()
  color.a = savedButtons[currentEdit].color[4]
  savedButtons[currentEdit].color = color
  savedButtons[currentEdit].color[4] = savedButtons[currentEdit].color.a

  updateObject()
end
-- ** createFontColorButton : 
function createFontColorButton(pos)
  if not pos.x then pos.x = pos[1] end
  if not pos.y then pos.y = pos[2] end
  if not pos.z then pos.z = pos[3] end

  createButton("font_color_label", "Font Color", {pos.x,pos.y,pos.z}, {scale = {0.4,0.4,0.4}})
  createButton("font_color_alpha_label", "Alpha", {pos.x-0.3,pos.y,pos.z+0.3}, {scale = {0.2,0.2,0.2}})
  createInput("font_color_alpha_input", "100%", {pos.x+0.4,pos.y,pos.z+0.3}, {scale = {0.2,0.2,0.2}, validation = 3, input_function = dynamicFunction("setAlphaFontColor", function(obj, player, input_value)
    if input_value == "" then
      input_value = 100
    end
    savedButtons[currentEdit].font_color[4] = tonumber(input_value)/100
  end)})

  colorFontItem = spawnObject({type = 'reversi_chip'})
  colorFontItem.setName("Font Color")
  colorFontItem.setRotation(self.getRotation())
  colorFontItem.setPosition(self.positionToWorld({pos.x*-1-1.2, pos.y+0.1, pos.z + 0.1}))
  local sca = self.getScale()
  colorFontItem.setScale({sca.x*0.5,0.1,sca.z*0.5})

  local button = {}
  button.click_function = "applyFontColor"
  button.function_owner = self
  button.width = 1200
  button.height = 400
  button.font_size = 400
  button.scale = {0.5,0.5,0.5}
  button.font_color = {0,0,0}
  button.label = 'Apply'
  button.position = {0,0.1,0}
  colorFontItem.createButton(button)
end
-- ** applyFontColor : 
function applyFontColor()
  local color = colorFontItem.getColorTint()
  color.a = savedButtons[currentEdit].font_color[4]
  savedButtons[currentEdit].font_color = color
  savedButtons[currentEdit].font_color[4] = savedButtons[currentEdit].font_color.a

  updateObject()
end

-- ** setInput : 
function setInput(input_value, pos, selected)
  if input_value == "" then
    input_value = "Ipso Facto"
  end

  local count = select(2, string.gsub(input_value,"(\n)","%1"))
  local modZ = 0.18*count

  if selected then
    editInput("input_label", {label = input_value, value = input_value, position = {pos.x+4, pos.y, pos.z - modZ}, height = 380+350*(count)})
  else
    local fixedString = string.gsub(input_value, "(\n)", " ")
    if string.len(fixedString) > 34 then
      fixedString = string.sub(fixedString, 0, 31) .. "..."
    end
    editInput("input_label", {label = fixedString, position = {pos.x+4, pos.y, pos.z}, height = 380})
  end
  savedButtons[currentEdit].label = input_value
  updateValues()
end
-- ** setTooltipInput : 
function setTooltipInput(input_value, pos, selected)
  if input_value == "" then
    input_value = ""
  end

  local count = select(2, string.gsub(input_value,"(\n)","%1"))
  local modZ = 0.18*count
  if selected then
    editInput("tooltip_input", {label = input_value, value = input_value, position = {pos.x+4, pos.y, pos.z+ 0.5 - modZ}, height = 380+350*(count)})
  else
    local fixedString = string.gsub(input_value, "(\n)", " ")
    if string.len(fixedString) > 34 then
      fixedString = string.sub(fixedString, 0, 31) .. "..."
    end
    editInput("tooltip_input", {label = fixedString, position = {pos.x+4, pos.y, pos.z+0.5}, height = 380})
  end

  savedButtons[currentEdit].tooltip = input_value

  updateValues()
end
-- ** setValueInput : 
function setValueInput(input_value, pos, selected)
  if input_value == "" then
    input_value = ""
  end

  local count = select(2, string.gsub(input_value,"(\n)","%1"))
  local modZ = 0.18*count
  if selected then
    editInput("value_input", {label = input_value, value = input_value, position = {pos.x+4, pos.y, pos.z+ 1 - modZ}, height = 380+350*(count)})
  else
    local fixedString = string.gsub(input_value, "(\n)", " ")
    if string.len(fixedString) > 34 then
      fixedString = string.sub(fixedString, 0, 31) .. "..."
    end
    editInput("value_input", {label = fixedString, position = {pos.x+4, pos.y, pos.z+1}, height = 380})
  end

  savedButtons[currentEdit].value = input_value

  updateValues()
end

selectionShown = false
-- ** hideButtonSelect : 
function hideButtonSelect()
  editButton("select_button", {color={1,1,1},click_function=dynamicFunction("select_main_button_click", function()
    showButtonSelect()
  end)})
  for k,v in pairs(savedButtons) do
    if v ~= "NULL" then
      toggleButton("select_button"..k, false)
    end
  end

  selectionShown = false
end
-- ** showButtonSelect : 
function showButtonSelect()
  editButton("select_button", {color={0.5,0.5,0.5},click_function=dynamicFunction("select_main_button_click", function()
    hideButtonSelect()
    updateValues()
  end)})

  local i = 1
  local modZ = 0.5
  for k,v in pairs(savedButtons) do
    if v ~= "NULL" then
      local buttName = "select_button"..k
      local fixedString = string.gsub(savedButtons[k].label,"(\n)"," ")
      if string.len(fixedString) > 22 then
        fixedString = string.sub(fixedString, 0, 19) .. "..."
      end

      local label = k ..' - '.. fixedString
      --local count = select(2, string.gsub(savedButtons[k].label,"(\n)","%1"))
      local table = {font_color={0,0,0},
      width=5000,
      height=400,--+400,--*count,
      click_function = dynamicFunction("select_button_click"..k,
      function()
        currentEdit = k
        hideButtonSelect()
        updateValues()
      end)}
      modZ = modZ --+ --0.2 * count
      local posi = {dropPos.x+3.5,dropPos.y+0.3,dropPos.z+modZ}
      createButton(buttName, label, posi, table)
      i = i + 1
      modZ = modZ + 0.5 --+ 0.2*(count)
    end
  end

  selectionShown = true
end

-- * createButtons : 
-- ** createLabelButtons : 
function createLabelButtons(pos)
  if not pos.x then pos.x = pos[1] end
  if not pos.y then pos.y = pos[2] end
  if not pos.z then pos.z = pos[3] end

  createButton("label_label", "Label", {pos.x,pos.y,pos.z})
  createInput("input_label", default_values.label, {pos.x+4,pos.y,pos.z}, {input_function = dynamicFunction("setLabel", function(obj, player, input_value, selected) setInput(input_value, pos, selected) end), width = 6000})

  createButton("tooltip_label", "Tooltip", {pos.x,pos.y,pos.z+0.5})
  createInput("tooltip_input", "None", {pos.x+4,pos.y,pos.z+0.5}, {input_function = dynamicFunction("setTooltip", function(obj, player, input_value, selected) setTooltipInput(input_value, pos, selected) end), width = 6000})

  createButton("value_label", "Value", {pos.x,pos.y,pos.z+1})
  createInput("value_input", "None", {pos.x+4,pos.y,pos.z+1}, {input_function = dynamicFunction("setValue", function(obj, player, input_value, selected) setValueInput(input_value, pos, selected) end), width = 6000})

  --Alignment Selection
  createButton("alignment_label", "Alignment", {pos.x+8.5,pos.y,pos.z})
  createButton("alignment_auto_select", "A", {pos.x+10,pos.y,pos.z},
    {click_function = dynamicFunction("selectAlign_Auto", function() selectAlignment("auto") end),tooltip="Automatic",width=400,height=400,font_color={0,0,0}})
  createButton("alignment_left_select", "L", {pos.x+10.5,pos.y,pos.z},
    {click_function = dynamicFunction("selectAlign_Left", function() selectAlignment("left") end),tooltip="Left",width=400,height=400,font_color={0,0,0}})
  createButton("alignment_center_select", "C", {pos.x+11,pos.y,pos.z},
    {click_function = dynamicFunction("selectAlign_Center", function() selectAlignment("center") end),tooltip="Center",width=400,height=400,font_color={0,0,0}})
  createButton("alignment_right_select", "R", {pos.x+11.5,pos.y,pos.z},
    {click_function = dynamicFunction("selectAlign_Right", function() selectAlignment("right") end),tooltip="Right",width=400,height=400,font_color={0,0,0}})
  createButton("alignment_just_select", "J", {pos.x+12,pos.y,pos.z},
    {click_function = dynamicFunction("selectAlign_Just", function() selectAlignment("just") end),tooltip="Justified",width=400,height=400,font_color={0,0,0}})

    --Alignment Selection
  createButton("validation_label", "Validation", {pos.x+8.5,pos.y,pos.z+1})
  createButton("validation_none_select", " ", {pos.x+10,pos.y,pos.z+1},
    {click_function = dynamicFunction("selectVali_None", function() selectValidation("none") end),tooltip="None",width=400,height=400,font_color={0,0,0}})
  createButton("validation_integer_select", "#", {pos.x+10.5,pos.y,pos.z+1},
    {click_function = dynamicFunction("selectVali_Integer", function() selectValidation("integer") end),tooltip="Integer",width=400,height=400,font_color={0,0,0}})
  createButton("validation_float_select", "0.1", {pos.x+11,pos.y,pos.z+1},
    {click_function = dynamicFunction("selectVali_Float", function() selectValidation("float") end),tooltip="Float",width=400,height=400,font_size=300,font_color={0,0,0}})
  createButton("validation_alpha_select", "A#", {pos.x+11.5,pos.y,pos.z+1},
    {click_function = dynamicFunction("selectVali_Alpha", function() selectValidation("alpha") end),tooltip="Alphanumeric",width=400,height=400,font_size=300,font_color={0,0,0}})
  createButton("validation_user_select", "U", {pos.x+12,pos.y,pos.z+1},
    {click_function = dynamicFunction("selectVali_User", function() selectValidation("user") end),tooltip="Username",width=400,height=400,font_color={0,0,0}})
  createButton("validation_name_select", "N", {pos.x+12.5,pos.y,pos.z+1},
    {click_function = dynamicFunction("selectVali_Name", function() selectValidation("name") end),tooltip="Name",width=400,height=400,font_color={0,0,0}})

  --Type Selection
  createButton("type_label", "Type", {pos.x+8.5,pos.y,pos.z+0.5})
  createButton("button_label", "Button", {pos.x+10.3,pos.y,pos.z+0.5})
  createButton("type_button_label", "\u{25C9}", {pos.x+9.5,pos.y,pos.z+0.5})
  createButton("type_button_click", "\u{25C9}", {pos.x+9.5,pos.y,pos.z+0.5},
    {click_function = dynamicFunction("selectType_Button", function() toggleType("Button") end), width=400, height=400, color={r=0,g=0,b=0,a=0}})
  createButton("input_label", "Input", {pos.x+12,pos.y,pos.z+0.5})
  createButton("type_input_label", "\u{25CB}", {pos.x+11.3,pos.y,pos.z+0.5})
  createButton("type_input_click", "\u{25CB}", {pos.x+11.3,pos.y,pos.z+0.5},
    {click_function = dynamicFunction("selectType_Input", function() toggleType("Input") end), width=400, height=400, color={r=0,g=0,b=0,a=0}})
end
-- ** createPositionButtons : 
function createPositionButtons(pos)
  if not pos.x then pos.x = pos[1] end
  if not pos.y then pos.y = pos[2] end
  if not pos.z then pos.z = pos[3] end

  createButton("position_label", "Position", {pos.x,pos.y,pos.z})

  createButton("position_x_label", "X", {pos.x+1,pos.y,pos.z-0.4}, {font_color = {219/255,26/255,24/255}})
  createButton("position_y_label", "Y", {pos.x+1,pos.y,pos.z}, {font_color = {49/255,179/255,43/255}})
  createButton("position_z_label", "Z", {pos.x+1,pos.y,pos.z+0.4}, {font_color = {31/255,136/255,255/255}})

  createInput("position_x_input", "0.0", {pos.x+1.9,pos.y,pos.z-0.4}, {validation = 3, input_function = dynamicFunction("setXPos", function(obj, player, input_value) if input_value == "" then input_value = 0.0 end savedButtons[currentEdit].position[1] = tonumber(input_value) updateObject() end)})
  createInput("position_y_input", "0.0", {pos.x+1.9,pos.y,pos.z}, {validation = 3, input_function = dynamicFunction("setYPos", function(obj, player, input_value) if input_value == "" then input_value = 0.0 end savedButtons[currentEdit].position[2] = tonumber(input_value) updateObject() end)})
  createInput("position_z_input", "0.0", {pos.x+1.9,pos.y,pos.z+0.4}, {validation = 3, input_function = dynamicFunction("setZPos", function(obj, player, input_value) if input_value == "" then input_value = 0.0 end savedButtons[currentEdit].position[3] = tonumber(input_value) updateObject() end)})

  createButton("position_x_add", ">", {pos.x+2.82, pos.y, pos.z-0.5}, {rotation = {0,-90,0}})
  createButton("position_x_add_button", ">", {pos.x+2.82, pos.y, pos.z-0.5}, {rotation = {0,-90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("addXPos", function()
    savedButtons[currentEdit].position[1] = roundValue(savedButtons[currentEdit].position[1]+increment_value.position)
    editInput('position_x_input',{value = savedButtons[currentEdit].position[1]})
    updateObject()
  end)})
  createButton("position_x_sub", ">", {pos.x+2.79, pos.y, pos.z-0.3}, {rotation = {0,90,0}})
  createButton("position_x_sub_button", ">", {pos.x+2.79, pos.y, pos.z-0.3}, {rotation = {0,90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("subXPos", function()
    savedButtons[currentEdit].position[1] = roundValue(savedButtons[currentEdit].position[1]-increment_value.position)
    editInput('position_x_input',{value = savedButtons[currentEdit].position[1]})
    updateObject()
  end)})

  createButton("position_y_add", ">", {pos.x+2.82, pos.y, pos.z-0.1}, {rotation = {0,-90,0}})
  createButton("position_y_add_button", ">", {pos.x+2.82, pos.y, pos.z-0.1}, {rotation = {0,-90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("addYPos",
  function()
    savedButtons[currentEdit].position[2] = roundValue(savedButtons[currentEdit].position[2]+increment_value.position)
    editInput('position_y_input',{value = savedButtons[currentEdit].position[2]})
    updateObject()
  end)})
  createButton("position_y_sub", ">", {pos.x+2.79, pos.y, pos.z+0.1}, {rotation = {0,90,0}})
  createButton("position_y_sub_button", ">", {pos.x+2.79, pos.y, pos.z+0.1}, {rotation = {0,90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("subYPos",
  function()
    savedButtons[currentEdit].position[2] = roundValue(savedButtons[currentEdit].position[2]-increment_value.position)
    editInput('position_y_input',{value = savedButtons[currentEdit].position[2]})
    updateObject()
  end)})

  createButton("position_z_add", ">", {pos.x+2.82, pos.y, pos.z+0.3}, {rotation = {0,-90,0}})
  createButton("position_z_add_button", ">", {pos.x+2.82, pos.y, pos.z+0.3}, {rotation = {0,-90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("addZPos",
  function()
    savedButtons[currentEdit].position[3] = roundValue(savedButtons[currentEdit].position[3]+increment_value.position)
    editInput('position_z_input',{value = savedButtons[currentEdit].position[3]})
    updateObject()
  end)})
  createButton("position_z_sub", ">", {pos.x+2.79, pos.y, pos.z+0.5}, {rotation = {0,90,0}})
  createButton("position_z_sub_button", ">", {pos.x+2.79, pos.y, pos.z+0.5}, {rotation = {0,90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("subZPos",
  function()
    savedButtons[currentEdit].position[3] = roundValue(savedButtons[currentEdit].position[3]-increment_value.position)
    editInput('position_z_input',{value = savedButtons[currentEdit].position[3]})
    updateObject()
  end)})

  createButton("position_increment_label", "Increment:", {pos.x-0.3,pos.y,pos.z+0.3}, {scale = {0.2,0.2,0.2}})
  createInput("position_increment_input", "0.1", {pos.x+0.4,pos.y,pos.z+0.3}, {scale = {0.2,0.2,0.2}, validation = 3, input_function = dynamicFunction("setPosIncrement", function(obj, player, input_value)
    if input_value == "" then
      input_value = 0.1
    end
    increment_value.position = tonumber(input_value)
  end)})
end
-- ** createRotationButtons : 
function createRotationButtons(pos)
  if not pos.x then pos.x = pos[1] end
  if not pos.y then pos.y = pos[2] end
  if not pos.z then pos.z = pos[3] end

  createButton("rotation_label", "Rotation", {pos.x,pos.y,pos.z})

  createButton("rotation_x_label", "X", {pos.x+1,pos.y,pos.z-0.4}, {font_color = {219/255,26/255,24/255}})
  createButton("rotation_y_label", "Y", {pos.x+1,pos.y,pos.z}, {font_color = {49/255,179/255,43/255}})
  createButton("rotation_z_label", "Z", {pos.x+1,pos.y,pos.z+0.4}, {font_color = {31/255,136/255,255/255}})

  createInput("rotation_x_input", "0.0", {pos.x+1.9,pos.y,pos.z-0.4}, {validation = 3, input_function = dynamicFunction("setXRot", function(obj, player, input_value) if input_value == "" then input_value = 0.0 end savedButtons[currentEdit].rotation[1] = tonumber(input_value) updateObject() end)})
  createInput("rotation_y_input", "0.0", {pos.x+1.9,pos.y,pos.z}, {validation = 3, input_function = dynamicFunction("setYRot", function(obj, player, input_value) if input_value == "" then input_value = 0.0 end savedButtons[currentEdit].rotation[2] = tonumber(input_value) updateObject() end)})
  createInput("rotation_z_input", "0.0", {pos.x+1.9,pos.y,pos.z+0.4}, {validation = 3, input_function = dynamicFunction("setZRot", function(obj, player, input_value) if input_value == "" then input_value = 0.0 end savedButtons[currentEdit].rotation[3] = tonumber(input_value) updateObject() end)})

  createButton("rotation_x_add", ">", {pos.x+2.82, pos.y, pos.z-0.5}, {rotation = {0,-90,0}})
  createButton("rotation_x_add_button", ">", {pos.x+2.82, pos.y, pos.z-0.5}, {rotation = {0,-90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("addXRot", function()
    savedButtons[currentEdit].rotation[1] = roundValue(savedButtons[currentEdit].rotation[1]+increment_value.rotation)
    editInput('rotation_x_input',{value = savedButtons[currentEdit].rotation[1]})
    updateObject()
  end)})
  createButton("rotation_x_sub", ">", {pos.x+2.79, pos.y, pos.z-0.3}, {rotation = {0,90,0}})
  createButton("rotation_x_sub_button", ">", {pos.x+2.79, pos.y, pos.z-0.3}, {rotation = {0,90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("subXRot", function()
    savedButtons[currentEdit].rotation[1] = roundValue(savedButtons[currentEdit].rotation[1]-increment_value.rotation)
    editInput('rotation_x_input',{value = savedButtons[currentEdit].rotation[1]})
    updateObject()
  end)})

  createButton("rotation_y_add", ">", {pos.x+2.82, pos.y, pos.z-0.1}, {rotation = {0,-90,0}})
  createButton("rotation_y_add_button", ">", {pos.x+2.82, pos.y, pos.z-0.1}, {rotation = {0,-90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("addYRot",
  function()
    savedButtons[currentEdit].rotation[2] = roundValue(savedButtons[currentEdit].rotation[2]+increment_value.rotation)
    editInput('rotation_y_input',{value = savedButtons[currentEdit].rotation[2]})
    updateObject()
  end)})
  createButton("rotation_y_sub", ">", {pos.x+2.79, pos.y, pos.z+0.1}, {rotation = {0,90,0}})
  createButton("rotation_y_sub_button", ">", {pos.x+2.79, pos.y, pos.z+0.1}, {rotation = {0,90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("subYRot",
  function()
    savedButtons[currentEdit].rotation[2] = roundValue(savedButtons[currentEdit].rotation[2]-increment_value.rotation)
    editInput('rotation_y_input',{value = savedButtons[currentEdit].rotation[2]})
    updateObject()
  end)})

  createButton("rotation_z_add", ">", {pos.x+2.82, pos.y, pos.z+0.3}, {rotation = {0,-90,0}})
  createButton("rotation_z_add_button", ">", {pos.x+2.82, pos.y, pos.z+0.3}, {rotation = {0,-90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("addZRot",
  function()
    savedButtons[currentEdit].rotation[3] = roundValue(savedButtons[currentEdit].rotation[3]+increment_value.rotation)
    editInput('rotation_z_input',{value = savedButtons[currentEdit].rotation[3]})
    updateObject()
  end)})
  createButton("rotation_z_sub", ">", {pos.x+2.79, pos.y, pos.z+0.5}, {rotation = {0,90,0}})
  createButton("rotation_z_sub_button", ">", {pos.x+2.79, pos.y, pos.z+0.5}, {rotation = {0,90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("subZRot",
  function()
    savedButtons[currentEdit].rotation[3] = roundValue(savedButtons[currentEdit].rotation[3]-increment_value.rotation)
    editInput('rotation_z_input',{value = savedButtons[currentEdit].rotation[3]})
    updateObject()
  end)})

  createButton("rotation_increment_label", "Increment:", {pos.x-0.3,pos.y,pos.z+0.3}, {scale = {0.2,0.2,0.2}})
  createInput("rotation_increment_input", "10", {pos.x+0.4,pos.y,pos.z+0.3}, {scale = {0.2,0.2,0.2}, validation = 3, input_function = dynamicFunction("setRotIncrement", function(obj, player, input_value)
    if input_value == "" then
      input_value = 10
    end
    increment_value.rotation = tonumber(input_value)
  end)})
end
-- ** createScaleButtons : 
function createScaleButtons(pos)
  if not pos.x then pos.x = pos[1] end
  if not pos.y then pos.y = pos[2] end
  if not pos.z then pos.z = pos[3] end

  createButton("scale_label", "Scale", {pos.x,pos.y,pos.z})

  createButton("scale_x_label", "X", {pos.x+1,pos.y,pos.z-0.4}, {font_color = {219/255,26/255,24/255}})
  createButton("scale_y_label", "Y", {pos.x+1,pos.y,pos.z}, {font_color = {49/255,179/255,43/255}})
  createButton("scale_z_label", "Z", {pos.x+1,pos.y,pos.z+0.4}, {font_color = {31/255,136/255,255/255}})

  createInput("scale_x_input", "0.5", {pos.x+1.9,pos.y,pos.z-0.4}, {validation = 3, input_function = dynamicFunction("setXScale", function(obj, player, input_value) if input_value == "" then input_value = 0.0 end savedButtons[currentEdit].scale[1] = tonumber(input_value) updateObject() end)})
  createInput("scale_y_input", "0.5", {pos.x+1.9,pos.y,pos.z}, {validation = 3, input_function = dynamicFunction("setYScale", function(obj, player, input_value) if input_value == "" then input_value = 0.0 end savedButtons[currentEdit].scale[2] = tonumber(input_value) updateObject() end)})
  createInput("scale_z_input", "0.5", {pos.x+1.9,pos.y,pos.z+0.4}, {validation = 3, input_function = dynamicFunction("setZScale", function(obj, player, input_value) if input_value == "" then input_value = 0.0 end savedButtons[currentEdit].scale[3] = tonumber(input_value) updateObject() end)})

  createButton("scale_x_add", ">", {pos.x+2.82, pos.y, pos.z-0.5}, {rotation = {0,-90,0}})
  createButton("scale_x_add_button", ">", {pos.x+2.82, pos.y, pos.z-0.5}, {rotation = {0,-90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("addXScale", function()
    savedButtons[currentEdit].scale[1] = roundValue(savedButtons[currentEdit].scale[1]+increment_value.scale)
    editInput('scale_x_input',{value = savedButtons[currentEdit].scale[1]})
    updateObject()
  end)})
  createButton("scale_x_sub", ">", {pos.x+2.79, pos.y, pos.z-0.3}, {rotation = {0,90,0}})
  createButton("scale_x_sub_button", ">", {pos.x+2.79, pos.y, pos.z-0.3}, {rotation = {0,90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("subXScale", function()
    savedButtons[currentEdit].scale[1] = roundValue(savedButtons[currentEdit].scale[1]-increment_value.scale)
    editInput('scale_x_input',{value = savedButtons[currentEdit].scale[1]})
    updateObject()
  end)})

  createButton("scale_y_add", ">", {pos.x+2.82, pos.y, pos.z-0.1}, {rotation = {0,-90,0}})
  createButton("scale_y_add_button", ">", {pos.x+2.82, pos.y, pos.z-0.1}, {rotation = {0,-90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("addYScale",
  function()
    savedButtons[currentEdit].scale[2] = roundValue(savedButtons[currentEdit].scale[2]+increment_value.scale)
    editInput('scale_y_input',{value = savedButtons[currentEdit].scale[2]})
    updateObject()
  end)})
  createButton("scale_y_sub", ">", {pos.x+2.79, pos.y, pos.z+0.1}, {rotation = {0,90,0}})
  createButton("scale_y_sub_button", ">", {pos.x+2.79, pos.y, pos.z+0.1}, {rotation = {0,90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("subYScale",
  function()
    savedButtons[currentEdit].scale[2] = roundValue(savedButtons[currentEdit].scale[2]-increment_value.scale)
    editInput('scale_y_input',{value = savedButtons[currentEdit].scale[2]})
    updateObject()
  end)})

  createButton("scale_z_add", ">", {pos.x+2.82, pos.y, pos.z+0.3}, {rotation = {0,-90,0}})
  createButton("scale_z_add_button", ">", {pos.x+2.82, pos.y, pos.z+0.3}, {rotation = {0,-90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("addZScale",
  function()
    savedButtons[currentEdit].scale[3] = roundValue(savedButtons[currentEdit].scale[3]+increment_value.scale)
    editInput('scale_z_input',{value = savedButtons[currentEdit].scale[3]})
    updateObject()
  end)})
  createButton("scale_z_sub", ">", {pos.x+2.79, pos.y, pos.z+0.5}, {rotation = {0,90,0}})
  createButton("scale_z_sub_button", ">", {pos.x+2.79, pos.y, pos.z+0.5}, {rotation = {0,90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("subZScale",
  function()
    savedButtons[currentEdit].scale[3] = roundValue(savedButtons[currentEdit].scale[3]-increment_value.scale)
    editInput('scale_z_input',{value = savedButtons[currentEdit].scale[3]})
    updateObject()
  end)})

  createButton("scale_increment_label", "Increment:", {pos.x-0.3,pos.y,pos.z+0.3}, {scale = {0.2,0.2,0.2}})
  createInput("scale_increment_input", "0.1", {pos.x+0.4,pos.y,pos.z+0.3}, {scale = {0.2,0.2,0.2}, validation = 3, input_function = dynamicFunction("setSacIncrement", function(obj, player, input_value)
    if input_value == "" then
      input_value = 0.1
    end
    increment_value.scale = tonumber(input_value)
  end)})
end
-- ** createDimensionButtons : 
function createDimensionButtons(pos)
  if not pos.x then pos.x = pos[1] end
  if not pos.y then pos.y = pos[2] end
  if not pos.z then pos.z = pos[3] end

  createButton("dimension_label", "Dimensions", {pos.x-1.3,pos.y,pos.z})

  createButton("dimension_x_label", "Width", {pos.x+0.5,pos.y,pos.z-0.4}, {font_color = {219/255,26/255,24/255}})
  createButton("dimension_y_label", "Height", {pos.x+0.5,pos.y,pos.z}, {font_color = {49/255,179/255,43/255}})
  createButton("dimension_z_label", "Font Size", {pos.x+0.5,pos.y,pos.z+0.4}, {font_size = 300,font_color = {31/255,136/255,255/255}})

  createInput("dimension_x_input", "2000", {pos.x+1.9,pos.y,pos.z-0.4}, {validation = 3, input_function = dynamicFunction("setWidth", function(obj, player, input_value) if input_value == "" then input_value = 0.0 end savedButtons[currentEdit].width = tonumber(input_value) updateObject() end)})
  createInput("dimension_y_input", "400", {pos.x+1.9,pos.y,pos.z}, {validation = 3, input_function = dynamicFunction("setHeight", function(obj, player, input_value) if input_value == "" then input_value = 0.0 end savedButtons[currentEdit].height = tonumber(input_value) updateObject() end)})
  createInput("dimension_z_input", "400", {pos.x+1.9,pos.y,pos.z+0.4}, {validation = 3, input_function = dynamicFunction("setFont_Size", function(obj, player, input_value) if input_value == "" then input_value = 0.0 end savedButtons[currentEdit].font_size = tonumber(input_value) updateObject() end)})

  createButton("dimension_x_add", ">", {pos.x+2.82, pos.y, pos.z-0.5}, {rotation = {0,-90,0}})
  createButton("dimension_x_add_button", ">", {pos.x+2.82, pos.y, pos.z-0.5}, {rotation = {0,-90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("addWidth", function()
    savedButtons[currentEdit].width = roundValue(savedButtons[currentEdit].width+increment_value.dimension)
    editInput('dimension_x_input',{value = savedButtons[currentEdit].width})
    updateObject()
  end)})
  createButton("dimension_x_sub", ">", {pos.x+2.79, pos.y, pos.z-0.3}, {rotation = {0,90,0}})
  createButton("dimension_x_sub_button", ">", {pos.x+2.79, pos.y, pos.z-0.3}, {rotation = {0,90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("subWidth", function()
    savedButtons[currentEdit].width = roundValue(savedButtons[currentEdit].width-increment_value.dimension)
    editInput('dimension_x_input',{value = savedButtons[currentEdit].width})
    updateObject()
  end)})

  createButton("dimension_y_add", ">", {pos.x+2.82, pos.y, pos.z-0.1}, {rotation = {0,-90,0}})
  createButton("dimension_y_add_button", ">", {pos.x+2.82, pos.y, pos.z-0.1}, {rotation = {0,-90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("addHeight",
  function()
    savedButtons[currentEdit].height = roundValue(savedButtons[currentEdit].height+increment_value.dimension)
    editInput('dimension_y_input',{value = savedButtons[currentEdit].height})
    updateObject()
  end)})
  createButton("dimension_y_sub", ">", {pos.x+2.79, pos.y, pos.z+0.1}, {rotation = {0,90,0}})
  createButton("dimension_y_sub_button", ">", {pos.x+2.79, pos.y, pos.z+0.1}, {rotation = {0,90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("subHeight",
  function()
    savedButtons[currentEdit].height = roundValue(savedButtons[currentEdit].height-increment_value.dimension)
    editInput('dimension_y_input',{value = savedButtons[currentEdit].height})
    updateObject()
  end)})

  createButton("dimension_z_add", ">", {pos.x+2.82, pos.y, pos.z+0.3}, {rotation = {0,-90,0}})
  createButton("dimension_z_add_button", ">", {pos.x+2.82, pos.y, pos.z+0.3}, {rotation = {0,-90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("addFont_Size",
  function()
    savedButtons[currentEdit].font_size = roundValue(savedButtons[currentEdit].font_size+increment_value.dimension)
    editInput('dimension_z_input',{value = savedButtons[currentEdit].font_size})
    updateObject()
  end)})
  createButton("dimension_z_sub", ">", {pos.x+2.79, pos.y, pos.z+0.5}, {rotation = {0,90,0}})
  createButton("dimension_z_sub_button", ">", {pos.x+2.79, pos.y, pos.z+0.5}, {rotation = {0,90,0}, width = 200, height = 400, color = {0,0,0,0}, click_function = dynamicFunction("subFont_Size",
  function()
    savedButtons[currentEdit].font_size = roundValue(savedButtons[currentEdit].font_size-increment_value.dimension)
    editInput('dimension_z_input',{value = savedButtons[currentEdit].font_size})
    updateObject()
  end)})

  createButton("dimension_increment_label", "Increment:", {pos.x-1.6,pos.y,pos.z+0.3}, {scale = {0.2,0.2,0.2}})
  createInput("dimension_increment_input", "100", {pos.x-0.9,pos.y,pos.z+0.3}, {scale = {0.2,0.2,0.2}, validation = 3, input_function = dynamicFunction("setDymIncrement", function(obj, player, input_value)
    if input_value == "" then
      input_value = 100
    end
    increment_value.dimension = tonumber(input_value)
  end)})
end



-- * Value Functions
-- ** selectValidation : 
function selectValidation(type)
  local button = {color = {1,1,1,1}}

  editButton('validation_none_select',button)
  editButton('validation_integer_select',button)
  editButton('validation_float_select',button)
  editButton('validation_alpha_select',button)
  editButton('validation_user_select',button)
  editButton('validation_name_select',button)

  if type == 1 then type = "none"
  elseif type == 2 then type = "integer"
  elseif type == 3 then type = "float"
  elseif type == 4 then type = "alpha"
  elseif type == 5 then type = "user"
  elseif type == 6 then type = "name" end

  button = {color = {0.5,0.5,0.5,1}}
  editButton('validation_'..type..'_select',button)

  if type == "none" then type = 1
  elseif type == "integer" then type = 2
  elseif type == "float" then type = 3
  elseif type == "alpha" then type = 4
  elseif type == "user" then type = 5
  elseif type == "name" then type = 6 end

  savedButtons[currentEdit].validation = type
  updateObject()
end
-- ** selectAlignment : 
function selectAlignment(type)
  local button = {color = {1,1,1,1}}

  editButton('alignment_auto_select',button)
  editButton('alignment_left_select',button)
  editButton('alignment_center_select',button)
  editButton('alignment_right_select',button)
  editButton('alignment_just_select',button)

  if type == 1 then type = "auto"
  elseif type == 2 then type = "left"
  elseif type == 3 then type = "center"
  elseif type == 4 then type = "right"
  elseif type == 5 then type = "just" end

  button = {color = {0.5,0.5,0.5,1}}
  editButton('alignment_'..type..'_select',button)

  if type == "auto" then type = 1
  elseif type == "left" then type = 2
  elseif type == "center" then type = 3
  elseif type == "right" then type = 4
  elseif type == "just" then type = 5 end

  savedButtons[currentEdit].alignment = type
  updateObject()
end
-- ** toggleType : 
function toggleType(type)
  savedButtons[currentEdit].type = type

  if type == "Button" then
    editButton('type_button_label', {label = '\u{25C9}'})
    editButton('type_input_label', {label = '\u{25CB}'})

    toggleButton("value_label", false)
    toggleInput("value_input", false)

    toggleButton("validation_label", false)
    toggleButton("validation_none_select", false)
    toggleButton("validation_integer_select", false)
    toggleButton("validation_float_select", false)
    toggleButton("validation_alpha_select", false)
    toggleButton("validation_user_select", false)
    toggleButton("validation_name_select", false)
  elseif type == "Input" then
    editButton('type_button_label', {label = '\u{25CB}'})
    editButton('type_input_label', {label = '\u{25C9}'})

    toggleButton("value_label", true)
    toggleInput("value_input", true)

    toggleButton("validation_label", true)
    toggleButton("validation_none_select", true)
    toggleButton("validation_integer_select", true)
    toggleButton("validation_float_select", true)
    toggleButton("validation_alpha_select", true)
    toggleButton("validation_user_select", true)
    toggleButton("validation_name_select", true)
  end
  updateObject()
end

-- * Show and Hide Button/Input
-- ** toggleButton : 
function toggleButton(index,show)
  if not buttonIndex[index] then
    print("[ff0000]<Error>[ffffff] Can't toggle button [" .. index .. "]")
  end
  self.editButton({index = buttonIndex[index], scale = {show and 0.5 or 0,show and 0.5 or 0,show and 0.5 or 0}})
end
-- ** toggleInput : 
function toggleInput(index,show)
  if not inputIndex[index] then
    print("[ff0000]<Error>[ffffff] Can't toggle input [" .. index .. "]")
  end
  self.editInput({index = inputIndex[index], scale = {show and 0.5 or 0,show and 0.5 or 0,show and 0.5 or 0}})
end

-- * Create and Edit Button/Input
-- ** createInput : 
function createInput(index, label, position, overrides)
  local input_parameters = {}
  input_parameters.input_function = "nilFunction"
  input_parameters.function_owner = self
  input_parameters.label = label
  input_parameters.position = position
  input_parameters.rotation = {0,0,0}
  input_parameters.scale = {0.5,0.5,0.5}
  input_parameters.width = 1400
  input_parameters.height = 380
  input_parameters.font_size = 350
  input_parameters.color = {1,1,1,1}
  input_parameters.font_color = {0,0,0,1}
  input_parameters.tooltip = ""
  input_parameters.alignment = 3
  input_parameters.value = ""
  input_parameters.validation = 1

  if overrides ~= nil then
    for k,v in pairs(overrides) do
      input_parameters[k] = v
    end
  end

  if not inputIndex[index] then
    self.createInput(input_parameters)
    inputIndex[index] = #self.getInputs() - 1
  else
    input_parameters.index = inputIndex[index]
    self.editInput(input_parameters)
  end
end
-- ** createButton : 
function createButton(index, label, position, overrides)
  local button_parameters = {}
  button_parameters.click_function = 'nilFunction'
  button_parameters.function_owner = self
  button_parameters.label = label
  button_parameters.position = position
  button_parameters.rotation = {0,0,0}
  button_parameters.scale = {0.5,0.5,0.5}
  button_parameters.width = 0
  button_parameters.height = 0
  button_parameters.font_size = 400
  button_parameters.color = {1,1,1,1}
  button_parameters.font_color = {1,1,1,1}
  button_parameters.tooltip = ""
  button_parameters.alignment = 3

  if overrides ~= nil then
    for k,v in pairs(overrides) do
      button_parameters[k] = v
    end
  end

  if not buttonIndex[index] then
    self.createButton(button_parameters)
    buttonIndex[index] = #self.getButtons() - 1
  else
    button_parameters.index = buttonIndex[index]
    self.editButton(button_parameters)
  end
end
-- ** editInput : 
function editInput(index, update)
  if not inputIndex[index] then
    print("[ff0000]<Error>[ffffff] Can't edit input - [" .. index .. "]")
  end

  update.index = inputIndex[index]
  self.editInput(update)

  if dev then
    print("[ffFF00]<LOG>[ffffff] Edited - [" .. index .. "]")
    for k,v in pairs(self.getInputs()[update.index+1]) do
      if type(v) ~= "table" and v ~= self then
        --print("     " .. k .. " - " .. v)
      end
    end
  end
end
-- ** editButton : 
function editButton(index, update)
  if not buttonIndex[index] then
    print("[ff0000]<Error>[ffffff] Can't edit button [" .. index .. "]")
  end
  update.index = buttonIndex[index]
  self.editButton(update)
end

-- ** getInputValue : 
function getInputValue(index)
  if not inputIndex[index] then
    print("[ff0000]<Error>[ffffff] Can't edit input - [" .. index .. "]")
  end
  local value = self.getInputs()[inputIndex[index]+1].value
  if value == "" or value == nil then
    value = 0
  end
  return value
end

-- * Misc Functions
-- ** dynamicFunction : 
function dynamicFunction(funcName, func)
  self.setVar(funcName, func)
  return funcName
end
-- ** table.clone : 
function table.clone(orig)
  local orig_type = type(orig)
  local copy = nil
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[table.clone(orig_key)] = table.clone(orig_value)
    end
    setmetatable(copy, table.clone(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

-- ** roundValue :
function roundValue(val)
  local tempVal = val * 10000
  tempVal = math.floor(tempVal + 0.1)
  tempVal = tempVal/10000
  if math.abs(tempVal) < 0.00001 then
    tempVal = 0
  end
  return tempVal
end

-- * nilFunction : 
function nilFunction() return end
