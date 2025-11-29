--[[
    Open-Source Conditions
	Please read the license conditions in the LICENSE file. By using this script, you agree to these conditions.
]]

-- Locales
local Locales = DreamLocales[DreamCore.Language]

-- Thanks for Credits
-- Disclaimer: I know it´s Open-Source but please don´t remove this and give us the credits. Thanks!
if string.find(GetCurrentResourceName(), 'dream') then
	print("^6[Dream-Services]^7 Thank you for not changing the resource name!")
end

-- Global Variables
local IsInPropPlacer = false

-- Ready UI
RegisterNUICallback("readyUI", function(data, cb)
	SendNUIMessage({ type = 'startup', locales = Locales })
	cb()
end)

-- Snow System
if DreamCore.XmasSnow then
	print("^6[Dream-Services]^7 Snow is enabled!")
	Citizen.CreateThread(function()
		-- Audio & Particles
		RequestScriptAudioBank("SNOW_FOOTSTEPS", false)
		RequestScriptAudioBank("ICE_FOOTSTEPS", false)
		RequestNamedPtfxAsset("core_snow")
		while not HasNamedPtfxAssetLoaded("core_snow") do Citizen.Wait(100) end
		UseParticleFxAssetNextCall("core_snow")

		-- Weather
		SetWeatherTypeOverTime('XMAS', 5.0)
		Citizen.Wait(5000)
		while true do
			ClearOverrideWeather()
			ClearWeatherTypePersist()
			SetWeatherTypePersist('XMAS')
			SetWeatherTypeNow('XMAS')
			SetWeatherTypeNowPersist('XMAS')
			SetForceVehicleTrails(true)
			SetForcePedFootstepsTracks(true)
			N_0xc54a08c85ae4d410(5.0) -- Water Ice Layer

			Citizen.Wait(100)
		end
	end)

	if DreamCore.RealtimeTimeSync then
		RegisterNetEvent("dream_christmas:client:realtime")
		AddEventHandler("dream_christmas:client:realtime", function(hours, minutes, seconds)
			SetMillisecondsPerGameMinute(60000)
			NetworkOverrideClockTime(hours, minutes, seconds)
		end)
		TriggerServerEvent("dream_christmas:server:realtime")
	end

	if DreamCore.Snowballs then
		Citizen.CreateThread(function()
			RequestAnimDict('anim@mp_snowball')
			while not HasAnimDictLoaded('anim@mp_snowball') do Citizen.Wait(100) end

			local IsPickingUp = false
			local PickingUpNotifyCooldown = 0
			lib.addKeybind({
				name = 'pickupsnowball',
				description = 'Pickup Snowball',
				defaultKey = DreamCore.PickupSnowball,
				onReleased = function(self)
					if IsPickingUp then
						if PickingUpNotifyCooldown < GetGameTimer() then
							TriggerEvent("dream_christmas:client:notify", Locales['PickupSnowballCooldown'], "error", 5000)
							PickingUpNotifyCooldown = GetGameTimer() + 1000 -- 1s
						end
						return
					end

					if
						not IsPedOnFoot(cache.ped)
						or IsPedInAnyVehicle(cache.ped)
						or IsPedSwimming(cache.ped)
						or IsPedSwimmingUnderWater(cache.ped)
						or IsPedSprinting(cache.ped)
						or IsPedRunning(cache.ped)
						or IsPedRagdoll(cache.ped)
						or GetInteriorFromEntity(cache.ped) ~= 0 -- Check if player is in interior
						or IsInPropPlacer -- Not in prop placer
					then
						return
					end

					-- Check Limit
					local SnowballAmmo = 0
					if DreamCore.Inventory() == 'ox' then
						SnowballAmmo = exports.ox_inventory:GetItemCount('WEAPON_SNOWBALL')
					elseif DreamCore.Inventory() == 'qb' then
						SnowballAmmo = exports['qb-inventory']:GetItemAmount('WEAPON_SNOWBALL')
					else
						SnowballAmmo = GetAmmoInPedWeapon(cache.ped, GetHashKey('WEAPON_SNOWBALL'))
					end

					if (SnowballAmmo / DreamCore.PickupSnowballAmount) >= (DreamCore.SnowballLimit / DreamCore.PickupSnowballAmount) then
						if PickingUpNotifyCooldown < GetGameTimer() then
							TriggerEvent("dream_christmas:client:notify", Locales['PickupSnowballLimit'], "error", 5000)
							PickingUpNotifyCooldown = GetGameTimer() + 1000 -- 1s
						end
						return
					end

					IsPickingUp = true
					TaskPlayAnim(cache.ped, 'anim@mp_snowball', 'pickup_snowball', 8.0, -1, -1, 0, 1, 0, 0, 0)
					Citizen.Wait(DreamCore.PickupSnowballCooldown)
					TriggerServerEvent('dream_christmas:server:giveSnowballs')
					IsPickingUp = false
				end
			})
		end)

		-- Snowball Damage Modifier
		Citizen.CreateThread(function()
			local SnowballHash = GetHashKey('WEAPON_SNOWBALL')
			while true do
				if GetSelectedPedWeapon(cache.ped) == SnowballHash then
					SetPlayerWeaponDamageModifier(PlayerId(), DreamCore.SnowballDamageModifier)
				end
				Citizen.Wait(0)
			end
		end)
	end

	if DreamCore.SnowOverlay then
		Citizen.CreateThread(function()
			while true do
				if
					GetInteriorFromEntity(cache.ped) ~= 0 -- Check if player is in interior
					or IsPedInAnyVehicle(cache.ped) -- Check if player is in vehicle
				then
					SendNUIMessage({ type = 'snow_overlay:hide' })
				else
					SendNUIMessage({ type = 'snow_overlay:show' })
				end
				Citizen.Wait(1000)
			end
		end)
	end
