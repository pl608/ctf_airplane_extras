extras = {
}
internal = {
}


internal.colors ={
    blue='#0063b0',
    green='#4ee34c',
    orange='#ff8b0e',
    red='#dc1818',
    purple='#a437ff',
}


extras.auto_spawn = true --doesnt work yet and is ignored
extras.max_power = 500 --*technicly*should not be messed with but its fun
internal.speed = -139 --better off ground detection then before
internal.use_teams = true -- respect teams on explode
internal.explosion_radius =  4
internal.drop_radius_addition =  4
internal.cooldown = 15
--items that override bomb dropping
bomb_override = {   "ctf_ranged:pistol",
                    "ctf_ranged:rifle",
                    "ctf_ranged:shotgun",
                    "ctf_ranged:smg",
                    "ctf_ranged:sniper",
                    "ctf_ranged:sniper_magnum",
                    "ctf_airplane_extras:gasoline"
} 
internal.airplanes_destroyed = {}

airutils.fuel = {["ctf_airplane_extras:gasoline"] = 15/2} -- just kicked biofuel off the market :P
bomb_dejitter_time = 1--drop rate in secs higher the less bombs dropped per sec ie 10 = .1 dps 1 = 1 dps .1 = 1 dps(only intergers allowed :) and 0 means you die :P
last_drop = 0 -- need to move this to player meta so that you can spawn bombs faster. for lag reasons not messing with it now

local zero = {x=0,y=0,z=0}
--pa28/utilites.lua:33
function extras.paint_team(self,player,color)
    if color==nil then
        if player == nil then
            return
        end
        color = ctf_teams.get(player)
    end
    local texture_name = "pa28_painting.png"
    self.team = ctf_teams.get(player)
    minetest.log(tostring(self.team))
    if self.team ~= nil then
        self._color = colstr
        local l_textures = self.initial_properties.textures
        for _, texture in ipairs(l_textures) do
            local indx = texture:find(texture_name)
            if indx then
                l_textures[_] = texture_name.."^[multiply:".. internal.colors[color]
            end
        end
	    self.object:set_properties({textures=l_textures})
    end
end

--pa28/utilities.lua:234,
function extras.airplane_destroy(color)
    --if internal.airplanes_destroyed[color] then internal.airplanes_destroyed[color] = 1
    --end
    --internal.airplanes_destroyed[color] = internal.airplanes_destroyed[color] +1
    -- nuthin here :P
end
--pa28/entites.lua:366
function extras.DropBomb(self, player)
    local s = self.speed_a
    local team = ctf_teams.get(player)
    function drop(color)
        local inventory_item = "ctf_airplane_extras:missile_token"
        local inv = player:get_inventory()
        local weild = player:get_wielded_item()
        
        if check_override(wield) then
            return
        end

        if (os.time()-last_drop >= bomb_dejitter_time and s < internal.speed) then -- to avoid bombs blowing up bombs, and also is a control factor
            last_drop = os.time()
            if inv:contains_item("main", inventory_item) then
                local stack = ItemStack(inventory_item .. " 1")
                inv:remove_item("main", stack)
                if ctf_teams.get(player) == color then -- kinda reduntant but ig its an extra check
                    minetest.add_entity(player:get_pos(), "ctf_airplane_extras:missile_" .. color)
                else
                    minetest.add_entity(player:get_pos(), "ctf_airplane_extras:missile_blue")
                end
            else
                return
            end
        end
    end
    --drop("red")
    --drop("orange")
    --drop("purple")
    --drop("blue")
    drop(team)
end

function internal.spawn_plane(pos, node, other, color)
    --if airplanes_destroyed_red <= 0 then return end
    --if other ~= nil then 
    --    if other:get_wielded_item():get_name() or "did not work" == "ctf_map:adminpick" then 
    --        return 
    --    end 
    --end
    --if plane_spawned[pos_tostring(pos)] then return else plane_spawned[pos_tostring(pos)] = true end
    
    --if internal.airplanes_destroyed[color] <= 0 then
    --    return 
    --else 
    --    internal.airplanes_destroyed[color] = internal.airplanes_destroyed[color]-1 
    --end
    
    
    local pointed_pos = pos
    --local node_below = minetest.get_node(pointed_pos).name
    --local nodedef = minetest.registered_nodes[node_below]
    
    pointed_pos.y=pointed_pos.y+2.5
    --plane_spawned[pos_tostring(pos)] = true
    local pa28_ent = minetest.add_entity(pointed_pos, "pa28_custom:pa28")
    --extras.paint_team(pa28_ent, nil, color) -- should color plane on spawn 
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
                internal.explode(obj, internal.explosion_radius, team)
            end
        end
    })
