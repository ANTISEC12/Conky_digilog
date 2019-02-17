--==============================================================================
--                            Conky_digilog.lua
--			ArchSUS Linux (conky_lua)
--
--  author  : #ANTISEC (soroush.afzalian@gmail.com)
--  version : v0.1
--  license : Distributed under the terms of GNU GPL version 3 or later
--
--==============================================================================
--yours upload max speed KB/s
up_speed = 1024
--yours download max speed KB/s
down_speed = 1024

settings_table = {
 
    {
        name='downspeedf',
        arg='wlp2s0',
        max=down_speed,
        bg_colour=0xffffff,
        bg_alpha=0.9,
        fg_colour=0x0066ff,
        fg_alpha=0.9,
        x=3270, y=1800,
        radius=215,
        thickness=10,
        start_angle=1,
        end_angle=270
    },
    {
        name='upspeedf',
        arg='wlp2s0',
        max=up_speed,
        bg_colour=0xffffff,
        bg_alpha=0.9,
        fg_colour=0x0066ff,
        fg_alpha=0.9,
        x=3270, y=1800,
        radius=230,
        thickness=10,
        start_angle=1,
        end_angle=270
    },
}

require 'cairo'

function rgb_to_r_g_b(colour,alpha)
	return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

function draw_ring(cr,t,pt)
	local w,h=conky_window.width,conky_window.height
	
	local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
	local bgc, bga, fgc, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']

	local angle_0=sa*(2*math.pi/360)-math.pi/2
	local angle_f=ea*(2*math.pi/360)-math.pi/2
	local t_arc=t*(angle_f-angle_0)

	-- Draw background ring

	cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
	cairo_set_line_width(cr,ring_w)
	cairo_stroke(cr)
	
	-- Draw indicator ring

	cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
	cairo_stroke(cr)		
end

function conky_ring_stats()
	local function setup_rings(cr,pt)
		local str=''
		local value=0
		
		str=string.format('${%s %s}',pt['name'],pt['arg'])
		str=conky_parse(str)
		
		value=tonumber(str)
		if value == nil then value = 0 end
		pct=value/pt['max']
		
		draw_ring(cr,pct,pt)
	end

	if conky_window==nil then return end
	local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)
	
	local cr=cairo_create(cs)	
	
	local updates=conky_parse('${updates}')
	update_num=tonumber(updates)
	
	if update_num>5 then
		for i in pairs(settings_table) do
			setup_rings(cr,settings_table[i])
		end
	end
   cairo_surface_destroy(cs)
  cairo_destroy(cr)
end
