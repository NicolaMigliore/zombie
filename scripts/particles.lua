--spawn smoke
function spawn_smoke(_x,_y,_colors,_opts)
	for i=0, 2+rnd(4) do
		local angle = _opts.angle or rnd()
		local max_size = _opts.max_size or 0.5+rnd(2)
        local max_age = _opts.max_age or 30
		local spd = _opts.spd or 0.05
		local dx = cos(angle) * spd
		local dy = sin(angle) * spd

		if (_opts.dx) dx = _opts.dx
		if (_opts.dy) dy = _opts.dy 
		local p = new_particle(
			"smoke",
			new_position(_x,_y,max_size,0),
			dx,
			dy,
			max_age,
			_colors,
			max_size,
			{}
		)
		add(particles, p)
	end
end

function spawn_shatter(_x,_y,_colors,_opts)
	local tmp_dx, tmp_dy = _opts.dx or 0, _opts.dy or -1
	local ma = (_opts.max_age or 30) + rnd(10)
	for i=1,rnd(20)+5 do
		local angle = rnd()
		local dx = sin(angle)*rnd(1.5)+(tmp_dx/2)
		local dy = cos(angle)*rnd(1.5)+(tmp_dy/2)

		local p = new_particle(
			"pixel",
			new_position(_x,_y,1,0),
			dx,
			dy,
			ma,
			_colors,
			1,
			{ has_gravity=true }
		)
		add(particles, p)
	end
end