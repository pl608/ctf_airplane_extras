minetest.register_craftitem("ctf_airplane_extras:block_placer_red",{
    description = "Red Block Placer",
    inventory_image = "default_stone_brick.png^pa28.png",
    on_place = function(itemstack, placer, pointed_thing)
        airplanes_destroyed_red = airplanes_destroyed_red+1
        minetest.set_node(pointed_thing.under,{name="ctf_airplane_extras:airplane_spawnblock_red"})
    end
})

minetest.register_craftitem("ctf_airplane_extras:block_placer_blue",{
    description = "Blue Block Placer",
    inventory_image = "default_stone_brick.png^pa28_blue.png",
    on_place = function(itemstack, placer, pointed_thing)
        airplanes_destroyed_blue = airplanes_destroyed_blue+1
        minetest.set_node(pointed_thing.under,{name="ctf_airplane_extras:airplane_spawnblock_blue"})
    end
})

minetest.register_craftitem("ctf_airplane_extras:gasoline", {
    description = "Gasoline Can",
    inventory_image = "gasoline_fuel_can.png",
})

minetest.register_craftitem("ctf_airplane_extras:missile_tester",{
    description = "Missile",
    inventory_image = "missile_blue.png",
    on_place = function(itemstack, placer, pointed_thing)
        local pointed_pos = pointed_thing.under
		pointed_pos.y=pointed_pos.y+2.5
        minetest.add_entity(pointed_pos, "ctf_airplane_extras:missile_blue")
    end
})

minetest.register_craftitem("ctf_airplane_extras:missile_tester_red",{
    description = "Missile",
    inventory_image = "missile_red.png",
    on_place = function(itemstack, placer, pointed_thing)
        local pointed_pos = pointed_thing.under
		pointed_pos.y=pointed_pos.y+2.5
        minetest.add_entity(pointed_pos, "ctf_airplane_extras:missile_red")
    end
})