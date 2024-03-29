require 'cairo'

background=0xffffff
forground=0xffffff

settings_table = {
    {
        name='memperc',
        arg='',
        max=100,
        bg_colour=background,
        bg_alpha=0.1,
        fg_colour=forground,
        fg_alpha=0.5,
        x=170, y=0,
        radius=80,
        thickness=7,
        start_angle=140,
        end_angle=270
    },
    {
        name='fs_used_perc',
        arg='/',
        max=100,
        bg_colour=background,
        bg_alpha=0.1,
        fg_colour=forground,
        fg_alpha=0.5,
        x=300, y=100,
        radius=80,
        thickness=7,
        start_angle=180,
        end_angle=295
    }
}

cpu_ring={
    count=12,
    thickness=3,
    bg_colour=background,
    bg_alpha=0.1,
    fg_colour=forground,
    fg_alpha=0.6,
    x=300, y=0,
    radius=100,
}

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

function copy(obj)
    local res = {}
    for k,v in pairs(obj) do
        res[k] = v
    end
    return res
end

function draw_cpu_rings(cr)
    for i=1,cpu_ring['count'],1 do
        local pct=tonumber(conky_parse(string.format('${cpu cpu%s}', i-1)))/100
        local settings=copy(cpu_ring)
        settings['start_angle']=-180
        settings['end_angle']=-90
        settings['radius']=cpu_ring['radius']-(i*cpu_ring['thickness'])
        settings['fg_alpha'] = cpu_ring['fg_alpha']
        draw_ring(cr,pct,settings)
    end
end



function conky_main()
    local function setup_rings(cr,pt)
        local str=string.format('${%s %s}',pt['name'],pt['arg'])
        local str=conky_parse(str)
        local value=tonumber(str)
        local pct=value/pt['max']
        draw_ring(cr,pct,pt)
    end

    -- Check that Conky has been running for at least 5s
    if conky_window==nil then return end

    local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)
    local cr=cairo_create(cs)
    local updates=conky_parse('${updates}')
    update_num=tonumber(updates)


    if update_num>5 then
        draw_cpu_rings(cr)
        for i in pairs(settings_table) do
            setup_rings(cr,settings_table[i])
        end
    end
end
