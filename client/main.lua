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
			lib.addKeybind({
				name = 'pickupsnowball',
				description = 'Pickup Snowball',
				defaultKey = DreamCore.PickupSnowball,
				onReleased = function(self)
					if IsPickingUp then
						TriggerEvent("dream_christmas:client:notify", Locales['PickupSnowballCooldown'], "error", 5000)
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
					then
						return
					end

					IsPickingUp = true
					TaskPlayAnim(cache.ped, 'anim@mp_snowball', 'pickup_snowball', 8.0, -1, -1, 0, 1, 0, 0, 0)
					Citizen.Wait(DreamCore.PickupSnowballCooldown)
					TriggerEvent("dream_christmas:client:notify", Locales['PickupSnowball']:format(DreamCore.PickupSnowballAmount), "success", 5000)
					GiveWeaponToPed(GetPlayerPed(-1), GetHashKey('WEAPON_SNOWBALL'), DreamCore.PickupSnowballAmount, false, true)
					IsPickingUp = false
				end
			})

			while true do
				N_0x4757f00bc6323cfe('WEAPON_SNOWBALL', DreamCore.SnowballDamageModifier)
				Citizen.Wait(0)
			end
		end)
	end
end

-- Load Models
Citizen.CreateThread(function()
	for k, v in pairs(DreamCore.RandomProps) do
		lib.requestModel(GetHashKey(v.model))
	end
end)

local RandomPropsData = {}
RegisterNetEvent("dream_christmas:client:createRandomProps")
AddEventHandler("dream_christmas:client:createRandomProps", function(AllObjects)
	-- Delete Old Entites
	for _, v in pairs(RandomPropsData) do
		if DoesEntityExist(v.entity) then DeleteEntity(v.entity) end
		exports.ox_target:removeLocalEntity(v.entity, 'dream_christmas:' .. v.id)
		if v.blip then RemoveBlip(v.blip) end
	end
	RandomPropsData = {}

	for k, v in pairs(AllObjects) do
		-- Check Coords
		if DreamCore.CheckRandomCoords(v.coords) and not v.claimed then
			local SpawnedProp = CreateObject(GetHashKey(v.prop.model), v.coords, true, true, true)
			FreezeEntityPosition(SpawnedProp, true)
			exports.ox_target:addLocalEntity(SpawnedProp, {
				{
					label = Locales['RandomProp']['TargetLabel'],
					name = 'dream_christmas:' .. v.id,
					icon = 'fa-solid fa-gift',
					onSelect = function()
						if DreamCore.RandomPropTeleportToProp then
							local BeforeProp = GetOffsetFromEntityInWorldCoords(SpawnedProp, 0.0, -1.0, 0.0)
							SetEntityCoords(cache.ped, BeforeProp.x, BeforeProp.y, GetEntityCoords(cache.ped).z - 1)
							SetEntityHeading(cache.ped, GetEntityHeading(SpawnedProp))
						end
						FreezeEntityPosition(cache.ped, true)

						if lib.progressBar({
								duration = DreamCore.RandomPropProgressBar,
								label = Locales['RandomProp']['ProgressBar'],
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
							local result = lib.callback.await('dream_christmas:server:rewardRandomProp', false, v.id)

							if result.success then
								TriggerEvent("dream_christmas:client:notify", result.message, "success", 5000)
							else
								TriggerEvent("dream_christmas:client:notify", result.message, "error", 5000)
							end
						else
							FreezeEntityPosition(cache.ped, false)
						end
					end
				}
			})
			local SpawnedPropBlip = createBlip(v.prop.blip.name, v.coords, v.prop.blip.scale, v.prop.blip.sprite, v.prop.blip.color)

			RandomPropsData[v.id] = {
				id = v.id,
				entity = SpawnedProp,
				blip = SpawnedPropBlip,
				coords = v.coords,
				prop = v.prop
			}
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		local PlayerCoords = GetEntityCoords(cache.ped)
		for _, v in pairs(RandomPropsData) do
			if not v.forcedToGround then
				if #(v.coords - PlayerCoords) < 424 then -- OneSync-Range
					Citizen.Wait(0)
					SetEntityCoords(v.entity, v.coords.x, v.coords.y, v.coords.z - GetEntityHeightAboveGround(v.entity))
					RandomPropsData[v.id].forcedToGround = true
				end
			end
		end
		Citizen.Wait(1000)
	end
end)

RegisterNetEvent("dream_christmas:client:removeRandomProp")
AddEventHandler("dream_christmas:client:removeRandomProp", function(PropId)
	local RandomPropData = RandomPropsData[PropId]
	if RandomPropData then
		exports.ox_target:removeLocalEntity(RandomPropData.entity, 'dream_christmas:' .. RandomPropData.id)
		if RandomPropData.blip then
			RemoveBlip(RandomPropData.blip)
			RandomPropsData[PropId].blip = nil
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

		exports.ox_target:addLocalEntity(SpawnedProp, {
			{
				label = Locales['ChristmasTree']['Decorate']['TargetLabel'],
				name = 'dream_christmas:' .. v.id,
				icon = 'fa-solid fa-tree',
				onSelect = function()
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
			}
		})
		local SpawnedPropBlip = createBlip(v.blip.name, v.coords, v.blip.scale, v.blip.sprite, v.blip.color)

		ChristmasTreeData[k] = {
			entity = SpawnedProp,
			blip = SpawnedPropBlip
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

		exports.ox_target:addLocalEntity(SpawnedProp, {
			{
				label = Locales['ChristmasPresent']['Claim']['TargetLabel'],
				name = 'dream_christmas:' .. v.id,
				icon = 'fa-solid fa-gift',
				onSelect = function()
					if lib.progressBar({
							duration = DreamCore.ChristmasPresentProgressBar,
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
			}
		})
		local SpawnedPropBlip = createBlip(v.blip.name, v.coords, v.blip.scale, v.blip.sprite, v.blip.color)

		ChristmasPresentData[k] = {
			entity = SpawnedProp,
			blip = SpawnedPropBlip
		}
	end
end)




RegisterNetEvent("dream_christmas:client:notify")
AddEventHandler("dream_christmas:client:notify", function(text, type, duration)
	local type = type or 'info'
	local duration = duration or 5000
	lib.notify({
		type        = type,
		position    = 'center-right',
		title       = Locales['NotifyHeader'],
		description = text,
		duration    = duration
	})
end)

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then return end

	-- Delete Entites
	for _, v in pairs(RandomPropsData) do
		if DoesEntityExist(v.entity) then DeleteEntity(v.entity) end
		exports.ox_target:removeLocalEntity(v.entity, 'dream_christmas:' .. v.id)
		if v.blip then RemoveBlip(v.blip) end
	end

	for _, v in pairs(ChristmasTreeData) do
		if DoesEntityExist(v.entity) then DeleteEntity(v.entity) end
		if v.blip then RemoveBlip(v.blip) end
	end

	for _, v in pairs(ChristmasPresentData) do
		if DoesEntityExist(v.entity) then DeleteEntity(v.entity) end
		if v.blip then RemoveBlip(v.blip) end
	end

	FreezeEntityPosition(cache.ped, false)
end)
