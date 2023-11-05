-- doors/init.lua

-- our API object
doors = {}

doors.registered_doors = {}
doors.registered_trapdoors = {}

-- Load support for MT game translation.
local S = minetest.get_translator("doors")


local function replace_old_owner_information(pos)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("doors_owner")
	if owner and owner ~= "" then
		meta:set_string("owner", owner)
		meta:set_string("doors_owner", "")
	end
end

-- returns an object to a door object or nil
function doors.get(pos)
	local node_name = minetest.get_node(pos).name
	if doors.registered_doors[node_name] then
		-- A normal upright door
		return {
			pos = pos,
			open = function(self, player)
				if self:state() then
					return false
				end
				return doors.door_toggle(self.pos, nil, player)
			end,
			close = function(self, player)
				if not self:state() then
					return false
				end
				return doors.door_toggle(self.pos, nil, player)
			end,
			toggle = function(self, player)
				return doors.door_toggle(self.pos, nil, player)
			end,
			state = function(self)
				local state = minetest.get_meta(self.pos):get_int("state")
				return state %2 == 1
			end
		}
	elseif doors.registered_trapdoors[node_name] then
		-- A trapdoor
		return {
			pos = pos,
			open = function(self, player)
				if self:state() then
					return false
				end
				return doors.trapdoor_toggle(self.pos, nil, player)
			end,
			close = function(self, player)
				if not self:state() then
					return false
				end
				return doors.trapdoor_toggle(self.pos, nil, player)
			end,
			toggle = function(self, player)
				return doors.trapdoor_toggle(self.pos, nil, player)
			end,
			state = function(self)
				return minetest.get_node(self.pos).name:sub(-5) == "_open"
			end
		}
	else
		return nil
	end
end

local doors_hidden = {
	description = S("Hidden Door Segment"),
	inventory_image = "doors_hidden_segment.png^default_invisible_node_overlay.png",
	wield_image = "doors_hidden_segment.png^default_invisible_node_overlay.png",
	drawtype = "airlike",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	-- has to be walkable for falling nodes to stop falling.
	walkable = true,
	pointable = false,
	diggable = false,
	buildable_to = false,
	floodable = false,
	drop = "",
	groups = {not_in_creative_inventory = 1},
	on_blast = function() end,
	-- 1px block inside door hinge near node top
	collision_box = {
		type = "fixed",
		fixed = {-15/32, 13/32, -15/32, -13/32, 1/2, -13/32},
	},
}

-- this hidden node is placed on top of the bottom, and prevents
-- nodes from being placed in the top half of the door.
minetest.register_node("doors:hidden", table.copy(doors_hidden))
doors_hidden.walkable = false
minetest.register_node("doors:hidden_", table.copy(doors_hidden))

-- table used to aid door opening/closing
local transform = {
	{
		{v = "_a", param2 = 3},
		{v = "_a", param2 = 0},
		{v = "_a", param2 = 1},
		{v = "_a", param2 = 2},
	},
	{
		{v = "_c", param2 = 1},
		{v = "_c", param2 = 2},
		{v = "_c", param2 = 3},
		{v = "_c", param2 = 0},
	},
	{
		{v = "_b", param2 = 1},
		{v = "_b", param2 = 2},
		{v = "_b", param2 = 3},
		{v = "_b", param2 = 0},
	},
	{
		{v = "_d", param2 = 3},
		{v = "_d", param2 = 0},
		{v = "_d", param2 = 1},
		{v = "_d", param2 = 2},
	},
}

local function remove_hidden(pos)
	for _,ddir in ipairs({vector.new(-1,0,0),vector.new(0,0,-1),vector.new(1,0,0),vector.new(0,0,1)}) do
		for _,i in ipairs({0,1}) do
			local npos = vector.add(
				vector.add(pos, ddir),
				vector.new(0,i,0)
			)

			local localnode = minetest.get_node(npos).name
			if localnode == "doors:hidden" or localnode == "doors:hidden_" then
				minetest.remove_node(npos)
			end
		end
	end
