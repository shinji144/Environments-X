local LoadFile = EnvX.LoadFile --Lel Speed.
local P = "envx/"

local Environments = Environments

Environments.Hooks = {}
Environments.Version = 164
Environments.CurrentVersion = 0 --for update checking
Environments.FileVersion = 8
Environments.Debug = true

LoadFile(P.."variables.lua",1)
LoadFile(P.."core/sh_funcs.lua",1)

LoadFile(P.."menu.lua",0)
LoadFile(P.."spawn_menu.lua",0)

LoadFile(P.."core/sv_overrides.lua",2)
LoadFile(P.."core/sv_envx.lua",2)
LoadFile(P.."core/sv_envx_planets.lua",2)
LoadFile(P.."core/sv_envx_players.lua",2)

LoadFile(P.."events/sv_events.lua",2)

LoadFile(P.."core/sv_ls_support.lua",2)

LoadFile(P.."env_rd_init.lua",1)

if CLIENT then
	function Load(msg)
		include("vgui/HUD.lua")
		LoadFile(P.."core/cl_core.lua",0)
		EnvX.SpaceEngine = true
		
		local function Reload()
			include("vgui/HUD.lua")
			LoadHud()
		end
		concommand.Add("env_reload_hud", Reload)
		LoadHud()
		
		if msg then
			print("Environments Version "..msg:ReadShort().." Running On Server")
		end
	end
	usermessage.Hook("Environments", Load)
else
	LoadFile(P.."core/cl_core.lua",0)
	LoadFile("vgui/HUD.lua",0)
	
	function EnvX.SpaceEntity(ent)
		if ent:IsPlayer() then
			ent:SetGravity( 0.00001 )
			ent:SetNWBool( "inspace", true )
			
			if not EnvX.CanNoClip(ent) then
				ent:SetMoveType( MOVETYPE_FLY )
				if math.abs(ent:GetVelocity():Length()) > 50 then
					ent:SetLocalVelocity(Vector(0,0,0))
				end
			end
		else
			if ent:IsRagdoll() then
				if( ent and ent:IsValid() ) then
					for i = 0, ent:GetPhysicsObjectCount() do	
						local phys = ent:GetPhysicsObjectNum( i )
						if( phys and phys:IsValid() ) then
							phys:EnableGravity( false )
							phys:EnableDrag( false )
						end
					end
				end
			else
				local phys = ent:GetPhysicsObject()
				if phys then
					phys:EnableDrag( false )
					phys:EnableGravity( false )
				end
			end
		end
		if not ent.NoSpaceAfterEndTouch then
			ent.environment = Space()
		end
	end
end