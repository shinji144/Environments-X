local EnvX = EnvX

function EnvX.CanNoClip(ply) 
    if ply:GetMoveType() == MOVETYPE_NOCLIP then return true end
    if ply:IsAdmin() then return true end
	if not ply.environment then return true end --double check 
    
	if ply.environment.IsSpace and ply.environment:IsSpace() then return false end --not in space you don't
	
    return true    
end

hook.Add( "CanDrive","FUCKCANDRIVE", function( ply, ent ) return false end)