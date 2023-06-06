if FuriousAdminMenu.Config.ESX.Enabled then
    ESX = nil
    TriggerEvent(FuriousAdminMenu.Config.ESX.CoreEvent, function(obj) 
        ESX = obj 
    end)
end

TriggerEvent('FuriousAdmin:updateAllBans')

local BotToken = "Bot " .. FuriousAdminMenu.Config.DiscordSetup.BotToken
local tracked = {}
local Permissions = {
    OpenMenu = {},
    Ban = {},
    Kick = {},
    UnbanPlayer = {},
    SetMoney = {},
    SetBank = {},
    SetGroup = {},
    SetPermissionLevel = {},
    Spectate = {},
    Goto = {},
    Bring = {},
    FreezePlayer = {},
    ClearLoadout = {},
    ScreenshotPlayer = {},
    SpawnVehicle = {},
    FixVehicle = {},
    CleanVehicle = {},
    FlipVehicle = {},
    DeleteVehicle = {},
    Heal = {},
    FullArmor = {},
    NoClip = {},
    Invisibility = {},
    GodMode = {},
    GiveWeapon = {},          
    TeleportToWaypoint = {},
    CarWipe = {},
    EntityWipe = {}
}

function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
        data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = BotToken})
    while data == nil do
        Citizen.Wait(0)
    end
    return data
end

function GetRoleIdFromRoleName(name)
    if (Caches.RoleList ~= nil) then 
        return tonumber(Caches.RoleList[name]);
    else 
        local roles = GetGuildRoleList();
        return tonumber(roles[name]);
    end
end

function CheckEqual(role1, role2)
    local checkStr1 = false;
    local checkStr2 = false;
    local roleID1 = role1;
    local roleID2 = role2;
    local searchGuild1 = true;
    local searchGuild2 = true;
    if type(role1) == "string" then checkStr1 = true end;
    if type(role2) == "string" then checkStr2 = true end; 
    if checkStr1 then 
        local roles2 = {};
        for roleRef, roleID in pairs(roles2) do 
            if roleRef == role1 then 
                roleID1 = roleID;
                searchGuild1 = false;
            end
        end
        if searchGuild1 then 
            local roles = GetGuildRoleList();
            for roleName, roleID in pairs(roles) do 
                if roleName == role1 then 
                    roleID1 = roleID;
                end
            end
        end
    end
    if checkStr2 then
        local roles2 = {};
        for roleRef, roleID in pairs(roles2) do 
            if roleRef == role2 then 
                roleID2 = roleID;
                searchGuild2 = false;
            end
        end 
        if searchGuild2 then 
            local roles = GetGuildRoleList();
            for roleName, roleID in pairs(roles) do 
                if roleName == role2 then 
                    roleID2 = roleID;
                end
            end
        end
    end
    if tonumber(roleID1) == tonumber(roleID2) then 
        return true;
    end
    return false;
end

function GetDiscordName(user) 
    local discordId = nil
    local nameData = nil;
    for _, id in ipairs(GetPlayerIdentifiers(user)) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break
        end
    end
    if discordId then 
        local endpoint = ("users/%s"):format(discordId)
        local member = DiscordRequest("GET", endpoint, {})
        if member.code == 200 then
            local data = json.decode(member.data)
            if data ~= nil then 
                nameData = data.username .. "#" .. data.discriminator;
            end
        end
    end
    return nameData;
end

Caches = {
    Avatars = {}
}

function ResetCaches()
    Caches = {};
end

function GetGuildRoleList()
    if (Caches.RoleList == nil) then 
        local guild = DiscordRequest("GET", "guilds/"..FuriousAdminMenu.Config.DiscordSetup.GuildID, {})
        if guild.code == 200 then
            local data = json.decode(guild.data)
            local roles = data.roles;
            local roleList = {};
            for i = 1, #roles do 
                roleList[roles[i].name] = roles[i].id;
            end
            Caches.RoleList = roleList;
        else
            Caches.RoleList = nil;
        end
    end
    return Caches.RoleList;
end

local recent_role_cache = {}

function GetDiscordRoles(user)
    local discordId = nil
    for _, id in ipairs(GetPlayerIdentifiers(user)) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break;
        end
    end

    if discordId then
        if recent_role_cache[discordId] then
            return recent_role_cache[discordId]
        end
        local endpoint = ("guilds/%s/members/%s"):format(FuriousAdminMenu.Config.DiscordSetup.GuildID, discordId)
        local member = DiscordRequest("GET", endpoint, {})
        if member.code == 200 then
            local data = json.decode(member.data)
            local roles = data.roles
            if true then
                recent_role_cache[discordId] = roles
                Citizen.SetTimeout(((5)*1000), function() 
                    recent_role_cache[discordId] = nil
                end)
            end
            return roles
        else
            return false
        end
    else
        return false
    end
    return false
end

function RefreshDiscordRoles(player)
    local discordId = nil
    for _, id in ipairs(GetPlayerIdentifiers(player)) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break;
        end
    end

    if discordId then
        if recent_role_cache[discordId] then
            return recent_role_cache[discordId]
        end
        local endpoint = ("guilds/%s/members/%s"):format(FuriousAdminMenu.Config.DiscordSetup.GuildID, discordId)
        local member = DiscordRequest("GET", endpoint, {})
        if member.code == 200 then
            local data = json.decode(member.data)
            local roles = data.roles
            recent_role_cache[discordId] = roles
            Wait(5000)
            recent_role_cache[discordId] = nil
        end
    end
end

RegisterServerEvent('FuriousAdmin:RefreshSVRoles')
AddEventHandler('FuriousAdmin:RefreshSVRoles', function()
    TriggerClientEvent('FuriousAdmin:RefreshCLRoles', source)
    RefreshDiscordRoles(source)
end)

Citizen.CreateThread(function()
    local guild = DiscordRequest("GET", "guilds/"..FuriousAdminMenu.Config.DiscordSetup.GuildID, {})
    if guild.code == 200 then
        local data = json.decode(guild.data)
        print("^1[FuriousAdmin]^7 ^4[Discord]^7: Admin Menu set to: "..data.name.." ("..data.id..")")
        Wait(500)
        TriggerClientEvent('FuriousAdmin:ShowPlayerlist', -1)
        TriggerClientEvent('FuriousAdmin:RefreshCLRoles', -1)
    else
        print("^1[FuriousAdmin]^7 ^4[Discord]^7: An error occured, please check your config and ensure everything is correct. Error: "..(guild.data or guild.code)) 
    end
end)

