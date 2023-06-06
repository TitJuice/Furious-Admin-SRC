local menuSize = 'size-150'
local scriptReady = false
local noclip = false
local menuLocation = 'topcenter'

if FuriousAdminMenu.Config.Menu.MenuSize == 'small' then
	menuSize = 'size-100'
	scriptReady = true
elseif FuriousAdminMenu.Config.Menu.MenuSize == 'medium' then
	menuSize = 'size-150'
	scriptReady = true
elseif FuriousAdminMenu.Config.Menu.MenuSize == 'large' then
	menuSize = 'size-200'
	scriptReady = true
else
	TriggerServerEvent('FuriousAdmin:ScriptError', 'Menu Size Error')
	menuSize = 'size-150'
	scriptReady = true
end

if scriptReady then
	if FuriousAdminMenu.Config.ESX.Enabled then
		ESX = nil
		Citizen.CreateThread(function()
			while ESX == nil do
				TriggerEvent(FuriousAdminMenu.Config.ESX.CoreEvent, function(obj) ESX = obj end)
				Citizen.Wait(100)
			end
		end)
	end

	RegisterNetEvent('FuriousAdmin:RefreshCLRoles')
	AddEventHandler('FuriousAdmin:RefreshCLRoles', function()
		Citizen.Wait(5000)
		TriggerServerEvent('FuriousAdmin:RefreshSVRoles')
	end)

	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(3)

			if noclip then
				local currentSpeed = 1
				local noclipEntity = IsPedInAnyVehicle(PlayerPedId(-1), false) and GetVehiclePedIsUsing(PlayerPedId(-1)) or PlayerPedId(-1)

				newPos = GetEntityCoords(entity)

				DisableControlAction(0, 32, true)
				DisableControlAction(0, 268, true)

				DisableControlAction(0, 31, true)

				DisableControlAction(0, 269, true)
				DisableControlAction(0, 33, true)

				DisableControlAction(0, 266, true)
				DisableControlAction(0, 34, true)

				DisableControlAction(0, 30, true)

				DisableControlAction(0, 267, true)
				DisableControlAction(0, 35, true)

				DisableControlAction(0, 44, true)
				DisableControlAction(0, 20, true)

				yoff = 0.0
				zoff = 0.0

				if GetControlInput() == "MouseAndKeyboard" and not DisableNoClipActions then
					if IsDisabledControlPressed(0, 32) then
						yoff = 0.5
					end
					if IsDisabledControlPressed(0, 33) then
						yoff = -0.5
					end
					if IsDisabledControlPressed(0, 34) then
						SetEntityHeading(PlayerPedId(-1), GetEntityHeading(PlayerPedId(-1)) + 3.0)
					end
					if IsDisabledControlPressed(0, 35) then
						SetEntityHeading(PlayerPedId(-1), GetEntityHeading(PlayerPedId(-1)) - 3.0)
					end
					if IsDisabledControlPressed(0, 22) then
						zoff = 0.21
					end
					if IsDisabledControlPressed(0, 21) then
						zoff = -0.21
					end
					if IsDisabledControlPressed(0, 54) then
						currentSpeed = 10.0
					end
				end

				newPos = GetOffsetFromEntityInWorldCoords(noclipEntity, 0.0, yoff * (currentSpeed + 0.3), zoff * (currentSpeed + 0.3))
				heading = GetEntityHeading(noclipEntity)

				SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
				SetEntityRotation(noclipEntity, 0.0, 0.0, 0.0, 0, false)
				SetEntityHeading(noclipEntity, heading)

				SetEntityCollision(noclipEntity, false, false)
				SetEntityCoordsNoOffset(noclipEntity, newPos.x, newPos.y, newPos.z, true, true, true)

				SetEntityCollision(noclipEntity, true, true)
			else
				Citizen.Wait(500)
			end
		end
	end)

	RegisterNetEvent('FuriousAdmin:GiveCarCL')
	AddEventHandler('FuriousAdmin:GiveCarCL', function(Vehicle)
		SpawnCar(Vehicle)
	end)

	RegisterNetEvent('FuriousAdmin:GotoCommand')
	AddEventHandler('FuriousAdmin:GotoCommand', function(x2, y2, z2)
		x = tonumber(string.format("%2.2f", x2))
		y = tonumber(string.format("%2.2f", y2))
		z = tonumber(string.format("%2.2f", z2))
		SetEntityCoords(GetPlayerPed(-1), x, y, z)
	end)

	RegisterNetEvent('FuriousAdmin:ToggleNoclip')
	AddEventHandler('FuriousAdmin:ToggleNoclip', function(value)
		noclip = value
		if noclip then
			Notify('You entered '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Noclip^7')
		else
			Notify('You exited '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Noclip^7')
		end
	end)

	RegisterNetEvent('FuriousAdmin:ToggleInvisibility')
	AddEventHandler('FuriousAdmin:ToggleInvisibility', function(vl)
		value = not vl
		if vl then
			Notify('Invisibility: '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Activated^7')
		else
			Notify('Invisibility: '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Deactivated^7')
		end
		SetEntityVisible(PlayerPedId(), value)
	end)
	
	RegisterNetEvent('FuriousAdmin:ToggleGodmode')
	AddEventHandler('FuriousAdmin:ToggleGodmode', function(value)
		if value then
			Notify('Godmode: '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Activated^7')
		else
			Notify('Godmode: '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Deactivated^7')
		end
		SetPlayerInvincible(GetPlayerPed(-1), value)
	end)
	
	RegisterNetEvent('FuriousAdmin:Carwipe')
	AddEventHandler('FuriousAdmin:Carwipe', function()
		Notify('You Car '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Wiped^7')
		TriggerEvent('FuriousAdmin:utilone')
	end)

	RegisterNetEvent('FuriousAdmin:Entitywipe')
	AddEventHandler('FuriousAdmin:Entitywipe', function()
		Notify('You Entity '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Wiped^7')
		TriggerEvent('FuriousAdmin:utilone')
		TriggerEvent('FuriousAdmin:utiltwo')
		TriggerEvent('FuriousAdmin:utilthree')
	end)

	RegisterNetEvent('FuriousAdmin:Heal')
	AddEventHandler('FuriousAdmin:Heal', function()
		Notify('You '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Healed^7 Yourself')
		SetEntityHealth(PlayerPedId(), 200)
	end)

	RegisterNetEvent('FuriousAdmin:FullArmor')
	AddEventHandler('FuriousAdmin:FullArmor', function()
		Notify('You Gave Yourself '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Armor^7')
		SetPedArmour(PlayerPedId(), 100)
	end)

	RegisterNetEvent('FuriousAdmin:GiveWeapon')
	AddEventHandler('FuriousAdmin:GiveWeapon', function(weapon)
		GiveWeaponToPed(GetPlayerPed(-1), weapon, 500, false, true)
	end)

	RegisterNetEvent('FuriousAdmin:TeleportToWaypoint')
	AddEventHandler('FuriousAdmin:TeleportToWaypoint', function()
		local WaypointHandle = GetFirstBlipInfoId(8)
		if DoesBlipExist(WaypointHandle) then
			local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)
			Notify('You '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Teleported^7 to your Waypoint')
			for height = 1, 1000 do
				SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)
				local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)
				if foundGround then
					SetPedCoordsKeepVehicle(PlayerPedId(), waypointCoords["x"], waypointCoords["y"], height + 0.0)
					break
				end
				Citizen.Wait(5)
			end
		else
			Notify('Place a '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Waypoint^7 first')
		end
	end)

	RegisterNetEvent('FuriousAdmin:SpawnVehicle')
	AddEventHandler('FuriousAdmin:SpawnVehicle', function()
		local FMMC_KEY_TIP8 = 'Vehicle Name:'
		DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 64 + 1)
				
		while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
			Citizen.Wait(0)
		end
		
		local carModel = GetOnscreenKeyboardResult()
		if carModel and IsModelValid(carModel) and IsModelAVehicle(carModel) then
			if carModel == "adder" then
				Notify('This Vehicle is '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Blacklisted^7')
			else
				RequestModel(GetHashKey(carModel))
				Citizen.CreateThread(function()
					local cartimer = 0
					while not HasModelLoaded(GetHashKey(carModel)) do
						cartimer = cartimer + 100.0
						Citizen.Wait(100.0)
						if cartimer > 5000 then
							Notify('Vehicle Spawning '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Timedout^7')
							break
						end
					end
					SpawnCar(carModel)
				end)
			end
		else
			Notify(''..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Invalid^7 Vehicle Name')
		end
	end)

	RegisterNetEvent('FuriousAdmin:FixVehicle')
	AddEventHandler('FuriousAdmin:FixVehicle', function()
		local player = PlayerPedId()
		local carrito = GetVehiclePedIsIn(player, false)
		if IsPedInAnyVehicle(player, true) then
			SetVehicleEngineHealth(carrito, 1000)
			SetVehicleEngineOn(carrito, true, true)
			SetVehicleFixed(carrito)
			Notify('Vehicle '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Fixed^7')
		else
			Notify('You\'re not in a '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Vehicle^7')
		end
	end)

	RegisterNetEvent('FuriousAdmin:CleanVehicle')
	AddEventHandler('FuriousAdmin:CleanVehicle', function()
		local player = PlayerPedId()
		local carrito = GetVehiclePedIsIn(player, false)
		if IsPedInAnyVehicle(player, true) then
			SetVehicleDirtLevel(carrito, 0)
			Notify('Vehicle '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Cleaned^7')
		else
			Notify('You\'re not in a '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Vehicle^7')
		end
	end)

	RegisterNetEvent('FuriousAdmin:FlipVehicle')
	AddEventHandler('FuriousAdmin:FlipVehicle', function()
		local ppd = PlayerPedId()
		local dacar = GetVehiclePedIsIn(ppd)
		if IsPedInAnyVehicle(ppd, true) then
			if not IsVehicleOnAllWheels(dacar) then
				SetVehicleOnGroundProperly(dacar)
				Notify('Vehicle '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Flipped^7')
			else
				Notify(''..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Vehicle^7 is not Upside Down')
			end
		else
			Notify('You\'re not in a '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Vehicle^7')
		end
	end)

	RegisterNetEvent('FuriousAdmin:DeleteVehicle')
	AddEventHandler('FuriousAdmin:DeleteVehicle', function()
		local ped = PlayerPedId()
		local vehs = GetVehiclePedIsIn(ped)
		if IsPedInAnyVehicle(ped, true) then
			DeleteEntity(vehs)
			Notify('You '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Deleted^7 Your Vehicle')
		else
			Notify('You\'re not in a '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Vehicle^7')
		end
	end)

	RegisterCommand(FuriousAdminMenu.Config.Functions.Noclip.Command.String, function()
		if noclip then
			TriggerServerEvent('FuriousAdmin:CheckPermission', 'Noclip', false)
		else
			TriggerServerEvent('FuriousAdmin:CheckPermission', 'Noclip', true)
		end
	end)
	
	if FuriousAdminMenu.Config.Functions.Noclip.Keybind.Enabled then
		if FuriousAdminMenu.Config.Functions.Noclip.Command.Enabled then
			RegisterKeyMapping(FuriousAdminMenu.Config.Functions.Noclip.Command.String, 'Noclip [Furious Admin]', 'keyboard', FuriousAdminMenu.Config.Functions.Noclip.Keybind.Bind)
		else
			RegisterCommand('fa:noclip', function()
				if noclip then
					TriggerServerEvent('FuriousAdmin:CheckPermission', 'Noclip', false)
				else
					TriggerServerEvent('FuriousAdmin:CheckPermission', 'Noclip', true)
				end
			end)
			RegisterKeyMapping('fa:noclip', 'Noclip [Furious Admin]', 'keyboard', FuriousAdminMenu.Config.Functions.Noclip.Keybind.Bind)
		end
	end
	
	RegisterCommand('fa:stopSpectating', function()
		if spectating then
			spectating = false
			NetworkSetInSpectatorMode(false, GetPlayerPed(-1))
			Notify('You exited '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Spectate^7')
		end
	end)
	
	RegisterKeyMapping('fa:stopSpectating', 'Stop Spectating [Furious Admin]', 'keyboard', 'E')

	function SpawnCar(carModel)
		local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			DeleteEntity(GetVehiclePedIsUsing(PlayerPedId()))
			spawnedCar = CreateVehicle(GetHashKey(carModel), x, y, z, GetEntityHeading(PlayerPedId()), true, true)
			SetVehicleEngineOn(spawnedCar, true, true, false)
			SetPedIntoVehicle(PlayerPedId(), spawnedCar, -1)
			SetVehicleNumberPlateText(spawnedCar, "Staff")
		else
			spawnedCar = CreateVehicle(GetHashKey(carModel), x, y, z, GetEntityHeading(PlayerPedId()), true, true)
			SetVehicleEngineOn(spawnedCar, true, true, false)
			SetPedIntoVehicle(PlayerPedId(), spawnedCar, -1)
			SetVehicleNumberPlateText(spawnedCar, "Staff")
		end
	end
	
	local assert = assert
	local MenuV = assert(MenuV)

	local menuOpened = false

	local aPlayerSelected = false

	local banMenuCreated = false
	
	local kickMenuCreated = false
	
	local manageMenuCreated = false
	
	local FuriousAdmin = MenuV:CreateMenu('Furious Admin', FuriousAdminMenu.Config.Menu.MenuTitle, menuLocation, FuriousAdminMenu.Config.Menu.MenuColor.r, FuriousAdminMenu.Config.Menu.MenuColor.g, FuriousAdminMenu.Config.Menu.MenuColor.b, menuSize)

	local menuOpenedFA = false
	
	RegisterNetEvent('FuriousAdmin:OpenMenu')
	AddEventHandler('FuriousAdmin:OpenMenu', function()
		FuriousAdminOpen()
	end)
	
	RegisterCommand(FuriousAdminMenu.Config.Functions.OpenMenu.Command.String, function()
		TriggerServerEvent('FuriousAdmin:CheckPermission', 'OpenMenu')
	end)
	
	if FuriousAdminMenu.Config.Functions.OpenMenu.Keybind.Enabled then
		if FuriousAdminMenu.Config.Functions.OpenMenu.Command.Enabled then
			RegisterKeyMapping(FuriousAdminMenu.Config.Functions.OpenMenu.Command.String, 'Open Menu [Furious Admin]', 'keyboard', FuriousAdminMenu.Config.Functions.OpenMenu.Keybind.Bind)
		else
			RegisterCommand('fa:openmenu', function()
				TriggerServerEvent('FuriousAdmin:CheckPermission', 'OpenMenu')
			end)
			RegisterKeyMapping('fa:openmenu', 'Open Menu [Furious RP]', 'keyboard', FuriousAdminMenu.Config.Functions.OpenMenu.Keybind.Bind)
		end
	end
			
	FuriousAdmin:On('open', function()
		menuOpened = true
		TriggerEvent('shotta:toggleHud', false)
	end)

	FuriousAdmin:On('close', function()
		menuOpened = false
		TriggerEvent('shotta:toggleHud', true)
	end)

	local kickMenuOpened = false
	local banMenuOpened = false
	local playListMenuOpened = false
	local utilityMenuOpened = false
	local selfMenuOpened = false
	local vehicleMenuOpened = false
	local playerListOpened = false
	local ThisPlayerFAOpenedBefore = false
	local TheBanListCreated = false
	local menuOpened = false

	RegisterNetEvent("FuriousAdmin:ReturnPlayers")
	AddEventHandler("FuriousAdmin:ReturnPlayers", function(playerlist)
		Players = playerlist
	end)

	local PlayerList = MenuV:CreateMenu('Furious Admin', 'Active Players', menuLocation, FuriousAdminMenu.Config.Menu.MenuColor.r, FuriousAdminMenu.Config.Menu.MenuColor.g, FuriousAdminMenu.Config.Menu.MenuColor.b, menuSize)
		
	PlayerList:On('open', function()
		playerListOpened = true
		local Players = {}
		for a, b in pairs(GetActivePlayers()) do
			table.insert(Players, {
				name = GetPlayerName(b),
				ped = b,
				id = GetPlayerServerId(b)
			})
		end			
		PlayerList:ClearItems()
		for k,v in pairs(Players) do
			aPlayerSelected = true
			currentPlayer = v.ped
			ThisPlayerFA = MenuV:CreateMenu('Furious Admin', 'Player - ' ..v.name.. ' (ID - '..v.id..')', menuLocation, FuriousAdminMenu.Config.Menu.MenuColor.r, FuriousAdminMenu.Config.Menu.MenuColor.g, FuriousAdminMenu.Config.Menu.MenuColor.b, menuSize)
			PlayerList:AddButton({icon = '', label = ''..v.name..' (ID - '..v.id..')', value = ThisPlayerFA, description = 'Press [Enter] To Select This Player'}) 
			selectedPlayerOptions(currentPlayer)
			ThisPlayerFA:On('open', function()
				ThisPlayerFAOpenedBefore = true
			end)
		end
	end)

	local PlayerListOptions = FuriousAdmin:AddButton({icon = '', label = 'Player Options', value = PlayerList, description = 'Press [Enter] For Player Options'})
	
	local VehicleOptions = MenuV:CreateMenu('Furious Admin', 'Vehicle Options', menuLocation, FuriousAdminMenu.Config.Menu.MenuColor.r, FuriousAdminMenu.Config.Menu.MenuColor.g, FuriousAdminMenu.Config.Menu.MenuColor.b, menuSize)
	local VehicleOptionsMenu = FuriousAdmin:AddButton({icon = '', label = 'Vehicle Options', value = VehicleOptions, description = 'Press [Enter] For Vehicle Options'})

	VehicleOptions:On('open', function()
		selfMenuOpened = true
	end)

	local SelfOptions = MenuV:CreateMenu('Furious Admin', 'Self Options', menuLocation, FuriousAdminMenu.Config.Menu.MenuColor.r, FuriousAdminMenu.Config.Menu.MenuColor.g, FuriousAdminMenu.Config.Menu.MenuColor.b, menuSize)
	local SelfOptionsMenu = FuriousAdmin:AddButton({icon = '', label = 'Self Options', value = SelfOptions, description = 'Press [Enter] For Vehicle Options'})
		
	SelfOptions:On('open', function()
		selfMenuOpened = true
	end)

	local UtilityOptions = MenuV:CreateMenu('Furious Admin', 'Utility Options', menuLocation, FuriousAdminMenu.Config.Menu.MenuColor.r, FuriousAdminMenu.Config.Menu.MenuColor.g, FuriousAdminMenu.Config.Menu.MenuColor.b, menuSize)
	local UtilityOptionsMenu = FuriousAdmin:AddButton({icon = '', label = 'Utility Options', value = UtilityOptions, description = 'Press [Enter] For Utility Options'})
		
	UtilityOptions:On('open', function()
		UtilityOptions:ClearItems()
		local TeleportToWaypoint = UtilityOptions:AddButton({icon = '', label = 'Teleport to Waypoint', value = '', description = 'Press [Enter] To Teleport to Waypoint'})
		local CarWipe = UtilityOptions:AddButton({icon = '', label = 'Car Wipe', value = '', description = 'Press [Enter] To Car Wipe'})
		local EntityWipe = UtilityOptions:AddButton({icon = '', label = 'Entity Wipe', value = '', description = 'Press [Enter] To Entity Wipe'})
		TeleportToWaypoint:On('select', function()
			TriggerServerEvent('FuriousAdmin:CheckPermission', 'TeleportToWaypoint')
		end)
		CarWipe:On('select', function()
			TriggerServerEvent('FuriousAdmin:CheckPermission', 'Carwipe')
		end)
		EntityWipe:On('select', function()
			TriggerServerEvent('FuriousAdmin:CheckPermission', 'Entitywipe')
		end)
		local utilityMenuOpened = true
		local ServerBansShowing = false
		BanListMenu = MenuV:CreateMenu('Furious Admin', 'Server Banlist', menuLocation, FuriousAdminMenu.Config.Menu.MenuColor.r, FuriousAdminMenu.Config.Menu.MenuColor.g, FuriousAdminMenu.Config.Menu.MenuColor.b, menuSize)
		UtilityOptions:AddButton({icon = '', label = 'View Banlist', value = BanListMenu, description = 'Press [Enter] To View The Banlist'})
		TriggerServerEvent('FuriousAdmin:GetBanlist')
		RegisterNetEvent('FuriousAdmin:ReturnBanlist')
		AddEventHandler('FuriousAdmin:ReturnBanlist', function(Bans)
			if TheBanListCreated then
				ThisBanFA:ClearItems()
				BanListMenu:ClearItems()
				ThisBanIdents:ClearItems()
			end
			for k, v in pairs(Bans) do
				ServerBansShowing = true
				local Name = k
				local Reason = tostring(v['reason'])
				local BannedBy = tostring(v['bannedby'])
				local License = tostring(v['license'])
				local Steam = tostring(v['steam'])
				local Discord = tostring(v['discord'])
				local Live = tostring(v['live'])
				local Xbox = tostring(v['xbl'])
				ThisBanFA = MenuV:CreateMenu('Furious Admin', 'Admin Ban - ' .. k .. '', menuLocation, FuriousAdminMenu.Config.Menu.MenuColor.r, FuriousAdminMenu.Config.Menu.MenuColor.g, FuriousAdminMenu.Config.Menu.MenuColor.b, menuSize)
				BanListMenu:AddButton({icon = '', label = k, value = ThisBanFA, description = 'Press [Enter] To View This Ban'})
				ThisBanIdents = MenuV:CreateMenu('Furious Admin', 'Identifiers - ' .. k .. '', menuLocation, FuriousAdminMenu.Config.Menu.MenuColor.r, FuriousAdminMenu.Config.Menu.MenuColor.g, FuriousAdminMenu.Config.Menu.MenuColor.b, menuSize)
				ThisBanFA:AddButton({icon = '', label = 'Name: ' .. Name .. '', value = '', description = ''})
				ThisBanFA:AddButton({icon = '', label = 'Reason: ' .. Reason .. '', value = '', description = ''})
				ThisBanFA:AddButton({icon = '', label = 'Banned By: ' .. BannedBy .. '', value = '', description = ''})
				ThisBanFA:AddButton({icon = '', label = 'View Identifiers', value = ThisBanIdents, description = 'Press [Enter] To View Identifiers'})
				ThisBanIdents:AddButton({icon = '', label = 'License: ' .. License:gsub('license:', ''):gsub('license2:', '') .. '', value = '', description = ''})
				ThisBanIdents:AddButton({icon = '', label = 'Steam: ' .. Steam:gsub('steam:', '') .. '', value = '', description = ''})
				ThisBanIdents:AddButton({icon = '', label = 'Discord: ' .. Discord:gsub('discord:', '') .. '', value = '', description = ''})
				ThisBanIdents:AddButton({icon = '', label = 'Live: ' .. Live:gsub('live:', '') .. '', value = '', description = ''})
				ThisBanIdents:AddButton({icon = '', label = 'Xbox: ' .. Xbox:gsub('xbl:', '') .. '', value = '', description = ''})
				UnbanButton = ThisBanFA:AddButton({icon = '', label = 'Unban This Player', value = '', description = 'Press [Enter] To Unban This Player'})
				UnbanButton:On('select', function()
					TriggerServerEvent('FuriousAdmin:CheckPermission', 'UnbanPlayer', v['steam'], k)
				end)
				TheBanListCreated = true
			end
			Wait(50)
			if not ServerBansShowing then
				BanListMenu:ClearItems()
				BanListMenu:AddButton({icon = '', label = 'There is No Active Server Bans!', value = '', description = ''})
			end
		end)
	end)
	
	local SpawnVehicle = VehicleOptions:AddButton({icon = '', label = 'Spawn Vehicle', value = '', description = 'Press [Enter] To Spawn a Vehicle'})
	local FixVehicle = VehicleOptions:AddButton({icon = '', label = 'Fix Vehicle', value = '', description = 'Press [Enter] To Fix your Vehicle'})
	local CleanVehicle = VehicleOptions:AddButton({icon = '', label = 'Clean Vehicle', value = '', description = 'Press [Enter] To Clean your Vehicle'})
	local FlipVehicle = VehicleOptions:AddButton({icon = '', label = 'Flip Vehicle', value = '', description = 'Press [Enter] To Flip your Vehicle'})
	local DeleteVehicle = VehicleOptions:AddButton({icon = '', label = 'Delete Vehicle', value = '', description = 'Press [Enter] To Delete your Vehicle'})

	local Heal = SelfOptions:AddButton({icon = '', label = 'Heal', value = '', description = 'Press [Enter] To Self Heal'})
	local FullArmor = SelfOptions:AddButton({icon = '', label = 'Full Armor', value = '', description = 'Press [Enter] To Recieve Full Armor'})
	local ButtonNoclip = SelfOptions:AddCheckbox({icon = '', label = 'Noclip', value = '', description = 'Press [Enter] To Toggle Noclip'})
	local Invisibility = SelfOptions:AddCheckbox({icon = '', label = 'Invisibility', value = '', description = 'Press [Enter] To Toggle Invisibility'})
	local Godmode = SelfOptions:AddCheckbox({icon = '', label = 'Godmode', value = '', description = 'Press [Enter] To Toggle Godmode'})
	
	local WeaponOptions = MenuV:CreateMenu('Furious Admin', 'Weapon Options', menuLocation, FuriousAdminMenu.Config.Menu.MenuColor.r, FuriousAdminMenu.Config.Menu.MenuColor.g, FuriousAdminMenu.Config.Menu.MenuColor.b, menuSize)
	local WeaponOptionsMenu = SelfOptions:AddButton({icon = '', label = 'Weapon Options', value = WeaponOptions, description = 'Press [Enter] For Weapon Options'})
		
	for k,v in pairs(FuriousAdminMenu.Config.Weapons) do
		local GiveWeapon = WeaponOptions:AddButton({icon = '', label = v.label, value = v.spawn, description = 'Press [Enter] For A '..v.label..''})
		GiveWeapon:On('select', function(menu) 
			TriggerServerEvent('FuriousAdmin:CheckPermission', 'GiveWeapon', v.spawn)
		end)
	end

	local states = {}
	states.frozen = false
	states.frozenPos = nil

	local DisableNoClipActions = false

	function GetControlInput()
		return Citizen.InvokeNative(0xA571D46727E2B718, 2) and "MouseAndKeyboard" or "GamePad"
	end

	function Notify(message)
		if FuriousAdminMenu.Config.Alerts.PlayerNotifys then
			TriggerEvent('chat:addMessage', {
				template = '<div style="padding: 0.5vw; margin: 0.5vw; background-color: rgba(0, 0, 0, 0.4); border-radius: 10px; border-left: 2px solid rgba(255, 0, 0, 1.0);"><i class="fas fa-users"></i> ^1Furious Admin:^7 '..message..'! </div>'
			})
		end
	end

	Heal:On('select', function()
		TriggerServerEvent('FuriousAdmin:CheckPermission', 'Heal', true)
	end)

	FullArmor:On('select', function()
		TriggerServerEvent('FuriousAdmin:CheckPermission', 'FullArmor', true)
	end)

	ButtonNoclip:On('check', function()
		TriggerServerEvent('FuriousAdmin:CheckPermission', 'Noclip', true)
	end)
	
	ButtonNoclip:On('uncheck', function()
		TriggerServerEvent('FuriousAdmin:CheckPermission', 'Noclip', false)
	end)
	
	Invisibility:On('check', function()
		TriggerServerEvent('FuriousAdmin:CheckPermission', 'Invisibility', true)
	end)
	
	Invisibility:On('uncheck', function()
		TriggerServerEvent('FuriousAdmin:CheckPermission', 'Invisibility', false)
	end)
	
	Godmode:On('check', function()
		TriggerServerEvent('FuriousAdmin:CheckPermission', 'Godmode', true)
	end)
	
	Godmode:On('uncheck', function()
		TriggerServerEvent('FuriousAdmin:CheckPermission', 'Godmode', false)
	end)

	SpawnVehicle:On('select', function()
		TriggerServerEvent('FuriousAdmin:CheckPermission', 'SpawnVehicle')
	end)

	FixVehicle:On('select', function()
		TriggerServerEvent('FuriousAdmin:CheckPermission', 'FixVehicle')
	end)

	CleanVehicle:On('select', function()
		TriggerServerEvent('FuriousAdmin:CheckPermission', 'CleanVehicle')
	end)

	FlipVehicle:On('select', function()
		TriggerServerEvent('FuriousAdmin:CheckPermission', 'FlipVehicle')
	end)

	DeleteVehicle:On('select', function()
		TriggerServerEvent('FuriousAdmin:CheckPermission', 'DeleteVehicle')
	end)

	function Goto(currentPlayer)
		TriggerServerEvent('FuriousAdmin:TargetCorrectPlayer', 'goto', GetPlayerServerId(currentPlayer), currentPlayer)
		Notify('You tp\'ed to '..FuriousAdminMenu.Config.Main.ChatPrefixColor..''..GetPlayerName(currentPlayer)..'^7')
	end

	function Bring(currentPlayer)
		local adminsLocation = GetEntityCoords(GetPlayerPed(-1))
		local oBx, oBy, oBz = adminsLocation.x, adminsLocation.y, adminsLocation.z
		TriggerServerEvent('FuriousAdmin:TargetCorrectPlayer', 'bring', GetPlayerServerId(currentPlayer), currentPlayer, nil, nil, oBx, oBy, oBz)
		Notify('You brought '..FuriousAdminMenu.Config.Main.ChatPrefixColor..''..GetPlayerName(currentPlayer)..'^7')
	end

	RegisterNetEvent('FuriousAdmin:NotifyMessage')
	AddEventHandler('FuriousAdmin:NotifyMessage', function(type, adminsName, data)
		if type == 'goto' then
			Notify(''..FuriousAdminMenu.Config.Main.ChatPrefixColor..''..adminsName..'^7 has tp\'ed to you')
		elseif type == 'bring' then
			Notify(''..FuriousAdminMenu.Config.Main.ChatPrefixColor..''..adminsName..'^7 has brought you')
		elseif type == 'clearloadout' then
			Notify(''..FuriousAdminMenu.Config.Main.ChatPrefixColor..''..adminsName..'^7 has cleared your loadout')
		elseif type == 'givecar' then
			Notify('Vehicle: '..FuriousAdminMenu.Config.Main.ChatPrefixColor..''..data..'^7\nRecieved From: '..FuriousAdminMenu.Config.Main.ChatPrefixColor..''..adminsName..'^7')
		end
	end)

	RegisterNetEvent('FuriousAdmin:GotoPlayer')
	AddEventHandler('FuriousAdmin:GotoPlayer', function(currentPlayer, adminsName)
		local gotoLocation = GetEntityCoords(GetPlayerPed(currentPlayer))
		local Gx, Gy, Gz = gotoLocation.x, gotoLocation.y, gotoLocation.z
		SetEntityCoords(GetPlayerPed(-1), Gx, Gy, Gz)
	end)

	RegisterNetEvent('FuriousAdmin:BringPlayer')
	AddEventHandler('FuriousAdmin:BringPlayer', function(adminsName, Bx, By, Bz)
		SetEntityCoords(GetPlayerPed(-1), Bx, By, Bz)
	end)

	local SleepTime = 10

	function Spectate(currentPlayer)
		spectating = not spectating
		local player = GetPlayerPed(currentPlayer)
		Notify(''..FuriousAdminMenu.Config.Main.ChatPrefixColor..'^3<br>Spectating: ^2'..GetPlayerName(currentPlayer)..' ['..GetPlayerServerId(currentPlayer)..']^7 | Press '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'[E]^7 To Stop Spectating')
		Citizen.CreateThread(function()
			while true do
				Citizen.Wait(SleepTime)
				if spectating then
					SleepTime = 3
					DisableNoClipActions = true
					DisableControlAction(0, 34, false)
					DisableControlAction(0, 32, false)
					DisableControlAction(0, 31, false)
					DisableControlAction(0, 30, false)
				else
					DisableNoClipActions = false
					SleepTime = 500
				end
			end
		end)
		if spectating then
			RequestCollisionAtCoord(GetEntityCoords(player))
			NetworkSetInSpectatorMode(true, player)
		else
			RequestCollisionAtCoord(GetEntityCoords(player))
			NetworkSetInSpectatorMode(false, player)
		end
	end
	
	RegisterNetEvent('FuriousAdmin:FreezeToggle')
	AddEventHandler('FuriousAdmin:FreezeToggle', function(freezeType)
		local playerPed = GetPlayerPed(-1)
		FreezeEntityPosition(playerPed, freezeType)
		if IsPedInAnyVehicle(playerPed, false) then
			FreezeEntityPosition(GetVehiclePedIsIn(playerPed, false), freezeType)
		end 
	end)

	function FreezeToggle(currentPlayer, freezeType)
		TriggerServerEvent('FuriousAdmin:SyncFreeze', GetPlayerServerId(currentPlayer), freezeType)
	end

	function ClearLoadout(currentPlayer)
		TriggerServerEvent('FuriousAdmin:TargetCorrectPlayer', 'clearloadout', GetPlayerServerId(currentPlayer))
		Notify('You Cleared '..FuriousAdminMenu.Config.Main.ChatPrefixColor..''..GetPlayerName(currentPlayer)..'\'s^7 Loadout')
	end
	
	RegisterNetEvent('FuriousAdmin:ClearPlayersLoadout')
	AddEventHandler('FuriousAdmin:ClearPlayersLoadout', function()
		RemoveAllPedWeapons(GetPlayerPed(-1))
	end)

	function Screenshot(currentPlayer)
		TriggerServerEvent('FuriousAdmin:TargetCorrectPlayer', 'screenshot', GetPlayerServerId(currentPlayer))
		Notify('You Screenshotted '..FuriousAdminMenu.Config.Main.ChatPrefixColor..''..GetPlayerName(currentPlayer)..'\'s^7 Screen')
	end

	RegisterNetEvent('FuriousAdmin:ScreenshotPlayer')
	AddEventHandler('FuriousAdmin:ScreenshotPlayer', function()
		exports['screenshot-basic']:requestScreenshotUpload('https://discord.com/api/webhooks/947979192262332416/bcQgzUostxWrchLcU2YeGvizczNLl-rivLM9nZJOH2UnX7j9RSMv6bc2-GWNS1YcI6tF', 'files[]', function() end)
	end)

	RegisterNetEvent('FuriousAdmin:getCrntPlyrInfo')
	AddEventHandler('FuriousAdmin:getCrntPlyrInfo', function(currentPlayer)
		crntPlyrHealth = GetEntityHealth(GetPlayerPed(currentPlayer))
		crntPlyrArmor = GetPedArmour(GetPlayerPed(currentPlayer))
	end)

	function ExtraOptions(currentPlayer)
		Name = ThisPlayerFA:AddButton({icon = '', label = 'Name: '..GetPlayerName(currentPlayer)..' ['..GetPlayerServerId(currentPlayer)..']', value = '', description = 'Players Name & ID'})
	end

	function ScreenshotOption(currentPlayer)
		local targetPlayer = currentPlayer

		ScreenshotButton = ThisPlayerFA:AddButton({icon = '', label = 'Screenshot Player', value = '', description = 'Press [Enter] To Screenshot This Player'})

		ScreenshotButton:On('select', function()
			Screenshot(targetPlayer)
		end)
	end

	function ClearLoadoutOption(currentPlayer)
		local targetPlayer = currentPlayer

		ClearLoadoutButton = ThisPlayerFA:AddButton({icon = '', label = 'Clear Loadout', value = '', description = 'Press [Enter] To Clear This Player\'s Loadout'})

		ClearLoadoutButton:On('select', function()
			ClearLoadout(targetPlayer)
		end)
	end

	function FreezeOption(currentPlayer)		
		local targetPlayer = currentPlayer

		FreezeButton = ThisPlayerFA:AddCheckbox({icon = '', label = 'Freeze Player', value = '', description = 'Press [Enter] To Toggle Freeze'})

		FreezeButton:On('check', function()
			FreezeToggle(targetPlayer, true)
		end)
		
		FreezeButton:On('uncheck', function()
			FreezeToggle(targetPlayer, false)
		end)
	end

	function BringOption(currentPlayer)
		local targetPlayer = currentPlayer

		BringButton = ThisPlayerFA:AddButton({icon = '', label = 'Bring Player', value = '', description = 'Press [Enter] To Goto This Player'})

		BringButton:On('select', function()
			Bring(targetPlayer)
		end)
	end

	function GotoOption(currentPlayer)
		local targetPlayer = currentPlayer

		GotoButton = ThisPlayerFA:AddButton({icon = '', label = 'Goto Player', value = '', description = 'Press [Enter] To Bring This Player'})

		GotoButton:On('select', function()
			Goto(targetPlayer)
		end)
	end

	function SpectateOption(currentPlayer)
		local targetPlayer = currentPlayer

		SpectateToggle = ThisPlayerFA:AddButton({icon = '', label = 'Spectate', value = '', description = 'Press [Enter] To Kick This Player'})

		SpectateToggle:On('select', function()
			Spectate(targetPlayer)
		end)
	end

	function BanOption(currentPlayer, BanReason)
		banMenuCreated = true
		BanMenu = MenuV:CreateMenu('Furious Admin', 'Player - ' ..GetPlayerName(currentPlayer).. ' (ID - '..GetPlayerServerId(currentPlayer)..')', menuLocation, FuriousAdminMenu.Config.Menu.MenuColor.r, FuriousAdminMenu.Config.Menu.MenuColor.g, FuriousAdminMenu.Config.Menu.MenuColor.b, menuSize)
		ThisPlayerFA:AddButton({icon = '', label = 'Ban Player', value = BanMenu, description = 'Press [Enter] To Ban This Player'}) 
		BanOptions(currentPlayer, BanReason)
	end

	function BanOptions(currentPlayer, BanReason)
		BanMenu:ClearItems()

		local BanLength = 10800
		local tgtsID = GetPlayerServerId(currentPlayer)

		BanReasonXBTN = BanMenu:AddButton({icon = '', label = 'Enter Reason: '..BanReason, value = GetPlayerServerId(selectedPlayer), description = 'Press [Enter] To Type A Reason'})

		BanMenu:On('open', function()
			banMenuOpened = true
		end)

		BanReasonXBTN:On('select', function()
			AddTextEntry('FMMC_KEY_TIP1', 'Enter Ban Reason:')
			DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 64 + 1)
			while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
				Citizen.Wait(3)
			end			
			local result = GetOnscreenKeyboardResult()
			BanReason = result
			if BanReason == "" then 
				BanReason = "No Reason Specified."
			end
			
			BanOptions(currentPlayer, BanReason)
		end)

		BanTimeSelect = BanMenu:AddSlider({ icon = '', label = 'Ban Length', description = 'Cylce Through To Select A Ban Length', value = 0, values = {
			{label = '3 Hours', value = '3hours'},
			{label = '6 Hours', value = '6hours'},
			{label = '12 Hours', value = '12hours'},
			{label = '1 Day', value = '1day'},
			{label = '3 Days', value = '3days'},
			{label = '1 Week', value = '1week'},
			{label = '2 Weeks', value = '2weeks'},
			{label = '1 Month', value = '1month'},
			{label = '3 Months', value = '3months'},
			{label = '6 Months', value = '6months'},
			{label = '1 Year', value = '1year'},
			{label = 'Permanent', value = 'permanent'}
		}, disabled = false });

		BanTimeSelect:On('change', function(item, BanTime) 
			if BanTime == 1 then
				BanLength = 10800
			elseif BanTime == 2 then
				BanLength = 21600
			elseif BanTime == 3 then
				BanLength = 43200
			elseif BanTime == 4 then
				BanLength = 86400
			elseif BanTime == 5 then
				BanLength = 259200
			elseif BanTime == 6 then
				BanLength = 604800
			elseif BanTime == 7 then
				BanLength = 1209600
			elseif BanTime == 8 then
				BanLength = 2630000
			elseif BanTime == 9 then
				BanLength = 7890000
			elseif BanTime == 10 then
				BanLength = 15780000
			elseif BanTime == 11 then
				BanLength = 31540000
			elseif BanTime == 12 then
				BanLength = 999999999
			end
		end)

		ConfirmBan = BanMenu:AddButton({icon = '', label = 'Confirm Ban', value = GetPlayerServerId(selectedPlayer), description = 'Press [Enter] To Ban This Player'})

		ConfirmBan:On('select', function()
			TriggerServerEvent('FuriousAdmin:CheckPermission', 'Ban', tgtsID, BanReason, BanLength)
		end)
	end

	function KickOption(currentPlayer, KickReason)
		kickMenuCreated = true
		KickMenu = MenuV:CreateMenu('Furious Admin', 'Player - ' ..GetPlayerName(currentPlayer).. ' (ID - '..GetPlayerServerId(currentPlayer)..')', menuLocation, FuriousAdminMenu.Config.Menu.MenuColor.r, FuriousAdminMenu.Config.Menu.MenuColor.g, FuriousAdminMenu.Config.Menu.MenuColor.b, menuSize)
		ThisPlayerFA:AddButton({icon = '', label = 'Kick Player', value = KickMenu, description = 'Press [Enter] To Kick This Player'}) 
		KickOptions(currentPlayer, KickReason)
	end

	function KickOptions(currentPlayer, KickReason)
		KickMenu:ClearItems()

		local tgtsID = GetPlayerServerId(currentPlayer)

		KickReasonXBTN = KickMenu:AddButton({icon = '', label = 'Enter Reason: '..KickReason, value = GetPlayerServerId(selectedPlayer), description = 'Press [Enter] To Type A Reason'})

		KickMenu:On('open', function()
			kickMenuOpened = true
		end)

		KickReasonXBTN:On('select', function()
			AddTextEntry('FMMC_KEY_TIP1', 'Enter Kick Reason:')
			DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 64 + 1)
			while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
				Citizen.Wait(3)
			end			
			local result = GetOnscreenKeyboardResult()
			KickReason = result
			if KickReason == "" then 
				KickReason = "No Reason Specified."
			end

			KickOptions(currentPlayer, KickReason)
		end)
		
		ConfirmKick = KickMenu:AddButton({icon = '', label = 'Confirm Kick', value = GetPlayerServerId(selectedPlayer), description = 'Press [Enter] To Kick This Player'})

		ConfirmKick:On('select', function()
			TriggerServerEvent('FuriousAdmin:CheckPermission', 'Kick', tgtsID, KickReason)
		end)
	end

	function ManagePlayerOption(currentPlayer)
		manageMenuCreated = true
		
		ManagePlayerMenu = MenuV:CreateMenu('Furious Admin', 'Player - ' ..GetPlayerName(currentPlayer).. ' (ID - '..GetPlayerServerId(currentPlayer)..')', menuLocation, FuriousAdminMenu.Config.Menu.MenuColor.r, FuriousAdminMenu.Config.Menu.MenuColor.g, FuriousAdminMenu.Config.Menu.MenuColor.b, menuSize)
		ThisPlayerFA:AddButton({icon = '', label = 'Manage Player', value = ManagePlayerMenu, description = 'Press [Enter] To Manage This Player'}) 

		SetMoneyButton = ManagePlayerMenu:AddButton({icon = '', label = 'Set Players Money', description = 'Press [Enter] To Set this Players Money'})

		SetMoneyButton:On('select', function()
			AddTextEntry('FMMC_KEY_TIP1', 'Enter Money Amount:')
			DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 64 + 1)
			while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
				Citizen.Wait(3)
			end			
			local moneyAmount = tonumber(GetOnscreenKeyboardResult())
			
			TriggerServerEvent('FuriousAdmin:SetMoney', GetPlayerServerId(currentPlayer), moneyAmount)
		end)
		
		SetBankButton = ManagePlayerMenu:AddButton({icon = '', label = 'Set Players Bank', description = 'Press [Enter] To Set this Players Bank'})

		SetBankButton:On('select', function()
			AddTextEntry('FMMC_KEY_TIP1', 'Enter Bank Amount:')
			DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 64 + 1)
			while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
				Citizen.Wait(3)
			end			
			local bankAmount = tonumber(GetOnscreenKeyboardResult())
			
			TriggerServerEvent('FuriousAdmin:SetBank', GetPlayerServerId(currentPlayer), bankAmount)
		end)
				
		SetGroupButton = ManagePlayerMenu:AddButton({icon = '', label = 'Set Players Group', description = 'Press [Enter] To Set this Players Group'})

		SetGroupButton:On('select', function()
			AddTextEntry('FMMC_KEY_TIP1', 'Enter Group Name:')
			DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 64 + 1)
			while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
				Citizen.Wait(3)
			end			
			local group = tostring(GetOnscreenKeyboardResult())
			
			TriggerServerEvent('FuriousAdmin:SetGroup', GetPlayerServerId(currentPlayer), group)
		end)
						
		SetLevelButton = ManagePlayerMenu:AddButton({icon = '', label = 'Set Permission Level', description = 'Press [Enter] To Set this Players Level'})

		SetLevelButton:On('select', function()
			AddTextEntry('FMMC_KEY_TIP1', 'Enter Permission Level:')
			DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", "", "", "", "", 64 + 1)
			while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
				Citizen.Wait(3)
			end			
			local level = tostring(GetOnscreenKeyboardResult())
			
			TriggerServerEvent('FuriousAdmin:SetPermissionLevel', GetPlayerServerId(currentPlayer), level)
		end)
	end

	function selectedPlayerOptions(currentPlayer)
		BanOption(currentPlayer, 'No Reason Specified.')
		KickOption(currentPlayer, 'No Reason Specified.')
		if FuriousAdminMenu.Config.ESX.Enabled then
			ManagePlayerOption(currentPlayer)
		end
		SpectateOption(currentPlayer)
		GotoOption(currentPlayer)
		BringOption(currentPlayer)
		FreezeOption(currentPlayer)
		ClearLoadoutOption(currentPlayer)
		ScreenshotOption(currentPlayer)
		ExtraOptions(currentPlayer)
	end

	local alreadyOnList = false

	AddEventHandler('playerSpawned', function()
		if not alreadyOnList then
			alreadyOnList = true
			currentPlayer = PlayerId()
			TriggerServerEvent('FuriousAdmin:AddToServerlist', currentPlayer)
		end
	end)

	RefreshDPlayers = PlayerList:AddButton({icon = '', label = 'Refresh Disconnected Players', value = '', description = 'Press [Enter] To Refresh Disconnected Players'})

	RefreshDPlayers:On('select', function()
		Notify('Refreshed '..FuriousAdminMenu.Config.Main.ChatPrefixColor..'Disconnected^7 Players')
		TriggerServerEvent("FuriousAdmin:requestCachedPlayers")
	end)
	
	local entityEnumerator = {
		__gc = function(enum)
			if enum.destructor and enum.handle then
				enum.destructor(enum.handle)
			end
			enum.destructor = nil
			enum.handle = nil
		end
	}
	
	function EnumerateEntities(initFunc, moveFunc, disposeFunc)
		return coroutine.wrap(function()
			local iter, id = initFunc()
			if not id or id == 0 then
				disposeFunc(iter)
				return
			end
			local enum = {handle = iter, destructor = disposeFunc}
			setmetatable(enum, entityEnumerator)
			local next = true
			repeat
				coroutine.yield(id)
				next, id = moveFunc(iter)
			until not next
			enum.destructor, enum.handle = nil, nil
			disposeFunc(iter)
		end)
	end

	function EnumerateObjects()
		return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
	end
	
	function EnumeratePeds()
		return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
	end
	
	function EnumerateVehicles()
		return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
	end
	
	function EnumeratePickups()
		return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
	end

	RegisterNetEvent("FuriousAdmin:utilone")
	AddEventHandler("FuriousAdmin:utilone", function()
		for vehicle in EnumerateVehicles() do
			if (not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1))) then 
				SetVehicleHasBeenOwnedByPlayer(vehicle, false) 
				SetEntityAsMissionEntity(vehicle, false, false) 
				Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle)) 
				if (DoesEntityExist(vehicle)) then
					Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(vehicle)) 
				end
			end
		end
	end)

	RegisterNetEvent('FuriousAdmin:utiltwo')
	AddEventHandler('FuriousAdmin:utiltwo', function()
		for ped in EnumeratePeds() do
			if not IsPedAPlayer(ped) then
				Citizen.InvokeNative(0x9614299DCB53E54B, Citizen.PointerValueIntInitialized(ped)) 
				if DoesEntityExist(ped) then
					Citizen.InvokeNative(0x9614299DCB53E54B, Citizen.PointerValueIntInitialized(ped)) 
				end
			end
		end
	end)

	RegisterNetEvent('FuriousAdmin:utilthree')
	AddEventHandler('FuriousAdmin:utilthree', function()
		for object in EnumerateObjects() do
			if DoesEntityExist(object) then
				Citizen.InvokeNative(0x539E0AE3E6634B9F, Citizen.PointerValueIntInitialized(object)) 
			end
		end
	end)

	function FuriousAdminOpen()
		if menuOpenedFA then
			FuriousAdmin:Close()
			PlayerList:Close()
			if aPlayerSelected then
				ThisPlayerFA:Close()
			end
			VehicleOptions:Close()
			SelfOptions:Close()
			UtilityOptions:Close()
			WeaponOptions:Close()
			if banMenuCreated then
				BanMenu:Close()
			end
			if kickMenuCreated then
				KickMenu:Close()
			end
			if manageMenuCreated then
				ManagePlayerMenu:Close()
			end
			FuriousAdmin:Open()
		else
			menuOpenedFA = true
			FuriousAdmin:Open()
		end
	end
end

Citizen.CreateThread(function()
	TriggerServerEvent('FuriousAdmin:GetAllPermissions')
end)

AddEventHandler('onClientResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		noclip = false
	end
end)