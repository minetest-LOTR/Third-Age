local S = minetest.get_translator("doors")


for _,color in ipairs({"green", "red", "yellow", "blue"}) do
	doors.register("hobbit_door_"..color, {
			tiles = {{ name = "doors_hobbit_door_"..color..".png", backface_culling = true }},
			description = S("Green Hobbit Door"),
			inventory_image = "doors_hobbit_door_"..color..".png",
			groups = {node = 1, axe = 2, hand = 2, flammable = 2},
			gain_open = 0.06,
			gain_close = 0.13,
			door_width = 2,
			box1 = {-1/2,-1/2,-1/2,3/2,3/2,-6/16},
			box2 = {-3/2.43,-1/2.73,-1/2.75,1/2,3/2.17,-6/25},
			mesh1 = "doors_hobbit_door.obj",
			mesh2 = "doors_hobbit_door_open.obj",
			animations = {
				open = {x=1,y=10},
			},
      --[[
			recipe = { -- WIP: requires dyes
				{"doors:hobbit_door_generic", "lottdyes:"..color},
			}]]
	})
end
doors.register("hobbit_door_generic", {
  tiles = {{ name = "doors_hobbit_door.png", backface_culling = true }},
  description = S("Hobbit Door"),
  inventory_image = "doors_hobbit_door.png",
  groups = {node = 1, axe = 2, hand = 2, flammable = 2},
  gain_open = 0.06,
  gain_close = 0.13,
  door_width = 2,
  box1 = {-1/2,-1/2,-1/2,3/2,3/2,-6/16},
  box2 = {-3/2.43,-1/2.73,-1/2.75,1/2,3/2.17,-6/25},
  mesh1 = "doors_hobbit_door.obj",
  mesh2 = "doors_hobbit_door_open.obj",
  animations = {
    open = {x=1,y=10},
  },
  recipe = { -- placeholder recipe
  {"group:wood", "group:wood", "group:wood"},
  {"group:wood", "lottores:copper_ore", "group:wood"},
  {"group:wood", "group:wood", "group:wood"},
}
})