function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end
    return identifiers
end

function BanPlayer(src, reason, bannedby, banlength) 
    local bansFile = LoadResourceFile(GetCurrentResourceName(), "bans.json")
    local cfg = json.decode(bansFile)
    local ids = ExtractIdentifiers(src);
    local playerIP = ids.ip;
    local playerSteam = ids.steam;
    local playerLicense = ids.license;
    local playerXbl = ids.xbl;
    local playerLive = ids.live;
    local playerDisc = ids.discord;
    local banData = {};
    banData['ip'] = "Not Provided";
    banData['reason'] = reason;
    banData['bannedby'] = bannedby;
    banData['ban'] = banlength;
    banData['license'] = "Not Provided";
    banData['steam'] = "Not Provided";
    banData['xbl'] = "Not Provided";
    banData['live'] = "Not Provided";
    banData['discord'] = "Not Provided";
    if ip ~= nil and ip ~= "nil" and ip ~= "" then 
        banData['ip'] = tostring(ip);
    end
    if playerLicense ~= nil and playerLicense ~= "nil" and playerLicense ~= "" then 
        banData['license'] = tostring(playerLicense);
    end
    if playerSteam ~= nil and playerSteam ~= "nil" and playerSteam ~= "" then 
        banData['steam'] = tostring(playerSteam);
    end
    if playerXbl ~= nil and playerXbl ~= "nil" and playerXbl ~= "" then 
        banData['xbl'] = tostring(playerXbl);
    end
    if playerLive ~= nil and playerLive ~= "nil" and playerLive ~= "" then 
        banData['live'] = tostring(playerXbl);
    end
    if playerDisc ~= nil and playerDisc ~= "nil" and playerDisc ~= "" then 
        banData['discord'] = tostring(playerDisc);
    end
    cfg[tostring(GetPlayerName(src))] = banData;
    SaveResourceFile(GetCurrentResourceName(), "bans.json", json.encode(cfg, { indent = true }), -1)
end

function isBanned(src)
    local bansFile = LoadResourceFile(GetCurrentResourceName(), "bans.json")
    local cfg = json.decode(bansFile)
    local ids = ExtractIdentifiers(src);
    local playerIP = ids.ip;
    local playerSteam = ids.steam;
    local playerLicense = ids.license;
    local playerXbl = ids.xbl;
    local playerLive = ids.live;
    local playerDisc = ids.discord;
    for k, v in pairs(cfg) do 
        local reason = v['reason']
        local bannedby = v['bannedby']
        local ip = v['ip']
        local license = v['license']
        local steam = v['steam']
        local xbl = v['xbl']
        local live = v['live']
        local discord = v['discord']
        if tostring(ip) == tostring(playerIP) then 
            return { ['reason'] = reason, ['bannedby'] = bannedby } 
        end;
        if tostring(license) == tostring(playerLicense) then 
            return { ['reason'] = reason, ['bannedby'] = bannedby } 
        end;
        if tostring(steam) == tostring(playerSteam) then 
            return { ['reason'] = reason, ['bannedby'] = bannedby } 
        end;
        if tostring(xbl) == tostring(playerXbl) then 
            return { ['reason'] = reason, ['bannedby'] = bannedby } 
        end;
        if tostring(live) == tostring(playerLive) then 
            return { ['reason'] = reason, ['bannedby'] = bannedby } 
        end;
        if tostring(discord) == tostring(playerDisc) then 
            return { ['reason'] = reason, ['bannedby'] = bannedby } 
        end;
    end
    return false;
end

function OnPlayerConnecting(name, setKickReason, deferrals)
    deferrals.defer();
    local src = source;
    local banned = false;
    local ban = isBanned(src);
    local ids = ExtractIdentifiers(src);
    local playerIP = ids.ip;
    local playerSteam = ids.steam;
    if GetPlayerName(src) then
        print('^1[Furious Admin]^7 ^1[Info]^7: Checking ban data for ^4'..GetPlayerName(src)..'^7')
    end
    Citizen.Wait(100);
    if ban then
        local reason = ban['reason'];
        local bannedby = ban['bannedby'];
        if GetPlayerName(src) then
            print('^1[Furious Admin]^7 ^3[Alert]^7: The Player ^4'..GetPlayerName(src)..'^7 tried joining, but is banned for ^2'..reason..'^7')
        end
        deferrals.done('\n\n\n[Furious Admin]:\nInformation: You\'ve been banned from '..FuriousAdminMenu.Config.Main.ServerName..'\nReason: '..reason..'\nBanned By: '..bannedby..'\nSteamhex: '..playerSteam:gsub('steam:', '')..'\n\nAppeal at our Discord - '..FuriousAdminMenu.Config.Main.DiscordInvite..'\n\n');
        banned = true;
        CancelEvent();
        return;
    else
        deferrals.done();
    end
end

function updateBan()
    local bansFile = LoadResourceFile(GetCurrentResourceName(), "bans.json")
    local cfg = json.decode(bansFile)
    for k, v in pairs(cfg) do 
        cfg['banlength'] = tonumber(cfg['banlength']) - 5;
        if cfg['banlength'] <= 0 then
            UnbanPlayer(cfg['steam'])
        else
            SaveResourceFile(GetCurrentResourceName(), "bans.json", json.encode(cfg, { indent = true }), -1)
        end
    end
end

function checkSteamBan(banSteam)
    local bansFile = LoadResourceFile(GetCurrentResourceName(), "bans.json")
    local cfg = json.decode(bansFile)
    for k, v in pairs(cfg) do 
        local steam = tostring(v['steam']);
        if steam == tostring(banSteam) then
            return true;
        else
            return false;
        end
    end
end

function ReturnName(banSteam)
    local bansFile = LoadResourceFile(GetCurrentResourceName(), "bans.json")
    local cfg = json.decode(bansFile)
    for k, v in pairs(cfg) do 
        local steam = tostring(v['steam']);
        if steam == tostring(banSteam) then 
            local name = k;
            return name;
        end
    end
    return false;
end

