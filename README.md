# Fivem Framework Support - Admin & Support Tool

A comprehensive admin and support tool for FiveM servers, based on the ESX Framework. It provides an intuitive user interface created with `ox_lib` and allows authorized team members to perform a variety of actions on the server.

> [!WARNING]
> <span style="color:red;">**Performance Warning:** This resource is currently unoptimized and can have a significant impact on client-side performance. Resource monitor readings can reach up to **0.47ms**, especially when ESP features are active. An update to address this will be released soon.</span>

## ✨ Features

- **Granular Permission System:** Access control based on ESX groups. Define exactly which categories (`users`, `actions`, `visuals`) each group can access.
- **Duty System:** Team members can go on or off duty. The duty status is made visible to all players (optional).
- **Discord Logs:** Logging of important actions via Discord webhooks (duty status, player actions, self-actions).
- **User Actions (Category: `users`):**
    - **TP To:** Teleport to a player.
    - **TP Here:** Teleport a player to you.
    - **Kick, Freeze/Unfreeze, Revive, Heal, Give Armor.**
    - **Repair Vehicle, Toggle Combat Mode (PvP).**
    - **Give Food & Water.**
- **Admin Actions (Category: `actions`):**
    - **Noclip:** Advanced noclip with adjustable speed (Mouse Wheel) and sprint.
    - **Self-Heal, Self-Armor, Self-Revive.**
    - **Godmode, Invisibility, No-Ragdoll.**
    - **Give self Food & Water.**
- **Visuals (Category: `visuals`):**
    - **ESP:** Toggle bounding boxes, health and armor bars.
    - **ID:** Toggle player server IDs.
    - **Nametag:** Toggle player names.
- **User Interface:** Modern and user-friendly menu created with `ox_lib`.

## 📦 Dependencies

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

## ⚙️ Configuration

All configuration is done in the `shared/config.lua` file.

### Permissions (`Config.AdminGroups`)

Here you define which ESX groups have access to the admin menu. Set the value for a group to `true` to grant access.

```
