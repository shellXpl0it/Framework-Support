local onAdminDuty = false
local onDutyPlayers = {}
local toggleStates = {
    godmode = false,
    noragdoll = false,
    invisibility = false,
    noclip = false,
    esp = false,
    espId = false,
    espNametag = false,
}

local noclipBaseSpeed = 3.0
local noclipDisplaySpeed = 1


local function hasAccess(categories, category)
    if not categories then return false end
    for _, cat in ipairs(categories) do
        if cat == category then
            return true
        end
    end
    return false
end

RegisterNetEvent('framework-support:client:openMenu', function(allowedCategories)
    lib.notify({
        id = 'support_menu_opening',
        title = 'Framework Support',
        description = 'Opening the settings menu.',
        type = 'inform',
        icon = 'shield-alt'
    })
    local menuOptions = {}

    if onAdminDuty then
        if hasAccess(allowedCategories, 'users') then
            table.insert(menuOptions, {
                title = 'Users', description = 'View online users.', icon = 'users', menu = 'support_submenu_users'
            })
        end
        if hasAccess(allowedCategories, 'actions') then
            table.insert(menuOptions, {
                title = 'Actions', description = 'Execute admin actions.', icon = 'terminal', menu = 'support_submenu_actions'
            })
        end
        if hasAccess(allowedCategories, 'visuals') then
            table.insert(menuOptions, {
                title = 'Visuals', description = 'Change visual settings.', icon = 'eye', menu = 'support_submenu_visuals'
            })
        end
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
                if toggleStates.invisibility then
                    toggleStates.invisibility = false
                    SetEntityVisible(PlayerPedId(), true, false)
                    lib.notify({ title = 'Support Invisibility', description = 'Invisibility automatically disabled.', type = 'error' })
                end
                if toggleStates.noclip then
                    toggleStates.noclip = false
                    local ped = PlayerPedId()
                    SetEntityVisible(ped, true, false)
                    SetEntityCollision(ped, true, true)
                    noclipBaseSpeed = 3.0
                    noclipDisplaySpeed = 1
                    lib.notify({ title = 'Support Noclip', description = 'Noclip automatically disabled.', type = 'error' })
                end
                if toggleStates.esp then
                    toggleStates.esp = false
                    lib.notify({ title = 'Support ESP', description = 'ESP automatically disabled.', type = 'error' })
                end
                if toggleStates.espId then
                    toggleStates.espId = false
                    lib.notify({ title = 'Support ESP ID', description = 'ESP ID automatically disabled.', type = 'error' })
                end
                if toggleStates.espNametag then
                    toggleStates.espNametag = false
                    lib.notify({ title = 'Support ESP Nametag', description = 'ESP Nametag automatically disabled.', type = 'error' })
                end
            end

            lib.hideContext()
            TriggerServerEvent('framework-support:server:requestMenuOpen')
        end
    })

    lib.registerContext({
        id = 'support_settings_menu',
        title = 'Framework Support',
        options = menuOptions
    })

    local commandOptions = {}
    local commandOrder = {}
    for name in pairs(Config.Commands) do
        table.insert(commandOrder, name)
    end
    table.sort(commandOrder, function(a, b) return a == 'noclip' end)

    for _, commandName in ipairs(commandOrder) do
        local settings = Config.Commands[commandName]
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

    local visualsOptions = {}
    table.insert(visualsOptions, {
        title = 'ESP',
        description = 'Toggles player ESP for yourself.',
        icon = 'street-view',
        checked = toggleStates.esp,
        onSelect = function()
            toggleStates.esp = not toggleStates.esp
            lib.notify({
                title = 'Support ESP',
                description = toggleStates.esp and 'ESP has been enabled.' or 'ESP has been disabled.',
                type = toggleStates.esp and 'success' or 'error'
            })
            lib.hideContext()
            lib.showContext('support_submenu_visuals')
        end
    })
    table.insert(visualsOptions, {
        title = 'ID',
        description = 'Toggles player ID display.',
        icon = 'id-badge',
        checked = toggleStates.espId,
        onSelect = function()
            toggleStates.espId = not toggleStates.espId
            lib.notify({
                title = 'Support ESP ID',
                description = toggleStates.espId and 'ESP ID has been enabled.' or 'ESP ID has been disabled.',
                type = toggleStates.espId and 'success' or 'error'
            })
            lib.hideContext()
            lib.showContext('support_submenu_visuals')
        end
    })
    table.insert(visualsOptions, {
        title = 'Nametag',
        description = 'Toggles player nametag display.',
        icon = 'user-tag',
        checked = toggleStates.espNametag,
        onSelect = function()
            toggleStates.espNametag = not toggleStates.espNametag
            lib.notify({
                title = 'Support ESP Nametag',
                description = toggleStates.espNametag and 'Nametag has been enabled.' or 'Nametag has been disabled.',
                type = toggleStates.espNametag and 'success' or 'error'
            })
            lib.hideContext()
            lib.showContext('support_submenu_visuals')
        end
    })
    lib.registerContext({
        id = 'support_submenu_visuals',
        title = 'Visuals',
        menu = 'support_settings_menu',
        options = visualsOptions
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

                        if Config.PlayerActions.tpTo then
                            table.insert(playerActionOptions, {
                                title = 'TP To',
                                description = 'Teleport yourself to this player.',
                                icon = 'location-arrow',
                                onSelect = function() TriggerServerEvent('framework-support:server:tpToPlayer', sId) end
                            })
                        end
                        if Config.PlayerActions.tpHere then
                            table.insert(playerActionOptions, {
                                title = 'TP Here',
                                description = 'Teleport this player to you.',
                                icon = 'download',
                                onSelect = function() TriggerServerEvent('framework-support:server:tpPlayerToMe', sId) end
                            })
                        end
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
                        if Config.PlayerActions.food then
                            table.insert(playerActionOptions, {
                                title = 'Give Food',
                                description = 'Fills this player\'s hunger.',
                                icon = 'utensils',
                                onSelect = function() TriggerServerEvent('framework-support:server:giveFoodToPlayer', sId) end
                            })
                        end
                        if Config.PlayerActions.water then
                            table.insert(playerActionOptions, {
                                title = 'Give Water',
                                description = 'Fills this player\'s thirst.',
                                icon = 'tint',
                                onSelect = function() TriggerServerEvent('framework-support:server:giveWaterToPlayer', sId) end
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
RegisterNetEvent('framework-support:server:requestMenuOpen', function()
    ExecuteCommand('fac')
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

RegisterNetEvent('framework-support:client:giveFood', function()
    TriggerEvent('esx_status:set', 'hunger', 1000000)
    lib.notify({
        id = 'framework_fed',
        title = 'Support Food',
        description = 'You have been fed.',
        type = 'success'
    })
end)

RegisterNetEvent('framework-support:client:giveWater', function()
    TriggerEvent('esx_status:set', 'thirst', 1000000)
    lib.notify({
        id = 'framework_watered',
        title = 'Support Water',
        description = 'Your thirst has been quenched.',
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

RegisterNetEvent('framework-support:client:toggleInvisibility', function()
    toggleStates.invisibility = not toggleStates.invisibility
    SetEntityVisible(PlayerPedId(), not toggleStates.invisibility, false)
    lib.notify({
        title = 'Support Invisibility',
        description = toggleStates.invisibility and 'Invisibility has been enabled.' or 'Invisibility has been disabled.',
        type = toggleStates.invisibility and 'success' or 'error'
    })
end)

RegisterNetEvent('framework-support:client:toggleNoclip', function()
    toggleStates.noclip = not toggleStates.noclip
    local ped = PlayerPedId()
    local isInVehicle = IsPedInAnyVehicle(ped, false)

    if toggleStates.noclip then
        SetEntityVisible(ped, false, false)
        SetEntityCollision(ped, false, false)
    else
        SetEntityVisible(ped, true, false)
        SetEntityCollision(ped, true, true)
        noclipBaseSpeed = 3.0
        noclipDisplaySpeed = 1
    end

    lib.notify({
        title = 'Support Noclip',
        description = toggleStates.noclip and 'Noclip has been enabled.' or 'Noclip has been disabled.',
        type = toggleStates.noclip and 'success' or 'error'
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

RegisterNetEvent('framework-support:client:setCoords', function(coords)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, true)
end)

CreateThread(function()
    while true do
        if toggleStates.noclip then
            local ped = PlayerPedId()
            SetEntityVelocity(ped, 0.0, 0.0, 0.0)

            if IsControlJustPressed(0, 14) then
                noclipBaseSpeed = math.max(noclipBaseSpeed - 1.0, 1.0)
                noclipDisplaySpeed = math.floor(noclipBaseSpeed)
            elseif IsControlJustPressed(0, 15) then
                noclipBaseSpeed = math.min(noclipBaseSpeed + 1.0, 10.0)
                noclipDisplaySpeed = math.floor(noclipBaseSpeed)
            end

            local coords = GetEntityCoords(ped)
            local camRot = GetGameplayCamRot(2)

            local forwardVector = vector3(
                -math.sin(math.rad(camRot.z)) * math.cos(math.rad(camRot.x)),
                math.cos(math.rad(camRot.z)) * math.cos(math.rad(camRot.x)),
                math.sin(math.rad(camRot.x))
            )

            local rightVector = vector3(
                math.cos(math.rad(camRot.z)),
                math.sin(math.rad(camRot.z)),
                0
            )

            local upVector = vector3(0.0, 0.0, 1.0)

            local currentMovementSpeed = noclipBaseSpeed * 0.5 
            if IsControlPressed(0, 21) then
                currentMovementSpeed = currentMovementSpeed * 4.0
            end

            if IsControlPressed(0, 32) then
                coords = coords + forwardVector * currentMovementSpeed
            end
            if IsControlPressed(0, 33) then
                coords = coords - forwardVector * currentMovementSpeed
            end
            if IsControlPressed(0, 34) then
                coords = coords - rightVector * currentMovementSpeed
            end
            if IsControlPressed(0, 35) then
                coords = coords + rightVector * currentMovementSpeed
            end
            if IsControlPressed(0, 38) then
                coords = coords + upVector * currentMovementSpeed
            end
            if IsControlPressed(0, 44) then
                coords = coords - upVector * currentMovementSpeed
            end

            SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
        end

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

CreateThread(function()
    while true do
        Wait(0)
        if toggleStates.noclip then
            local text = string.format("Noclip Speed: %d", noclipDisplaySpeed)
            SetTextFont(4)
            SetTextScale(0.0, 0.4)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextRightJustify(true)
            SetTextWrap(0.0, 1.0)
            SetTextEntry("STRING")
            AddTextComponentString(text)
            DrawText(0.95, 0.02)
        end
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
                    if IsEntityVisible(targetPed) then
                        local coords = GetEntityCoords(targetPed)
                        Draw3DText(coords.x, coords.y, coords.z + 1.0, 'Support')
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    while true do        
        Wait(0)

        if onAdminDuty and (toggleStates.esp or toggleStates.espId or toggleStates.espNametag) then
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
                        if toggleStates.esp then
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
                            DrawRect(healthBarX, boxTop + height / 2, 0.006, height + 0.002, 0, 0, 0, 200)
                            DrawRect(healthBarX, boxTop + height / 2, 0.004, height, 50, 50, 50, 150)
                            DrawRect(healthBarX, boxTop + height - (height * healthPercent / 2), 0.004, height * healthPercent, 76, 175, 80, 255)

                            if armor > 0 then
                                local armorBarX = boxLeft - 0.013
                                DrawRect(armorBarX, boxTop + height / 2, 0.006, height + 0.002, 0, 0, 0, 200)
                                DrawRect(armorBarX, boxTop + height / 2, 0.004, height, 50, 50, 50, 150)
                                DrawRect(armorBarX, boxTop + height - (height * armorPercent / 2), 0.004, height * armorPercent, 3, 169, 244, 255)
                            end

                            DrawRect(boxCenter, boxTop, width + 0.002, 0.003, 0,0,0,200)
                            DrawRect(boxCenter, boxTop + height, width + 0.002, 0.003, 0,0,0,200)
                            DrawRect(boxLeft, boxTop + height / 2, 0.003, height, 0,0,0,200)
                            DrawRect(boxLeft + width, boxTop + height / 2, 0.003, height, 0,0,0,200)

                            DrawRect(boxCenter, boxTop, width, 0.001, 255, 255, 255, 255)
                            DrawRect(boxCenter, boxTop + height, width, 0.001, 255, 255, 255, 255)
                            DrawRect(boxLeft, boxTop + height / 2, 0.001, height, 255, 255, 255, 255)
                            DrawRect(boxLeft + width, boxTop + height / 2, 0.001, height, 255, 255, 255, 255)
                        end

                        if toggleStates.espNametag or toggleStates.espId then
                            local textParts = {}
                            if toggleStates.espNametag then
                                table.insert(textParts, GetPlayerName(i))
                            end
                            if toggleStates.espId then
                                table.insert(textParts, string.format('[%s]', GetPlayerServerId(i)))
                            end
                            local text = table.concat(textParts, ' ')

                            local boxCenter = (headScreenX + feetScreenX) / 2
                            local boxTop = headScreenY

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
    end
end)