function UnbanPlayer(banSteam)
    local bansFile = LoadResourceFile(GetCurrentResourceName(), "bans.json")
    local cfg = json.decode(bansFile)
    for k, v in pairs(cfg) do 
        local steam = tostring(v['steam']);
        if steam == tostring(banSteam) then 
            local name = k;
            cfg[k] = nil;
            SaveResourceFile(GetCurrentResourceName(), "bans.json", json.encode(cfg, { indent = true }), -1)
            return name;
        end
    end
    return false;
end

function HasPermission(perm, player)
    if perm == 'Noclip' then
        return(Permissions[player].NoClip or false)
    elseif perm == 'Invisibility' then
        return(Permissions[player].Invisibility or false)
    elseif perm == 'Godmode' then
        return(Permissions[player].Godmode or false)
    elseif perm == 'GiveWeapon' then
        return(Permissions[player].GiveWeapon or false)
    elseif perm == 'Carwipe' then
        return(Permissions[player].CarWipe or false)
    elseif perm == 'FixVehicle' then
        return(Permissions[player].FixVehicle or false)
    elseif perm == 'CleanVehicle' then
        return(Permissions[player].CleanVehicle or false)
    elseif perm == 'FlipVehicle' then
        return(Permissions[player].FlipVehicle or false)
    elseif perm == 'DeleteVehicle' then
        return(Permissions[player].DeleteVehicle or false)
    elseif perm == 'Entitywipe' then
        return(Permissions[player].EntityWipe or false)
    elseif perm == 'Heal' then
        return(Permissions[player].Heal or false)
    elseif perm == 'FullArmor' then
        return(Permissions[player].FullArmor or false)
    elseif perm == 'Ban' then
        return(Permissions[player].Ban or false)
    elseif perm == 'Kick' then
        return(Permissions[player].Kick or false)
    elseif perm == 'UnbanPlayer' then
        return(Permissions[player].UnbanPlayer or false)
    elseif perm == 'OpenMenu' then
        return(Permissions[player].OpenMenu or false)
    elseif perm == 'SetPermissionLevel' then
        return(Permissions[player].SetPermissionLevel or false)
    elseif perm == 'SetGroup' then
        return(Permissions[player].SetGroup or false)
    elseif perm == 'SetBank' then
        return(Permissions[player].SetBank or false)
    elseif perm == 'SetMoney' then
        return(Permissions[player].SetMoney or false)
    elseif perm == 'TeleportToWaypoint' then
        return(Permissions[player].TeleportToWaypoint or false)
    elseif perm == 'Bring' then
        return(Permissions[player].Bring or false)
    elseif perm == 'Goto' then
        return(Permissions[player].Goto or false)
    elseif perm == 'SendBack' then
        return(Permissions[player].SendBack or false)
    elseif perm == 'GoBack' then
        return(Permissions[player].GoBack or false)
    else
        return(false)
    end
end

local GoBackCoords = {}
local SendBackCoords = {}

AddEventHandler("playerConnecting", OnPlayerConnecting)

RegisterServerEvent("FuriousAdmin:AddToServerlist")
AddEventHandler("FuriousAdmin:AddToServerlist", function(currentplayer)
    TriggerClientEvent('FuriousAdmin:AddToPlayerlist', -1, currentPlayer)
end)

AddEventHandler('playerDropped', function()
    TriggerClientEvent('FuriousAdmin:RevokeFromPlayerlist', source)
end)

RegisterServerEvent('FuriousAdmin:updateAllBans')
AddEventHandler('FuriousAdmin:updateAllBans', function()
    updateBan()
    Wait(5 * 1000)
    TriggerEvent('FuriousAdmin:updateAllBans')
end)

RegisterServerEvent('FuriousAdmin:TestEvent')
AddEventHandler('FuriousAdmin:TestEvent', function(data)
	urlLocation = data:find('url')
    ssUrlBeg = data:sub(urlLocation):gsub('url": "', '')
    ssUrlEnd = ssUrlBeg:find('screenshot.jpg')
    screenshotUrl = ssUrlBeg:sub(1, tonumber(ssUrlEnd - 1))..'screenshot.jpg'
end)

ESX.RegisterServerCallback('FuriousAdmin:CheckValidId', function(source, cb, playerId)
    if tonumber(playerId) and GetPlayerName(playerId) then
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('FuriousAdmin:TargetCorrectPlayer')
AddEventHandler('FuriousAdmin:TargetCorrectPlayer', function(tcpType, targetsId, targetsPed, vehicle, vehicleName, Bx, By, Bz)
    if tcpType == 'screenshot' then
        TriggerClientEvent('FuriousAdmin:ScreenshotPlayer', targetsId)
    elseif tcpType == 'clearloadout' then
        TriggerClientEvent('FuriousAdmin:ClearPlayersLoadout', targetsId)
        TriggerClientEvent('FuriousAdmin:NotifyMessage', targetsId, 'clearloadout', GetPlayerName(source))
    elseif tcpType == 'bring' then
        SendBackCoords[targetsId] = GetEntityCoords(GetPlayerPed(targetsId))
        TriggerClientEvent('FuriousAdmin:BringPlayer', targetsId, GetPlayerName(source), Bx, By, Bz)
        TriggerClientEvent('FuriousAdmin:NotifyMessage', targetsId, 'bring', GetPlayerName(source))
    elseif tcpType == 'goto' then
        GoBackCoords[source] = GetEntityCoords(GetPlayerPed(source))
        TriggerClientEvent('FuriousAdmin:GotoPlayer', source, targetsPed, GetPlayerName(source))
        TriggerClientEvent('FuriousAdmin:NotifyMessage', targetsId, 'goto', GetPlayerName(source))
    elseif tcpType == 'givecar' then
        TriggerClientEvent('FuriousAdmin:GiveCarCL', targetsId, vehicle)
        TriggerClientEvent('FuriousAdmin:NotifyMessage', targetsId, 'givecar', GetPlayerName(source), vehicleName)
    end
end)

RegisterServerEvent('FuriousAdmin:SyncCoords')
AddEventHandler('FuriousAdmin:SyncCoords', function(coords)
    TriggerClientEvent('FuriousAdmin:GotoCoords', source, coords)
end)

RegisterServerEvent('FuriousAdmin:SyncFreeze')
AddEventHandler('FuriousAdmin:SyncFreeze', function(currentPlayer, freezeType)
    TriggerClientEvent('FuriousAdmin:FreezeToggle', currentPlayer, freezeType)
end)

RegisterServerEvent('FuriousAdmin:ScriptError')
AddEventHandler('FuriousAdmin:ScriptError', function(data)
    if data == 'Menu Size Error' then
        print('^1[FuriousAdmin]^7 ^3[Alert]^7: Menu Size is not Set Correctly in the Config!')
        Wait(50)
        print('^1[FuriousAdmin]^7 ^3[Alert]^7: Size will Automatically be Set to Medium')
        Wait(50)
        print('^1[FuriousAdmin]^7 ^3[Alert]^7: Size set to: ^2"'..FuriousAdminMenu.Config.Menu.MenuSize..'"^7, Sizes availible: ^2"small", "medium", "large"^7')
    end
end)

RegisterServerEvent('FuriousAdmin:GetBanlist')
AddEventHandler('FuriousAdmin:GetBanlist', function()
    local BanFile = LoadResourceFile(GetCurrentResourceName(), "bans.json")
    local BansData = json.decode(BanFile)
    TriggerClientEvent('FuriousAdmin:ReturnBanlist', source, BansData)
end)

RegisterServerEvent('FuriousAdmin:BanPlayer')
AddEventHandler('FuriousAdmin:BanPlayer', function(source, tgt, BanReason, BanLength)
    if GetPlayerName(tgt) then
        TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 You banned '..GetPlayerName(tgt)..'! </div>'
        })
        BanPlayer(tgt, BanReason, GetPlayerName(source), BanLength)
        DropPlayer(tgt, '\n[Furious Admin]:\nInformation: You\'ve been banned from '..FuriousAdminMenu.Config.Main.ServerName..'\nReason: '..BanReason..'\nBanned By: '..GetPlayerName(source)..'\nNickname: '..GetPlayerName(tgt)..'\n')
    else
        TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 This Player isn\'t in the Server anymore! </div>'
        })
    end
