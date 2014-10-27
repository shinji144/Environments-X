--Basic missile luancher 4X
local Data={name="Small Basic missile Launcher",class="basic_missile_weapon",In={"Missile Parts"},MountType="Small",ammoclass="basic_missile",heat=5,InUse={1},Shots = 4,BLength = 40,Rows = { -4 , 4 },Cols = { -4 , 4 }}
LDE.Weapons.RegisterLauncher(Data)

--Basic missile luancher 8X
local Data={name="Medium Basic missile Launcher",class="med_basic_missile_weapon",In={"Missile Parts"},MountType="Small",ammoclass="basic_missile",heat=5,InUse={1},Shots = 8,BLength = 45,Rows = { -4 , 4 },Cols = { -12 , -4, 4, 12 }}
LDE.Weapons.RegisterLauncher(Data)

--Basic missile luancher 10X
local Data={name="Large Basic missile Launcher",class="lrg_basic_missile_weapon",In={"Missile Parts"},MountType="Small",ammoclass="basic_missile",heat=5,InUse={1},Shots = 10,BLength = 65,Rows = { -5 , 5 },Cols = { -16 , -8, 0, 8, 16 }}
LDE.Weapons.RegisterLauncher(Data)

--Stinger luancher 16X
local Data={name="Stinger Launcher",class="stinger_missile_weapon",In={"Missile Parts"},MountType="Small",ammoclass="stinger_missile",heat=3,InUse={1},Shots = 16,BLength = 55,Rows = { -4 , 4 },Cols = { -12 , -12, 0, 12, 12 }}
LDE.Weapons.RegisterLauncher(Data)

--Heavy missile luancher 3X
local Data={name="Heavy missile Launcher",class="heavy_missile_weapon",In={"Missile Parts","Liquid Polylodarium"},MountType="Small",ammoclass="heavy_missile",heat=50,InUse={3,10},Shots = 3,BLength = 40,Rows = { -4 , 4 },Cols = { -16 , -8, 0, 8, 16 }}
LDE.Weapons.RegisterLauncher(Data)

--Nuclear luancher 1X
local Data={name="Nuclear Launcher",class="nuclear_missile_weapon",In={"Missile Parts","Liquid Polylodarium"},MountType="Huge",ammoclass="nuke_missile",heat=400,InUse={10,100},Shots = 1,BLength = 450,Rows = { -4 , 4 },Cols = { -12 , -12, 0, 12, 12 },AimVec = "Left"}
LDE.Weapons.RegisterLauncher(Data)

--Double Needle Launcher 21X
local Data={name="Large Needle missile Launcher",class="lrg_needle_missile_weapon",In={"Missile Parts"},MountType="Small",ammoclass="needle_missile",heat=1,InUse={1},HasLid=true,Shots = 21,BLength = 40,Rows = { -12 , -12, 0, 12, 12 },Cols = { -4 , 4 },ClosedModel = "models/Slyfo_2/rocketpod_lg_closed.mdl",OpenModel="models/Slyfo_2/rocketpod_lg_open.mdl",AimVec = "Up"}
LDE.Weapons.RegisterLauncher(Data)


