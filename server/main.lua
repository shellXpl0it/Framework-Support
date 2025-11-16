print('^5 Framework Support               ^0')
print('^2================================================^0')
print('^5[Support]:^0 System loaded successfully.')
print('^5[Support]:^0 Using ox_lib for UI and notifications.')
print('^2================================================^0')

local ESX = nil
local frozenPlayers = {}
local combatDisabledPlayers = {}
local onDutyAdmins = {}

AddEventHandler('playerDropped', function(reason)
    if onDutyAdmins[source] then
        onDutyAdmins[source] = nil
        TriggerClientEvent('framework-support:client:updateDutyStates', -1, onDutyAdmins)
    end
end)

-- Helper function to get detailed player information for embeds
local function getPlayerInfo(xPlayer)
    if not xPlayer then return "Unknown Player" end
    local identifier = xPlayer.getIdentifier() or "N/A"
    return string.format("**%s** (`%s`)\n*Identifier: `%s`*", xPlayer.getName(), xPlayer.source, identifier)
end

CreateThread(function()
    while not ESX or not lib do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Wait(100)
    end
end)

local function sendToDiscord(webhookUrl, embed)
    if not webhookUrl or webhookUrl == '' or webhookUrl == " " then return end

    local data = {
        username = "Framework Support",
        avatar_url = "https://i.imgur.com/a5hA20A.png",
        embeds = { embed }
    }

    PerformHttpRequest(webhookUrl, function(err, text, headers)
        if err ~= 204 and err ~= 200 then
            print('^1[Support ERROR]^7: Failed to send Discord webhook. Error: ' .. err .. ' | ' .. text)
        end
    end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' })
end

RegisterCommand('fac', function(source, args, rawCommand)
    local player = source

    local xPlayer = ESX.GetPlayerFromId(player)

    if not xPlayer then return end

    local group = xPlayer.getGroup()

    if not group then 
        return print('^1[Support ERROR]^7: Could not get player group for source: ' .. player)
    end

    if Config.AdminGroups[group] then
        TriggerClientEvent('framework-support:client:openMenu', player)
    else
        TriggerClientEvent('framework-support:client:showNoPermission', player)
    end
end, false)

RegisterNetEvent('framework-support:server:setDutyState', function(isOnDuty)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if isOnDuty then
        onDutyAdmins[source] = true
        print(('[Support]: Player ID %s has gone ON duty.'):format(source))
        local embed = {
            author = { name = "Duty Status Changed" },
            color = 65280, -- Green
            fields = {
                { name = "👮 Admin", value = getPlayerInfo(xPlayer), inline = false },
                { name = "Status", value = "**ON DUTY**", inline = false }
            },
            footer = { text = "Framework Support" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
        }
        if Config.Webhooks.duty.enabled then
            sendToDiscord(Config.Webhooks.duty.url, embed)
        end
    else
        onDutyAdmins[source] = nil
        print(('[Support]: Player ID %s has gone OFF duty.'):format(source))
        local embed = {
            author = { name = "Duty Status Changed" },
            color = 16711680, -- Red
            fields = {
                { name = "👮 Admin", value = getPlayerInfo(xPlayer), inline = false },
                { name = "Status", value = "**OFF DUTY**", inline = false }
            },
            footer = { text = "Framework Support" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
        }
        if Config.Webhooks.duty.enabled then
            sendToDiscord(Config.Webhooks.duty.url, embed)
        end
    end

    TriggerClientEvent('framework-support:client:updateDutyStates', -1, onDutyAdmins)
end)

RegisterNetEvent('framework-support:server:executeSelfAction', function(clientEvent, actionLabel)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    if Config.AdminGroups[xPlayer.getGroup()] then
        TriggerClientEvent(clientEvent, source)
        local embed = {
            author = { name = "Self-Action Executed" },
            color = 3447003, -- Blue
            fields = {
                { name = "👮 Admin", value = getPlayerInfo(xPlayer), inline = true },
                { name = "⚡ Action", value = string.format("**%s**", actionLabel), inline = true }
            },
            footer = { text = "Framework Support" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
        }
        if Config.Webhooks.selfActions.enabled then
            sendToDiscord(Config.Webhooks.selfActions.url, embed)
        end
    else
        print(('[Support]: Player %s (ID: %s) tried to trigger self-action "%s" without permission.'):format(xPlayer.getName(), source, clientEvent))
    end
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    TriggerClientEvent('framework-support:client:updateDutyStates', source, onDutyAdmins)
end)

RegisterNetEvent('framework-support:server:toggleCombat', function(targetId)
    local source = source
    local adminPlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromId(targetId)

    if not adminPlayer or not targetPlayer then return end

    if not Config.AdminGroups[adminPlayer.getGroup()] then
        return
    end

    combatDisabledPlayers[targetId] = not combatDisabledPlayers[targetId]

    TriggerClientEvent('framework-support:client:setCombatState', targetId, combatDisabledPlayers[targetId])
    print(('[Support]: Player %s (ID: %s) %s combat for player %s (ID: %s).'):format(adminPlayer.getName(), source, combatDisabledPlayers[targetId] and 'disabled' or 'enabled', targetPlayer.getName(), targetId))
    local embed = {
        author = { name = "Player Action: Toggle Combat" },
        color = 15105570, -- Orange
        fields = {
            { name = "👮 Admin", value = getPlayerInfo(adminPlayer), inline = true },
            { name = "🎯 Target", value = getPlayerInfo(targetPlayer), inline = true },
            { name = "Status", value = combatDisabledPlayers[targetId] and '**Disabled**' or '**Enabled**', inline = false }
        },
        footer = { text = "Framework Support" },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    }
    if Config.Webhooks.userActions.enabled then
        sendToDiscord(Config.Webhooks.userActions.url, embed)
    end
end)

RegisterNetEvent('framework-support:server:toggleFreeze', function(targetId)
    local source = source
    local adminPlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromId(targetId)

    if not adminPlayer or not targetPlayer then return end

    if not Config.AdminGroups[adminPlayer.getGroup()] then
        return
    end

    frozenPlayers[targetId] = not frozenPlayers[targetId]

    TriggerClientEvent('framework-support:client:setFreezeState', targetId, frozenPlayers[targetId])
    local embed = {
        author = { name = "Player Action: Toggle Freeze" },
        color = 15105570, -- Orange
        fields = {
            { name = "👮 Admin", value = getPlayerInfo(adminPlayer), inline = true },
            { name = "🎯 Target", value = getPlayerInfo(targetPlayer), inline = true },
            { name = "Status", value = frozenPlayers[targetId] and '**Frozen**' or '**Unfrozen**', inline = false }
        },
        footer = { text = "Framework Support" },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    }
    if Config.Webhooks.userActions.enabled then
        sendToDiscord(Config.Webhooks.userActions.url, embed)
    end
end)

RegisterNetEvent('framework-support:server:revivePlayer', function(targetId)
    local source = source
    local adminPlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromId(targetId)

    if not adminPlayer or not targetPlayer then return end

    if not Config.AdminGroups[adminPlayer.getGroup()] then
        return
    end

    TriggerClientEvent('framework-support:client:revivePlayer', targetId)
    print(('[Support]: Player %s (ID: %s) revived player %s (ID: %s).'):format(adminPlayer.getName(), source, targetPlayer.getName(), targetId))
    local embed = {
        author = { name = "Player Action: Revive" },
        color = 3066993, -- Green
        fields = {
            { name = "👮 Admin", value = getPlayerInfo(adminPlayer), inline = true },
            { name = "🎯 Target", value = getPlayerInfo(targetPlayer), inline = true }
        },
        footer = { text = "Framework Support" },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    }
    if Config.Webhooks.userActions.enabled then
        sendToDiscord(Config.Webhooks.userActions.url, embed)
    end
end)

RegisterNetEvent('framework-support:server:healPlayer', function(targetId)
    local source = source
    local adminPlayer = ESX.GetPlayerFromId(source)
    if not Config.AdminGroups[adminPlayer.getGroup()] then return end
    local targetPlayer = ESX.GetPlayerFromId(targetId)
    TriggerClientEvent('framework-support:client:healPlayer', targetId)
    local embed = {
        author = { name = "Player Action: Heal" },
        color = 3066993, -- Green
        fields = {
            { name = "👮 Admin", value = getPlayerInfo(adminPlayer), inline = true },
            { name = "🎯 Target", value = getPlayerInfo(targetPlayer), inline = true }
        },
        footer = { text = "Framework Support" },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    }
    if Config.Webhooks.userActions.enabled then
        sendToDiscord(Config.Webhooks.userActions.url, embed)
    end
end)

RegisterNetEvent('framework-support:server:armorPlayer', function(targetId)
    local source = source
    local adminPlayer = ESX.GetPlayerFromId(source)
    if not Config.AdminGroups[adminPlayer.getGroup()] then return end
    local targetPlayer = ESX.GetPlayerFromId(targetId)
    TriggerClientEvent('framework-support:client:giveArmor', targetId)
    local embed = {
        author = { name = "Player Action: Armor" },
        color = 3447003, -- Blue
        fields = {
            { name = "👮 Admin", value = getPlayerInfo(adminPlayer), inline = true },
            { name = "🎯 Target", value = getPlayerInfo(targetPlayer), inline = true }
        },
        footer = { text = "Framework Support" },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    }
    if Config.Webhooks.userActions.enabled then
        sendToDiscord(Config.Webhooks.userActions.url, embed)
    end
end)

RegisterNetEvent('framework-support:server:repairVehicleForPlayer', function(targetId)
    local source = source
    local adminPlayer = ESX.GetPlayerFromId(source)
    if not Config.AdminGroups[adminPlayer.getGroup()] then return end
    local targetPlayer = ESX.GetPlayerFromId(targetId)
    TriggerClientEvent('framework-support:client:repairVehicle', targetId)
    local embed = {
        author = { name = "Player Action: Repair Vehicle" },
        color = 10181046, -- Gray
        fields = {
            { name = "👮 Admin", value = getPlayerInfo(adminPlayer), inline = true },
            { name = "🎯 Target", value = getPlayerInfo(targetPlayer), inline = true }
        },
        footer = { text = "Framework Support" },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    }
    if Config.Webhooks.userActions.enabled then
        sendToDiscord(Config.Webhooks.userActions.url, embed)
    end
end)

RegisterNetEvent('framework-support:server:kickPlayer', function(targetId, reason)
    local source = source
    local adminPlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromId(targetId)

    if not adminPlayer or not targetPlayer then return end

    if not Config.AdminGroups[adminPlayer.getGroup()] then
        return
    end

    local finalReason = reason
    if not finalReason or finalReason:gsub('%s*', '') == '' then
        finalReason = 'Kicked by an Administrator.'
    end

    local kickReason = table.concat({
        "🛡️ Framework Support 🛡️\n",
        "You have been removed from the server.\n\n",
        "👤 You:\n",
        string.format("   - Username: %s\n", targetPlayer.getName()),
        string.format("   - ID: %s\n\n", targetId),
        "👮 Staff:\n",
        string.format("   - Username: %s\n", adminPlayer.getName()),
        string.format("   - ID: %s\n\n", source),
        "📋 Reason:\n",
        string.format("   - %s", finalReason)
    }, "")

    DropPlayer(targetId, kickReason)

    print(('[Support]: Player %s (ID: %s) kicked player %s (ID: %s).'):format(adminPlayer.getName(), source, targetPlayer.getName(), targetId))
    local embed = {
        author = { name = "Player Action: Kick" },
        color = 15158332, -- Red
        fields = {
            { name = "👮 Admin", value = getPlayerInfo(adminPlayer), inline = true },
            { name = "🎯 Target", value = getPlayerInfo(targetPlayer), inline = true },
            { name = "📝 Reason", value = finalReason, inline = false }
        },
        footer = { text = "Framework Support" },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    }
    if Config.Webhooks.userActions.enabled then
        sendToDiscord(Config.Webhooks.userActions.url, embed)
    end
end)