end)

RegisterServerEvent('FuriousAdmin:KickPlayer')
AddEventHandler('FuriousAdmin:KickPlayer', function(source, tgt, KickReason)
    if GetPlayerName(tgt) then
        TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 You kicked '..GetPlayerName(tgt)..'! </div>'
        })
        DropPlayer(tgt, '\n[Furious Admin]:\nInformation: You\'ve been kicked from '..FuriousAdminMenu.Config.Main.ServerName..'\nReason: '..KickReason..'\nKicked By: '..GetPlayerName(source)..'\nNickname: '..GetPlayerName(tgt)..'\n')
    else
        TriggerClientEvent('chat:addMessage', source, {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 This Player isn\'t in the Server anymore! </div>'
        })
    end
end)

RegisterServerEvent('FuriousAdmin:UnbanPlayer')
AddEventHandler('FuriousAdmin:UnbanPlayer', function(src, steam, bName)
    local player = src
    local bannedName = bName
    UnbanPlayer(steam)
    print('^1[Furious Admin]^7 ^3' .. GetPlayerName(player) .. '^7 Unbanned ^3' .. bannedName .. '^7!')
end)

RegisterServerEvent('FuriousAdmin:unbanThisPlayer')
AddEventHandler('FuriousAdmin:unbanThisPlayer', function(tgt)
    UnbanPlayer(GetPlayerIdentifier(tgt))
end)

