
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName	= "Environments Systems Core"
ENT.Author		= "CmdrMatthew"
ENT.Purpose		= "Base for all RD Sents"
ENT.Instructions	= ""

ENT.Spawnable		= false
ENT.AdminSpawnable	= false


if(SERVER)then
	
	local T = {} --Create a empty Table
	
	T.Power = function(Device,ply,Data)
		Device:SetActive( nil, ply )
	end
	
	T.Mult = function(Device,ply,Data)
		Device:SetMultiplier(tonumber(Data))
	end
	
	T.Mute = function(Device,ply,Data)
		if (Device.TriggerInput) then
			Device:TriggerInput("Mute", tonumber(Data))//SetMultiplier(tonumber(args[2]))
		end
	end
	
	ENT.Panel=T --Set our panel functions to the table.
	
else 
	
	function ENT:PanelFunc(um,e,entID)
	
		e.Functions={}
		
		e.DevicePanel = [[
		@<Button>Toggle Power</Button><N>PowerButton</N><Func>Power</Func>
		@<Slider>Multiplier</Slider><N>Multiplier</N><Func>Mult</Func><Set>GetMult</Set>
		@<Checkbox>Mute</Checkbox><N>Mute</N><Func>Mute</Func>
		]]

		e.Functions.Power = function()
			RunConsoleCommand( "envsendpcommand",entID,"Power")
		end
		
		e.Functions.Mult = function(Value)
			RunConsoleCommand( "envsendpcommand",entID,"Mult",Value)
		end
		
		e.Functions.GetMult = function(label,Data,Device)
			label:SetValue( Device:GetNetworkedInt("EnvMultiplier") or 1 )
		end
		
		e.Functions.Mute = function(Value)
			RunConsoleCommand( "envsendpcommand",entID,"Mute", Value)
		end
	end
	
	function envDeviceTrigger(um)
		entID = um:ReadString()
		e = um:ReadEntity()

		e:PanelFunc(um,e,entID)
		
		e.Window = vgui.Create( "EnvDeviceGUI")
		e.Window:SetMouseInputEnabled( true )
		e.Window:SetVisible( true )
		e.Window:CompilePanel()
		
		--if(not ValidEntity(e)) then return end;
	end
	usermessage.Hook("EnvODMenu", envDeviceTrigger)
end