end

function pos_tostring(pos)
    return "x=" .. tostring(pos.x) .. ",y=".. tostring(pos.y) .. ",z=".. tostring(pos.z).. ")"
end

function internal.remove_nodes(pos, radius, disable_drop_nodes)
    if not disable_drop_nodes then disable_drop_nodes = true end
    local pr = PseudoRandom(os.time())
    for z = -radius, radius do
        for y = -radius, radius do
            for x = -radius, radius do
                -- do fancy stuff
                local r = vector.length(vector.new(x, y, z))
                if (radius * radius) / (r * r) >= (pr:next(80, 125) / 100) then
                    local p = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
                    if check_immortal(p) == true then
                        return
                    else
                        minetest.remove_node(p)
                    end
                end
            end
        end
    end
    if disable_drop_nodes ~= false then
        local radius = radius+internal.drop_radius_addition
        for z = -radius, radius do
            for y = -radius, radius do
                for x = -radius, radius do
                    -- do fancy stuff
                    local r = vector.length(vector.new(x, y, z))
                    if (radius * radius) / (r * r) >= (pr:next(80, 125) / 100) then
                        local p = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
                        if check_immortal(p) == true then
                            return
                        else
                            minetest.spawn_falling_node(p)
                        end
                    end
                end
            end
        end
    end
end
-- This is the fun part
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
    minetest.sound_play("grenades_explode", {
        pos = pos,
        gain = 2.0,
        max_hear_distance = 128,
    })
    local objs = minetest.get_objects_inside_radius(pos, radius)
    -- remove nodes
    internal.remove_nodes(pos, radius)
    --damage entites/players
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
    object:remove()
end

function check_immortal(pos)
    local node = minetest.get_node(pos)
    local def = minetest.registered_nodes[node.name]
    if not (def and def.groups) then 
        return
    else 
        if (def.groups.immortal) then
            return def.groups.immortal >= 1
        end
    end
end

function check_override(item)
    for z = 0, get_table_len(bomb_override) do
        if item == ItemStack(bomb_override[z]) then
            return true
        else
            return false
        end
    end
end

function pos_tostring(pos)
    return "x=" .. tostring(pos.x) .. ",y=".. tostring(pos.y) .. ",z=".. tostring(pos.z).. ")"
end

function get_table_len(table)
    local len = 0
    for k, v in pairs(table) do
        len = len+1
    end
    return len
end

-- DEBUG TOOLS
----[[
minetest.register_chatcommand('set_spawn', {
    params = "<color> <amount>",
	description = "set amount of planes in <color> to 10",
	privs = {interact = true},
    func = function(name, param)
        
        local pname, score = string.match(param, "^(.*) (.*)$")
        internal.airplanes_destroyed[pname] = 10
    end
})
minetest.register_chatcommand("vars", {
	params = "",
	description = "shows vars",
	privs = {interact = true},
    func = function(name, param)
        --local msg = "internal.use_teams = "..tostring(internal.use_teams)
        minetest.log("___________________________________________")
        minetest.log("speed = "..tostring(internal.speed))
        
    end
})

minetest.register_chatcommand("drop", {
	params = "",
	description = "drop bomb for testing purposes",
	privs = {interact = true},
    func = function(name, param)
        player = minetest.get_player_by_name(name)
        extras.DropBomb(player)
    end
})
--
----]]
dofile(minetest.get_modpath("ctf_airplane_extras") .. "/blocks.lua")
dofile(minetest.get_modpath("ctf_airplane_extras") .. "/items.lua")
dofile(minetest.get_modpath("ctf_airplane_extras") .. "/entities.lua")
dofile(minetest.get_modpath("ctf_airplane_extras") .. "/crafts.lua")
-- for showoff purposes only
--dofile(minetest.get_modpath("ctf_airplane_extras") .. "/display.lua") 