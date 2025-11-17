Config = {}
Config.AdminGroups = {
    ['founder'] = { 'users', 'actions', 'visuals' },
}

-- Discord Webhooks for logging --
Config.Webhooks = {
    duty = {
        enabled = false,
        url = "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID" -- Webhook for on/off duty status changes
    },
    selfActions = {
        enabled = false,
        url = "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID" -- Webhook for actions from the "Actions" tab (Heal, Godmode, etc.)
    },
    userActions = {
        enabled = false,
        url = "https://discord.com/api/webhooks/YOUR_WEBHOOK_ID" -- Webhook for actions performed on other players (Kick, Freeze, etc.)
    }
}

-- Aduty Options --
Config.EnableESP = true
Config.EnableSupportTag = true
Config.ESPShowOnSelf = true

-- Users Tab --
Config.PlayerActions = {
    kick = true,
    freeze = true,
    revive = true,
    heal = true,
    armor = true,
    repairVehicle = true,
    toggleCombat = true,
    food = true,
    water = true,
    tpTo = true,
    tpHere = true,
}

-- Actions Tab --
Config.Commands = {
    noclip = {
        enabled = true,
        clientEvent = 'framework-support:client:toggleNoclip',
        label = 'Noclip',
        description = 'Toggles noclip, allowing you to fly through objects.'
    },
    heal = {
        enabled = true,
        clientEvent = 'framework-support:client:healPlayer',
        label = 'Heal',
        description = 'Restores your health to full.'
    },
    armor = {
        enabled = true,
        clientEvent = 'framework-support:client:giveArmor',
        label = 'Armor',
        description = 'Gives you a full set of armor.'
    },
    revive = {
        enabled = true,
        clientEvent = 'framework-support:client:revivePlayer',
        label = 'Revive',
        description = 'Revives you if you are dead.'
    },
    godmode = {
        enabled = true,
        clientEvent = 'framework-support:client:toggleGodmode',
        label = 'Godmode',
        description = 'Toggles invincibility for yourself.'
    },
    noragdoll = {
        enabled = true,
        clientEvent = 'framework-support:client:toggleNoRagdoll',
        label = 'No Ragdoll',
        description = 'Toggles whether you can be ragdolled.'
    },
    invisibility = {
        enabled = true,
        clientEvent = 'framework-support:client:toggleInvisibility',
        label = 'Invisibility',
        description = 'Toggles your visibility.'
    },
    food = {
        enabled = true,
        clientEvent = 'framework-support:client:giveFood',
        label = 'Food',
        description = 'Fills your hunger.'
    },
    water = {
        enabled = true,
        clientEvent = 'framework-support:client:giveWater',
        label = 'Water',
        description = 'Fills your thirst.'
    }
}