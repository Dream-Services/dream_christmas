--[[
    Open-Source Conditions
	Please read the license conditions in the LICENSE file. By using this script, you agree to these conditions.
]]

-- Functions
function createPed(ModelHash, ModelPos, ModelHeading)
    -- Load Model
    local HashKey = GetHashKey(ModelHash)
    RequestModel(HashKey)
    while not HasModelLoaded(HashKey) do
        Citizen.Wait(1)
    end

    -- Spawn NPC
    local PedNPC = CreatePed(4, HashKey, ModelPos, ModelHeading, false, true)

    SetEntityHeading(PedNPC, ModelHeading)
    FreezeEntityPosition(PedNPC, true)
    SetEntityInvincible(PedNPC, true)
    SetBlockingOfNonTemporaryEvents(PedNPC, true)
    SetModelAsNoLongerNeeded(HashKey)

    return PedNPC
end

function removePed(PedID)
    DeletePed(PedID)
end

function createBlip(DisplayName, BlipCoords, BlipScale, BlipSprite, BlipColor, BlipDisplay, BlipShortRange)
    local BlipDisplay = BlipDisplay or 4
    local BlipShortRange = BlipShortRange
    if not BlipShortRange then BlipShortRange = true end

    local NewBlip = AddBlipForCoord(BlipCoords)

    SetBlipScale(NewBlip, BlipScale)
    SetBlipSprite(NewBlip, BlipSprite)
    SetBlipColour(NewBlip, BlipColor)
    SetBlipDisplay(NewBlip, BlipDisplay)
    SetBlipAsShortRange(NewBlip, BlipShortRange)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(DisplayName)
    EndTextCommandSetBlipName(NewBlip)

    return NewBlip
end

function removeBlip(BlipID)
    return RemoveBlip(BlipID)
end
