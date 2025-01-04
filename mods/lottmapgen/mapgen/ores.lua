
minetest.register_ore({
	ore_type = "blob",
	ore = "lottitems:dirt",
	wherein = {"lottitems:stone", "lottitems:red_stone", "lottitems:sandstone",
		"lottitems:blue_stone"},
	clust_scarcity = 25 * 25 * 25,
	clust_size = 5,
	y_min = -31000,
	y_max = 100,
	noise_threshold = 0.0,
	noise_params = {
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = 32423,
		octaves = 1,
		persist = 0,
	},
})

minetest.register_ore({
	ore_type = "blob",
	ore = "lottitems:gravel",
	wherein = {"lottitems:stone", "lottitems:red_stone", "lottitems:sandstone",
		"lottitems:blue_stone"},
	clust_scarcity = 25 * 25 * 25,
	clust_size = 5,
	y_min = -31000,
	y_max = 100,
	noise_threshold = 0.0,
	noise_params = {
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = 53765,
		octaves = 1,
		persist = 0,
	},
})

minetest.register_ore({
	ore_type = "blob",
	ore = "lottitems:dark_gravel",
	wherein = {"lottitems:stone", "lottitems:red_stone", "lottitems:sandstone",
		"lottitems:blue_stone"},
	clust_scarcity = 25 * 25 * 25,
	clust_size = 5,
	y_min = -31000,
	y_max = 100,
	noise_threshold = 0.0,
	noise_params = {
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = 91322,
		octaves = 1,
		persist = 0,
	},
})

minetest.register_ore({
	ore_type = "blob",
	ore = "lottitems:sand",
	wherein = {"lottitems:stone", "lottitems:red_stone", "lottitems:sandstone",
		"lottitems:blue_stone"},
	clust_scarcity = 25 * 25 * 25,
	clust_size = 5,
	y_min = -31000,
	y_max = 15,
	noise_threshold = 0.0,
	noise_params = {
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = 12389,
		octaves = 1,
		persist = 0,
	},
})

minetest.register_ore({
	ore_type = "blob",
	ore = "lottitems:desert_sand",
	wherein = {"lottitems:desert_sandstone"},
	clust_scarcity = 15 * 15 * 15,
	clust_size = 5,
	y_min = -31000,
	y_max = 15,
	noise_threshold = 0.0,
	noise_params = {
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = 37835,
		octaves = 1,
		persist = 0,
	},
})

minetest.register_ore({
	ore_type = "blob",
	ore = "lottitems:gravel",
	wherein = {"lottitems:desert_sandstone"},
	clust_scarcity = 15 * 15 * 15,
	clust_size = 5,
	y_min = -31000,
	y_max = 15,
	noise_threshold = 0.0,
	noise_params = {
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = 37835,
		octaves = 1,
		persist = 0,
	},
})