--Mining Laser Effect - Made by <somenamehere>. Modified by Syncaidius
--====================================================================

local Glow1 = Material("particles/flamelet2")
Glow1:SetInt("$spriterendermode",0)
Glow1:SetInt("$illumfactor",8)
Glow1:SetFloat("$alpha",0.6)


/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )
	self.Position = data:GetOrigin()
	self.Start = data:GetStart()
	self.RightAngle = data:GetAngles():Right()
	self.UpAngle = data:GetAngles():Up()
	self.BeamWidth = 16
	self.LifeTime = CurTime() + 2
	self.Alpha = 1
	self.Entity:SetRenderBounds( Vector()*-8192, Vector()*8192 )	
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	local Pos = self.Position
	local t = CurTime()
	if t < self.LifeTime then 
		self.Fade = (self.LifeTime - t) / 2
		return true
	else
		return false	
	end
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )
	local pos = self.Position
	local pos2 = self.Start
	
	if self.Fade == nil then self.Fade = 0 end
	Glow1:SetFloat("$alpha",self.Fade)
	Glow1:SetVector("$color",Vector(0, 0.5, 1)) 
	render.SetMaterial(Glow1)
	

	local start1 = pos+(self.RightAngle*(self.BeamWidth*self.Fade))
	local start2 = pos-(self.RightAngle*(self.BeamWidth*self.Fade))
	local start3 = pos+(self.UpAngle*(self.BeamWidth*self.Fade))
	local start4 = pos-(self.UpAngle*(self.BeamWidth*self.Fade))
	
	local end1 = pos2+(self.RightAngle*(self.BeamWidth*self.Fade))
	local end2 = pos2-(self.RightAngle*(self.BeamWidth*self.Fade))
	end1 = end1 + ((self.RightAngle*(pos:Distance(pos2) / 16))*self.Fade)
	end2 = end2 - ((self.RightAngle*(pos:Distance(pos2) / 16))*self.Fade)
	local end3 = pos2+(self.UpAngle*(self.BeamWidth*self.Fade))
	local end4 = pos2-(self.UpAngle*(self.BeamWidth*self.Fade))
	end3 = end3 + ((self.UpAngle*(pos:Distance(pos2) / 16))*self.Fade)
	end4 = end4 - ((self.UpAngle*(pos:Distance(pos2) / 16))*self.Fade)
		
	render.DrawQuad(start1, end1, end2, start2)
	render.DrawQuad(start2, end2, end1, start1)
	render.DrawQuad(start3, end3, end4, start4)
	render.DrawQuad(start4, end4, end3, start3)
end