end


-- Load Models
Citizen.CreateThread(function()
	for k, v in pairs(DreamCore.PropSystem) do
		lib.requestModel(GetHashKey(v.model))
	end
end)

local PropSystemData = {}
RegisterNetEvent("dream_christmas:client:createPropSystem")
AddEventHandler("dream_christmas:client:createPropSystem", function(AllObjects)
	-- Delete Old Entites
	for _, v in pairs(PropSystemData) do
		if DoesEntityExist(v.entity) then DeleteEntity(v.entity) end

		-- Target
		if DreamCore.Target() == 'ox' then
			exports.ox_target:removeLocalEntity(v.entity, v.target)
		elseif DreamCore.Target() == 'qb' then
			exports['qb-target']:RemoveTargetEntity(v.entity, v.target)
		end

		if v.blip then RemoveBlip(v.blip) end
	end
	PropSystemData = {}

	for k, v in pairs(AllObjects) do
		-- Check Coords
		if DreamCore.CheckPropCoords(v.coords) and not v.claimed then
			local SpawnedProp = CreateObject(GetHashKey(v.prop.model), v.coords, false, true, true)
			SetEntityHeading(SpawnedProp, v.heading)
			FreezeEntityPosition(SpawnedProp, true)
			SetEntityInvincible(SpawnedProp, true)
			SetBlockingOfNonTemporaryEvents(SpawnedProp, true)

			-- Add Target
			local TargetId = nil
			TargetSelect = function()
				if DreamCore.PropSystemGoToProp then
					local BeforeProp = GetOffsetFromEntityInWorldCoords(SpawnedProp, 0.0, -1.0, 0.0)
					local TargetX, TargetY, TargetZ = BeforeProp.x, BeforeProp.y, GetEntityCoords(cache.ped).z
					TaskGoStraightToCoord(cache.ped, TargetX, TargetY, TargetZ, 1.0, -1, GetEntityHeading(SpawnedProp), 0.0)

					while true do
						local PedCoords = GetEntityCoords(cache.ped)
						if #(PedCoords - vector3(TargetX, TargetY, TargetZ)) < 0.2 then
							ClearPedTasks(cache.ped)
							SetEntityHeading(cache.ped, GetEntityHeading(SpawnedProp))
							break
						end
						Citizen.Wait(50)
					end
				end

				FreezeEntityPosition(cache.ped, true)
				SetCurrentPedWeapon(cache.ped, GetHashKey('WEAPON_UNARMED'), true) -- Unarm Player
				SendNUIMessage({ type = 'activity_popup:start', variant = 'randomprop_snowman' })
				if
					DreamCore.ProgressBar({
						duration = DreamCore.PropSystemProgressBar,
						label = Locales['PropSystem']['ProgressBar'],
						disable = {
							move = true,
							sprint = true,
							combat = true,
							car = true,
						},
						anim = {
							dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
							clip = 'machinic_loop_mechandplayer'
						}
					})
				then
					SendNUIMessage({ type = 'activity_popup:stop' })
					FreezeEntityPosition(cache.ped, false)
					local result = lib.callback.await('dream_christmas:server:rewardPropSystem', false, v.id)

					if result.success then
						TriggerEvent("dream_christmas:client:notify", result.message, "success", 5000)
					else
						TriggerEvent("dream_christmas:client:notify", result.message, "error", 5000)
					end
				else
					SendNUIMessage({ type = 'activity_popup:stop' })
					FreezeEntityPosition(cache.ped, false)
				end
			end

			if DreamCore.Target() == 'ox' then
				TargetId = ('dream_christmas:%s:%s'):format('PropSystem', v.id)
				exports.ox_target:addLocalEntity(SpawnedProp, {
					{
						label = Locales['PropSystem']['TargetLabel'],
						name = TargetId,
						icon = 'fa-solid fa-gift',
						onSelect = TargetSelect
					}
				})
			elseif DreamCore.Target() == 'qb' then
				TargetId = Locales['PropSystem']['TargetLabel']
				exports['qb-target']:AddTargetEntity(SpawnedProp, {
					options = {
						{
							label = TargetId,
							icon = 'fa-solid fa-gift',
							action = TargetSelect
						}
					}
				})
			end

			local SpawnedPropBlip = nil
			if v.prop.blip.enable then
				SpawnedPropBlip = createBlip(v.prop.blip.name, v.coords, v.prop.blip.scale, v.prop.blip.sprite, v.prop.blip.color)
			end

			PropSystemData[v.id] = {
				id = v.id,
				entity = SpawnedProp,
				blip = SpawnedPropBlip,
				coords = v.coords,
				prop = v.prop,
				target = TargetId
			}
		end
	end
end)

