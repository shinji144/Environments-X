if(SERVER)then


else
		
	function LDE.UI.MissingModelsPanel(Missing)
	
		if(LDE.MissPanel and LDE.MissPanel:IsValid())then return end
		local OpenTime = CurTime()+15
		
		local window = vgui.Create( "DFrame" )
		if ScrW() > 640 then -- Make it larger if we can.
			window:SetSize( ScrW()*0.9, ScrH()*0.9 )
		else
			window:SetSize( 640, 480 )
		end
		window:Center()
		window:SetTitle( "Env-X Notification!" )
		window:SetVisible( true )
		window:MakePopup()
		window:ShowCloseButton( false ) 

		LDE.MissPanel=window 
		
		local button = vgui.Create( "DButton", window )
		button:SetText( "Click a button to copy packs link into your clipboard. (Then Paste it into your browser.)" )
		button.DoClick = function() end
		button:SetSize( 600, 40 )
		button:SetPos( 10, button:GetTall() - 10 )	
		
		local lbox = vgui.Create( "DButton", window )
		lbox:SetText( "Click a box for a link." )
		lbox.DoClick = function() end
		lbox:SetSize( 400, 80 )
		lbox:SetPos( 500, lbox:GetTall()*7 - 10 )
		
		local instruct = vgui.Create( "DButton", window )
		instruct:SetText( "Instructions: " ) 
		instruct.DoClick = function() end
		instruct:SetSize( 400, 40 )
		instruct:SetPos( 90, instruct:GetTall()*14 - 20 )
		
		local html = vgui.Create( "HTML", window )--Make the html before hand.
		local I=0
		for N,v in pairs(Missing) do 
			I=I+1
			local button = vgui.Create( "DButton", window )
			button:SetText( N )
			button.DoClick = function() 
				html:SetSize( 600, 400 ) 
				html:SetPos( 420, 80 ) 
				html:OpenURL( v.S )
				lbox:SetText( v.L )
				instruct:SetText( v.I )
				lbox.DoClick = function()
					SetClipboardText(v.L) 
				end	
			end
			button:SetSize( 400, 80 )
			button:SetPos( 10, button:GetTall()*I - 10 )			
		end
		
		local button = vgui.Create( "DButton", window )
		button:SetText( "Please Install These." )
		button.DoClick = function()
			if(OpenTime-CurTime()<0)then 
				window:Close() 
			end 
		end
		button.Think = function()
			if(OpenTime-CurTime()>0)then
				button:SetText("Can close in... "..math.Round(OpenTime-CurTime())) 
			else 
				button:SetText("Close Now.")
			end
		end
		button:SetSize( 150, 40 )
		button:SetPos( (window:GetWide() - button:GetWide()) / 3, window:GetTall() - button:GetTall() - 20 )
	end

end		
