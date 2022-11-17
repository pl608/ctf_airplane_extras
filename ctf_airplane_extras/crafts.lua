minetest.register_craftitem("ctf_airplane_extras:missile_fin_blue", {
    description = "Missile Fins",
    inventory_image = "missile_blue_fin.png"
})
minetest.register_craft({
    output = "ctf_airplane_extras:missile_fin_blue",
    recipe = {
        {"default:steel_ingot", "", "default:steel_ingot"},
        {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
        {"default:steel_ingot", "", "default:steel_ingot"},
    }
})
minetest.register_craft({
    output = "ctf_airplane_extras:missile_blue",
    recipe = {
        {"default:steel_ingot", "ctf_airplane_extras:missile_fin_blue", "default:steel_ingot"},
        {"default:steel_ingot", "tnt:tnt", "default:steel_ingot"},
        {"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
    }
})