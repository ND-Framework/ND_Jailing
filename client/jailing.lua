local pedLocations = lib.load("data.peds")
local allowedJobs = require("data.jobs")

local function jailInput()
    local nearbyPlayers = lib.callback.await("ND_Jailing:getNearbyPlayers")

    local input = lib.inputDialog("Jail person", {
        {
            type = "select",
            label = "Nearby players",
            placeholder = "Select a player",
            required = true,
            options = nearbyPlayers or {{ value = 0, label = "No players found nearby!", disabled = true }}
        },
        {
            type = "number",
            label = "Jail sentence",
            description = "Time in minutes, result from MDT charges.",
            required = true,
            max = 100,
            min = 1,
            step = 1
        }
    })

    local player = input and tonumber(input[1])
    if not player or palyer == 0 then return end

    TriggerServerEvent("ND_Jailing:sentencePlayer", player, input[2])
end

local guardOptions = {
    {
        name = "ND_Jailing:open",
        icon = "fa-solid fa-building-shield",
        label = "Jail person",
        distance = 2.5,
        groups = allowedJobs,
        onSelect = function(data)
            jailInput()
        end
    }
}

local function createJailPed(location)
    NDCore.createAiPed({
        model = `s_m_m_prisguard_01`,
        coords = location,
        options = guardOptions,
        anim = {
            dict = "anim@amb@casino@valet_scenario@pose_d@",
            clip = "base_a_m_y_vinewood_01"
        },
    })
end

for i=1, #pedLocations do
    createJailPed(pedLocations[i])
end
