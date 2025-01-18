local allowedJobs = require("data.jobs")
local discord = lib.load("data.discord")

lib.callback.register("ND_Jailing:getNearbyPlayers", function(src)
    local player = NDCore.getPlayer(src)
    if not player or not lib.table.contains(allowedJobs, player.job) then return end
    
    local playerList = {}
    local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(GetPlayerPed(src)), 15)

    for i=1, #nearbyPlayers do
        local ply = NDCore.getPlayer(nearbyPlayers[i].id)
        if ply.source ~= src then            
            playerList[#playerList+1] = {
                value = ply.source,
                label = ("[%s] %s"):format(ply.source, ply.fullname)
            }
        end
    end

    if #playerList == 0 then
        playerList[#playerList+1] = {
            value = 0,
            label = "No players found nearby!",
            disabled = true
        }
    end
    
    return playerList
end)

local function sentenceNotify(player, sentenceTime)
    if not sentenceTime or sentenceTime <= 0 then return end

    player.notify({
        title = "Jail",
        description = ("%s minute%s left to your sentence!"):format(sentenceTime, sentenceTime == 1 and "" or "s"),
        duration = 5000,
        type = "inform"
    })
end

local function hexToDiscordColor(hex)
    hex = hex:gsub("#", "")

    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    
    return r * 65536 + g * 256 + b
end

local function sendToDiscord(title, description, fields)
    if not discord.enabled then return end

    local embed = {
        {
            title = title,
            description = description,
            fields = fields,
            footer = {
                icon_url = "https://i.imgur.com/notBtrZ.png",
                text = "Created by Andyyy"
            },
            color = hexToDiscordColor(discord.color)
        }
    }
    PerformHttpRequest(discord.webhook, function(err, text, headers) end, 'POST', json.encode({username = "Jail logs", embeds = embed}), {["Content-Type"] = "application/json"})
end

local function jailPlayer(src, targetSrc, sentenceTime, adminByPass)
    local player = NDCore.getPlayer(src)
    if not player then return end

    if not lib.table.contains(allowedJobs, player.job) and not adminByPass then return end

    targetSrc = tonumber(targetSrc)
    sentenceTime = tonumber(sentenceTime)
    if not targetSrc or not sentenceTime or sentenceTime > 1000 or sentenceTime < 1 then return end

    local targetPlayer = NDCore.getPlayer(targetSrc)
    if not targetPlayer then return end

    sendToDiscord("Jail logs", ("**Jail time:** %s minute(s)"):format(sentenceTime), {
        {
            name = adminByPass and "**Admin (used /jail command):**" or "**Officer:**",
            value = ("**Server ID:** %s\n**Username:** %s\n**Character name:** %s"):format(src, GetPlayerName(src), player.fullname)
        },
        {
            name = "**Prisoner:**",
            value = ("**Server ID:** %s\n**Username:** %s\n**Character name:** %s"):format(targetSrc, GetPlayerName(targetSrc), targetPlayer.fullname)
        }
    })

    TriggerClientEvent("ND_Police:uncuffPed", targetSrc)
    targetPlayer.setMetadata("jailed", sentenceTime)
    TriggerClientEvent("ND_Jailing:sentencePlayer", targetSrc, true)
    sentenceNotify(targetPlayer, sentenceTime)
end

RegisterNetEvent("ND_Jailing:sentencePlayer", function(targetSrc, sentenceTime)
    local src = source
    jailPlayer(src, targetSrc, sentenceTime)
end)

AddEventHandler("ND:characterLoaded", function(player)
    local sentence = player.getMetadata("jailed")
    if not sentence or sentence < 1 then return end

    TriggerClientEvent("ND_Jailing:sentencePlayer", player.source, true)
    sentenceNotify(player, sentence)
end)

lib.cron.new("* * * * *", function()
    local players = NDCore.getPlayers()

    for src, player in pairs(players) do
        local sentence = player.getMetadata("jailed")

        if sentence and sentence >= 1 then
            player.setMetadata("jailed", sentence-1)
            sentenceNotify(player, sentence)
        elseif sentence and sentence <= 0 then
            player.setMetadata("jailed", nil)
            TriggerClientEvent("ND_Jailing:sentencePlayer", src, false)
        end
    end
end)

lib.addCommand("unjail", {
    help = "Admin command, unjail player.",
    restricted = "group.admin",
    params = {
        {
            name = "target",
            type = "playerId",
            help = "Target player's server id"
        }
    }
}, function(source, args, raw)
    local targetPlayer = NDCore.getPlayer(args.target)
    if not targetPlayer then return end

    targetPlayer.setMetadata("jailed", nil)
    TriggerClientEvent("ND_Jailing:sentencePlayer", targetPlayer.source, false)
end)

lib.addCommand("jail", {
    help = "Admin command, jail player.",
    restricted = "group.admin",
    params = {
        {
            name = "target",
            type = "playerId",
            help = "Target player's server id"
        },
        {
            name = "time",
            type = "number",
            help = "Amount of time in (minutes) to jail for"
        }
    }
}, function(source, args, raw)
    jailPlayer(source, args.target, args.time, true)
end)
