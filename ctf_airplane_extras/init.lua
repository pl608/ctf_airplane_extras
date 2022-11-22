extras = {}
internal = {}
--plane_spawned = {}

extras.auto_spawn = true --doesnt work yet and is ignored
extras.max_power = 150 --*technicly*should not be messed with but its fun
internal.use_teams = true -- respect teams on explode
internal.explosion_radius =  5

image_timout = 4
airplanes_destroyed_red = 0
airplanes_destroyed_blue = 0
airutils.fuel = {["ctf_airplane_extras:gasoline"] = 15/2}
bomb_dejitter_time = .25--drop rate in secs higher the less bombs dropped per sec ie 10 = .1 dps 1 = 1 dps .1 = 1 dps(only intergers allowed :) and 0 means you die :P
last_drop = 0

local zero = {x=0,y=0,z=0}

function extras.airplane_destroy(color)
    if color == "red" then
        airplanes_destroyed_red = airplanes_destroyed_red+1
    end
    if color == "blue" then
        airplanes_destroyed_blue = airplanes_destroyed_blue+1
    end
end
-- used in pa28/entites.lua:366
function extras.DropBomb(player)
    local team = ctf_teams.get(player)
    function drop(color)
        local inventory_item = "ctf_airplane_extras:missile_token"
        local inv = player:get_inventory()
        if os.time()-last_drop >= bomb_dejitter_time then -- to avoid bombs blowing up bombs, and also is a control factor
            last_drop = os.time()
            if inv:contains_item("main", inventory_item) then
                local stack = ItemStack(inventory_item .. " 1")
                inv:remove_item("main", stack)
                if ctf_teams.get(player) == color then
                    minetest.add_entity(player:get_pos(), "ctf_airplane_extras:missile_" .. color)
                else
                    minetest.add_entity(player:get_pos(), "ctf_airplane_extras:missile_blue")
                end
            else
                return
            end
        end
    end
    drop("red")
    drop("orange")
    drop("purple")
    drop("blue")
end

function internal.spawn_plane(pos, node, other, is_red)
    --if airplanes_destroyed_red <= 0 then return end
    if other ~= nil then if other:get_wielded_item():get_name() or "did not work" == "ctf_map:adminpick" then return end end
    --if plane_spawned[internal.pos_tostring(pos)] then return else plane_spawned[internal.pos_tostring(pos)] = true end
    if is_red then 
        if airplanes_destroyed_red <= 0 then
            return 
        else 
            airplanes_destroyed_red = airplanes_destroyed_red-1 
        end
    end
    if not is_red then 
        if airplanes_destroyed_blue <= 0 then 
            return 
        else 
            airplanes_destroyed_blue = airplanes_destroyed_blue-1 
        end
    end
    
    local pointed_pos = pos
    --local node_below = minetest.get_node(pointed_pos).name
    --local nodedef = minetest.registered_nodes[node_below]
    
    pointed_pos.y=pointed_pos.y+2.5
    --plane_spawned[internal.pos_tostring(pos)] = true
    local pa28_ent = minetest.add_entity(pointed_pos, "pa28_custom:pa28")
    return itemstack
end

function internal.register_bomb(team) 
    local one_step = false    
    minetest.register_entity("ctf_airplane_extras:missile_"..team, {   
        initial_properties = {
            physical = true,
            visual = "sprite",
            backface_culling = false,
            visual_size = {x = 1, y = 1, z = 1},
            textures = {"missile_" .. team..".png"},
            collisionbox = {-.5, -.5, -.25, .5, .5, .25},
            pointable = false,
            static_save = false,
        },
        on_step = function(self,var,moveresult)
            local obj = self.object
            obj:set_acceleration({x=0,y=-9.8,z=0})
            if moveresult.collides and moveresult.collisions then
                if one_step then
                    internal.explode(obj, internal.explosion_radius, team)
                    one_step = false
                else
                    one_step=true
                end
            end
        end
    })
end

function internal.pos_tostring(pos)
    return "x=" .. tostring(pos.x) .. ",y=".. tostring(pos.y) .. ",z=".. tostring(pos.z).. ")"
end

function internal.remove_nodes(pos, radius)
    local pr = PseudoRandom(os.time())
    for z = -radius, radius do
    for y = -radius, radius do
    for x = -radius, radius do
        -- do fancy stuff
        local r = vector.length(vector.new(x, y, z))
        if (radius * radius) / (r * r) >= (pr:next(80, 125) / 100) then
            local p = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
            minetest.log(minetest.get_node(pos).name.." destroyed by a bomb at "..internal.pos_tostring(p) or "failed get_node at "..internal.pos_tostring(p))
            minetest.set_node(p, {name="air"})
        end
    end
    end
    end
end

function internal.explode(object, radius, team)
    local pos = object:get_pos()
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
    internal.remove_nodes(pos, radius)
    object:remove()
end
--[[
minetest.register_abm({
	nodenames = {"ctf_airplane_extras:airplane_spawnblock_red"},
	--neighbors = {"default:water_source", "default:water_flowing"},
	interval = 5.0, -- Run every 10 seconds
	chance = 2, -- Select every 1 in 2 nodes
	action = function(pos, node, active_object_count, active_object_count_wider)
		internal.spawn_plane(pos, node, nil, true)
	end
})]]

-- DEBUG TOOLS

minetest.register_chatcommand("vars", {
	params = "",
	description = "shows vars",
	privs = {interact = true},
    func = function(name, param)
        --local msg = "internal.use_teams = "..tostring(internal.use_teams)
        minetest.log("___________________________________________")
        minetest.log("lastdrop-os.time() = "..tostring(last_drop-os.time()))
        minetest.log("lastdrop = "..tostring(last_drop))
        minetest.log("os.time() = "..tostring(os.time()))
        minetest.log("internal.explosion_radius = "..tostring(internal.explosion_radius))
        minetest.log("airplanes_destroyed_red = "..tostring(airplanes_destroyed_red))
        minetest.log("airplanes_destroyed_blue = "..tostring(airplanes_destroyed_blue))
    end
})


dofile(minetest.get_modpath("ctf_airplane_extras") .. "/blocks.lua")
dofile(minetest.get_modpath("ctf_airplane_extras") .. "/items.lua")
dofile(minetest.get_modpath("ctf_airplane_extras") .. "/entities.lua")
dofile(minetest.get_modpath("ctf_airplane_extras") .. "/crafts.lua")
-- for show off purposes only
--dofile(minetest.get_modpath("ctf_airplane_extras") .. "/display.lua") 