-- Force to ground only in random mode
-- Fixed position is fixed and shouldnt be changed
if DreamCore.PropSystemMode == 'random' then
	Citizen.CreateThread(function()
		while true do
			local PlayerCoords = GetEntityCoords(cache.ped)
			for _, v in pairs(PropSystemData) do
				if not v.forcedToGround then
					if #(v.coords - PlayerCoords) < 424 then -- OneSync-Range
						Citizen.Wait(0)
						SetEntityCoords(v.entity, v.coords.x, v.coords.y, v.coords.z - GetEntityHeightAboveGround(v.entity))
						PropSystemData[v.id].forcedToGround = true
					end
				end
			end
			Citizen.Wait(1000)
		end
	end)
end

RegisterNetEvent("dream_christmas:client:removePropSystem")
AddEventHandler("dream_christmas:client:removePropSystem", function(PropId)
	local PropData = PropSystemData[PropId]
	if PropData then
		-- Target
		if DreamCore.Target() == 'ox' then
			exports.ox_target:removeLocalEntity(PropData.entity, PropData.target)
		elseif DreamCore.Target() == 'qb' then
			exports['qb-target']:RemoveTargetEntity(PropData.entity, PropData.target)
		end

		if PropData.blip then
			RemoveBlip(PropData.blip)
			PropSystemData[PropId].blip = nil
		end
	end
end)

-- Christmas Tree
local ChristmasTreeData = {}
Citizen.CreateThread(function()
	for k, v in pairs(DreamCore.ChristmasTree) do
		lib.requestModel(GetHashKey(v.model))
		local SpawnedProp = CreateObject(GetHashKey(v.model), v.coords, false, true, true)
		SetEntityHeading(SpawnedProp, v.heading)
		FreezeEntityPosition(SpawnedProp, true)
		SetEntityInvincible(SpawnedProp, true)
		SetBlockingOfNonTemporaryEvents(SpawnedProp, true)

		-- Add Target
		local TargetId = nil
		TargetSelect = function()
			if DreamCore.ChristmasTreeGoToProp then
				local BeforeProp = GetOffsetFromEntityInWorldCoords(SpawnedProp, 0.0, -1.0, 0.0)
				local TargetX, TargetY, TargetZ = BeforeProp.x, BeforeProp.y, GetEntityCoords(cache.ped).z
				TaskGoStraightToCoord(cache.ped, TargetX, TargetY, TargetZ, 1.0, -1, GetEntityHeading(SpawnedProp), 0.0)

				while true do
					local PedCoords = GetEntityCoords(cache.ped)
					if #(PedCoords - vector3(TargetX, TargetY, TargetZ)) < 0.2 then
						ClearPedTasks(cache.ped)
						SetEntityHeading(cache.ped, GetEntityHeading(SpawnedProp))
						break
					end
					Citizen.Wait(50)
				end
			end

			SetCurrentPedWeapon(cache.ped, GetHashKey('WEAPON_UNARMED'), true) -- Unarm Player
			SendNUIMessage({ type = 'activity_popup:start', variant = 'tree' })
			if DreamCore.ProgressBar({
					duration = DreamCore.ChristmasTreeProgressBar.decorate,
					label = Locales['ChristmasTree']['Decorate']['ProgressBar'],
					disable = {
						move = true,
						sprint = true,
						combat = true,
						car = true,
					},
					anim = {
						dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
						clip = 'machinic_loop_mechandplayer'
					}
				})
			then
				SendNUIMessage({ type = 'activity_popup:stop' })
				local result = lib.callback.await('dream_christmas:server:decorateChristmasTree', false, v.id)
				if result.success then
					TriggerEvent("dream_christmas:client:notify", result.message, "success", 5000)
				else
					TriggerEvent("dream_christmas:client:notify", result.message, "error", 5000)
				end
			else
				SendNUIMessage({ type = 'activity_popup:stop' })
			end
		end

		if DreamCore.Target() == 'ox' then
			TargetId = ('dream_christmas:%s:%s'):format('christmastree', v.id)
			exports.ox_target:addLocalEntity(SpawnedProp, {
				{
					label = Locales['ChristmasTree']['Decorate']['TargetLabel'],
					name = TargetId,
					icon = 'fa-solid fa-tree',
					onSelect = TargetSelect
				}
			})
		elseif DreamCore.Target() == 'qb' then
			TargetId = Locales['ChristmasTree']['Decorate']['TargetLabel']
			exports['qb-target']:AddTargetEntity(SpawnedProp, {
				options = {
					{
						label = TargetId,
						icon = 'fa-solid fa-tree',
						action = TargetSelect
					}
				}
			})
		end

		local SpawnedPropBlip = nil
		if v.blip.enable then
			SpawnedPropBlip = createBlip(v.blip.name, v.coords, v.blip.scale, v.blip.sprite, v.blip.color)
		end

		ChristmasTreeData[k] = {
			entity = SpawnedProp,
			blip = SpawnedPropBlip,
			target = TargetId
		}
	end
end)

