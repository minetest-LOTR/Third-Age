-- Tmp dig all pick!
minetest.register_tool("lotttools:omni_pick", {
	description = "Digs all!",
	inventory_image = "lotttools_pick.png",
	tool_capabilities = {
		full_punch_interval = 0.5,
		groupcaps = {
			pickaxe = {maxlevel = 0, uses = 100,
				times = {[1] = 0.5, [2] = 0.75, [3] = 1, [4] = 0.2}},
			axe = {maxlevel = 0, uses = 100,
				times = {[1] = 0.5, [2] = 0.75, [3] = 1, [4] = 0.2}},
			plant = {maxlevel = 0, uses = 100,
				times = {[1] = 0.5, [2] = 0.75, [3] = 1, [4] = 0.2}},
		}
	},
})

--[[minetest.register_craftitem("lotttools:tool_rod", {
	description = "Tool Rod",
	inventory_image = "lotttools_tool_rod.png",
})]]

minetest.register_tool("lotttools:flint_pickaxe", {
	description = "Flint Pickaxe",
	inventory_image = "lotttools_flint_pickaxe.png",
	tool_capabilities = {
		full_punch_interval = 1.5,
		groupcaps = {
			pickaxe = {maxlevel = 0, uses = 100,
				times = {[1] = 3}}
		},
	},
})

minetest.register_tool("lotttools:flint_axe", {
	description = "Flint Pickaxe",
	inventory_image = "lotttools_flint_axe.png",
	tool_capabilities = {
		full_punch_interval = 1.5,
		groupcaps = {
			axe = {maxlevel = 0, uses = 100,
				times = {[1] = 3}}
		},
	},
})

minetest.register_tool("lotttools:flint_shovel", {
	description = "Flint Pickaxe",
	inventory_image = "lotttools_flint_shovel.png",
	tool_capabilities = {
		full_punch_interval = 1.5,
		groupcaps = {
			shovel = {maxlevel = 0, uses = 100,
				times = {[1] = 3}}
		},
	},
})

minetest.register_craft({
	output = "lotttools:flint_pickaxe",
	recipe = {
		{"lottitems:flint", "lottitems:flint", "lottitems:flint"},
		{"", "lottitems:stick", ""},
		{"", "lottitems:stick", ""},
	},
})

minetest.register_craft({
	output = "lotttools:flint_axe",
	recipe = {
		{"lottitems:flint", "lottitems:flint"},
		{"lottitems:flint", "lottitems:stick"},
		{"", "lottitems:stick"},
	},
})

minetest.register_craft({
	output = "lotttools:flint_pickaxe",
	recipe = {
		{"lottitems:flint", "lottitems:flint", "lottitems:flint"},
		{"", "lottitems:stick", ""},
		{"", "lottitems:stick", ""},
	},
})