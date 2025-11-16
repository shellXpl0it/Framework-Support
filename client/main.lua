local onAdminDuty = false
local onDutyPlayers = {}
local toggleStates = {
    godmode = false,
    noragdoll = false,
}


RegisterNetEvent('framework-support:client:openMenu', function()
    lib.notify({
        id = 'support_menu_opening',
        title = 'Framework Support',
        description = 'Opening the settings menu.',
        type = 'inform',
        icon = 'shield-alt'
    })

    local menuOptions = {}

    if onAdminDuty then
        table.insert(menuOptions, {
            title = 'Users',
            description = 'View online users.',
            icon = 'users',
            menu = 'support_submenu_users'
        })

        table.insert(menuOptions, {
            title = 'Actions',
            description = 'Execute admin actions.',
            icon = 'terminal',
            menu = 'support_submenu_actions'
        })
    end

    table.insert(menuOptions, {
        title = 'Admin Duty',
        description = 'Toggle your on-duty status.',
        icon = 'shield-alt',
        checked = onAdminDuty,
        onSelect = function()
            onAdminDuty = not onAdminDuty
            TriggerServerEvent('framework-support:server:setDutyState', onAdminDuty)
            lib.notify({
                title = 'Admin Duty',
                description = onAdminDuty and 'You are now ON duty.' or 'You are now OFF duty.',
                type = onAdminDuty and 'success' or 'error'
            })

            if not onAdminDuty then
                if toggleStates.godmode then
                    toggleStates.godmode = false
                    SetPlayerInvincible(PlayerId(), false)
                    lib.notify({ title = 'Support Godmode', description = 'Godmode automatically disabled.', type = 'error' })
                end
                if toggleStates.noragdoll then
                    toggleStates.noragdoll = false
                    SetPedCanRagdoll(PlayerPedId(), true)
                    lib.notify({ title = 'Support No Ragdoll', description = 'No Ragdoll automatically disabled.', type = 'error' })
                end
            end

            lib.hideContext()
            TriggerEvent('framework-support:client:openMenu')
        end
    })

    lib.registerContext({
        id = 'support_settings_menu',
        title = 'Framework Support',
        options = menuOptions
    })

    local commandOptions = {}
    for commandName, settings in pairs(Config.Commands) do
        local isToggle = toggleStates[commandName] ~= nil

        table.insert(commandOptions, {
            title = settings.label,
            description = settings.description,
            icon = 'play-circle',
            disabled = not settings.enabled,
            checked = isToggle and toggleStates[commandName],
            onSelect = (function(s)
                return function()
                    if s.clientEvent then
                        TriggerServerEvent('framework-support:server:executeSelfAction', s.clientEvent, s.label)
                        -- For non-toggle actions, show a generic notification
                        -- Toggles have their own specific notifications
                        if not isToggle then
                            lib.notify({
                                title = 'Action Executed',
                                description = ('Used: %s'):format(s.label),
                                type = 'success'
                            })
                        end
                        lib.hideContext()
                        lib.showContext('support_submenu_actions')
                    end
                end
            end)(settings)
        })
    end

    lib.registerContext({
        id = 'support_submenu_actions',
        title = 'Actions',
        menu = 'support_settings_menu',
        options = commandOptions
    })

    local userOptions = {}
    local activePlayers = {}
    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            table.insert(activePlayers, i)
        end
    end

    for _, playerIndex in ipairs(activePlayers) do
        local serverId = GetPlayerServerId(playerIndex)
        local playerName = GetPlayerName(playerIndex)

        if serverId > 0 then
            table.insert(userOptions, {
                title = playerName,
                description = 'ID: ' .. serverId,
                icon = 'user',
                onSelect = (function(pName, sId)
                    return function()
                        if not onAdminDuty then
                            lib.notify({
                                title = 'Admin Duty',
                                description = 'You must be on duty to perform player actions.',
                                type = 'error'
                            })
                            return
                        end
                        local playerActionOptions = {}

                        if Config.PlayerActions.kick then
                            table.insert(playerActionOptions, {
                                title = 'Kick Player',
                                description = 'Remove this player from the server.',
                                icon = 'user-times',
                                onSelect = function() TriggerServerEvent('framework-support:server:kickPlayer', sId) end
                            })
                        end
                        if Config.PlayerActions.freeze then
                            table.insert(playerActionOptions, {
                                title = 'Freeze / Unfreeze',
                                description = 'Freezes or unfreezes the player.',
                                icon = 'snowflake',
                                onSelect = function() TriggerServerEvent('framework-support:server:toggleFreeze', sId) end
                            })
                        end
                        if Config.PlayerActions.revive then
                            table.insert(playerActionOptions, {
                                title = 'Revive Player',
                                description = 'Revives this player if they are dead.',
                                icon = 'heartbeat',
                                onSelect = function() TriggerServerEvent('framework-support:server:revivePlayer', sId) end
                            })
                        end
                        if Config.PlayerActions.heal then
                            table.insert(playerActionOptions, {
                                title = 'Heal Player',
                                description = 'Restores this player\'s health.',
                                icon = 'medkit',
                                onSelect = function() TriggerServerEvent('framework-support:server:healPlayer', sId) end
                            })
                        end
                        if Config.PlayerActions.armor then
                            table.insert(playerActionOptions, {
                                title = 'Give Armor',
                                description = 'Gives this player full armor.',
                                icon = 'shield-alt',
                                onSelect = function() TriggerServerEvent('framework-support:server:armorPlayer', sId) end
                            })
                        end
                        if Config.PlayerActions.repairVehicle then
                            table.insert(playerActionOptions, {
                                title = 'Repair Vehicle',
                                description = 'Repairs this player\'s vehicle.',
                                icon = 'car-mechanic',
                                onSelect = function() TriggerServerEvent('framework-support:server:repairVehicleForPlayer', sId) end
                            })
                        end
                        if Config.PlayerActions.toggleCombat then
                            table.insert(playerActionOptions, {
                                title = 'Toggle Combat',
                                description = 'Disables or enables the player\'s ability to fight.',
                                icon = 'hand-paper',
                                onSelect = function() TriggerServerEvent('framework-support:server:toggleCombat', sId) end
                            })
                        end

                        lib.registerContext({
                            id = 'support_player_actions_menu',
                            title = ('Actions for %s (ID: %s)'):format(pName, sId),
                            menu = 'support_submenu_users',
                            options = playerActionOptions
                        })
                        lib.showContext('support_player_actions_menu')                        
                    end
                end)(playerName, serverId)
            })
        end
    end

    lib.registerContext({
        id = 'support_submenu_users',
        title = ('Online Users (%s)'):format(#activePlayers),
        menu = 'support_settings_menu',
        options = userOptions
    })

    lib.showContext('support_settings_menu')

end)

RegisterNetEvent('framework-support:client:showNoPermission', function()
    lib.notify({
        id = 'support_no_permission',
        title = 'Framework Support',
        description = 'You do not have permission to use this.',
        type = 'error'
    })
end)

RegisterNetEvent('framework-support:client:showCommandDisabled', function()
    lib.notify({
        id = 'support_command_disabled',
        title = 'Framework Support',
        description = 'This command is currently disabled.',
        type = 'error'
    })
end)

RegisterNetEvent('framework-support:client:repairVehicle', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if not DoesEntityExist(vehicle) then
        vehicle = lib.getClosestVehicle(GetEntityCoords(ped))
    end

    if DoesEntityExist(vehicle) then
        SetVehicleFixed(vehicle)
        SetVehicleDirtLevel(vehicle, 0.0)
        SetVehicleUndriveable(vehicle, false)
        lib.notify({
            title = 'Support Repair',
            description = 'Your vehicle has been repaired.',
            type = 'success'
        })
    else
        lib.notify({
            title = 'Support Repair',
            description = 'No vehicle found nearby.',
            type = 'error'
        })
    end
end)

RegisterNetEvent('framework-support:client:healPlayer', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    lib.notify({
        id = 'framework_healed',
        title = 'Support Heal',
        description = 'You have been healed.',
        type = 'success'
    })
end)

RegisterNetEvent('framework-support:client:giveArmor', function()
    local ped = PlayerPedId()
    SetPedArmour(ped, 100)
    lib.notify({
        id = 'framework_armored',
        title = 'Support Armor',
        description = 'You have been given full armor.',
        type = 'success'
    })
end)

RegisterNetEvent('framework-support:client:revivePlayer', function()
    local ped = PlayerPedId()
    if IsPlayerDead(PlayerId()) then
        ResurrectPed(ped)
        SetEntityHealth(ped, GetEntityMaxHealth(ped))
        ClearPedTasksImmediately(ped)
        lib.notify({
            id = 'framework_revived',
            title = 'Support Revive',
            description = 'You have been revived.',
            type = 'success'
        })
    else
        lib.notify({ description = 'You are not dead.', type = 'inform' })
    end
end)

RegisterNetEvent('framework-support:client:toggleGodmode', function()
    toggleStates.godmode = not toggleStates.godmode
    SetPlayerInvincible(PlayerId(), toggleStates.godmode)
    lib.notify({
        title = 'Support Godmode',
        description = toggleStates.godmode and 'Godmode has been enabled.' or 'Godmode has been disabled.',
        type = toggleStates.godmode and 'success' or 'error'
    })
end)

RegisterNetEvent('framework-support:client:toggleNoRagdoll', function()
    toggleStates.noragdoll = not toggleStates.noragdoll
    SetPedCanRagdoll(PlayerPedId(), not toggleStates.noragdoll)
    lib.notify({
        title = 'Support No Ragdoll',
        description = toggleStates.noragdoll and 'No Ragdoll has been enabled.' or 'No Ragdoll has been disabled.',
        type = toggleStates.noragdoll and 'success' or 'error'
    })
end)

RegisterNetEvent('framework-support:client:setFreezeState', function(isFrozen)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, isFrozen)
    lib.notify({
        title = 'Framework Support',
        description = isFrozen and 'You have been frozen by an admin.' or 'You have been unfrozen by an admin.',
        type = isFrozen and 'error' or 'success',
        duration = 5000
    })
end)

