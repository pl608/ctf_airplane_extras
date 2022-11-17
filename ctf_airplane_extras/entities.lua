
minetest.register_entity("ctf_airplane_extras:" .. "missile_blue", {
        
    initial_properties = {
        physical = true,
        visual = "sprite",
        --mesh = "missile.b3d",
        backface_culling = false,
        visual_size = {x = 1, y = 1, z = 1},
        textures = {"missile_blue.png"},
        collisionbox = {-.5, -.5, -.25, .5, .5, .25},
        pointable = false,
        static_save = false,
    },
    on_step = function(self,var,moveresult)
        local obj = self.object
        obj:set_acceleration({x=0,y=-9.8,z=0})
        if moveresult.collides and moveresult.collisions then
            internal.explode(obj, 10)
        end
    end
})

minetest.register_entity("ctf_airplane_extras:" .. "missile_red", {
        
    initial_properties = {
        physical = true,
        visual = "sprite",
        --mesh = "missile.b3d",
        backface_culling = false,
        visual_size = {x = 1, y = 1, z = 1},
        textures = {"missile_red.png"},
        collisionbox = {-.5, -.5, -.25, .5, .5, .25},
        pointable = false,
        static_save = false,
    },
    on_step = function(self,var,moveresult)
        local obj = self.object
        obj:set_acceleration({x=0,y=-9.8,z=0})
        if moveresult.collides and moveresult.collisions then
            internal.explode(obj, 10)
        end
    end
})
