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
end

-- Snow Overlay
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
			local SpawnedProp = CreateObject(GetHashKey(v.prop.model), v.coords, true, true, true)
			SetEntityHeading(SpawnedProp, v.heading)
			FreezeEntityPosition(SpawnedProp, true)
			SetEntityInvincible(SpawnedProp, true)
			SetBlockingOfNonTemporaryEvents(SpawnedProp, true)

			-- Add Target
			local TargetId = nil
			TargetSelect = function()
				if DreamCore.PropSystemTeleportToProp then
					local BeforeProp = GetOffsetFromEntityInWorldCoords(SpawnedProp, 0.0, -1.0, 0.0)
					SetEntityCoords(cache.ped, BeforeProp.x, BeforeProp.y, GetEntityCoords(cache.ped).z - 1)
					SetEntityHeading(cache.ped, GetEntityHeading(SpawnedProp))
				end
				FreezeEntityPosition(cache.ped, true)
				SetCurrentPedWeapon(cache.ped, GetHashKey('WEAPON_UNARMED'), true) -- Unarm Player

				if lib.progressBar({
						duration = DreamCore.PropSystemProgressBar,
						label = Locales['PropSystem']['ProgressBar'],
						useWhileDead = false,
						canCancel = false,
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
					FreezeEntityPosition(cache.ped, false)
					local result = lib.callback.await('dream_christmas:server:rewardPropSystem', false, v.id)

					if result.success then
						TriggerEvent("dream_christmas:client:notify", result.message, "success", 5000)
					else
						TriggerEvent("dream_christmas:client:notify", result.message, "error", 5000)
					end
				else
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

			local SpawnedPropBlip = createBlip(v.prop.blip.name, v.coords, v.prop.blip.scale, v.prop.blip.sprite, v.prop.blip.color)

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
		local SpawnedProp = CreateObject(GetHashKey(v.model), v.coords, true, true, true)
		SetEntityHeading(SpawnedProp, v.heading)
		FreezeEntityPosition(SpawnedProp, true)
		SetEntityInvincible(SpawnedProp, true)
		SetBlockingOfNonTemporaryEvents(SpawnedProp, true)

		-- Add Target
		local TargetId = nil
		TargetSelect = function()
			if DreamCore.ChristmasTreeTeleportToProp then
				local BeforeProp = GetOffsetFromEntityInWorldCoords(SpawnedProp, 0.0, -1.0, 0.0)
				SetEntityCoords(cache.ped, BeforeProp.x, BeforeProp.y, GetEntityCoords(cache.ped).z - 1)
				SetEntityHeading(cache.ped, GetEntityHeading(SpawnedProp))
			end

			SetCurrentPedWeapon(cache.ped, GetHashKey('WEAPON_UNARMED'), true) -- Unarm Player
			if lib.progressBar({
					duration = DreamCore.ChristmasTreeProgressBar.decorate,
					label = Locales['ChristmasTree']['Decorate']['ProgressBar'],
					useWhileDead = false,
					canCancel = false,
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
				local result = lib.callback.await('dream_christmas:server:decorateChristmasTree', false, v.id)
				if result.success then
					TriggerEvent("dream_christmas:client:notify", result.message, "success", 5000)
				else
					TriggerEvent("dream_christmas:client:notify", result.message, "error", 5000)
				end
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
		local SpawnedPropBlip = createBlip(v.blip.name, v.coords, v.blip.scale, v.blip.sprite, v.blip.color)

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
		local SpawnedProp = CreateObject(GetHashKey(v.model), v.coords, true, true, true)
		SetEntityHeading(SpawnedProp, v.heading)
		FreezeEntityPosition(SpawnedProp, true)
		FreezeEntityPosition(SpawnedProp, true)
		SetEntityInvincible(SpawnedProp, true)
		SetBlockingOfNonTemporaryEvents(SpawnedProp, true)

		-- Add Target
		local TargetId = nil
		TargetSelect = function()
			if DreamCore.ChristmasPresentTeleportToProp then
				local BeforeProp = GetOffsetFromEntityInWorldCoords(SpawnedProp, 0.0, -1.0, 0.0)
				SetEntityCoords(cache.ped, BeforeProp.x, BeforeProp.y, GetEntityCoords(cache.ped).z - 1)
				SetEntityHeading(cache.ped, GetEntityHeading(SpawnedProp))
			end

			SetCurrentPedWeapon(cache.ped, GetHashKey('WEAPON_UNARMED'), true) -- Unarm Player
			if lib.progressBar({
					duration = DreamCore.ChristmasPresentProgressBar.open,
					label = Locales['ChristmasPresent']['Claim']['ProgressBar'],
					useWhileDead = false,
					canCancel = false,
					disable = {
						move = true,
						sprint = true,
						combat = true,
						car = true,
					},
					anim = {
						dict = 'anim@gangops@facility@servers@bodysearch@',
						clip = 'player_search'
					}
				})
			then
				local result = lib.callback.await('dream_christmas:server:claimChristmasPresent', false, v.id)
				if result.success then
					TriggerEvent("dream_christmas:client:notify", result.message, "success", 5000)
				else
					TriggerEvent("dream_christmas:client:notify", result.message, "error", 5000)
				end
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
		local SpawnedPropBlip = createBlip(v.blip.name, v.coords, v.blip.scale, v.blip.sprite, v.blip.color)

		ChristmasPresentData[k] = {
			entity = SpawnedProp,
			blip = SpawnedPropBlip,
			target = TargetId
		}
	end
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

	FreezeEntityPosition(cache.ped, false)
end)