RegisterCommand('sakick', function(src, args, rawCmd)
    source = src
    if src > 0 then
        if args[1] then
            if tonumber(args[1]) and GetPlayerName(tonumber(args[1])) then
                local target = tonumber(args[1])
                local reason = args
				table.remove(reason, 1)
				table.remove(reason, 1)
				if(#reason == 0)then
					KickReason = "No Reason Provided"
				else
					KickReason = "" .. table.concat(reason, " ")
				end
                TriggerClientEvent('chat:addMessage', source, {
                    template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 You banned ^4'..GetPlayerName(source)..'^7 from the Server Permanently! </div>'
                })
                DropPlayer(target, '\n[Furious Admin]:\nInformation: You\'ve been kicked from '..FuriousAdminMenu.Config.Main.ServerName..'\nReason: '..KickReason..'\nKicked By: '..GetPlayerName(source)..'\nNickname: '..GetPlayerName(target)..'\n')
            else
                TriggerClientEvent('chat:addMessage', source, {
                    template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Please provide a Valid Player ID! </div>'
                })
            end
        else
            TriggerClientEvent('chat:addMessage', source, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Please provide a Valid Player ID! </div>'
            })
        end
    else
        if args[1] then
            if tonumber(args[1]) and GetPlayerName(tonumber(args[1])) then
                local target = tonumber(args[1])
                local reason = args
				table.remove(reason, 1)
				table.remove(reason, 1)
				if(#reason == 0)then
					BanReason = "No Reason Provided"
				else
					BanReason = "" .. table.concat(reason, " ")
				end
                if BanReason then
                    print('^1[Furious Admin]^7 You kicked ^4'..GetPlayerName(target)..'^7 from the Server!')
                    DropPlayer(target, '\n[Furious Admin]:\nInformation: You\'ve been kicked from '..FuriousAdminMenu.Config.Main.ServerName..'\nReason: '..BanReason..'\nKicked By: Console\nNickname: '..GetPlayerName(target)..'\n')
                else
                    print('^1[Furious Admin]^7 Please provide a Valid Ban Reason!')
                end
            else
                print('^1[Furious Admin]^7 Please provide a Valid Player ID!')
            end
        else
            print('^1[Furious Admin]^7 Please provide a Valid Player ID!')
        end
    end
end)

RegisterCommand('saban', function(src, args, rawCmd)
    source = src
    if src > 0 then
        if args[1] then
            if tonumber(args[1]) and GetPlayerName(tonumber(args[1])) then
                local target = tonumber(args[1])
                local reason = args
				table.remove(reason, 1)
				table.remove(reason, 1)
				if(#reason == 0)then
					BanReason = "No Reason Provided"
				else
					BanReason = "" .. table.concat(reason, " ")
				end
                BanPlayer(target, BanReason, GetPlayerName(source), 999999999)
                TriggerClientEvent('chat:addMessage', source, {
                    template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 You banned ^4'..GetPlayerName(source)..'^7 from the Server Permanently! </div>'
                })
                DropPlayer(target, '\n[Furious Admin]:\nInformation: You\'ve been banned from '..FuriousAdminMenu.Config.Main.ServerName..'\nReason: '..BanReason..'\nBanned By: '..GetPlayerName(source)..'\nNickname: '..GetPlayerName(target)..'\n')
            else
                TriggerClientEvent('chat:addMessage', source, {
                    template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Please provide a Valid Player ID! </div>'
                })
            end
        else
            TriggerClientEvent('chat:addMessage', source, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Please provide a Valid Player ID! </div>'
            })
        end
    else
        if args[1] then
            if tonumber(args[1]) and GetPlayerName(tonumber(args[1])) then
                local target = tonumber(args[1])
                local reason = args
				table.remove(reason, 1)
				table.remove(reason, 1)
				if(#reason == 0)then
					BanReason = "No Reason Provided"
				else
					BanReason = "" .. table.concat(reason, " ")
				end
                if BanReason then
                    BanPlayer(target, BanReason, 'Console', 999999999)
                    print('^1[Furious Admin]^7 You banned ^4'..GetPlayerName(target)..'^7 from the Server Permanently!')
                    DropPlayer(target, '\n[Furious Admin]:\nInformation: You\'ve been banned from '..FuriousAdminMenu.Config.Main.ServerName..'\nReason: '..BanReason..'\nBanned By: Console\nNickname: '..GetPlayerName(target)..'\n')
                else
                    print('^1[Furious Admin]^7 Please provide a Valid Ban Reason!')
                end
            else
                print('^1[Furious Admin]^7 Please provide a Valid Player ID!')
            end
        else
            print('^1[Furious Admin]^7 Please provide a Valid Player ID!')
        end
    end
end)

RegisterCommand('saunban', function(src, args, rawCmd)
    source = src
    if src > 0 then
        if args[1] then
            steamhex = 'steam:'..tostring(args[1])
            if tostring(steamhex) then
                if checkSteamBan(steamhex) then
                    bannedName = ReturnName(steamhex)
                    UnbanPlayer(steamhex)
                    TriggerClientEvent('chat:addMessage', source, {
                        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 You unbanned '..bannedName..' </div>'
                    })
                else
                    TriggerClientEvent('chat:addMessage', source, {
                        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Please provide a Valid Steamhex! </div>'
                    })
                end
            else
                TriggerClientEvent('chat:addMessage', source, {
                    template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Please provide a Valid Steamhex! </div>'
                })
            end
        else
            TriggerClientEvent('chat:addMessage', source, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Please provide a Valid Steamhex! </div>'
            })
        end
    else
        if args[1] then
            steamhex = 'steam:'..tostring(args[1])
            if tostring(steamhex) then
                if checkSteamBan(steamhex) then
                    bannedName = ReturnName(steamhex)
                    UnbanPlayer(steamhex)
                    print('^1[Furious Admin]^7 You unbanned ^4'..bannedName..'^7 from the Server!')
                else
                    print('^1[Furious Admin]^7 Please provide a Valid Steamhex!')                
                end
            else
                print('^1[Furious Admin]^7 Please provide a Valid Steamhex!')
            end
        else
            print('^1[Furious Admin]^7 Please provide a Valid Steamhex!')
        end
    end
end)

function GetDiscordId(player)
    for _, id in ipairs(GetPlayerIdentifiers(player)) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
        end
    end
    if discordId then
        return discordId
    else
        return false
    end
end

RegisterServerEvent('FuriousAdmin:CheckPermission')
AddEventHandler('FuriousAdmin:CheckPermission', function(perm, vl, vl2, vl3, vl4, vl5)
    local player = source
    local hasPerms = false
    local Permission = perm
    local value = vl
    local value2 = vl2
    local value3 = vl3
    local value4 = vl4
    local value5 = vl5

    if Permission == 'Noclip' then
        if HasPermission('Noclip', player) then
            TriggerClientEvent('FuriousAdmin:ToggleNoclip', player, value)
            hasPerms = true
        end
    elseif Permission == 'Invisibility' then
        if HasPermission('Invisibility', player) then
            TriggerClientEvent('FuriousAdmin:ToggleInvisibility', player, value)
            hasPerms = true
        end
    elseif Permission == 'Godmode' then
        if HasPermission('Godmode', player) then
            TriggerClientEvent('FuriousAdmin:ToggleGodmode', player, value)
            hasPerms = true
        end
    elseif Permission == 'GiveWeapon' then
        if HasPermission('GiveWeapon', player) then
            TriggerClientEvent('FuriousAdmin:GiveWeapon', player, value)
            hasPerms = true
        end
    elseif Permission == 'Carwipe' then
        if HasPermission('Carwipe', player) then
            TriggerClientEvent('FuriousAdmin:Carwipe', player)
            hasPerms = true
        end
    elseif Permission == 'SpawnVehicle' then
        if HasPermission('SpawnVehicle', player) then
            TriggerClientEvent('FuriousAdmin:SpawnVehicle', player)
            hasPerms = true
        end
    elseif Permission == 'FixVehicle' then
        if HasPermission('FixVehicle', player) then
            TriggerClientEvent('FuriousAdmin:FixVehicle', player)
            hasPerms = true
        end
    elseif Permission == 'CleanVehicle' then
        if HasPermission('CleanVehicle', player) then
            TriggerClientEvent('FuriousAdmin:CleanVehicle', player)
            hasPerms = true
        end
    elseif Permission == 'FlipVehicle' then
        if HasPermission('FlipVehicle', player) then
            TriggerClientEvent('FuriousAdmin:FlipVehicle', player)
            hasPerms = true
        end
    elseif Permission == 'DeleteVehicle' then
        if HasPermission('DeleteVehicle', player) then
            TriggerClientEvent('FuriousAdmin:DeleteVehicle', player)
            hasPerms = true
        end
    elseif Permission == 'Entitywipe' then
        if HasPermission('Entitywipe', player) then
            TriggerClientEvent('FuriousAdmin:Entitywipe', player)
            hasPerms = true
        end
    elseif Permission == 'TeleportToWaypoint' then
        if HasPermission('TeleportToWaypoint', player) then
            TriggerClientEvent('FuriousAdmin:TeleportToWaypoint', player)
            hasPerms = true
        end
    elseif Permission == 'Heal' then
        if HasPermission('Heal', player) then
            TriggerClientEvent('FuriousAdmin:Heal', player)
            hasPerms = true
        end
    elseif Permission == 'FullArmor' then
        if HasPermission('FullArmor', player) then
            TriggerClientEvent('FuriousAdmin:FullArmor', player)
            hasPerms = true
        end
    elseif Permission == 'Ban' then
        if HasPermission('Ban', player) then
            TriggerEvent('FuriousAdmin:BanPlayer', player, value, value2, value3)
            hasPerms = true
        end
    elseif Permission == 'Kick' then
        if HasPermission('Kick', player) then
            TriggerEvent('FuriousAdmin:KickPlayer', player, value, value2)
            hasPerms = true
        end
    elseif Permission == 'UnbanPlayer' then
        if HasPermission('UnbanPlayer', player) then
            TriggerEvent('FuriousAdmin:UnbanPlayer', player, value, value2)
            hasPerms = true
        end
    elseif Permission == 'OpenMenu' then
        if HasPermission('OpenMenu', player) then
            TriggerClientEvent('FuriousAdmin:OpenMenu', player)
            hasPerms = true
        end
    end

    Wait(50)

    if not hasPerms then
        TriggerClientEvent('chat:addMessage', player, {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Insufficient Permissions! </div>'
        })
    end
end)

local SentInPrintGotPerms = {}
local SentInFails = {}

RegisterServerEvent('FuriousAdmin:GetAllPermissions')
AddEventHandler('FuriousAdmin:GetAllPermissions', function(plyr)
    local player
    local Success = false
    local Group = 'Civilian'

    if GetPlayerName(source) then
        player = source
    elseif plyr then
        player = plyr
    else
        return
    end

    if player ~= nil then
        Permissions[player] = {}
        Permissions[player].OpenMenu = false
        Permissions[player].Ban = false
        Permissions[player].Kick = false
        Permissions[player].UnbanPlayer = false
        Permissions[player].SetMoney = false
        Permissions[player].SetBank = false
        Permissions[player].SetGroup = false
        Permissions[player].SetPermissionLevel = false
        Permissions[player].Spectate = false
        Permissions[player].Goto = false
        Permissions[player].Bring = false
        Permissions[player].GoBack = false
        Permissions[player].SendBack = false
        Permissions[player].FreezePlayer = false
        Permissions[player].ClearLoadout = false
        Permissions[player].ScreenshotPlayer = false
        Permissions[player].SpawnVehicle = false
        Permissions[player].FixVehicle = false
        Permissions[player].CleanVehicle = false
        Permissions[player].FlipVehicle = false
        Permissions[player].DeleteVehicle = false
        Permissions[player].Heal = false
        Permissions[player].FullArmor = false
        Permissions[player].NoClip = false
        Permissions[player].Invisibility = false
        Permissions[player].GodMode = false
        Permissions[player].GiveWeapon = false
        Permissions[player].TeleportToWaypoint = false
        Permissions[player].CarWipe = false
        Permissions[player].EntityWipe = false

        if GetDiscordId(player) ~= nil and GetDiscordId(player) and GetDiscordRoles(player) then
            local DiscordRoles = 0
            for _,_ in pairs(GetDiscordRoles(player)) do
                DiscordRoles = DiscordRoles + 1
                for _,x in pairs(MenuPerms.Groups) do
                    if tonumber(x.RoleId) == tonumber(GetDiscordRoles(player)[DiscordRoles]) and MenuPerms.Permissions[tostring(x.Group)] ~= nil and json.encode(MenuPerms.Permissions[tostring(x.Group)]) ~= '[]' then
                        Group = tostring(x.Group)
                        Permissions[player].OpenMenu = MenuPerms.Permissions[Group].OpenMenu
                        Permissions[player].Ban = MenuPerms.Permissions[Group].Ban
                        Permissions[player].Kick = MenuPerms.Permissions[Group].Kick
                        Permissions[player].UnbanPlayer = MenuPerms.Permissions[Group].UnbanPlayer
                        Permissions[player].SetMoney = MenuPerms.Permissions[Group].SetMoney
                        Permissions[player].SetBank = MenuPerms.Permissions[Group].SetBank
                        Permissions[player].SetGroup = MenuPerms.Permissions[Group].SetGroup
                        Permissions[player].SetPermissionLevel = MenuPerms.Permissions[Group].SetPermissionLevel
                        Permissions[player].Spectate = MenuPerms.Permissions[Group].Spectate
                        Permissions[player].Goto = MenuPerms.Permissions[Group].Goto
                        Permissions[player].Bring = MenuPerms.Permissions[Group].Bring
                        Permissions[player].GoBack = MenuPerms.Permissions[Group].GoBack
                        Permissions[player].SendBack = MenuPerms.Permissions[Group].SendBack
                        Permissions[player].FreezePlayer = MenuPerms.Permissions[Group].FreezePlayer
                        Permissions[player].ClearLoadout = MenuPerms.Permissions[Group].ClearLoadout
                        Permissions[player].ScreenshotPlayer = MenuPerms.Permissions[Group].ScreenshotPlayer
                        Permissions[player].SpawnVehicle = MenuPerms.Permissions[Group].SpawnVehicle
                        Permissions[player].FixVehicle = MenuPerms.Permissions[Group].FixVehicle
                        Permissions[player].CleanVehicle = MenuPerms.Permissions[Group].CleanVehicle
                        Permissions[player].FlipVehicle = MenuPerms.Permissions[Group].FlipVehicle
                        Permissions[player].DeleteVehicle = MenuPerms.Permissions[Group].DeleteVehicle
                        Permissions[player].Heal = MenuPerms.Permissions[Group].Heal
                        Permissions[player].FullArmor = MenuPerms.Permissions[Group].FullArmor
                        Permissions[player].NoClip = MenuPerms.Permissions[Group].NoClip
                        Permissions[player].Invisibility = MenuPerms.Permissions[Group].Invisibility
                        Permissions[player].GodMode = MenuPerms.Permissions[Group].GodMode
                        Permissions[player].GiveWeapon = MenuPerms.Permissions[Group].GiveWeapon
                        Permissions[player].TeleportToWaypoint = MenuPerms.Permissions[Group].TeleportToWaypoint
                        Permissions[player].CarWipe = MenuPerms.Permissions[Group].CarWipe
                        Permissions[player].EntityWipe = MenuPerms.Permissions[Group].EntityWipe
                        Success = true
                    end
                end
            end
        end

        if SentInPrintGotPerms[player] == nil or SentInPrintGotPerms[player] == false then
            if Success then
                print('^7[^4Shotta^7] [^2Success^7] Recieved ^6Admin Menu^7 permissions for the player ^3'..GetPlayerName(player)..' {#'..player..'} ['..GetPlayerIdentifiers(player)[1]:gsub('steam:', '')..'] ('..tostring(Group)..')^7')
                SentInPrintGotPerms[player] = true
            else
                if (SentInFails[player] == nil or json.encode(SentInFails[player]) == '[]') then
                    SentInFails[player] = 0
                end
                SentInFails[player] = SentInFails[player] + 1
                if SentInFails[player] <= 2 then
                    print('^7[^4Shotta^7] [^1Error^7] Failed recieving ^6Admin Menu^7 permissions for the player ^3'..GetPlayerName(player)..' {#'..player..'} ['..GetPlayerIdentifiers(player)[1]:gsub('steam:', '')..'] ('..tostring(Group)..')^7 [^1'..SentInFails[player]..'/2 Attemption Fails^7]^7')
                    SentInPrintGotPerms[player] = false
                    Wait(500)
                    TriggerEvent('FuriousAdmin:GetAllPermissions', player)
                end
            end
        end
    end
end)

RegisterServerEvent('FuriousAdmin:SetPermissionLevel')
AddEventHandler('FuriousAdmin:SetPermissionLevel', function(currentPlayer, level)
    local player = source
    local targetsId = currentPlayer

    if HasPermission('SetPermissionLevel', player) then
        if level then
            TriggerEvent("es:getAllGroups", function(groups)
                TriggerEvent("es:setPlayerData", targetsId, "permission_level", level, function(response, success) 
                    TriggerClientEvent('es:setPlayerDecorator', targetsId, 'rank', level, true)
                    TriggerClientEvent('chat:addMessage', player, {
                        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 You set ^1'..GetPlayerName(targetsId)..'\'s^7 Permission Level to ^2'..level..'^7! </div>'
                    })
                end)
            end)
        else
            TriggerClientEvent('chat:addMessage', player, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Please provide a Valid Group to Set! </div>'
            })
        end
    else
        TriggerClientEvent('chat:addMessage', player, {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Insufficient Permissions! </div>'
        })
    end
end)

