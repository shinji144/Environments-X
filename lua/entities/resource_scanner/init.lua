AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

--# Initialize
function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self.Range = 1000
	self.MaxRange = 1000
	self.Angle = 15
	self.Energy_Increment = self.Range * 0.02
	
	self.dt.Density = 1
	self.dt.Depth = 0
	self.dt.Size = 0
	self.dt.Range = self.Range
	self.dt.Quantity = 0
	self.dt.Distance = 0
	self.dt.ScanAngle = self.Angle
	self.dt.TargetAngle = Angle(0,0,0)
	
	if WireAddon then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On", "Range","ScanAngle" })
		self.Outputs = WireLib.CreateSpecialOutputs(self, 
			{ "On","Density","Depth","Range","Size","Quantity","Distance","ScanAngle","TargetAngle"},
			{"NORMAL","NORMAL","NORMAL","NORMAL","NORMAL","NORMAL","NORMAL","NORMAL","ANGLE"}
		)
	else
		self.Inputs = {{Name="On"}}
	end
	
	self.SetScanAngle(self.Angle)
end

--# Set the maximum range of the scanner ( affects energy use )
function ENT:SetRange(range)
	if not range or type(range) ~= "number" then return end

	if self.env_extra then self.MaxRange = self.env_extra
	else self.MaxRange = 1000
	end

	if range < 10 then range = 10
	elseif range > self.MaxRange then range = self.MaxRange
	end
	-- yeah redundant  -_-
	self.Range = range
	self.dt.Range = self.Range
	self.Energy_Increment = self.Range * (self.Angle * 0.00425)
	return self.Range
end

--# Set the angle of the scaning beam
function ENT:SetScanAngle(angle)
	if not angle or type(angle) ~= "number" then return end

	if angle < 1 then angle = 1
	elseif angle > 45 then angle = 45
	end
	-- todo: ugh get rid of the redundancy
	self.Angle,self.dt.ScanAngle = angle,angle
	return self.Angle
end

--# Activate the Scanner
function ENT:TurnOn()
	self.Active = 1
	self:SetOOO(1)
	self:Scan()
	self:TriggerWireOutputs()
	self:EmitSound("/buttons/combine_button3.wav",100,100)
end

--# Shut down the scanner
function ENT:TurnOff()
	self.Active = 0
	self:SetOOO(0)
	
	-- update datatable
	self.dt.Density = 1
	self.dt.Depth = 0
	self.dt.Size = 0
	self.dt.Quantity = 0
	self.dt.Distance = 0
	self.dt.TargetAngle = Angle(0,0,0)
	-- triger wire outputs
	self:TriggerWireOutputs()
end

--# Read inputs
function ENT:TriggerInput(iname,value)
	if iname == "On" then
		self:SetActive(value)
	end
	if iname == "Range" then
		self:SetRange(value)
	end
	if iname == "ScanAngle" then
		self:SetScanAngle(value)
	end
end

function ENT:TriggerWireOutputs()
	if WireAddon then
		Wire_TriggerOutput(self,"On",self.Active)
		Wire_TriggerOutput(self,"Density",self.dt.Density)
		Wire_TriggerOutput(self,"Depth",self.dt.Depth)
		Wire_TriggerOutput(self,"Range",self.dt.Range)
		Wire_TriggerOutput(self,"Size",self.dt.Size)
		Wire_TriggerOutput(self,"Quantity",self.dt.Quantity)
		Wire_TriggerOutput(self,"Distance",self.dt.Distance)
		Wire_TriggerOutput(self,"ScanAngle",self.dt.ScanAngle )
		Wire_TriggerOutput(self,"TargetAngle",self.dt.TargetAngle )
	end
end

--# Ouch ( todo: make scanner less accurate when damaged )
function ENT:Damage()
	if self.damaged == 0 then self.damaged = 1 end
end

--# Repairs are good.
function ENT:Repair()
	self.BaseClass.Repair(self)
	self:SetColor(Color(255, 255, 255, 255))
	self.damaged = 0
end

--# Scan for the closest resource in the cone.
function ENT:Scan()
	if self:GetResourceAmount("energy") <= 0 then
		self:TurnOff()
		return
	end
	
	local res,Pos = {},self:GetPos()
	local restypes = {"resource_pool","resource_asteroid"}
	scandir = self:GetForward()
	scandir:Normalize()
	
	-- Fooking Hax damn ents.FindInCone is shait!
	local scanAng = math.cos( (math.pi / 180 ) * self.Angle )
	local function IsInCone(ent)
		local dir = (ent:GetPos() - Pos )
		dir:Normalize()
		local dot = scandir:Dot(dir)
		return dot >= scanAng
	end
	
	local ST = ents.FindInSphere(Pos,self.Range)
	for k,v in pairs(ST) do
		if table.HasValue(restypes,v:GetClass()) and IsInCone(v) then
			res[#res+1] = v
		end
	end
	
	local closest,dist = nil, self.Range
	if (#res > 0 ) then
		-- Find the closest target
		for k,v in pairs(res) do 
			local range = Pos:Distance( v:GetPos() )
			if  range < dist then  closest,dist = v,range end
		end
	end
	local quantity = 0
	local density = 1
	local depth = 0
	local size = 0
	local distance = 0
	local angle = Angle(0,0,0)
	
	local function angnorm(ang) -- normalize angle for direction finding.
		if not ang and type(ang) ~= "Angle" then return end
		return Angle( (ang.pitch+180)%360-180,(ang.yaw+180)%360-180,(ang.roll+180)%360-180)
	end
	
	if closest ~= nil then
		density = math.Round( 1+ (closest.density^2 / (dist*1e-1) ),2)
		depth = closest.depth
		size = closest.base_volume
		quantity = #res or 0
		distance = math.Round( ( ( (dist-closest.radius) * 0.75) * 2.54) * 1e-2,2)
		
		local fuckgarry = (closest:GetPos() - self:GetPos())
		fuckgarry:Normalize()
		angle = angnorm ( self:GetAngles() - fuckgarry:Angle() ) or Angle(0,0,0)
	end
		-- update datatable
		self.dt.Density = density
		self.dt.Depth = depth or 0
		self.dt.Size = size
		self.dt.Range = self.Range
		self.dt.Quantity = quantity
		self.dt.Distance = distance
		self.dt.TargetAngle = angle or Angle(0,0,0)
		
	-- triger wire outputs
	self:TriggerWireOutputs()
	-- consume energy
	self:ConsumeResource("energy",self.Energy_Increment)
end

--# Do what we gotta do.
function ENT:Think()
	self.BaseClass.Think(self)
	
	if self.Active == 1 then
		self:Scan()
	end
	self:NextThink( CurTime() + 0.1 )
	return true
end