end
local function set_hidden(pos, ddir, def, mul, v)
	remove_hidden(pos)

	if mul then
		if ddir == 0 then
			mul = vector.new(0,0,-1)
		elseif ddir == 1 then
			mul = vector.new(-1,0,0)
		elseif ddir == 2 then
			mul = vector.new(0,0,1)
		else
			mul = vector.new(1,0,0)
		end
	end
	local meta = minetest.get_meta(pos):get_int("original_param2")
	local mm = -1
	if meta == 1 or meta == 3 then
		mm = 1
	end
	if ddir == 0 then
		ddir = vector.new(-1*mm,0,0)
	elseif ddir == 1 then
		ddir = vector.new(0,0,-1*mm)
	elseif ddir == 2 then
		ddir = vector.new(1*mm,0,0)
	else
		ddir = vector.new(0,0,1*mm)
	end


	for _,i in ipairs({0,1}) do
		local npos = vector.add(
			vector.add(pos, ddir),
			vector.new(0,i,0)
		)
		local cpos = npos
		if mul then
			cpos = vector.add(
				vector.add(pos, mul),
				vector.new(0,i,0)
			)
		end

		local localnode = minetest.registered_nodes[minetest.get_node(cpos).name]
		if localnode.walkable or not localnode.buildable_to then
			minetest.sound_play("doors_door_blocked",
				{pos = pos, gain = def.door.gains[1], max_hear_distance = 10}, true)
			return true
		end
		minetest.set_node(
			cpos, {name = "doors:hidden_"}
		)
	end
end

