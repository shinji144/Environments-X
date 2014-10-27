
ENT.Type = "anim"
ENT.Base = "base_env_entity"
ENT.PrintName = "LS Core"
ENT.Author = "CmdrMatthew"
ENT.Purpose = "To Test"
ENT.Instructions = "Eat up!" 
ENT.Category = "Environments"


list.Set( "LSEntOverlayText" , "env_lscore", {HasOOO = true, resnames ={ "oxygen", "energy", "water", "nitrogen"} } )


if(SERVER)then
	
	local T = {} --Create a empty Table
	
	T.Power = function(Device,ply,Data)
		Device:SetActive( nil, ply )
	end
	
	T.O2Per = function(Device,ply,Data)
		if (Device.TriggerInput) then
			Device:TriggerInput("Max O2 level", tonumber(Data))//SetMultiplier(tonumber(args[2]))
		end
	end
	
	T.Gravity = function(Device,ply,Data)
		if (Device.TriggerInput) then
			Device:TriggerInput("Gravity", tonumber(Data))//SetMultiplier(tonumber(args[2]))
		end
	end
	
	ENT.Panel=T --Set our panel functions to the table.
	
else 

	function ENT:PanelFunc(um,e,entID)

		e.Functions={}
		
		e.DevicePanel = [[
		@<Button>Toggle Power</Button><N>PowerButton</N><Func>Power</Func>
		@<Slider>O2 Percent</Slider><N>O2Percent</N><Func>O2Per</Func><Set>GetO2Per</Set>
		@<Checkbox>Gravity</Checkbox><N>Gravity</N><Func>Gravity</Func>
		]]

		e.Functions.Power = function()
			RunConsoleCommand( "envsendpcommand",entID,"Power")
		end
		
		e.Functions.O2Per = function(Value)
			RunConsoleCommand( "envsendpcommand",entID,"O2Per",Value)
		end
		
		e.Functions.GetO2Per = function(label,Data,Device)
			label:SetValue( Device:GetNetworkedInt("EnvMaxO2") or 11 )
		end
		
		e.Functions.Gravity = function(Value)
			RunConsoleCommand( "envsendpcommand",entID,"Gravity", Value)
		end
		
	end

end
