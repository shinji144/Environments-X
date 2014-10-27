

local Spawn = function()
	local PlanetCheck = function(planet)
		if(math.random(1,10)==6)then 
			return true
		end
	end
	for I=1,100 do
		rock = ents.Create("land_rock")
		local Planet = LDE.Anons:FindPlanetClass(PlanetCheck)
		local Point = LDE.Anons:PointOnPlanet(Planet,rock.Data)
		if(not Point)then 
			rock:Remove()
		else
			rock:SetPos(Point)
			rock:Spawn()
		end
	end
end
local Touch = function(self) end
local Int = function(self)
	local rockmodels = {
	"models/props_canal/rock_riverbed01d.mdl","models/props_canal/rock_riverbed02a.mdl","models/props_canal/rock_riverbed02b.mdl",
	"models/props_canal/rock_riverbed02c.mdl","models//props_debris/concrete_spawnchunk001a.mdl","models//props_debris/concrete_spawnchunk001b.mdl",
	"models//props_debris/concrete_spawnchunk001c.mdl","models//props_debris/concrete_spawnchunk001d.mdl","models//props_debris/concrete_spawnchunk001e.mdl",
	"models//props_debris/concrete_spawnchunk001f.mdl","models//props_debris/concrete_spawnchunk001g.mdl","models//props_debris/concrete_spawnchunk001h.mdl",
	"models//props_debris/concrete_spawnchunk001i.mdl","models//props_debris/concrete_spawnchunk001j.mdl","models//props_debris/concrete_spawnchunk001k.mdl",
	"models/props_wasteland/rockcliff01g.mdl","models/props_wasteland/rockgranite01c.mdl","models/props_wasteland/rockgranite04b.mdl",
	"models/props_wasteland/rockcliff01c.mdl","models/props_wasteland/rockcliff01j.mdl","models/props_wasteland/rockgranite02a.mdl",
	"models/props_wasteland/rockgranite04c.mdl","models/props_wasteland/rockcliff01e.mdl","models/props_wasteland/rockgranite01a.mdl",
	"models/props_wasteland/rockgranite03c.mdl","models/props_wasteland/rockcliff01b.mdl","models/props_wasteland/rockcliff01f.mdl",
	"models/props_wasteland/rockgranite01b.mdl","models/props_wasteland/rockgranite04a.mdl","models/props_wasteland/rockcliff01g.mdl",} 
	self:SetModel(rockmodels[math.random(1,table.Count(rockmodels))])
	self.Ore = LDE:CalcHealth(self)
end

local Data={name="Rock",class="land_rock",Type="Planet",Startup=Int,ThinkSpeed=1,SpawnMe=Spawn,Collide=Touch,Initial=true}
--LDE.Anons.GenerateAnomaly(Data)