-- Christmas Present
local ChristmasPresentData = {}
Citizen.CreateThread(function()
	for k, v in pairs(DreamCore.ChristmasPresents) do
		lib.requestModel(GetHashKey(v.model))
		local SpawnedProp = CreateObject(GetHashKey(v.model), v.coords, false, true, true)
		SetEntityHeading(SpawnedProp, v.heading)
		FreezeEntityPosition(SpawnedProp, true)
		SetEntityInvincible(SpawnedProp, true)
		SetBlockingOfNonTemporaryEvents(SpawnedProp, true)

		-- Add Target
		local TargetId = nil
		TargetSelect = function()
			if DreamCore.ChristmasPresentGoToProp then
				local BeforeProp = GetOffsetFromEntityInWorldCoords(SpawnedProp, 0.0, -0.5, 0.0)
				local TargetX, TargetY, TargetZ = BeforeProp.x, BeforeProp.y, GetEntityCoords(cache.ped).z
				TaskGoStraightToCoord(cache.ped, TargetX, TargetY, TargetZ, 1.0, -1, GetEntityHeading(SpawnedProp), 0.0)

				while true do
					local PedCoords = GetEntityCoords(cache.ped)
					if #(PedCoords - vector3(TargetX, TargetY, TargetZ)) < 0.2 then
						ClearPedTasks(cache.ped)
						SetEntityHeading(cache.ped, GetEntityHeading(SpawnedProp))
						break
					end
					Citizen.Wait(50)
				end
			end

			SetCurrentPedWeapon(cache.ped, GetHashKey('WEAPON_UNARMED'), true) -- Unarm Player
			SendNUIMessage({ type = 'activity_popup:start', variant = 'present' })
			if DreamCore.ProgressBar({
					duration = DreamCore.ChristmasPresentProgressBar.open,
					label = Locales['ChristmasPresent']['Claim']['ProgressBar'],
					disable = {
						move = true,
						sprint = true,
						combat = true,
						car = true,
					},
					anim = {
						dict = 'amb@medic@standing@kneel@idle_a',
						clip = 'idle_c'
					}
				})
			then
				SendNUIMessage({ type = 'activity_popup:stop' })
				local result = lib.callback.await('dream_christmas:server:claimChristmasPresent', false, v.id)
				if result.success then
					TriggerEvent("dream_christmas:client:notify", result.message, "success", 5000)
				else
					TriggerEvent("dream_christmas:client:notify", result.message, "error", 5000)
				end
			else
				SendNUIMessage({ type = 'activity_popup:stop' })
			end
		end

		if DreamCore.Target() == 'ox' then
			TargetId = ('dream_christmas:%s:%s'):format('christmaspresent', v.id)
			exports.ox_target:addLocalEntity(SpawnedProp, {
				{
					label = Locales['ChristmasPresent']['Claim']['TargetLabel'],
					name = TargetId,
					icon = 'fa-solid fa-gift',
					onSelect = TargetSelect
				}
			})
		elseif DreamCore.Target() == 'qb' then
			TargetId = Locales['ChristmasPresent']['Claim']['TargetLabel']
			exports['qb-target']:AddTargetEntity(SpawnedProp, {
				options = {
					{
						label = TargetId,
						icon = 'fa-solid fa-gift',
						action = TargetSelect
					}
				}
			})
		end

		local SpawnedPropBlip = nil
		if v.blip.enable then
			SpawnedPropBlip = createBlip(v.blip.name, v.coords, v.blip.scale, v.blip.sprite, v.blip.color)
		end

		ChristmasPresentData[k] = {
			entity = SpawnedProp,
			blip = SpawnedPropBlip,
			target = TargetId
		}
	end
end)

