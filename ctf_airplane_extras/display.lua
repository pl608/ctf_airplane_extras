
minetest.register_node("ctf_airplane_extras:airplane_spawnblock_display",{
    description = "Airplane Spawn Block",
    tiles = {"default_stone_brick.png^pa28.png"},
})

minetest.register_entity("ctf_airplane_extras:missile_red_display", {
        
    initial_properties = {
        physical = true,
        visual = "sprite",
        backface_culling = false,
        visual_size = {x = 1, y = 1, z = 1},
        textures = {"missile_red.png"},
        collisionbox = {-.5, -.5, -.25, .5, .5, .25},
        pointable = true,
        static_save = false,
    }
})
minetest.register_entity("ctf_airplane_extras:missile_blue_display", {
        
    initial_properties = {
        physical = true,
        visual = "sprite",
        backface_culling = false,
        visual_size = {x = 1, y = 1, z = 1},
        textures = {"missile_blue.png"},
        collisionbox = {-.5, -.5, -.25, .5, .5, .25},
        pointable = true,
        static_save = false,
    }
})
minetest.register_craftitem("ctf_airplane_extras:d_missile_red", {
    description = "display missile",
    inventory_image = "missile_red.png",
    on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
        
        local pointed_pos = pointed_thing.under
        --local node_below = minetest.get_node(pointed_pos).name
        --local nodedef = minetest.registered_nodes[node_below]
        
		pointed_pos.y=pointed_pos.y+1.5
		local pa28_ent = minetest.add_entity(pointed_pos, "ctf_airplane_extras:missile_red_display")
        itemstack:take_item()
		return itemstack
	end,
})


minetest.register_craftitem("ctf_airplane_extras:d_missile_blue", {
    description = "display missile",
    inventory_image = "missile_blue.png",
    on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
        
        local pointed_pos = pointed_thing.under
        --local node_below = minetest.get_node(pointed_pos).name
        --local nodedef = minetest.registered_nodes[node_below]
        
		pointed_pos.y=pointed_pos.y+1.5
		local pa28_ent = minetest.add_entity(pointed_pos, "ctf_airplane_extras:missile_blue_display")
		if pa28_ent and placer then
            local ent = pa28_ent:get_luaentity()
            local owner = placer:get_player_name()
            ent.owner = owner
			pa28_ent:set_yaw(placer:get_look_horizontal())
			itemstack:take_item()
		end

		return itemstack
	end,
})