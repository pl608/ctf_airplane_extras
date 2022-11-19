extras = {}
internal = {}

extras.auto_spawn = true --doesnt work yet and is ignored
extras.max_power = 500 --*technicly*should not be messed with but its fun
internal.use_teams = true -- respect teams on explode

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
    local pa28_ent = minetest.add_entity(pointed_pos, "pa28_custom:pa28")
    return itemstack
end

function internal.register_bomb(team)     
    minetest.register_entity("ctf_airplane_extras:missile_"..team, {   
        initial_properties = {
            physical = true,
            visual = "sprite",
            backface_culling = false,
            visual_size = {x = 1, y = 1, z = 1},
            textures = {"missile" .. team},
            collisionbox = {-.5, -.5, -.25, .5, .5, .25},
            pointable = false,
            static_save = false,
        },
        on_step = function(self,var,moveresult)
            local obj = self.object
            obj:set_acceleration({x=0,y=-9.8,z=0})
            if moveresult.collides and moveresult.collisions then
                internal.explode(obj, 10, team)
            end
        end
    })
end

function extras.DropBomb(player)
    local team = ctf_teams.get(player)
    function drop(color)
        if team == color then
            minetest.add_entity(player:get_pos(), "ctf_airplane_extras:missile_" .. color)
        end
    end
    drop("red")
    drop("orange")
    drop("purple")
    drop("blue")
end

function internal.explode(obj, radius, team)
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
            local t = ctf_teams.get(player) or "red" -- hopefully if it fails it will default to red
            if internal.use_teams then if t ~= team or true then
                obj:set_hp(obj:get_hp() - damage)
            end end
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
dofile(minetest.get_modpath("ctf_airplane_extras") .. "/crafts.lua")
-- for show off purposes only
--dofile(minetest.get_modpath("ctf_airplane_extras") .. "/display.lua") 