-- Christmas Advent Calendar
local ChristmasAdventCalendarData = {}
if DreamCore.AdventCalendar.enable then
	Citizen.CreateThread(function()
		if DreamCore.AdventCalendar.peds.usePeds then
			ChristmasAdventCalendarData.peds = {}
			for k, v in pairs(DreamCore.AdventCalendar.peds.locations) do
				-- Load Model
				lib.requestModel(GetHashKey(v.model))

				-- Create Object
				local PedNPC = createPed(
					v.model,
					v.coords,
					v.heading
				)

				-- Create Blip
				local PedBlip = nil
				if DreamCore.AdventCalendar.blip.enable then
					PedBlip = createBlip(
						DreamCore.AdventCalendar.blip.name,
						v.coords,
						DreamCore.AdventCalendar.blip.scale,
						DreamCore.AdventCalendar.blip.sprite,
						DreamCore.AdventCalendar.blip.color
					)
				end

				ChristmasAdventCalendarData.peds[k] = {
					npc = PedNPC,
					blip = PedBlip
				}

				-- Add Target
				TargetSelect = function()
					OpenAdventCalendar()
				end

				if DreamCore.Target() == 'ox' then
					exports.ox_target:addLocalEntity(PedNPC, {
						{
							label = Locales['AdventCalendar']['Open']['TargetLabel'],
							name = 'dream_christmas:adventcalendar',
							icon = 'fa-solid fa-candy-cane',
							onSelect = TargetSelect
						}
					})
				elseif DreamCore.Target() == 'qb' then
					exports['qb-target']:AddTargetEntity(PedNPC, {
						options = {
							{
								label = Locales['AdventCalendar']['Open']['TargetLabel'],
								icon = 'fa-solid fa-candy-cane',
								action = TargetSelect
							}
						}
					})
				end
			end
		end
	end)

	if DreamCore.AdventCalendar.command then
		RegisterCommand(DreamCore.AdventCalendar.command, function()
			OpenAdventCalendar()
		end, false)
	end
end

RegisterNUICallback('claimAdventDoor', function(data)
	local result = lib.callback.await('dream_christmas:server:claimAdventDoor', false, data.dayId)
	if result.success then
		TriggerEvent("dream_christmas:client:notify", result.message, "success", 5000)
	else
		TriggerEvent("dream_christmas:client:notify", result.message, "error", 5000)
	end
end)

local IsInAdventCalendar = false
function OpenAdventCalendar()
	if not DreamCore.AdventCalendar.enable then
		print("^6[Dream-Services] ^7Advent Calendar is disabled in the config!")
		return
	end

	if IsInAdventCalendar then
		print("^6[Dream-Services] ^7You are already in the Advent Calendar UI!")
		return
	end

	local data = lib.callback.await('dream_christmas:server:getAdventCalendarData', false)
	if data then
		IsInAdventCalendar = true
		StartScreenBlur()
		SendNUIMessage({
			type = 'advent_calendar:show',
			data = data
		})
		SetNuiFocus(true, true)
	else
		print("^6[Dream-Services] ^7Failed to fetch Advent Calendar data from server!")
	end
end