RegisterServerEvent('FuriousAdmin:SetGroup')
AddEventHandler('FuriousAdmin:SetGroup', function(currentPlayer, group)
    local player = source
    local targetsId = currentPlayer
    local validGroup = false
    local hasPerms = false

    if HasPermission('SetGroup', player) then
        if group then
            TriggerEvent("es:getAllGroups", function(groups)
                for k, v in pairs(groups) do
                    if group == k then
                        TriggerEvent("es:getPlayerFromId", targetsId, function(user)
                            ExecuteCommand('remove_principal identifier.' .. user.getIdentifier() .. " group." .. user.getGroup())
            
                            TriggerEvent("es:setPlayerData", targetsId, "group", group, function(response, success)
                                TriggerClientEvent('es:setPlayerDecorator', targetsId, 'group', tonumber(group), true)
                                ExecuteCommand('add_principal identifier.' .. user.getIdentifier() .. " group." .. user.getGroup())
                                TriggerClientEvent('chat:addMessage', player, {
                                    template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 You set ^1'..GetPlayerName(targetsId)..'\'s^7 Group to ^2'..group..'^7! </div>'
                                })
                            end)
                        end)
                        validGroup = true
                    end
                end
                
                Wait(250)
        
                if not validGroup then
                    TriggerClientEvent('chat:addMessage', player, {
                        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Please provide a Valid Group to Set! </div>'
                    })
                end
            end)
        else
            TriggerClientEvent('chat:addMessage', player, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Please provide a Valid Group to Set! </div>'
            })
        end
    else
        TriggerClientEvent('chat:addMessage', player, {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Insufficient Permissions! </div>'
        })
    end
