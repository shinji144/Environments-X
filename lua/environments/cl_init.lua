
local scripted_ents = scripted_ents
local table = table
local util = util
local timer = timer
local ents = ents
local duplicator = duplicator
local math = math
local tostring = tostring
local MeshQuad = MeshQuad
local Vector = Vector
local type = type
local tonumber = tonumber
local pairs = pairs

local drawcables = CreateClientConVar("env_draw_cables", 1, true, true)

hook.Add( "PopulateMenuBar", "EnvironmentsLifeSupportAddMenubar", function( menubar )
    local m = menubar:AddOrGetMenu( "Environments" )
	
	m:AddSpacer()
	
	m:AddCVar( "Draw 3D Cables?", "env_draw_cables", "1", "0" )
end)
	

local models = {}
function Environments.GetScreenInfo(model)
	local info = {}
	for k,v in pairs(models) do
		if k == model then
			return v
		end
	end
end

function Environments.RegisterModelScreenData(model, offset, angle, height, width)
	models[model] = {}
	models[model].Offset = offset
	models[model].Angle = angle
	models[model].X = width
	models[model].Y = height
end
Environments.RegisterModelScreenData("models/punisher239/punisher239_reactor_small.mdl", Vector(-110,0,50), Angle(0,30,270), 0, 0)

if CLIENT then
	local resolution = 0.1
	local startpos, endpos, endpos2, cyl
	function Environments.DrawCable(ent, p1, p1f, p2, p2f)
		if Mesh then
			ent.mesh = Mesh()
		else
			ent.mesh = NewMesh()
		end
		local tab = {}
		for mu = 0, 1 - resolution, resolution do
			startpos =  Vector( ( p2.x - p1.x ) * mu + p1.x, hermiteInterpolate( p2.y - p1f.y * 100, p1.y, p2.y, p1.y - p2f.y * 100, 0.5, 0, mu ), hermiteInterpolate( p2.z - p1f.z * 100, p1.z, p2.z, p1.z - p2f.z * 100, 0.5, 0, mu ) )
			endpos = Vector( ( p2.x - p1.x ) * ( mu + resolution ) + p1.x, hermiteInterpolate( p2.y - p1f.y * 100, p1.y, p2.y, p1.y - p2f.y * 100, 0.5, 0, mu + resolution ), hermiteInterpolate( p2.z - p1f.z * 100, p1.z, p2.z, p1.z - p2f.z * 100, 0.5, 0, mu + resolution ) )
			
			if ( mu + resolution >= 1 ) then
				endpos2 = p2 - p1f * 100
			else
				endpos2 = Vector( ( p2.x - p1.x ) * ( mu + resolution*2 ) + p1.x, hermiteInterpolate( p2.y - p1f.y * 100, p1.y, p2.y, p1.y - p2f.y * 100, 0.5, 0, mu + resolution*2 ), hermiteInterpolate( p2.z - p1f.z * 100, p1.z, p2.z, p1.z - p2f.z * 100, 0.5, 0, mu + resolution*2 ) )
			end
			
			cyl = GenerateCylinder( startpos, endpos - startpos, endpos, endpos2 - endpos, 1.3 )
			for k,v in pairs(cyl) do
				table.insert(tab, v)
			end
		end
		ent.mesh:BuildFromTriangles(tab)
	end
	
	local ang
	function getStartPosition( p, d, angle, radius )
		ang = d:Angle():Right():Angle()
		ang:RotateAroundAxis( d, angle )
		return p + (ang:Forward() * radius)
	end

	local ang
	function getEndPosition( p, d, angle, radius )
		ang = d:Angle():Right():Angle()
		ang:RotateAroundAxis( d, angle )
		return p + (ang:Forward() * radius)
	end
	
	local function Vertex( pos, u, v, normal )
		return { pos = pos, u = u, v = v, normal = normal }
	end
	
	local function MeshQuad( v1, v2, v3, v4, t ) --s = 0
		return
		{        
			Vertex( v1, 0, 0 ),
			Vertex( v2, (v1-v2):Length() * t, 0 ),
			Vertex( v4, 0, (v1-v4):Length() * t ),
			Vertex( v2, (v1-v2):Length() * t, 0 ),
			Vertex( v3, (v3-v4):Length() * t, (v2-v3):Length() * t),
			Vertex( v4, 0, (v1-v4):Length() * t ),
		}    
	end
	
	local angle, ang
	function GenerateCylinder( p1, d1, p2, d2, radius, segments )
		segments = segments or 10
		angle = 360 / segments
		d1:Normalize()
		d2:Normalize()
		local tab = {}	
		for i = 0, segments - 1 do
			ang = i * angle
			--local inside = MeshQuad(getStartPosition( p1, d1, ang, radius ),getStartPosition( p1, d1, ang + angle, radius ),getEndPosition( p2, d2, ang + angle, radius ),getEndPosition( p2, d2, ang, radius ), 1)
			-- Outside
			local outside = MeshQuad(getEndPosition( p2, d2, ang, radius ),getEndPosition( p2, d2, ang + angle, radius ),getStartPosition( p1, d1, ang + angle, radius ),getStartPosition( p1, d1, ang, radius ), 0.1)--i*0.1, (i + 1)*0.1)

			--for k,v in pairs(inside) do
			--	table.insert(tab, v)
		--	end
			for k,v in pairs(outside) do
				table.insert(tab, v)
			end
		end
		return tab
	end
	
	local m0, m1, mu2, mu3
	local a0, a1, a2, a3
	function hermiteInterpolate( y1, y2, y3, y4, tension, bias, mu )	
		mu2 = mu * mu --mu^2
		mu3 = mu2 * mu --mu^3
		m0 = ( y2 - y1 ) * ( 1 + bias ) * ( 1 - tension ) / 2 + ( y3 - y2 ) * ( 1 - bias ) * ( 1 - tension ) / 2
		m1 = ( y3 - y2 ) * ( 1 + bias ) * ( 1 - tension ) / 2 + ( y4 - y3 ) * ( 1 - bias ) * ( 1 - tension ) / 2
		a0 = 2 * mu3 - 3 * mu2 + 1
		a1 = mu3 - 2 * mu2 + mu
		a2 = mu3 - mu2
		a3 = -2 * mu3 + 3 * mu2
		
		return a0 * y2 + a1 * m0 + a2 * m1 + a3 * y3
	end
end

local nettable = {}
local ent_table = {}
//New Networking System, sorry RD3
local function CreateNetTable(netid)
	nettable[netid] = {}
	local index = nettable[netid]
	index.resources = {}
	index.maxresources = {}
	index.cons = {}
	
	index.resources_last = {}
	index.last_update = {};
	
	return index
end

function Environments.GetNetTable(id)
	if !id then
		return nettable
	end
	return nettable[id] or CreateNetTable(id)
end

local function CreateEntTable(id)
	ent_table[id] = {}
	local index = ent_table[id]
	index.network = 0
	index.resources = {}
	index.maxresources = {}
	return index
end

function Environments.GetEntTable(id)
	if !id then
		return ent_table
	end
	return ent_table[id] or CreateEntTable(id)
end
