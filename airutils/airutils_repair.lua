local S = minetest.get_translator("airutils_custom")

-- trike repair
minetest.register_craftitem("airutils_custom:repair_tool",{
	description = "Repair Tool",
	inventory_image = "airutils_repair_tool.png",
})

minetest.register_craft({
    output = "airutils_custom:repair_tool",
    recipe = {
	    {"", "default:steel_ingot", ""},
	    {"", "default:steel_ingot", ""},
	    {"default:steel_ingot", "", "default:steel_ingot"},
    },
})

