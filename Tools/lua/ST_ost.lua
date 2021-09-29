startGUID = "0cbf1d"
function onload()
  -- clickable area
  self.createButton({
      click_function="click", function_owner=self,
      position={0, 0.2, 0}, height=700, width=700, color={1,1,1,0}, label=""
  })
  -- button label
  self.createButton({
      click_function="click", function_owner=self,
      position={0, 0.2, 0}, height=1, width=1, color={1,1,1,1}, label="ST OST", font_size=200
  })
end

function click()
  self.AssetBundle.playTriggerEffect(0)
  print("ST OST")
  getObjectFromGUID(startGUID).setValue("https://www.youtube.com/embed/yySw7vkdkZY?autoplay=1&loop=1")
  -- https://www.youtube.com/watch?v=yySw7vkdkZY
  -- <iframe width="560" height="315" src="https://www.youtube.com/embed/SbQc_JLUH7k?autoplay=1&loop=1&start=5&end=8&playlist=96kI8Mp1uOU" frameborder="0" allowfullscreen></iframe>
end
