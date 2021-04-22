local function GetJobByTeamID(ID)
    local name = team.GetName(ID)
    for i,v in pairs(RPExtraTeams)do
        if(v["name"] == name)then
            return v
        end
    end
end

local OpenedFrame = false
local function StartUI_RPNAME(jobbed)
    if(OpenedFrame)then return; end
    OpenedFrame = true
    local Frame = vgui.Create("DFrame")
    Frame:SetSize(650, 160)
    Frame:Center()
    Frame:MakePopup()
    Frame:ShowCloseButton(false)
    Frame:SetTitle("")
	
    function Frame:Paint()
        draw.RoundedBox(5, 0, 0, Frame:GetWide(), Frame:GetTall(), Color( 29, 29, 29, 255 ))
        draw.RoundedBox(0, 25, 70, 250, 25, Color( 100, 100, 100, 200 ))
        draw.DrawText("Prefix", "Trebuchet24", 25, 50, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT)
        draw.DrawText("Name", "Trebuchet24", 275, 50, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT)
        draw.DrawText("Choose your name!", "DermaLarge", 325, 10, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER)
        draw.DrawText("You can take a new identity by typing !rpname.", "DermaDefault", 325, 145, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER)
        local owo = ""
        if(jobbed)then
            owo = GetJobByTeamID(LocalPlayer():Team())["prefix"]
            if(owo == nil)then
                owo = GetJobByTeamID(LocalPlayer():Team())["name"]
            end
        else
            owo = "" -- Default prefix
        end
        draw.DrawText(owo, "CloseCaption_Bold", 265, 70, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT)
    end
	
    local Textbox = vgui.Create("DTextEntry", Frame)
    Textbox:SetSize(350, 25)
    Textbox:SetPos(275, 70)
    Textbox:SetFont("CloseCaption_Bold")
    local Confirm = vgui.Create("DButton", Frame)
    Confirm:SetSize(600, 15)
    Confirm:SetPos(25, 95)
    Confirm:SetText("")
	
    function Confirm:Paint()
        draw.RoundedBox(3, 0, 0, Confirm:GetWide(), Confirm:GetTall(), Color( 100, 255, 100, 255 ))
        draw.DrawText("Confirmation de l'identité", "DermaDefault", 265, 0, Color( 0, 0, 0, 255 ), TEXT_ALIGN_LEFT)
    end
	
    function Confirm:DoClick() -- Defines what should happen when the label is clicked
        net.Start("UPDATENAMERP")
        net.WriteString(Textbox:GetText())
        net.SendToServer()
        OpenedFrame = false
	    Frame:Close()
    end 
end

local function GetJobRPName(ply, job)
    if(file.Exists(ply:SteamID64() .. "_RPNAMEDATA.txt", "DATA"))then
        local owo = file.Read(ply:SteamID64().."_RPNAMEDATA.txt","DATA")
        local uwu = util.JSONToTable(owo)
        if(uwu[job] != nil)then
            return uwu[job]
        else
            return nil
        end
    else
        return nil
    end
end

if(CLIENT)then
    net.Receive("OPENRPUI", function()
        StartUI_RPNAME(true)
    end)
    net.Receive("OPENRPUI_NEW", function()
        StartUI_RPNAME(false)
    end)
end

if(SERVER)then
    util.AddNetworkString("OPENRPUI")
    util.AddNetworkString("OPENRPUI_NEW")
    util.AddNetworkString("RPUINOTIFY")
    util.AddNetworkString("UPDATENAMERP")
	
    hook.Add("PlayerInitialSpawn", "StartUI", function( ply )
        net.Start("OPENRPUI_NEW")
        net.Send(ply)
    end)
	
    hook.Add("CanChangeRPName", "RPOVR", function( ply, name )
        return false, ""
    end)
	
    hook.Add("OnPlayerChangedTeam", "Display_RPNameMenu", function(ply, prev, now)
        local owo = GetJobByTeamID(now)["prefix"]
        local hasname = GetJobRPName(ply, GetJobByTeamID(now)["command"])
        if(hasname != nil)then
            if(owo != nil)then
                ply:setRPName(owo..hasname)
                net.Start("RPUINOTIFY")
                net.WriteString(owo..hasname)
                net.Send(ply)
            end
        else
            net.Start("OPENRPUI")
            net.Send(ply)
        end
    end)
	
    net.Receive("UPDATENAMERP", function(len, ply)
        local owo = net.ReadString()
        if(string.len(owo) < 3) then 
            net.Start("OPENRPUI")
            net.Send(ply)
            return
        end
		
        local qwq = {}
        if(file.Exists(ply:SteamID64() .. "_RPNAMEDATA.txt", "DATA"))then
            qwq = util.JSONToTable(file.Read(ply:SteamID64() .. "_RPNAMEDATA.txt", "DATA"))
        end
        qwq[GetJobByTeamID(ply:Team())["command"]] = owo
        local uwu = GetJobByTeamID(ply:Team())["prefix"]
        if(uwu == nil)then
            uwu = ""
        end
		
        ply:setRPName(uwu..owo)
        net.Start("RPUINOTIFY")
        net.WriteString(uwu..owo)
        net.Send(ply)
        file.Write(ply:SteamID64() .. "_RPNAMEDATA.txt", util.TableToJSON(qwq, false))
    end)
	
    hook.Add("PlayerSay", "RPUICHAT", function( ply, text )
	
	    if string.lower(text) == "!rpname" then
		    net.Start("OPENRPUI")
            net.Send(ply)
	    end
        if string.sub(string.lower(text), 0, 5) == "/nick" then
            return
        end
        if string.sub(string.lower(text), 0, 5) == "/name" then
            return
        end
        if string.sub(string.lower(text), 0, 7) == "/rpname" then
            return
        else
            print(string.sub(string.lower(text), 0, 7))
        end
    end)
end