end)

RegisterServerEvent('FuriousAdmin:SetBank')
AddEventHandler('FuriousAdmin:SetBank', function(currentPlayer, bank)
    local targetsId = currentPlayer
    local player = source
    local hasPerms = false

    if HasPermission('SetBank', player) then
        if bank then
            TriggerEvent("es:getPlayerFromId", targetsId, function(user)
                if user then
                    user.setBankBalance(bank)

                    TriggerClientEvent('chat:addMessage', player, {
                        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 You set ^1'..GetPlayerName(targetsId)..'\'s^7 Bank Cash to ^2$'..bank..'^7! </div>'
                    })
                end
            end)
        else
            TriggerClientEvent('chat:addMessage', player, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Invalid Amount of Bank Cash! </div>'
            })
        end
    else
        TriggerClientEvent('chat:addMessage', player, {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Insufficient Permissions! </div>'
        })
    end
end)

RegisterServerEvent('FuriousAdmin:SetMoney')
AddEventHandler('FuriousAdmin:SetMoney', function(currentPlayer, money)
    local targetsId = currentPlayer
    local player = source
    local hasPerms = false

    if HasPermission('SetMoney', player) then
        if money then
            TriggerEvent("es:getPlayerFromId", targetsId, function(user)
                if user then
                    user.setMoney(money)

                    TriggerClientEvent('chat:addMessage', player, {
                        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 You set ^1'..GetPlayerName(targetsId)..'\'s^7 Money to ^2$'..money..'^7! </div>'
                    })
                end
            end)
        else
            TriggerClientEvent('chat:addMessage', player, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Invalid Amount of Money! </div>'
            })
        end
    else
        TriggerClientEvent('chat:addMessage', player, {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Insufficient Permissions! </div>'
        })
    end
end)