-- Christmas Snowman System
local IsBuildingSnowman = false
if DreamCore.ChristmasSnowman.enable then
	RegisterNetEvent("dream_christmas:client:useSnowmanCarrot")
	AddEventHandler("dream_christmas:client:useSnowmanCarrot", function()
		if IsBuildingSnowman then
			DreamCore.Notify(Locales['ChristmasSnowman']['Error']['AlreadyBuilding'], "error", 5000)
			return
		end

		if IsInPropPlacer then
			DreamCore.Notify(Locales['ChristmasSnowman']['Error']['InPropPlacer'], "error", 5000)
			return
		end

		IsBuildingSnowman = true

		if not DreamCore.ChristmasSnowman.buildInstant then
			DreamCore.Notify(Locales['ChristmasSnowman']['Build']['Start'], "success", 5000)

			-- Start Anim
			RequestAnimDict(DreamCore.ChristmasSnowman.buildAnim.dict)
			while not HasAnimDictLoaded(DreamCore.ChristmasSnowman.buildAnim.dict) do Wait(10) end
			TaskPlayAnim(cache.ped, DreamCore.ChristmasSnowman.buildAnim.dict, DreamCore.ChristmasSnowman.buildAnim.clip, 3.0, 3.0, -1, DreamCore.ChristmasSnowman.buildAnim.flag, 0, false, false, false)

			SendNUIMessage({ type = 'snowman_progress_bar:start' })
			local TraveledDistance = 0.0
			local LastCoords = GetEntityCoords(cache.ped)
			while TraveledDistance < DreamCore.ChristmasSnowman.buildDistance do
				local CurrentCoords = GetEntityCoords(cache.ped)
				local CurrentDistance = #(LastCoords - CurrentCoords)
				TraveledDistance = TraveledDistance + CurrentDistance
				LastCoords = CurrentCoords
				SendNUIMessage({ type = 'snowman_progress_bar:progress', progress = math.min((TraveledDistance / DreamCore.ChristmasSnowman.buildDistance) * 100, 100) })
				Citizen.Wait(50)
			end
			SendNUIMessage({ type = 'snowman_progress_bar:stop' })
			ClearPedTasks(cache.ped)
		end

		-- Start Prop Placer
		local PropCoords = StartPropPlacer(DreamCore.ChristmasSnowman.snowmanModel, 'snowman')

		if PropCoords then
			IsBuildingSnowman = false

			local result = lib.callback.await('dream_christmas:server:placeSnowman', false, PropCoords)
			if result.success then
				PlaceSnowmanProp(PropCoords)
			else
				DreamCore.Notify(result.message, "error", 5000)
			end
		else
			IsBuildingSnowman = false
			DreamCore.Notify(Locales['ChristmasSnowman']['Error']['General'], "error", 5000)
		end
	end)
end

