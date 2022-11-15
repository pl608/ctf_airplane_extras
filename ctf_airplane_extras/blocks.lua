
--ctf_airplane_extras nodes:

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

