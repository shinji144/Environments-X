ENT.Type = "anim"
ENT.Base = "base_env_entity"

ENT.PrintName = "R01 Automatic Resource Manager"
ENT.Author = "Mechanos"
ENT.Contact = "can't make me"
ENT.Purpose = "Does anyone read these?"
ENT.Instructions = "Point away from face" 
ENT.Category = "Environments"

ENT.Spawnable = false
ENT.AdminSpawnable = false
--ENT.RenderGroup = RENDERGROUP_BOTH
-- The next line is seriously important don't forget that shiat!  *(( I MEAN IT ))* -- lol old Deep comments
ENT.AutomaticFrameAdvance = true

ENT.ExtraOverlayData = {}
--ENT.ExtraOverlayData[">"] = "D"
ENT.ExtraOverlayData["\nStatus"] = "\n".."Idle"
list.Set( "LSEntOverlayText" , "env_autogen", {HasOOO = true, genresnames ={ "energy", "water", "oxygen", "hydrogen"} } )

if(SERVER)then
	
	local T = {} --Create a empty Table
	
	T.Power = function(Device,ply,Data)
		Device:SetActive( nil, ply )
	end
	
	--[[T.O2Per = function(Device,ply,Data)
		if (Device.TriggerInput) then
			Device:TriggerInput("Max O2 level", tonumber(Data))//SetMultiplier(tonumber(args[2]))
		end
	end
	
	T.Gravity = function(Device,ply,Data)
		if (Device.TriggerInput) then
			Device:TriggerInput("Gravity", tonumber(Data))//SetMultiplier(tonumber(args[2]))
		end
	end
	]]
	ENT.Panel=T --Set our panel functions to the table.
else 
	ENT.LastStatus=""
	
	function ENT:PanelFunc(um,e,entID)

		e.Functions={}
		
		e.DevicePanel = [[
		@<Button>Toggle Power</Button><N>PowerButton</N><Func>Power</Func>
		]]
		--@<Slider>O2 Percent</Slider><N>O2Percent</N><Func>O2Per</Func><Set>GetO2Per</Set>
		--@<Checkbox>Gravity</Checkbox><N>Gravity</N><Func>Gravity</Func>

		e.Functions.Power = function()
			RunConsoleCommand( "envsendpcommand",entID,"Power")
		end
		
		--[[e.Functions.O2Per = function(Value)
			RunConsoleCommand( "envsendpcommand",entID,"O2Per",Value)
		end
		
		e.Functions.GetO2Per = function(label,Data,Device)
			label:SetValue( Device:GetNetworkedInt("EnvMaxO2") or 11 )
		end
		
		e.Functions.Gravity = function(Value)
			RunConsoleCommand( "envsendpcommand",entID,"Gravity", Value)
		end
		]]--
		
	end
	
	function ENT:Initialize()
		--self:SetNWString( "status", "Y U DO DIS" )
		self:NextThink(CurTime() + 1)
	end
	
	function ENT:Think()
		local message = self:GetNWString( "status" )
		if message != self.LastStatus then
			--message = message or ""
			self.ExtraOverlayData["\nStatus"] = "\n" .. message
			self.LastStatus = message
		end
		self:NextThink(CurTime() + 3)
	end

end
