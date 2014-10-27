if(SERVER)then
	util.AddNetworkString( "PlyOpenLDEMotd" )
	
	function OpenMotdThing( ply, text, public )
		if (string.sub(text, 1, 6) == "!xmotd") then
			net.Start( "PlyOpenLDEMotd" )
			net.Send( ply )
			return true
		end
	end
	hook.Add( "PlayerSay", "chatCommand", OpenMotdThing );

else
		
	function LDE.UI.MOTD()
		local window = vgui.Create( "DFrame" )
		if ScrW() > 640 then -- Make it larger if we can.
			window:SetSize( ScrW()*0.9, ScrH()*0.9 )
		else
			window:SetSize( 640, 480 )
		end
		window:Center()
		window:SetTitle( "Env-X MOTD!" )
		window:SetVisible( true )
		window:MakePopup()
		
		local html = vgui.Create( "HTML", window )

		local button = vgui.Create( "DButton", window )
		button:SetText( "Close" )
		button.DoClick = function() window:Close() end
		button:SetSize( 150, 40 )
		button:SetPos( (window:GetWide() - button:GetWide()) / 2, window:GetTall() - button:GetTall() - 10 )
			
		html:SetSize( window:GetWide() - 20, window:GetTall() - button:GetTall() - 50 )
		html:SetPos( 10, 30 )
		html:OpenURL( "http://tausc.site.nfoservers.com/SBMOTD/MOTD.html" )
	end
	
    net.Receive( "PlyOpenLDEMotd", function( len )
		LDE.UI.MOTD()
    end )
	
end		