function doors.door_toggle(pos, node, clicker)
	local meta = minetest.get_meta(pos)
	node = node or minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	local name = def.door.name

	local state = meta:get_string("state")
	if state == "" then
		-- fix up lvm-placed right-hinged doors, default closed
		if node.name:sub(-2) == "_b" then
			state = 2
		else
			state = 0
		end
	else
		state = tonumber(state)
	end

	replace_old_owner_information(pos)


	-- until Lua-5.2 we have no bitwise operators :(
	if state % 2 == 1 then
		state = state - 1
	else
		state = state + 1
	end

	local dir = node.param2

	-- It's possible param2 is messed up, so, validate before using
	-- the input data. This indicates something may have rotated
	-- the door, even though that is not supported.
	if not transform[state + 1] or not transform[state + 1][dir + 1] then
		return false
	end


	local ddir = transform[state + 1][dir+1].param2

	if def.door_width > 1 then -- run some checks and add build protection if a large door
		if set_hidden(pos, ddir, def) then
			minetest.chat_send_player(clicker:get_player_name(), "Door is blocked!")
			return false
		end
	end

	if state % 2 == 0 then -- play sounds if no obstruction
		minetest.sound_play(def.door.sounds[1],
			{pos = pos, gain = def.door.gains[1], max_hear_distance = 10}, true)
	else
		minetest.sound_play(def.door.sounds[2],
			{pos = pos, gain = def.door.gains[2], max_hear_distance = 10}, true)
	end


	minetest.swap_node(pos, {
		name = name .. transform[state + 1][dir+1].v,
		param2 = transform[state + 1][dir+1].param2
	})

	--if def.animations.open then
		--set_animation(def.animations.open, 24, 0)
	--end

	meta:set_int("state", state)

	return
end


local function on_place_node(place_to, newnode,
	placer, oldnode, itemstack, pointed_thing)
	-- Run script hook
	for _, callback in ipairs(minetest.registered_on_placenodes) do
		-- Deepcopy pos, node and pointed_thing because callback can modify them
		local place_to_copy = {x = place_to.x, y = place_to.y, z = place_to.z}
		local newnode_copy =
			{name = newnode.name, param1 = newnode.param1, param2 = newnode.param2}
		local oldnode_copy =
			{name = oldnode.name, param1 = oldnode.param1, param2 = oldnode.param2}
		local pointed_thing_copy = {
			type  = pointed_thing.type,
			above = vector.new(pointed_thing.above),
			under = vector.new(pointed_thing.under),
			ref   = pointed_thing.ref,
		}
		callback(place_to_copy, newnode_copy, placer,
			oldnode_copy, itemstack, pointed_thing_copy)
	end

end


function doors.register(name, def)
	if not name:find(":") then
		name = "doors:" .. name
	end


	minetest.register_craftitem(":" .. name, {
		description = def.description,
		inventory_image = def.inventory_image,
		groups = table.copy(def.groups),

		on_place = function(itemstack, placer, pointed_thing)
			local pos

			if pointed_thing.type ~= "node" then
				return itemstack
			end

			local doorname = itemstack:get_name()
			local node = minetest.get_node(pointed_thing.under)
			local pdef = minetest.registered_nodes[node.name]
			if pdef and pdef.on_rightclick and
					not (placer and placer:is_player() and
					placer:get_player_control().sneak) then
				return pdef.on_rightclick(pointed_thing.under,
						node, placer, itemstack, pointed_thing)
			end

			if pdef and pdef.buildable_to then
				pos = pointed_thing.under
			else
				pos = pointed_thing.above
				node = minetest.get_node(pos)
				pdef = minetest.registered_nodes[node.name]
				if not pdef or not pdef.buildable_to then
					return itemstack
				end
			end

			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			local top_node = minetest.get_node_or_nil(above)
			local topdef = top_node and minetest.registered_nodes[top_node.name]

			if not topdef or not topdef.buildable_to then
				return itemstack
			end

			local pn = placer and placer:get_player_name() or ""
			if minetest.is_protected(pos, pn) or minetest.is_protected(above, pn) then
				return itemstack
			end

			local dir = placer and minetest.dir_to_facedir(placer:get_look_dir()) or 0

			local ref = {
				{x = -1, y = 0, z = 0},
				{x = 0, y = 0, z = 1},
				{x = 1, y = 0, z = 0},
				{x = 0, y = 0, z = -1},
			}

			local aside = {
				x = pos.x + ref[dir + 1].x,
				y = pos.y + ref[dir + 1].y,
				z = pos.z + ref[dir + 1].z,
			}



			local state = 0
			if minetest.get_item_group(minetest.get_node(aside).name, "door") == 1 then
				state = state + 2
				minetest.set_node(pos, {name = doorname .. "_b", param2 = dir})
				minetest.set_node(above, {name = "doors:hidden", param2 = (dir + 3) % 4})
			else
				minetest.set_node(pos, {name = doorname .. "_a", param2 = dir})
				minetest.set_node(above, {name = "doors:hidden", param2 = dir})
			end

			local meta = minetest.get_meta(pos)
			--minetest.set_metadata()
			meta:set_int("original_param2", dir)

			local ddir = transform[state+1][dir+1].param2

			if def.door_width > 1 then -- run some checks and add build protection if a large door
				if set_hidden(pos, ddir, def, true) then
					minetest.chat_send_player(placer:get_player_name(), "Door is blocked!")
					minetest.dig_node(pos)
					return
				end
			end

			meta:set_int("state", state)

			if def.protected then
				meta:set_string("owner", pn)
				meta:set_string("infotext", def.description .. "\n" .. S("Owned by @1", pn))
			end

			if not minetest.is_creative_enabled(pn) then
				itemstack:take_item()
			end



			minetest.sound_play(def.sounds.place, {pos = pos}, true)

			on_place_node(pos, minetest.get_node(pos),
				placer, node, itemstack, pointed_thing)


			return itemstack
		end
	})
	def.inventory_image = nil

	if def.recipe then
		minetest.register_craft({
			output = name,
			recipe = def.recipe,
		})
	end
	def.recipe = nil

	if not def.sounds then
		def.sounds = {"open.ogg", "close.ogg"}
	end

	if not def.sound_open then
		def.sound_open = "doors_door_open"
	end

	if not def.sound_close then
		def.sound_close = "doors_door_close"
	end

	if not def.gain_open then
		def.gain_open = 0.3
	end

	if not def.gain_close then
		def.gain_close = 0.3
	end

	def.groups.not_in_creative_inventory = 1
	def.groups.door = 1
	def.drop = name
	def.door = {
		name = name,
		sounds = {def.sound_close, def.sound_open},
		gains = {def.gain_close, def.gain_open},
	}
	if not def.on_rightclick then
		def.on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			doors.door_toggle(pos, node, clicker)
			return itemstack
		end
	end

	def.after_dig_node = function(pos, node, meta, digger)
		minetest.remove_node({x = pos.x, y = pos.y + 1, z = pos.z})
		remove_hidden(pos)
		minetest.check_for_falling({x = pos.x, y = pos.y + 1, z = pos.z})
	end
	def.on_rotate = function(pos, node, user, mode, new_param2)
		return false
	end

	if def.protected then
		def.can_dig = true
		def.on_blast = function() end
		def.on_key_use = function(pos, player)
			local door = doors.get(pos)
			door:toggle(player)
		end
		def.on_skeleton_key_use = function(pos, player, newsecret)
			replace_old_owner_information(pos)
			local meta = minetest.get_meta(pos)
			local owner = meta:get_string("owner")
			local pname = player:get_player_name()

			-- verify placer is owner of lockable door
			if owner ~= pname then
				minetest.record_protection_violation(pos, pname)
				minetest.chat_send_player(pname, S("You do not own this locked door."))
				return nil
			end

			local secret = meta:get_string("key_lock_secret")
			if secret == "" then
				secret = newsecret
				meta:set_string("key_lock_secret", secret)
			end

			return secret, S("a locked door"), owner
		end
		def.node_dig_prediction = ""
	else
		def.on_blast = function(pos, intensity)
			minetest.remove_node(pos)
			-- hidden node doesn't get blasted away.
			minetest.remove_node({x = pos.x, y = pos.y + 1, z = pos.z})
			return {name}
		end
	end

	def.on_destruct = function(pos)
		minetest.remove_node({x = pos.x, y = pos.y + 1, z = pos.z})
	end

	def.drawtype = "mesh"
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.sunlight_propagates = true
	def.walkable = true
	def.door_width = def.door_width or 1
	def.is_ground_content = false
	def.buildable_to = false
	def.selection_box = {type = "fixed", fixed = def.box1 or {-1/2,-1/2,-1/2,1/2,3/2,-6/16}}
	def.collision_box = {type = "fixed", fixed = def.box1 or {-1/2,-1/2,-1/2,1/2,3/2,-6/16}}
	def.use_texture_alpha = def.use_texture_alpha or "clip"

	def.mesh = def.mesh1 or "door_a.b3d"
	minetest.register_node(":" .. name .. "_a", table.copy(def))
	minetest.register_node(":" .. name .. "_d", table.copy(def))

	def.selection_box = {type = "fixed", fixed = def.box2 or {-1/2,-1/2,-1/2,1/2,3/2,-6/16}}
	def.collision_box = {type = "fixed", fixed = def.box2 or {-1/2,-1/2,-1/2,1/2,3/2,-6/16}}
	def.mesh = def.mesh2 or "door_b.b3d"
	minetest.register_node(":" .. name .. "_b", table.copy(def))
	minetest.register_node(":" .. name .. "_c", table.copy(def))



	doors.registered_doors[name .. "_a"] = true
	doors.registered_doors[name .. "_b"] = true
	doors.registered_doors[name .. "_c"] = true
	doors.registered_doors[name .. "_d"] = true
end

-- Capture mods using the old API as best as possible.
function doors.register_door(name, def)
	if def.only_placer_can_open then
		def.protected = true
	end
	def.only_placer_can_open = nil

	local i = name:find(":")
	local modname = name:sub(1, i - 1)
	if not def.tiles then
		if def.protected then
			def.tiles = {{name = "doors_door_steel.png", backface_culling = true}}
		else
			def.tiles = {{name = "doors_door_wood.png", backface_culling = true}}
		end
		minetest.log("warning", modname .. " registered door \"" .. name .. "\" " ..
				"using deprecated API method \"doors.register_door()\" but " ..
				"did not provide the \"tiles\" parameter. A fallback tiledef " ..
				"will be used instead.")
	end

	doors.register(name, def)
end

----fuels----
local modpath = minetest.get_modpath("doors")

dofile(modpath .. "/hobbit.lua")