local isCombatDisabled = false

RegisterNetEvent('framework-support:client:setCombatState', function(isDisabled)
    isCombatDisabled = isDisabled
    lib.notify({
        title = 'Framework Support',
        description = isCombatDisabled and 'Your combat has been disabled by an admin.' or 'Your combat has been enabled by an admin.',
        type = isCombatDisabled and 'error' or 'success',
        duration = 5000
    })
end)

CreateThread(function()
    while true do
        if isCombatDisabled then
            DisablePlayerFiring(PlayerId(), true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
        end
        if toggleStates.noragdoll then
            SetPedCanRagdoll(PlayerPedId(), false)
        end
        Wait(0)
    end
end)

RegisterNetEvent('framework-support:client:updateDutyStates', function(dutyList)
    onDutyPlayers = dutyList
end)

local function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)

    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov

    if onScreen then
        SetTextScale(0.0, 0.45 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 0, 0, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

CreateThread(function()
    while true do
        Wait(0)
        if Config.EnableSupportTag then
            for playerServerId, _ in pairs(onDutyPlayers) do
                local playerClientId = GetPlayerFromServerId(tonumber(playerServerId))
                if playerClientId ~= -1 and NetworkIsPlayerActive(playerClientId) then
                    local targetPed = GetPlayerPed(playerClientId)
                    local coords = GetEntityCoords(targetPed)
                    Draw3DText(coords.x, coords.y, coords.z + 1.0, 'Support')
                end
            end
        end
    end
end)

CreateThread(function()
    while true do        
        Wait(0)

        if onAdminDuty and Config.EnableESP then
            for i = 0, 255 do
                if NetworkIsPlayerActive(i) and (Config.ESPShowOnSelf or GetPlayerPed(i) ~= PlayerPedId()) then
                    local ped = GetPlayerPed(i)
                    local pos = GetEntityCoords(ped)
                    
                    local min, max = GetModelDimensions(GetEntityModel(ped))
                    local headPos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, max.z)
                    local feetPos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, min.z)

                    local headOnScreen, headScreenX, headScreenY = World3dToScreen2d(headPos.x, headPos.y, headPos.z)
                    local feetOnScreen, feetScreenX, feetScreenY = World3dToScreen2d(feetPos.x, feetPos.y, feetPos.z)

                    if headOnScreen and feetOnScreen then
                        local height = feetScreenY - headScreenY
                        local width = height * 0.3

                        local boxCenter = (headScreenX + feetScreenX) / 2
                        local boxLeft = boxCenter - width / 2
                        local boxTop = headScreenY

                        local health = GetEntityHealth(ped)
                        local maxHealth = GetEntityMaxHealth(ped)
                        local healthPercent = health / maxHealth
                        local armor = GetPedArmour(ped)
                        local armorPercent = armor / 100

                        local healthBarX = boxLeft - 0.006
                        DrawRect(healthBarX, boxTop + height / 2, 0.006, height + 0.002, 0, 0, 0, 200) -- Outline
                        DrawRect(healthBarX, boxTop + height / 2, 0.004, height, 50, 50, 50, 150) -- Background
                        DrawRect(healthBarX, boxTop + height - (height * healthPercent / 2), 0.004, height * healthPercent, 76, 175, 80, 255) -- Fill

                        if armor > 0 then
                            local armorBarX = boxLeft - 0.013
                            DrawRect(armorBarX, boxTop + height / 2, 0.006, height + 0.002, 0, 0, 0, 200) -- Outline
                            DrawRect(armorBarX, boxTop + height / 2, 0.004, height, 50, 50, 50, 150) -- Background
                            DrawRect(armorBarX, boxTop + height - (height * armorPercent / 2), 0.004, height * armorPercent, 3, 169, 244, 255) -- Fill
                        end

                        DrawRect(boxCenter, boxTop, width + 0.002, 0.003, 0,0,0,200) -- Top Outline
                        DrawRect(boxCenter, boxTop + height, width + 0.002, 0.003, 0,0,0,200) -- Bottom Outline
                        DrawRect(boxLeft, boxTop + height / 2, 0.003, height, 0,0,0,200) -- Left Outline
                        DrawRect(boxLeft + width, boxTop + height / 2, 0.003, height, 0,0,0,200) -- Right Outline

                        DrawRect(boxCenter, boxTop, width, 0.001, 255, 255, 255, 255) -- Top
                        DrawRect(boxCenter, boxTop + height, width, 0.001, 255, 255, 255, 255) -- Bottom
                        DrawRect(boxLeft, boxTop + height / 2, 0.001, height, 255, 255, 255, 255) -- Left
                        DrawRect(boxLeft + width, boxTop + height / 2, 0.001, height, 255, 255, 255, 255) -- Right

                        local text = string.format('%s [%s]', GetPlayerName(i), GetPlayerServerId(i))
                        SetTextFont(4)
                        SetTextScale(0.0, 0.4)
                        SetTextColour(255, 255, 255, 255)
                        SetTextDropshadow(0, 0, 0, 0, 255)
                        SetTextEdge(1, 0, 0, 0, 255)
                        SetTextCentre(true)
                        SetTextEntry("STRING")
                        AddTextComponentString(text)
                        DrawText(boxCenter, boxTop - 0.025)
                    end
                end
            end
        end
    end
end)
