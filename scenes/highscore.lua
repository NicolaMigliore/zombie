function _highscore_i()
	cartdata("jack_vs_zombies_1")
	hscores = {}
	load_hs()
	sort_hs()
	hs_chars = split("a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z")
	initials = { 1, 1, 1 }
	initials_i = 1
end
function _highscore_u()
	if score > 0 then 
		-- input initials
		if btnp(➡️) then
			initials_i+=1
			if initials_i>3 then
				initials_i=1
			end
			sfx(17)
		end
		if btnp(⬅️) then
			initials_i-=1
			if initials_i<1 then
				initials_i=3
			end
			sfx(17)
		end
		if btnp(⬆️) then
			initials[initials_i]+=1
			if initials[initials_i]>#hs_chars then
				initials[initials_i]=1
			end
			sfx(18)
		end
		if btnp(⬇️) then
			initials[initials_i]-=1
			if initials[initials_i]<1 then
				initials[initials_i]=#hs_chars
			end
			sfx(18)
		end


		-- save score
		if (btnp(❎)) add_hs(initials[1],initials[2],initials[3],score) sfx(17) load_scene_level()
	end
end
function _highscore_d()
	camera()
	draw_window_frame(10, 7, 107, 90)

	print("high scores",40,14,7)
	-- print scores
	for i=1,5 do
		local hs = hscores[i]
		local y=20+(i*6)
		local s=" "..hs[4]
		--rank
		print(i.." - ",30,y,7)
		--name
		local p_name=hs_chars[hs[1]]
		p_name=p_name..hs_chars[hs[2]]
		p_name=p_name..hs_chars[hs[3]]
		print(p_name,45,y,7)
		--score
		print(s,100-#s*4,y,7)
	end

	if score > 0 then
		--initials input 
		for i=1,#initials do
			local ini_c=7
			if(i==initials_i) ini_c = 8--blink_c
			print(hs_chars[initials[i]],42+(i*4),66,ini_c)
			print(score,60,66,7)
		end

		print("❎ to restart",36,74,blink_color1.color)
	end
end

function reset_hs()
	hscores = {
		{ 1, 1, 1, 0 },
		{ 1, 1, 1, 0 },
		{ 1, 1, 1, 0 },
		{ 1, 1, 1, 0 },
		{ 1, 1, 1, 0 }
	}
end

-- load high scores
function load_hs()
	--create default values if missing
	if dget(0) != 1 then
		reset_hs()
		save_hs()
	end

	local j = 1
	for i = 1, 5 do
		hscores[i] = {}
		hscores[i][1] = dget(j)
		hscores[i][2] = dget(j + 1)
		hscores[i][3] = dget(j + 2)
		hscores[i][4] = dget(j + 3)
		j += 4
	end
	sort_hs()
end

-- Saves all high scores
function save_hs()
	--indicate there is a saved data
	dset(0, 1)
	--store highscores
	local j = 1
	for i = 1, 5 do
		dset(j, hscores[i][1])
		dset(j + 1, hscores[i][2])
		dset(j + 2, hscores[i][3])
		dset(j + 3, hscores[i][4])
		j += 4
	end
end

function add_hs(c1, c2, c3, score)
	add(hscores, { c1, c2, c3, score })
	sort_hs()
	save_hs()
end

function sort_hs()
	for i = 1, #hscores do
		local j = i
		while j > 1 and hscores[j - 1][4] < hscores[j][4] do
			hscores[j], hscores[j - 1] = hscores[j - 1], hscores[j]
			j = j - 1
		end
	end
end

function load_scene_highscore()
	mode = "highscore"
end