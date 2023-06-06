FuriousAdminMenu = {}
FuriousAdminMenu.Config = { -- [refer to documentation in discord for full info & details if your confused]
    Main = {
        BanFile = 'bans.json',
        ServerName = 'Wock Life',
        DiscordInvite = 'discord.gg/wocklife',
        ChatPrefixColor = '^7'
    },
    Menu = {
        MenuTitle = 'Wocklife Admin Menu',
        MenuSize = 'medium', -- [small, medium, large]
        MenuColor = {r = 255, g = 255, b = 255}
    },
    Alerts = {
        PlayerNotifys = true
    },
    ESX = {
        Enabled = true,
        CoreEvent = 'esx:getSharedObject'
    },
    DiscordSetup = {
        GuildID = 1066783332253310996,
        BotToken = "MTEwMjY5MTczMjY3Nzc0MjY0Mw.GWm_nZ.AL0ZeN6Tn59oxGvoiFyXnzQsH3jSBXrzeK5HRM",
        Webhooks = {
            Screenshots = 'https://discord.com/api/webhooks/1102392427383373925/ooje-0yUxKWj9cioMyPWzFYPNgdbMyIUIdK4X0QYf_G20YUOHrg_nWPwLa8R1-CN9ohn'
        }
    },
    Weapons = {
        {label = 'Combat Pistol', spawn = 'weapon_combatpistol'},
    },
    Functions = {
        Noclip = {
            Command = {
                Enabled = true, -- [true, false]
                String = 'noclip' -- [Command Name (/fa:noclip)]
            },
            Keybind = {
                Enabled = false, -- [true, false]
                Bind = 'N' -- [Button Bind (N)]
            }
        },
        StopSpectating = {
            Command = {
                Enabled = true, -- [true, false]
                String = 'FuriousAdmin:stopspectating' -- [Command Name (/fa:stopspectating)]
            },
            Keybind = {
                Enabled = true, -- [true, false]
                Bind = 'E' -- [Button Bind (E)]
            }
        },
        OpenMenu = {
            Command = {
                Enabled = true, -- [true, false]
                String = 'FuriousAdmin:openmenu' -- [Command Name (/fa:openmenu)]
            },
            Keybind = {
                Enabled = true, -- [true, false]
                Bind = 'F5' -- [Button Bind (F9)]
            }
        }
    }
}