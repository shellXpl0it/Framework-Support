# Framework Support - Admin & Support Tool

A comprehensive admin and support tool for FiveM servers, based on the ESX Framework. It provides an intuitive user interface created with `ox_lib` and allows authorized team members to perform a variety of actions on the server.

## ✨ Features

- **Permission System:** Access control based on ESX groups.
- **Duty System:** Team members can go on or off duty. The duty status is made visible to all players (optional).
- **Discord Logs:** Logging of important actions via Discord webhooks (duty status, player actions, self-actions).
- **Player Interactions:**
    - Kick
    - Freeze / Unfreeze
    - Revive
    - Heal
    - Give Armor
    - Repair Vehicle
    - Toggle Combat Mode (PvP)
- **Self-Actions for Admins:**
    - Heal
    - Give Armor
    - Revive
    - Godmode
    - No-Ragdoll
- **ESP (Player Display):** Shows information about nearby players (optional).
- **User Interface:** Modern and user-friendly menu created with `ox_lib`.

## 📦 Abhängigkeiten

Make sure the following resources are installed on your server and started before `framework-support`:

- **es_extended** (tested with Legacy 1.9.0, but should be compatible with newer versions)
- **ox_lib** (required for the user interface and notifications)

## 🛠️ Installation

1.  Download the script and unzip it.
2.  Rename the folder to `framework-support`.
3.  Place the folder in your `resources` directory.
4.  Open your `server.cfg` and add the following line (make sure it is **after** the dependencies):

    ```cfg
    ensure framework-support
    ```

5.  Configure `shared/config.lua` to your liking (see below).
6.  Restart your server.

## ⚙️ Konfiguration

All configuration is done in the `shared/config.lua` file.

### Permissions (`Config.AdminGroups`)

Here you define which ESX groups have access to the admin menu. Set the value for a group to `true` to grant access.

```