-- Prop Placer
local PreviewEntity = nil
function StartPropPlacer(prop, previewEntityType)
	IsInPropPlacer = true
	local IsInPlacerLocal = true
	local FinalPropCoords = nil

	-- Load Model
	lib.requestModel(prop)

	-- Place Prop
	local SpawnCoords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 3.0, 0.0)
	local PreviewEntityCoords = vector4(SpawnCoords.x, SpawnCoords.y, SpawnCoords.z - 1.0, GetEntityHeading(cache.ped) + 90.0)
	PreviewEntity = CreateObject(prop, PreviewEntityCoords.x, PreviewEntityCoords.y, PreviewEntityCoords.z, false, true, false)
	SetEntityHeading(PreviewEntity, PreviewEntityCoords.w)
	SetEntityCollision(PreviewEntity, false, true)
	SetEntityAlpha(PreviewEntity, 200, false)
	PlaceObjectOnGroundProperly(PreviewEntity)
	FreezeEntityPosition(PreviewEntity, true)

	-- Draw Outline
	if CheckPreviewPropCoords(PreviewEntityCoords, previewEntityType) then
		SetEntityDrawOutlineColor(127, 255, 0, 200) -- Green
	else
		SetEntityDrawOutlineColor(220, 20, 60, 200) -- Red
	end
	SetEntityDrawOutlineShader(1)
	SetEntityDrawOutline(PreviewEntity, true)

	-- Scaleform
	-- Thanks to sadboilogan for the Scaleform Example
	-- https://forum.cfx.re/t/instructional-buttons/53283
	local PreviewScaleform = RequestScaleformMovie("instructional_buttons")
	while not HasScaleformMovieLoaded(PreviewScaleform) do
		Citizen.Wait(0)
	end

	DrawScaleformMovieFullscreen(PreviewScaleform, 255, 255, 255, 0, 0)

	PushScaleformMovieFunction(PreviewScaleform, "CLEAR_ALL")
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(PreviewScaleform, "SET_CLEAR_SPACE")
	PushScaleformMovieFunctionParameterInt(200)
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(PreviewScaleform, "SET_DATA_SLOT")
	PushScaleformMovieFunctionParameterInt(0)
	ScaleformButton(GetControlInstructionalButton(2, 38, true))
	ScaleformButton(GetControlInstructionalButton(2, 44, true))
	ScaleformButtonMessage(Locales['PropPlacer']['Rotate'])
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(PreviewScaleform, "SET_DATA_SLOT")
	PushScaleformMovieFunctionParameterInt(1)
	ScaleformButton(GetControlInstructionalButton(2, 177, true))
	ScaleformButtonMessage(Locales['PropPlacer']['Cancel'])
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(PreviewScaleform, "SET_DATA_SLOT")
	PushScaleformMovieFunctionParameterInt(2)
	ScaleformButton(GetControlInstructionalButton(2, 18, true))
	ScaleformButtonMessage(Locales['PropPlacer']['Place'])
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(PreviewScaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(PreviewScaleform, "SET_BACKGROUND_COLOUR")
	PushScaleformMovieFunctionParameterInt(0)
	PushScaleformMovieFunctionParameterInt(0)
	PushScaleformMovieFunctionParameterInt(0)
	PushScaleformMovieFunctionParameterInt(80)
	PopScaleformMovieFunctionVoid()

	-- Prevent the Player from using Cover
	SetPlayerCanUseCover(cache.playerId, false) -- Disable Cover

	-- Raycast Coords
	local EndCoords = vector3(PreviewEntityCoords.x, PreviewEntityCoords.y, PreviewEntityCoords.z)
	Citizen.CreateThread(function()
		while IsInPlacerLocal do
			local _, _, RaycastCoords, _ = lib.raycast.fromCamera(511, 4, 50.0)
			EndCoords = RaycastCoords
			Citizen.Wait(10)
		end
	end)

	while true do
		local EntityPositionChanged = false

		DrawScaleformMovieFullscreen(PreviewScaleform, 255, 255, 255, 255, 0)

		-- Disable Keys
		DisableControlAction(0, 21, true) -- Disable Running
		DisableControlAction(0, 22, true) -- Disable Jumping
		DisableControlAction(0, 23, true) -- Disable Entering Vehicle
		DisableControlAction(0, 24, true) -- Disable Attacking
		DisableControlAction(0, 25, true) -- Disable Aim

		-- Place
		if IsControlJustPressed(0, 18) or IsControlPressed(0, 18) then
			if CheckPreviewPropCoords(PreviewEntityCoords, previewEntityType) then
				FinalPropCoords = PreviewEntityCoords
			end
			break
		end

		-- Cancel
		if IsControlJustPressed(0, 177) or IsControlPressed(0, 177) then
			break
		end

		-- Change Entity Position
		if PreviewEntityCoords.xyz ~= vector3(EndCoords.x, EndCoords.y, EndCoords.z) then
			PreviewEntityCoords = vector4(EndCoords.x, EndCoords.y, EndCoords.z, PreviewEntityCoords.w)
			EntityPositionChanged = true
		end

		-- Q
		if IsControlJustPressed(0, 44) or IsControlPressed(0, 44) then
			PreviewEntityCoords = vector4(PreviewEntityCoords.x, PreviewEntityCoords.y, PreviewEntityCoords.z, PreviewEntityCoords.w + 0.5)
			EntityPositionChanged = true
		end

		-- E
		if IsControlJustPressed(0, 38) or IsControlPressed(0, 38) then
			PreviewEntityCoords = vector4(PreviewEntityCoords.x, PreviewEntityCoords.y, PreviewEntityCoords.z, PreviewEntityCoords.w - 0.5)
			EntityPositionChanged = true
		end

		-- Move Preview Entity
		if EntityPositionChanged then
			SetEntityCoordsNoOffset(PreviewEntity, PreviewEntityCoords.xyz)
			SetEntityHeading(PreviewEntity, PreviewEntityCoords.w)
			PlaceObjectOnGroundProperly(PreviewEntity)
			FreezeEntityPosition(PreviewEntity, true)

			if CheckPreviewPropCoords(PreviewEntityCoords, previewEntityType) then
				SetEntityDrawOutlineColor(127, 255, 0, 200)
			else
				SetEntityDrawOutlineColor(220, 20, 60, 200)
			end
		end

		Citizen.Wait(0)
	end
	SetEntityDrawOutline(PreviewEntity, false) -- Disable Outline
	SetPlayerCanUseCover(cache.playerId, true) -- Enable Cover
	DeleteEntity(PreviewEntity)

	IsInPlacerLocal = false
	IsInPropPlacer = false
	if FinalPropCoords then
		return FinalPropCoords
	else
		return false
	end
end

function CheckPreviewPropCoords(PreviewEntityCoords, PreviewEntityType)
	-- Validate Entity Position
	local IsValid = true

	if PreviewEntityType == 'snowman' then
		-- Blacklisted Zones
		for k, v in pairs(DreamCore.ChristmasSnowman.blacklistedZones) do
			if #(PreviewEntityCoords.xyz - v.coords) < v.radius then IsValid = false end
		end

		-- On Road
		local _, ClosestRoadCoords, anotPos = GetClosestRoad(PreviewEntityCoords.x, PreviewEntityCoords.y, PreviewEntityCoords.z, 10, 1, false)
		if #(ClosestRoadCoords - PreviewEntityCoords.xyz) < DreamCore.ChristmasSnowman.distanceToNextRoad then IsValid = false end

		-- TODO: Add check distance to other snowman?
	end

	return IsValid
end

function ScaleformButtonMessage(text)
	BeginTextCommandScaleformString("STRING")
	AddTextComponentScaleform(text)
	EndTextCommandScaleformString()
end

function ScaleformButton(ControlButton)
	N_0xe83a3e3557a56640(ControlButton)
end

function ProgressBar(Data)
	local Finished = false
	local Canceled = false

	-- Disable controls
	local Disable = Data.disable or {}
	local DisableMove = Disable.move or false
	local DisableSprint = Disable.sprint or false
	local DisableCombat = Disable.combat or false
	local DisableCar = Disable.car or false

	-- Start NUI Progressbar
	SendNUIMessage({
		type = 'progress_bar:start',
		duration = Data.duration or 5000,
		label = Data.label or "Working",
		enableDotsAnimation = DreamCore.ChristmasProgressBar.enableDotsAnimation
	})

	-- Start Animation
	if Data.anim then
		RequestAnimDict(Data.anim.dict)
		while not HasAnimDictLoaded(Data.anim.dict) do Wait(10) end
		TaskPlayAnim(cache.ped, Data.anim.dict, Data.anim.clip, 8.0, -8.0, (Data.duration or 5000) / 1000, 0, 0, false, false, false)
	end

	-- Progress Loop
	local StartTime = GetGameTimer()
	while GetGameTimer() - StartTime < (Data.duration or 5000) do
		Citizen.Wait(0)

		-- Check for cancel
		if IsControlJustPressed(0, DreamCore.ChristmasProgressBar.cancelKey) then
			Canceled = true
			break
		end

		-- Disable controls
		if DisableMove then
			DisableControlAction(0, 30, true) -- Move
			DisableControlAction(0, 31, true)
			DisableControlAction(0, 32, true)
			DisableControlAction(0, 33, true)
			DisableControlAction(0, 34, true)
			DisableControlAction(0, 35, true)
		end

		if DisableSprint then
			DisableControlAction(0, 21, true) -- Sprint
		end

		if DisableCombat then
			DisablePlayerFiring(cache.ped, true)
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 25, true) -- Aim
		end

		if DisableCar and IsPedInAnyVehicle(cache.ped, false) then
			DisableControlAction(0, 59, true) -- Vehicle steering
			DisableControlAction(0, 60, true) -- Vehicle accelerator
			DisableControlAction(0, 61, true) -- Vehicle brake
		end
	end

	-- Stop NUI
	SendNUIMessage({ type = 'progress_bar:stop' })

	-- Stop Animation
	if Data.anim then
		ClearPedTasks(cache.ped)
	end

	Finished = not Canceled
	return Finished