RegisterCommand('tpm', function(source, args, rawCommand)
    local player = source

    if HasPermission('TeleportToWaypoint', player) then
        TriggerClientEvent('FuriousAdmin:TeleportToWaypoint', player)
    else
        TriggerClientEvent('chat:addMessage', player, {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Insufficient Permissions! </div>'
        })
    end
end)

RegisterCommand('bring', function(source, args, rawCommand)
    local player = source
    local tgtId = args[1]
    local hasPerms = false

    if HasPermission('Bring', player) then
        if args[1] then
            if(tonumber(args[1]) and GetPlayerName(tonumber(args[1])))then
                TriggerEvent("es:getPlayerFromId", player, function(aPlayer)
                    SendBackCoords[tonumber(args[1])] = GetEntityCoords(GetPlayerPed(tonumber(args[1])))
                    TriggerClientEvent('FuriousAdmin:GotoCommand', tonumber(args[1]), aPlayer.getCoords().x, aPlayer.getCoords().y, aPlayer.getCoords().z)
                end)
            else
                TriggerClientEvent('chat:addMessage', player, {
                    template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Please provide a Valid Player ID! </div>'
                })
            end
        else
            TriggerClientEvent('chat:addMessage', player, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Please provide a Valid Player ID! </div>'
            })
        end
    else
        TriggerClientEvent('chat:addMessage', player, {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Insufficient Permissions! </div>'
        })
    end
end)

RegisterCommand('goto', function(source, args, rawCommand)
    local player = source

    if HasPermission('Goto', player) then
        if args[1] then
            if(tonumber(args[1]) and GetPlayerName(tonumber(args[1])))then
                TriggerEvent("es:getPlayerFromId", tonumber(args[1]), function(target)
                    GoBackCoords[player] = GetEntityCoords(GetPlayerPed(player))
                    TriggerClientEvent('FuriousAdmin:GotoCommand', player, target.getCoords().x, target.getCoords().y, target.getCoords().z)
                end)
            else
                TriggerClientEvent('chat:addMessage', player, {
                    template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Please provide a Valid Player ID! </div>'
                })
            end
        else
            TriggerClientEvent('chat:addMessage', player, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Please provide a Valid Player ID! </div>'
            })
        end
    else
        TriggerClientEvent('chat:addMessage', player, {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Insufficient Permissions! </div>'
        })
    end
end)

RegisterCommand('sendback', function(source, args, rawCommand)
    local player = source

    if HasPermission('SendBack', player) then
        if args[1] then
            if(tonumber(args[1]) and GetPlayerName(tonumber(args[1]))) then
                if SendBackCoords[tonumber(args[1])] ~= nil and json.encode(SendBackCoords[tonumber(args[1])]) ~= '[]' then
                    TriggerClientEvent('FuriousAdmin:GotoCommand', tonumber(args[1]), SendBackCoords[tonumber(args[1])].x, SendBackCoords[tonumber(args[1])].y, SendBackCoords[tonumber(args[1])].z)
                else
                    TriggerClientEvent('chat:addMessage', player, {
                        template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 This player has no previous location! </div>'
                    })
                end
            else
                TriggerClientEvent('chat:addMessage', player, {
                    template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Please provide a Valid Player ID! </div>'
                })
            end
        else
            TriggerClientEvent('chat:addMessage', player, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Please provide a Valid Player ID! </div>'
            })
        end
    else
        TriggerClientEvent('chat:addMessage', player, {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Insufficient Permissions! </div>'
        })
    end
end)

RegisterCommand('goback', function(source, args, rawCommand)
    local player = source

    if HasPermission('GoBack', player) then
        if GoBackCoords[player] ~= nil and json.encode(GoBackCoords[player]) ~= '[]' then
            TriggerClientEvent('FuriousAdmin:GotoCommand', player, GoBackCoords[player].x, GoBackCoords[player].y, GoBackCoords[player].z)
        else
            TriggerClientEvent('chat:addMessage', player, {
                template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 You have no previous location! </div>'
            })
        end
    else
        TriggerClientEvent('chat:addMessage', player, {
            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(0, 100, 255, 1.0);"><i class="fas fa-users"></i> ^5Furious Admin:^7 Insufficient Permissions! </div>'
        })
    end
end)

local TimeoutCommand = {}
TriggerEvent('es:addCommand', 'report', function(source, args, user)
    if (TimeoutCommand[source] == nil or os.time() - TimeoutCommand[source] >= 10) then 
        TimeoutCommand[source] = os.time()
        TriggerClientEvent('chat:addMessage', source, {
			template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 111, 255, 0.50); border-radius: 3px;"><i class="fas fa-shield-alt"></i> {0}: {1}</div>',            
            args = {"Incoming Report - ".. GetPlayerName(source) .." (ID - "..source..")", table.concat(args, " ")}
        })
    
        TriggerEvent("es:getPlayers", function(pl)
            for k,v in pairs(pl) do
                TriggerEvent("es:getPlayerFromId", k, function(user)
                    if(user.getGroup() ~= 'user' and k ~= source)then
                        TriggerClientEvent('chat:addMessage', k, {
                            template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(255, 0, 0, 0.6); border-radius: 3px;"><i class="fas fa-exclamation-triangle"></i> {0}:<br> {1}</div>',
                            args = {"Incoming Report - ".. GetPlayerName(source) .." (ID - "..source..")", table.concat(args, " ")}
                        })
                    end
                end)
            end
        end)
    else
        TriggerClientEvent("esx:showNotification", source, "You cannot use this command for ~o~" .. (10 - (os.time() -TimeoutCommand[source])) .. "~w~ second(s).")
    end
end, {help = "Report a player or an issue", params = {{name = "report", help = "What you want to report"}}})

print([[^6

______           _                               _                
|  ____|        (_)                     /\      | |               
| |__ _   _ _ __ _  ___  _   _ ___     /  \   __| |_ __ ___  _ _ __  
|  __| | | | '__| |/ _ \| | | / __|   / /\ \ / _` | '_ ` _ \| | '_ \ 
| |  | |_| | |  | | (_) | |_| \__ \  / ____ \ (_| | | | | | | | | | |
|_|   \__,_|_|  |_|\___/ \__,_|___/ /_/    \_\__,_|_| |_| |_|_|_| |_|

^0]])
print('^6[Furious Admin]:^7 ^2[Info]^7 Successfully Authorized')