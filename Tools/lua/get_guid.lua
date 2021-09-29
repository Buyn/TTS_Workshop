local triggerIndex = 1 -- Which scripting button will trigger zoom-in
local zoomAmount = 5
local pitchAngle = 80
local rotate = false
local targetGUID = "000000"
local lockedTargetGUID = "none"

function onLoad(save_state)
    self.createInput({
        function_owner = self,
        input_function = "setShortcutKey",
        label = "Shortcut Key",
        tooltip = "Shortcut Key\n(number only)",
        value = 1,
        position = {0.1, 0.1, 0.3},
        scale = {0.5, 0.5, 0.5},
        width = 800,
        height = 700,
        font_size = 600,
        alignment = 3
    })

    self.createInput({
        function_owner = self,
        input_function = "setPitchAngle",
        label = "Pitch",
        tooltip = "Pitch angle\n(the higher, the more top-down the angle. Up to 90)",
        value = 80,
        position = {-0.5, 0.1, -0.8},
        scale = {0.5, 0.5, 0.5},
        width = 800,
        height = 700,
        font_size = 600,
        alignment = 3,
        validation = 3
    })

    self.createInput({
        function_owner = self,
        input_function = "setZoom",
        label = "Zoom",
        tooltip = "Zoom amount\n(the higher, the further away from the object)",
        value = 5,
        position = {0.9, 0.1, -0.8},
        scale = {0.5, 0.5, 0.5},
        width = 800,
        height = 700,
        font_size = 600,
        alignment = 3,
        validation = 3
    })

    self.createButton({
        click_function = "toggleRotate",
        function_owner = self,
        label = "?",
        position = {1.4, 0.1, 0.6},
        scale = {0.5, 0.5, 0.5},
        width = 500,
        height = 1000,
        font_size = 800,
        --color = {0.1311, 0.8554, 0.1117, 1},
        tooltip = "Click to turn camera rotation on/off"
    })

    self.createInput({
        input_function = "typeGUID",
        function_owner = self,
        label = "GUID",
        tooltip = "Enter the GUID of the object or drop on top of object to get its GUID",
        position = {-2.3, 0.1, 0.4},
        rotation = {0, 90, 0},
        scale = {0.5, 0.5, 0.5},
        width = 1350,
        height = 500,
        font_size = 400,
        alignment = 3,
        validation = 4
    })

    self.createButton({
        click_function = "lockGUID",
        function_owner = self,
        label = "?",
        tooltip = "Make camera hover that object, instead of what's under your mouse",
        position = {-2.3, 0.1, 1.4},
        rotation = {0, 90, 0},
        scale = {0.5, 0.5, 0.5},
        width = 400,
        height = 500,
        font_size = 400,
        alignment = 3
    })
end

function typeGUID(obj, color, guid)
    targetGUID = guid
end

function setShortcutKey(obj, player, value)
    triggerIndex = tonumber(value)
end

function setPitchAngle(obj, player, value)
    pitchAngle = tonumber(value)
end

function setZoom(obj, player, value)
    zoomAmount = tonumber(value)
end

function toggleRotate(obj, player)
    if rotate then
        self.editButton({
            index = 0,
            label = "?"
            --color = {0.8549, 0.1098, 0.1098, 1}
        })
        rotate = false
    else
        self.editButton({
            index = 0,
            label = "?"
            --color = {0.1311, 0.8554, 0.1117, 1}
        })
        rotate = true
    end
end

function onScriptingButtonDown(pressedIndex, playerColor)
    if playerColor == 'Grey' or pressedIndex ~= triggerIndex then
        return -- Return if invalid player or wrong button clicked
    end

    local obj
    if lockedTargetGUID == "none" then --if not aiming at an object
        obj = Player[playerColor].getHoverObject()
    else
        obj = getObjectFromGUID(lockedTargetGUID)
    end
    if not obj then-- Return if no hover object
        return
    end

    if rotate then
        Player[playerColor].lookAt({-- Focus camera on the hover object
            position = obj.getPosition(),
            yaw = obj.getRotation().y + 180,
            pitch = pitchAngle,
            distance = zoomAmount
        })
    else
        Player[playerColor].lookAt({-- Focus camera on the hover object
            position = obj.getPosition(),
            pitch = pitchAngle,
            yaw = obj.getRotation().y,
            distance = zoomAmount
        })
    end
end

function lockGUID(obj, color)
    --check that it's a GUID
    if string.sub(targetGUID,-string.len('\n')) ~= '\n' then
        local trueGUID = string.sub(targetGUID,0,6)
        if getObjectFromGUID(trueGUID) ~= nil and getObjectFromGUID(trueGUID) ~= self then
            self.editButton({
                index = 1,
                label = "X",
                color = stringColorToRGB("Red"),
                click_function = "clearTarget",
                tooltip = "Click to go back to looking at what is under your mouse"
            })
            self.createButton({
                click_function = "nothing",
                function_owner = self,
                label = "Locked",
                position = {-3, 0.1, 0.6},
                rotation = {0, 90, 0},
                scale = {0.5, 0.5, 0.5},
                width = 0,
                height = 500,
                font_size = 600,
                font_color = {1, 1, 1, 1},
                alignment = 3
            })
            lockedTargetGUID = trueGUID
        else
            broadcastToColor("Error: This is not a valid GUID", color, stringColorToRGB("Red"))
        end
    end
end

function clearTarget(obj, color)
    lockedTargetGUID = "none"
    self.editButton({
        index = 1,
        click_function = "lockGUID",
        label = "?",
        tooltip = "Make camera hover that object, instead of what's under your mouse",
        color = stringColorToRGB("White")
    })
    self.editInput({
        index = 3,
        value = "",
    })
    self.removeButton(2)
end

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
    targetGUID = collision_info.collision_object.getGUID()
    self.editInput({
        index = 3,
        value = targetGUID,
    })
end

function nothing(obj, color)

end
