function onCollisionEnter(collision_info)
  if collision_info.collision_object.interactable then
    local target = collision_info.collision_object
    ---ENTER CUSTOM INTERACTION BELOW---
    --replace me--
    --example: target.lock()
    print(target.getInput())
		end
  self.destruct()
	end
