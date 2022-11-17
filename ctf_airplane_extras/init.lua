extras = {}
internal = {}

extras.auto_spawn = true --doesnt work yet and is ignored

image_timout = 4
airplanes_destroyed_red = 1
airplanes_destroyed_blue = 0
airutils.fuel = {["ctf_airplane_extras:gasoline"] = 15/2}

local zero = {x=0,y=0,z=0}

function extras.airplane_destroy(color)
    if color == "red" then
        airplanes_destroyed_red = airplanes_destroyed_red+1
    end
    if color == "blue" then
        airplanes_destroyed_blue = airplanes_destroyed_blue+1
    end
end

function internal.spawn_plane(pos, node, other, is_red)
    --if airplanes_destroyed_red <= 0 then return end
    if other:get_wielded_item():get_name() == "ctf_map:adminpick" then return end
    
    if is_red then 
        if airplanes_destroyed_red <= 0 then
            return 
        end 
        airplanes_destroyed_red = airplanes_destroyed_red-1 
    end
    if not is_red then 
        if airplanes_destroyed_blue <= 0 then 
            return 
        end 
        airplanes_destroyed_blue = airplanes_destroyed_blue-1 
    end
    
    local pointed_pos = pos
    --local node_below = minetest.get_node(pointed_pos).name
    --local nodedef = minetest.registered_nodes[node_below]
    
    pointed_pos.y=pointed_pos.y+2.5
    local pa28_ent = minetest.add_entity(pointed_pos, "pa28:pa28")
    return itemstack
end

function extras.DropBomb(player)
    minetest.add_entity(player:get_pos(), "ctf_airplane_extras:missile_blue")
end

function internal.explode(obj, radius)
    local pos = obj:get_pos()
    --minetest.add_entity(pos,"ctf_airplane_extras:boom")
    minetest.add_particle({
        pos = pos,
        velocity = {x=0, y=0, z=0},
        acceleration = {x=0, y=0, z=0},
        expirationtime = 0.6,
        size = 60,
        collisiondetection = false,
        collision_removal = false,
        object_collision = false,
        vertical = false,
        texture = "grenades_boom.png",
        glow = 100
    })
    local objs = minetest.get_objects_inside_radius(pos, radius)
	for _, obj in pairs(objs) do
		local obj_pos = obj:get_pos()
		local dist = math.max(1, vector.distance(pos, obj_pos))

		local damage = (4 / dist) * radius
        if obj:is_player() then
            obj:set_hp(obj:get_hp() - damage)
        else
            local luaobj = obj:get_luaentity()

            -- object might have disappeared somehow
            if luaobj then
				local do_damage = true
				local do_knockback = true
				local entity_drops = {}
				local objdef = minetest.registered_entities[luaobj.name]

				if objdef and objdef.on_blast then
					do_damage, do_knockback, entity_drops = objdef.on_blast(luaobj, damage)
				end

				if do_knockback then
					local obj_vel = obj:get_velocity()
					--[[obj:set_velocity(calc_velocity(pos, obj_pos,
							obj_vel, radius * 10))]]
				end
				if do_damage then
                    --if not obj:get_armor_groups().imortal then
                            obj:punch(obj, 1.0, {
                                full_punch_interval = 1.0,
                                damage_groups = {fleshy = damage},
                            }, nil)
                    --end
				end
				for _, item in pairs(entity_drops) do
					add_drop(drops, item)
				end
			end

        end
    end
    obj:remove()
end

dofile(minetest.get_modpath("ctf_airplane_extras") .. "/blocks.lua")
dofile(minetest.get_modpath("ctf_airplane_extras") .. "/items.lua")
dofile(minetest.get_modpath("ctf_airplane_extras") .. "/entities.lua")