local prisonLocation = vec4(1703.49, 2505.82, 45.56, 35.53)
local releaseCoords = vec4(1845.64, 2585.79, 45.67, 272.73)

local function teleport(ped, coords, withVehicle)
    DoScreenFadeOut(500)
    Wait(500)
    FreezeEntityPosition(ped, true)
    
    lib.hideTextUI()
    StartPlayerTeleport(cache.playerId, coords.x, coords.y, coords.z, coords.w, withVehicle, true, true)
    
    while IsPlayerTeleportActive() or not HasCollisionLoadedAroundEntity(cache.ped) do Wait(10) end

    SetGameplayCamRelativeHeading(0)
    FreezeEntityPosition(ped, false)

    Wait(100)
    DoScreenFadeIn(500)
end

local prisonZone = lib.zones.poly({
    name = "prison",
    thickness = 45.0,
    points = {
        vec3(1808.0999755859, 2591.5, 60.0),
        vec3(1807.5, 2558.0, 60.0),
        vec3(1806.1500244141, 2535.6499023438, 60.0),
        vec3(1813.25, 2489.25, 60.0),
        vec3(1808.25, 2474.3000488281, 60.0),
        vec3(1762.5, 2427.0, 60.0),
        vec3(1748.5, 2420.1000976562, 60.0),
        vec3(1668.4499511719, 2408.3000488281, 60.0),
        vec3(1652.75, 2410.1999511719, 60.0),
        vec3(1558.4000244141, 2469.4499511719, 60.0),
        vec3(1551.25, 2483.1499023438, 60.0),
        vec3(1547.5500488281, 2575.9499511719, 60.0),
        vec3(1548.3000488281, 2591.4499511719, 60.0),
        vec3(1576.0999755859, 2667.1499023438, 60.0),
        vec3(1585.3000488281, 2679.6499023438, 60.0),
        vec3(1648.3000488281, 2740.8500976562, 60.0),
        vec3(1662.4499511719, 2748.3500976562, 60.0),
        vec3(1762.6999511719, 2752.1999511719, 60.0),
        vec3(1776.5999755859, 2746.6000976562, 60.0),
        vec3(1829.5999755859, 2703.3500976562, 60.0),
        vec3(1834.6999511719, 2688.8000488281, 60.0),
        vec3(1809.75, 2621.0, 60.0),
    },
    onExit = function(self)
        local player = NDCore.getPlayer()
        if not player then return end

        local sentence = player.metadata.jailed
        if not sentence or sentence < 1 then return end
        teleport(cache.ped, prisonLocation)
    end
})

RegisterNetEvent("ND_Jailing:sentencePlayer", function(setJailed)
    if source == "" then return end

    if setJailed then
        teleport(cache.ped, prisonLocation)
    else
        teleport(cache.ped, releaseCoords)
    end

    if NDCore.isResourceStarted("ND_Characters") then
        exports["ND_Characters"]:allowChangeCommand(not setJailed, setJailed and "can't change character while jailed")
    end
end)
