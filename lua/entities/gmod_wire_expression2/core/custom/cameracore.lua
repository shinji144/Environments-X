E2Lib.RegisterExtension("E2Camera", true)

--Useful
local function Camera_Get(E2,Index)
	if E2.Cameras==nil then return end
	return E2.Cameras[Index]
end

local function Camera_Count(E2)
	if E2.Cameras == nil then return 0 end
	return #E2.Cameras
end

local function Camera_List(E2)
	if E2.Cameras == nil then return {} end
	return E2.Cameras
end

--Zooming
local function Player_Zoom(Player,Zoom,Time)
	if not ValidEntity(Player) then return end
	if not Player:IsPlayer() then return end
	Zoom=Zoom or 0
	if Time == 0 then Time = 0.01 end
	Player:SetFOV(Zoom,Time)
end

local function Camera_Zoom(E2,Player,Index,Zoom,Time)
	local Camera = Camera_Get(E2,Index)
	if Camera == nil then return end
	Camera.Zoom = Zoom
	if Player:GetViewEntity() == Camera then
		Player_Zoom(Player,Zoom,Time)
	end
end



--Start
local function Camera_Start(E2,Player,Index)
	local Camera = Camera_Get(E2,Index)
	if Camera == nil then return end
	if not ValidEntity(Player) then return end
	Player:SetViewEntity(Camera)
	Player_Zoom(Player,Camera.Zoom,0)
end
--Stop
local function Camera_Stop(Player)
	if not ValidEntity(Player) then return end
	Player:SetViewEntity()
	Player_Zoom(Player,0,0)
end

--Creation
local function Camera_Create(E2,Player,Index,Position,Angles,Zoom)
	if E2.Cameras==nil then E2.Cameras={} end
	local Camera = Camera_Get(E2,Index)
	if Camera==nil then
		Camera = ents.Create("gmod_wire_cam")
		Camera:SetColor(0, 0, 0, 0)
		Camera:SetModel("models/props_junk/PopCan01a.mdl")
		Camera:Spawn()
		E2.Cameras[Index]=Camera
	end
	Camera:SetPos(Position)
	Camera:SetAngles(Angles)
	Camera.Zoom = Zoom
end

local function Camera_Delete(E2,Player,Index)
	local Camera = Camera_Get(E2,Index)
	if Camera ~= nil then
		if Player:GetViewEntity() == Camera then
			Camera_Stop(Player)
		end
		Camera:Remove()
	end
end

local function Camera_DeleteAll(E2,Player)
	Camera_Stop(Player)
	if E2.Cameras==nil then return end
	for Index,Camera in pairs (E2.Cameras) do
		Camera:Remove()
	end
	E2.Cameras=nil
end

registerCallback("destruct", function(self)
	if not self or not ValidEntity(self.entity) then return end 
	Camera_DeleteAll(self.entity,self.player)
end)

--Movement
local function Camera_Position(E2,Index,Position)
	local Camera = Camera_Get(E2,Index)
	if Camera == nil then return end
	Position = Position or Vector(0,0,0)
	Camera:SetPos(Position)
end

local function Camera_Move(E2,Index,Direction)
	local Camera = Camera_Get(E2,Index)
	if Camera == nil then return end
	Direction = Direction or Vector(0,0,0)
	Camera:SetPos(Camera:GetPos()+Direction)
end

--Angles
local function Camera_Angle(E2,Index,Angles)
	local Camera = Camera_Get(E2,Index)
	if Camera == nil then return end
	Angles = Angles or Angle(0,0,0)
	Camera:SetAngles(Angles)
end

local function Camera_Tilt(E2,Index,Angles)
	local Camera = Camera_Get(E2,Index)
	if Camera == nil then return end
	Angles = Angles or Angle(0,0,0)
	Camera:SetAngles(Camera:GetAngles()+Angles)
end

--Parenting

local function Camera_Parent(E2,Index,Parent)
	local Camera = Camera_Get(E2,Index)
	if Camera == nil then return end
	if not ValidEntity(Parent) then return end
	Camera:SetParent(Parent)
end

local function Camera_DeParent(E2,Index)
	local Camera = Camera_Get(E2,Index)
	if Camera == nil then return end
	Camera:SetParent()
end

-- E2 Functions

--Useful
e2function entity camera(index)
	return Camera_Get(self.entity,index)
end

e2function array cameraList()
	return Camera_List(self.entity)
end

e2function number cameraCount()
	return Camera_Count(self.entity)
end

--Start
e2function void cameraStart(number index)
	Camera_Start(self.entity,self.player,index)
end

e2function void entity:cameraStart(number index)
	if not ValidEntity(this) then return nil end
	if not this:IsVehicle() then return nil end
	if this:GetDriver() == nil then return nil end
	Camera_Start(self.entity,this:GetDriver(),index)
end

--Stop
e2function void cameraStop()
	Camera_Stop(self.player)
end

e2function void entity:cameraStop()
	if not ValidEntity(this) then return nil end
	if not this:IsVehicle() then return nil end
	if this:GetDriver() == nil then return nil end
	Camera_Stop(this:GetDriver())
end
hook.Add("PlayerLeaveVehicle", "StopTheCameras", Camera_Stop)

--Creation
e2function void cameraCreate(number index,vector pos,angle rot,number zoom)
	Camera_Create(self.entity,self.player,index,Vector(pos[1],pos[2],pos[3]),Angle(rot[1],rot[2],rot[3]),zoom)
end

e2function void cameraCreate(number index,vector pos,angle rot)
	Camera_Create(self.entity,self.player,index,Vector(pos[1],pos[2],pos[3]),Angle(rot[1],rot[2],rot[3]),0)
end

e2function void cameraCreate(number index,vector pos)
	Camera_Create(self.entity,self.player,index,Vector(pos[1],pos[2],pos[3]),self.entity:GetAngles(),0)
end

e2function void cameraCreate(number index)
	Camera_Create(self.entity,self.player,index,self.entity:GetPos()+self.entity:GetUp()*25,self.entity:GetAngles(),0)
end

e2function void cameraDelete(number index)
	Camera_Delete(self.entity,self.player,index)
end

e2function void cameraDeleteAll()
	Camera_DeleteAll(self.entity,self.player)
end

--Angles
e2function void cameraAng(number index,angle rot)
	Camera_Angle(self.entity,index,Angle(rot[1],rot[2],rot[3]))
end

e2function void cameraTilt(number index,angle rot)
	Camera_Tilt(self.entity,index,Angle(rot[1],rot[2],rot[3]))
end

--Movement
e2function void cameraPos(number index,vector pos)
	Camera_Position(self.entity,index,Vector(pos[1],pos[2],pos[3]))
end
e2function void cameraMove(number index,vector pos)
	Camera_Move(self.entity,index,Vector(pos[1],pos[2],pos[3]))
end


--Zooming
e2function void cameraZoom(number index,number zoom)
	Camera_Zoom(self.entity,self.player,index,zoom,0)
end

e2function void cameraZoom(number index,number zoom,number secs)
	Camera_Zoom(self.entity,self.player,index,zoom,secs)
end


--Parenting
e2function void cameraParent(number index,entity parent)
	Camera_Parent(self.entity,index,parent)
end

e2function void cameraUnParent(number index)
	Camera_DeParent(self.entity,index)
end