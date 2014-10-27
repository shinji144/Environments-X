-- Repair Tool
-- This tool repairs stuff

TOOL.Category = "Ship Cores"
TOOL.Name = "Health Reader"
TOOL.Tab = "Environments"
TOOL.ent = {}
TOOL.Timer = CurTime()	

local function IsReallyValid(trace)
	if not trace.Entity:IsValid() then return false end
	if trace.Entity:IsPlayer() then return false end
	if SERVER and not trace.Entity:GetPhysicsObject():IsValid() then return false end
	return true
end
		
if (SERVER) then
	AddCSLuaFile("lde_repair_tool.lua")
	function TOOL:Think()
		if (CurTime() > self.Timer) then
		local ply = self:GetOwner()
		if (ply:KeyDown( IN_ATTACK )) then
			local trace = ply:GetEyeTrace()
			if (!trace.Hit) then return end
				if (trace.HitPos:Distance(ply:GetShootPos()) < 125 and trace.Entity and LDE:CheckValid( trace.Entity )) then
					LDE:RepairHealth( trace.Entity, 10 )
					-- Run slower!
					self.Timer = CurTime() + 0.1
				end
			end
		end
		local ply = self:GetOwner()	
		local wep = ply:GetActiveWeapon()
		if not wep:IsValid() or wep:GetClass() != "gmod_tool" or ply:GetInfo("gmod_toolmode") != "lde_repair_tool" then return end
		local trace = ply:GetEyeTrace()
		if not IsReallyValid(trace) then return end
		ply:SetNetworkedFloat("ToolHealth", LDE:GetHealth(trace.Entity) or 0)
		ply:SetNetworkedFloat("ToolMaxHealth", LDE:CalcHealth(trace.Entity) or 0)
		ply:SetNetworkedFloat("ToolTemp", trace.Entity.LDE.Temperture or 0)
		ply:SetNetworkedFloat("ToolMaxTemp", trace.Entity.LDE.MeltingPoint or 0)
	end
end

if CLIENT then
	language.Add( "Tool.lde_repair_tool.name", "LDE health Detector" )
	language.Add( "Tool.lde_repair_tool.desc", "Used to see a entities Health." )
	language.Add( "Tool.lde_repair_tool.0", "Primary: Look at a entity to see its health." )
	
	function TOOL:Reload()
	end
	
	function TOOL.BuildCPanel( CPanel )
		local label = vgui.Create("DLabel", LDE_weaponframe)
		label:SetText("Aim at a entity to see its health.")
		label:SizeToContents()
		
		CPanel:AddItem(label)
	end
	
	local TipColor = Color( 250, 250, 200, 255 )

	surface.CreateFont("GModWorldtip", {font = "coolvetica", size = 24, weight = 500})
	
	local function DrawRepairTip()
		local pl = LocalPlayer()
		local wep = pl:GetActiveWeapon()
		if not wep:IsValid() or wep:GetClass() != "gmod_tool" or pl:GetInfo("gmod_toolmode") != "lde_repair_tool" then return end
		local trace = pl:GetEyeTrace()
		if not IsReallyValid(trace) then return end
		
		local hp = LocalPlayer():GetNWInt( "ToolHealth" )
		local maxhealth = LocalPlayer():GetNWInt( "ToolMaxHealth" )
		local temp = LocalPlayer():GetNWInt( "ToolTemp" )
		local maxtemp = LocalPlayer():GetNWInt( "ToolMaxTemp" )
		local text = "Health: "..hp
		local text2 = "MaxHealth: "..maxhealth
		local text3 = "Temperture: "..math.Round(temp)
		local text4 = "Melt Point: "..math.Round(maxtemp)
		
		local pos = (trace.Entity:LocalToWorld(trace.Entity:OBBCenter())):ToScreen()
		
		local black = Color( 0, 0, 0, 255 )
		local tipcol = Color( TipColor.r, TipColor.g, TipColor.b, 255 )
		
		local x = 0
		local y = 0
		local padding = 10
		local offset = 50
		
		surface.SetFont( "GModWorldtip" )
		local w, h = surface.GetTextSize( text )
		
		x = pos.x - w 
		y = pos.y - h 
		
		x = x - offset
		y = y - offset

		draw.RoundedBox( 8, x-padding-2, y-padding-2, w+padding*8+2, h+padding*8+2, black )
		
		
		local verts = {}
		verts[1] = { x=x+w/1.5-8, y=y+h+8 }
		verts[2] = { x=x+w+8, y=y+h/4-1 }
		verts[3] = { x=pos.x-offset/8+8, y=pos.y-offset/8+8 }
		
		draw.NoTexture()
		surface.SetDrawColor( 0, 0, 0, tipcol.a )
		surface.DrawPoly( verts )
		
		
		draw.RoundedBox( 8, x-padding, y-padding, w+padding*8, h+padding*8, tipcol )
		
		local verts = {}
		verts[1] = { x=x+w/1.5, y=y+h }
		verts[2] = { x=x+w, y=y+h/8 }
		verts[3] = { x=pos.x-offset/8, y=pos.y-offset/8 }
		
		draw.NoTexture()
		surface.SetDrawColor( tipcol.r, tipcol.g, tipcol.b, tipcol.a )
		surface.DrawPoly( verts )
		
		
		draw.DrawText( text, "GModWorldtip", x+w/2, y, black, TEXT_ALIGN_CENTER )
		draw.DrawText( text2, "GModWorldtip", x+w/1.6 , y+h, black, TEXT_ALIGN_CENTER )
		draw.DrawText( text3, "GModWorldtip", x+w/1.8, y+h*2, black, TEXT_ALIGN_CENTER )
		draw.DrawText( text4, "GModWorldtip", x+w/1.8, y+h*3, black, TEXT_ALIGN_CENTER )
	end
	hook.Add("HUDPaint", "RepairWorldTip", DrawRepairTip)
	
end
