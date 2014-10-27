
----Missiles-------

--missile
local Data={name="Basic Missile",class="basic_missile",model="models/Punisher239/punisher239_rocket.mdl",Mass=3,damage=800,range=600,speed=2000,DumbTime=5}
LDE.Weapons.RegisterMissile(Data)

--Stinger missile
local Data={name="Stinger Missile",class="stinger_missile",model="models/Slyfo_2/pss_netprojectile.mdl",Mass=1,damage=400,range=500,speed=4000,DumbTime=3}
LDE.Weapons.RegisterMissile(Data)

--Heavy missile
local Data={name="Heavy Missile",class="heavy_missile",model="models/Punisher239/punisher239_missile_light.mdl",Mass=5,damage=3400,range=1300,speed=1200,DumbTime=60}
LDE.Weapons.RegisterMissile(Data)

--Nuclear missile
local Data={name="Nuclear Missile",class="nuke_missile",model="models/Punisher239/punisher239_missile_cruise.mdl",Nuclear=true,Mass=30,damage=32000,range=3000,speed=700,DumbTime=180}
LDE.Weapons.RegisterMissile(Data)

--Needle missile
local Data={name="Needle Missile",class="needle_missile",model="models/Slyfo_2/pss_thrustprojectileopen.mdl",Mass=1,damage=400,range=1000,speed=6000,DumbTime=3}
LDE.Weapons.RegisterMissile(Data)






