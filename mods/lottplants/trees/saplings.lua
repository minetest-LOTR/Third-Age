local function sapling_on_place(itemstack, placer, pointed_thing,
    sapling_name, minp_relative, maxp_relative, interval)
    -- Position of sapling
    local pos = pointed_thing.under
    local node = minetest.get_node_or_nil(pos)
    local pdef = node and minetest.registered_nodes[node.name]

    if pdef and pdef.on_rightclick and
            not (placer and placer:is_player() and
            placer:get_player_control().sneak) then
        return pdef.on_rightclick(pos, node, placer, itemstack, pointed_thing)
    end

    if not pdef or not pdef.buildable_to then
        pos = pointed_thing.above
        node = minetest.get_node_or_nil(pos)
        pdef = node and minetest.registered_nodes[node.name]
        if not pdef or not pdef.buildable_to then
            return itemstack
        end
    end

    local player_name = placer and placer:get_player_name() or ""
    -- Check sapling position for protection
    if minetest.is_protected(pos, player_name) then
        minetest.record_protection_violation(pos, player_name)
        return itemstack
    end
    -- Check tree volume for protection
    if minetest.is_area_protected(
            vector.add(pos, minp_relative),
            vector.add(pos, maxp_relative),
            player_name,
            interval) then
        minetest.record_protection_violation(pos, player_name)
        -- Print extra information to explain
        minetest.chat_send_player(player_name,
            itemstack:get_definition().description .. " will intersect protection " ..
            "on growth")
        return itemstack
    end

    minetest.log("action", player_name .. " places node "
            .. sapling_name .. " at " .. minetest.pos_to_string(pos))

    local take_item = not minetest.is_creative_enabled(player_name)
    local newnode = {name = sapling_name}
    local ndef = minetest.registered_nodes[sapling_name]
    minetest.set_node(pos, newnode)

    -- Run callback
    if ndef and ndef.after_place_node then
        -- Deepcopy place_to and pointed_thing because callback can modify it
        if ndef.after_place_node(table.copy(pos), placer,
                itemstack, table.copy(pointed_thing)) then
            take_item = false
        end
    end

    -- Run script hook
    for _, callback in ipairs(minetest.registered_on_placenodes) do
        -- Deepcopy pos, node and pointed_thing because callback can modify them
        if callback(table.copy(pos), table.copy(newnode),
                placer, table.copy(node or {}),
                itemstack, table.copy(pointed_thing)) then
            take_item = false
        end
    end

    if take_item then
        itemstack:take_item()
    end

    return itemstack
end

local function can_grow(pos)
	local node_under = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
	if not node_under then
		return false
	end
	if minetest.get_item_group(node_under.name, "soil_quality") == 0 then
		return false
	end
	local light_level = minetest.get_node_light(pos)
	if not light_level or light_level < 13 then
		return false
	end
	return true
end


local function is_snow(pos)
	return minetest.find_node_near(pos, 1, {"group:snowy"})
end

local function register_sapling(name, box, time_min, time_max)
    if not time_min then
        time_min = 3
    end
    if not time_max then
        time_max = 5
    end
    if not box then
        box = {
            min = {x = -3, y = -2, z = -3},
            max = {x = 3, y = 6, z = 3},
        }
    end
	local function grow_tree(pos)
        if not can_grow(pos) then
            minetest.get_node_timer(pos):start(300)
            return
        end
        local snow = is_snow(pos)
		local x, y, z = pos.x, pos.y, pos.z
		local vm = minetest.get_voxel_manip()
		local minp, maxp = vm:read_from_map(
			{x = x + box.min.x, y = y + box.min.y, z = z + box.min.z},
			{x = x + box.max.x, y = y + box.max.y, z = z + box.max.z}
		)
		local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
		local data = vm:get_data()
		if lottmapgen[name .. "_tree"] then
			lottmapgen[name .. "_tree"](x, y, z, a, data, snow)
		else
			lottmapgen.generate_tree(x, y, z, a, data,
           		"lottplants:" .. name .. "_trunk",
            	"lottplants:" .. name .. "_leaves",
				box.max.y - math.random(1, 2))
		end
		vm:set_data(data)
		vm:write_to_map()
		vm:update_map()
	end
    minetest.register_node("lottplants:" .. name .. "_sapling", {
        description = lott.str_to_desc(name) .. " Sapling",
        drawtype = "plantlike",
        tiles = {"lottplants_" .. name .. "_sapling.png"},
        inventory_image = "lottplants_" .. name .. "_sapling.png",
        paramtype = "light",
		walkable = false,
        groups = {hand = 3, sapling = 1, [name] = 2, attached_node = 1},
        on_timer = grow_tree,
        on_construct = function(pos)
            minetest.get_node_timer(pos):start(math.random(time_min, time_max))
        end,
        on_place = function(itemstack, placer, pointed_thing)
            itemstack = sapling_on_place(itemstack, placer, pointed_thing,
                "lottplants:" .. name .. "_sapling",
                -- minp, maxp to be checked, relative to sapling pos
                box.min, box.max,
                -- maximum interval of interior volume check
                4)
            return itemstack
        end,
    })
end

register_sapling("alder", {
    min = {x = -4, y = -2, z = -4},
    max = {x = 4, y = 8, z = 4},
})

register_sapling("apple", {
	min = {x = -6, y = -4, z = -6},
	max = {x = 6, y = 10, z = 6},
})

register_sapling("ash", {
	min = {x = -6, y = -4, z = -6},
	max = {x = 6, y = 32, z = 6},
})

register_sapling("beech", {
	min = {x = -7, y = -2, z = -7},
	max = {x = 7, y = 15, z = 7},
})

register_sapling("birch", {
    min = {x = -4, y = -2, z = -4},
	max = {x = 4, y = 12, z = 4},
})

register_sapling("cedar", {
	min = {x = -5, y = -4, z = -5},
	max = {x = 5, y = 21, z = 5},
})

register_sapling("dark_oak", {
	min = {x = -6, y = -4, z = -6},
	max = {x = 6, y = 32, z = 6},
})

register_sapling("elm", {
    min = {x = -5, y = -2, z = -5},
	max = {x = 5, y = 13, z = 5},
})

register_sapling("holly", {
    min = {x = -3, y = -2, z = -3},
	max = {x = 3, y = 6, z = 3},
})

register_sapling("mallorn", {
	min = {x = -6, y = -4, z = -6},
	max = {x = 6, y = 32, z = 6},
})

register_sapling("maple", {
	min = {x = -4, y = -2, z = -4},
	max = {x = 4, y = 12, z = 4},
})

register_sapling("oak")

register_sapling("poplar", {
    min = {x = -4, y = -2, z = -4},
    max = {x = 4, y = 20, z = 4},
})

register_sapling("pine", {
    min = {x = -4, y = -2, z = -4},
	max = {x = 4, y = 14, z = 4},
})

register_sapling("rowan", {
	min = {x = -3, y = -2, z = -3},
	max = {x = 3, y = 7, z = 3},
})

register_sapling("white", {
	min = {x = -5, y = -2, z = -5},
	max = {x = 5, y = 22, z = 5},
})
