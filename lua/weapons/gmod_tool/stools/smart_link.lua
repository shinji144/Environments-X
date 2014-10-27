
TOOL.Category	= 'Tools'
TOOL.Name		= 'Smart Link Tool'
TOOL.Command	= nil
TOOL.ConfigName	= ''
TOOL.Tab = "Environments"

if ( CLIENT ) then
	language.Add( "tool.smart_link.name", "Smart Link Tool" )
	language.Add( "tool.smart_link.desc", "Links Resource-Carrying Devices to a Resource Node." )
	language.Add( "tool.smart_link.0", "Left Click: Select Devices.  Right Click: Link All devices to the selected Node.  Reload: Reset selected devices." )
    language.Add( "tool.smart_link.1", "Click on another Resource-Carrying Device" )
end

TOOL.ClientConVar[ "material" ] = "cable/cable2"
TOOL.ClientConVar[ "cable" ] = "1"

function TOOL:LeftClick( trace )
	if (!trace.Entity:IsValid()) or (trace.Entity:IsPlayer()) then return end
	if (CLIENT) then return true end
	if trace.Entity.Link then
		local iNum = self:NumObjects()
		local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )
		self:SetObject( iNum + 1, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )
		trace.Entity:SetColor(Color(0, 0, 255, 200))
	end
	return true
end

function TOOL:RightClick( trace )
	if (!trace.Entity:IsValid()) or (trace.Entity:IsPlayer()) then return end
	
	if (CLIENT) then return true end
	local iNum = self:NumObjects()

	if ( iNum > 0 and trace.Entity.IsNode and trace.Entity.Link ) then
		-- Get information we're about to use
		for k, v in pairs(self.Objects) do
			local Ent1,  Ent2  = self:GetEnt(k), trace.Entity
			//local Bone1, Bone2 = self:GetBone(k),	trace.PhysicsBone
			local WPos1, WPos2 = self:GetPos(k),		trace.Entity:GetPos()
			//local LPos1, LPos2 = self:GetLocalPos(k),	self:GetLocalPos(2)
			local length = ( WPos1 - WPos2):Length()
			
			Ent1:SetColor(Color(255, 255, 255, 255)) 

			local material	= self:GetClientInfo( "material" )
			local width		= self:GetClientNumber( "width" ) 
			local color		= Color(self:GetClientNumber("color_r"), self:GetClientNumber("color_g"), self:GetClientNumber("color_b"))
			

			if length <= 2048 then
				Ent1:Link(Ent2)
				Ent2:Link(Ent1)
			else
				self:GetOwner():SendLua( "GAMEMODE:AddNotify('The Entity and the Node are to far appart!', NOTIFY_GENERIC, 7);" )
			end
		end
		self:ClearObjects()
	else
		self:GetOwner():SendLua( "GAMEMODE:AddNotify('You didn't click on a Valid Resource node to link to!', NOTIFY_GENERIC, 7);" )
	end
	return true
end

function TOOL:Reload(trace)
	local iNum = self:NumObjects()
	if iNum > 0 then
		for k, v in pairs(self.Objects) do
			local Ent1  = self:GetEnt(k)
			Ent1:SetColor(Color(255, 255, 255, 255)) 
		end
	end
	self:ClearObjects()
	return true
end

function TOOL.BuildCPanel( panel )
	panel:AddControl( "Header", { Text = "#tool.smart_link.name", Description	= "#tool.smart_link.desc" }  )
end

