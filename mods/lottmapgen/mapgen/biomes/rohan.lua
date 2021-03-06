local c_rohan_grass = minetest.get_content_id("lottitems:rohan_grass")
local c_dirt = minetest.get_content_id("lottitems:dirt")
local c_red_stone = minetest.get_content_id("lottitems:red_stone")
local c_desertsand = minetest.get_content_id("lottitems:desert_sand")

lottmapgen.register_biome(17, {
	name = "Rohan",
	surface = function(data, vi)
		data[vi] = c_rohan_grass
	end,
	deco = function(data, p2data, vi, area, x, y, z, noise, noise2, schems)
		if noise2 > 0.2 then
			if math.random(PLANT2) == 2 then
				lottmapgen.dry_grass(data, vi, p2data)
			elseif noise > -0.3 then
				if math.random(PLANT2) == 3 then
					lottmapgen.tall_dry_grass(x, y, z, area, data, p2data)
				end
			end
		elseif noise2 > -0.4 then
			if math.random(PLANT4) == 2 then
				lottmapgen.dry_grass(data, vi, p2data)
			elseif math.random(PLANT6) == 3 then
				lottmapgen.grass(data, vi, p2data)
			elseif noise < -0.3 and noise > -0.4 then
				if math.random(TREE4) == 4 then
					lottmapgen.poplar_tree(x, y, z, area, data)
				end
			elseif math.random(PLANT13) == 1 then
				table.insert(schems, {"test.mts",
					{x = x, y = y-1, z = z},
					{12, 12, "lottitems:dirt", "lottitems:dirt"}})
			end
		else
			if math.random(PLANT4) == 4 then
				lottmapgen.grass(data, vi, p2data)
			elseif math.random(PLANT9) == 5 then
				lottmapgen.basic_flowers(data, vi, p2data)
			elseif math.random(PLANT7) == 6 then
				lottmapgen.dry_grass(data, vi, p2data)
			elseif noise > 0.55 then
				if math.random(TREE3) == 2 then
					lottmapgen.generate_tree(x, y, z, area, data,
						"lottplants:oak_trunk",
						"lottplants:oak_leaves", math.random(4, 5))
				elseif math.random(TREE9) == 3 then
					lottmapgen.generate_log(x, y, z, area, data, p2data,
						"lottplants:oak_trunk", math.random(2, 3))
				elseif math.random(PLANT7) == 9 then
					lottmapgen.leaf_litter(x, y, z, area, data)
				elseif math.random(PLANT8) == 8 then
					lottmapgen.perma_dirt(x, y, z, area, data)
				end
			elseif noise < -0.4 then
				if math.random(TREE3) == 3 then
					lottmapgen.alder_tree(x, y, z, area, data)
				elseif math.random(TREE5) == 4 then
					lottmapgen.generate_bush(x, y, z, area, data,
						"lottplants:alder_trunk",
						"lottplants:alder_leaves")
				elseif math.random(TREE7) == 2 then
					lottmapgen.generate_tree(x, y, z, area, data,
						"lottplants:oak_trunk",
						"lottplants:oak_leaves", math.random(4, 5))
				elseif math.random(TREE9) == 5 then
					lottmapgen.generate_log(x, y, z, area, data, p2data,
						"lottplants:alder_trunk", math.random(2, 4))
				elseif math.random(PLANT7) == 9 then
					lottmapgen.leaf_litter(x, y, z, area, data)
				elseif math.random(PLANT8) == 8 then
					lottmapgen.perma_dirt(x, y, z, area, data)
				end
			end
		end
	end,
	soil = c_dirt,
	soil_depth = 1,
	beach = c_desertsand,
	stone = c_red_stone,
	stone_depth = 55,
})
