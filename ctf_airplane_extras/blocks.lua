
--ctf_airplane_extras nodes:
-- Note: only blue planes atm
minetest.register_node("ctf_airplane_extras:airplane_spawnblock_red",{
    description = "Airplane Spawn Block",
    --inventory_image = "default_stone_brick.png^pa28.png",
    tiles = {"default_stone_brick.png^pa28.png"},
    groups = {immortal = 1, not_in_creative_inventory=1},
    on_punch = function(pos, node, puncher)
        internal.spawn_plane(pos, node, puncher, true)
    end,
})
minetest.register_node("ctf_airplane_extras:airplane_spawnblock_blue",{
    description = "Airplane Spawn Block",
    --inventory_image = "default_stone_brick.png^pa28_blue.png",
    tiles = {"default_stone_brick.png^pa28_blue.png"},
    groups = {immortal = 1, not_in_creative_inventory=1},
    on_punch = function(pos, node, puncher)
        internal.spawn_plane(pos, node, puncher, false)
    end,
})

minetest.register_abm({
	nodenames = {"ctf_airplane_extras:airplane_spawnblock_red"},
	--neighbors = {"default:water_source", "default:water_flowing"},
	interval = 5.0, -- Run every 10 seconds
	chance = 2, -- Select every 1 in 2 nodes
	action = function(pos, node, active_object_count, active_object_count_wider)
		internal.spawn_plane(pos, node, true)
	end
})

minetest.register_abm({
	nodenames = {"ctf_airplane_extras:airplane_spawnblock_blue"},
	--neighbors = {"default:water_source", "default:water_flowing"},
	interval = 5.0, -- Run every 10 seconds
	chance = 2, -- Select every 1 in 2 nodes
	action = function(pos, node, active_object_count, active_object_count_wider)
		internal.spawn_plane(pos, node, false)
	end
})