end

RegisterNUICallback('closeUI', function()
	IsInAdventCalendar = false
	StopScreenBlur()
	SetNuiFocus(false, false)
end)

RegisterNetEvent("dream_christmas:client:notify")
AddEventHandler("dream_christmas:client:notify", function(text, type, duration)
	DreamCore.Notify(text, type, duration)
end)

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then return end

	-- Delete Entites
	for _, v in pairs(PropSystemData) do
		if DoesEntityExist(v.entity) then DeleteEntity(v.entity) end

		-- Target
		if DreamCore.Target() == 'ox' then
			exports.ox_target:removeLocalEntity(v.entity, v.target)
		elseif DreamCore.Target() == 'qb' then
			exports['qb-target']:RemoveTargetEntity(v.entity, v.target)
		end

		if v.blip then RemoveBlip(v.blip) end
	end

	for _, v in pairs(ChristmasTreeData) do
		if DoesEntityExist(v.entity) then DeleteEntity(v.entity) end

		-- Target
		if DreamCore.Target() == 'ox' then
			exports.ox_target:removeLocalEntity(v.entity, v.target)
		elseif DreamCore.Target() == 'qb' then
			exports['qb-target']:RemoveTargetEntity(v.entity, v.target)
		end

		if v.blip then RemoveBlip(v.blip) end
	end

	for _, v in pairs(ChristmasPresentData) do
		if DoesEntityExist(v.entity) then DeleteEntity(v.entity) end

		-- Target
		if DreamCore.Target() == 'ox' then
			exports.ox_target:removeLocalEntity(v.entity, v.target)
		elseif DreamCore.Target() == 'qb' then
			exports['qb-target']:RemoveTargetEntity(v.entity, v.target)
		end

		if v.blip then RemoveBlip(v.blip) end
	end

	for _, v in pairs(ChristmasAdventCalendarData.peds or {}) do
		if DoesEntityExist(v.npc) then removePed(v.npc) end
		if v.blip then RemoveBlip(v.blip) end
	end

	if IsInAdventCalendar then
		SetTimecycleModifierStrength(0.0)
		SetTimecycleModifier('default')
		SetNuiFocus(false, false)
	end

	if IsBuildingSnowman then
		ClearPedTasks(cache.ped)
	end

	FreezeEntityPosition(cache.ped, false)
end)
