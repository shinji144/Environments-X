
local Group = {}

//Name of the MegaGroup
local GroupName = "Readme"
local Description = "Read this page."
local GlobalTags = ""
local GroupIcon = "gui/silkicons/world"

Group.Testing={TabName="Testing",
Text=[[
@<WEB>http://tausc.site.nfoservers.com/SBMOTD/MOTD.html</WEB>
]],
Tags=""
}

Group.Readme={TabName="Read Me!",
Text=[[
@<B>Welcome to the Tau Science Coalition!</B>

@<P>	This manual will cover all the basics of how to play Environments Extended, but keep in mind there's more to learn. We're glad to have you here, but there are rules: </P>

@<B>Rule 1: This is a spacebuild server. If you wish to play sandbox, please move to a different server.</B>
@<B>Rule 2: Be respectful. The community and admins are very friendly, unless you are disrespectful. If you need help with something, ask politely.</B>
@<B>Rule 3: Keep the server in mind; Other players are here to have a good time, so if something you create is likely to cause lag or a crash, please remove it or avoid building it in the first place.</B>



@<B>The Basics </B>

@<P> Every resource setup needs a node. These can be found by opening your Q menu, selecting the environments tab, finding the tools pane, and selecting the "Resource Nodes" tool.All life support, storage, generators, machines, weapons, etc will link to this node. To link, find the "Link tool" in the same pane as the node tool. Using this tool, click on the node and then the machine you want to link to that node. This adds that machine into the node's network. You will also need storage, so find the "Storages" tool under the Life Support pane and spawn in a resource cache. A resource cache holds all kinds of basic resources, as opposed to other caches which hold only one type. Once spawned, link this to your node. You now have a place to store the resources you gather. </P>	 
@<P> This game is based around managing resources. There are 3 essential resources, and others that will be necessary later. These three follow:</P>	

@<B>Energy</B>
@<P> All machines and life support systems (excluding energy generators) need energy to function. The 2 most popular methods to obtain energy are solar panels and fusion generators. Another popular method is wind turbines, but these only function within atmospheres.</P>
@<P> Solar Panels produce energy from only sunlight, but put out a lot of heat. Fusion generators produce a lot of power, but take water and produce a lot of heat. We will use fusion generators for this guide, so find the "Generators" tool in the Life Support pane, and spawn a fusion generator in. Link this to your node, but don't turn it on yet, as we have no water. If used without water, it will not produce much energy and will eventually explode. </P>

@<B>Water </B>
@<P> Water is essential to cooling your spaceship. It is also widely used as a source of oxygen, hydrogen, and energy. </P>

@<P> To obtain water, use a water pump. This can be found in the generators tool. Spawn a water pump submerged in water, and then use the link tool to link it to your node. Press the use key on it to turn the power on, (You need to turn on your fusion generator at this time as well) and if you have storage linked to your node it will start to pump water into that storage. The multiplier setting will make it produce more water, but will take more energy. You will likely have to increase the multiplier to balance out the water consumption from the fusion generator. Once this is set up, your storage should be filling with both energy and water.</P>

@<B>Oxygen</B>
@<P> Surprise! You need oxygen to breathe! Once you have water and energy, you can use a water splitter to create oxygen and hydrogen from water. This is also found in the generators tool. Spawn in a water splitter and link it to your node. Turn it on, and you should start recieving oxygen and hydrogen in your storage. </P>


@<B>Life Support</B>
@<P> Your HUD displays your current oxygen, coolant, energy, and fuel levels. These all start at 5%, which is not very much. To increase these values, spawn a suit dispenser. This is found under the Life Support pane in the Life Support tool. Link this to your node and press E on it. This will fill up your suit's resources with resources from your network, and that will allow you to survive in space and in other atmospheres.</P>
@<P> Another important life support feature is the Life Support Core. This will fill your ship with a livable atmosphere, but will take oxygen, water, and energy to maintain. It also produces fake gravity.</P>

@<B> To move on, click the "Cores" tab in the top left </B>

]],
Tags=""
}
Group.Cores={TabName="Cores, Mining, and Weapons",
Text=[[
@<B>Ship Cores and Heat</B>
@<P> Ship Cores are the last step in ship creation. After you build your ship and add in life support, you need to give it a core. This takes the volume of the parts of your ship and gives it health and shields. There are many different cores available, but for now stick to the trade core or the basic core. These cores have a good balance between heat, energy consumption, and health. To attach it to your ship, find the "Ship Cores" tool, select the core you want, and weld it anywhere to your ship. After a few seconds, it will display a health and shield value, as well as heat and redpoint. Heat is your current heat, (remember almost all machines produce heat) and redpoint is the point at which your ship will catch on fire from the heat. We don't want a burning ship, so to prevent that we attach radiators to the ship. To do this, find the "Core Upgrades" tool and the heat management tab. Spawn some of these radiators onto your ship and link them to your network. These will automatically regulate heat. </P>
@<P> Your shield starts at 0%, so we want to charge that. In the "Core Upgrades" tool spawn a Shield Regenerator on your ship and link it to your node. Turn it on and your shield will start regenerating slowly, but this consumes energy. If your core takes damage when your shield is down, you'll need a hull repairer to fix it. These are found in the same place as the shield regenerator, but it takes raw ore to heal your ship. </P>

@<B>Mining</B>
@<P> For most weapons, you will need ore, while some weapons require polylodarium. Ore can be obtained by using a mining laser (Mining Devices -> Mining Lasers -> Basic Laser) on asteroids found floating throughout space. You'll need special storage for ore found in the "Mining Storage" tool. Mining consumes energy. For polylodarium, the same process appies except you need a mining drill, and you use it on a hot planet.</P>
@<P> Ore and polylodarium can be refineed and processed in many different ways. Ore can be turned into refined or hardened ore and then turned into a variety of ammo types. Polylodarium is refined into liquid polylodarium and then used in high-level launchers.</P>

@<B>Weapons</B>
@<P> Environments Extended has a variety of different weapons, and each has there own pros and cons. Lasers take only energy to fire and have instant travel time. Other weapons require ammo to be made and have a small travel time but can be very powerful. Missle launchers have slow travel but can be very powerful, and can be wired to home in on targets.</P>
@<P> If you're new to the game, it might be best to stick to pulse lasers. They are a fairly powerful well rounded weapon. Remember, weapons do not fire in the spawn planet. We encourage you to experiment with other weapons!</P> 
@<HTML>http://tausc.site.nfoservers.com/HitchHikersGuide/ludspray.jpg</HTML><Right>Right side Text.</Right>

]],
Tags=""
}

-------Internal Work-------
for n,D in pairs(Group) do
	D.Tags=D.Tags.." "..GlobalTags
end

LDE.Manual.Documents[GroupName]={}
LDE.Manual.Documents[GroupName].Pages=Group
LDE.Manual.Documents[GroupName].PageName = GroupName
LDE.Manual.Documents[GroupName].Desc = Description
LDE.Manual.Documents[GroupName].Icon = GroupIcon
