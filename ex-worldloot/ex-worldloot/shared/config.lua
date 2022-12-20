Config = {}

Config.Debug = true -- Shows debug text

Config.DefaultRespawnTime = 30 -- Time in minutes
Config.DefaultRetryRespawnTime = 5 -- Time in minutes that the lootLocation can retry a spawn if the chance didn't success last time

Config.DefaultLootText = "Loot" -- Default loot text in qb-target interaction
Config.DefaultLootIcon = "fas fa-hand" -- Default loot icon in qb-target interaction [https://fontawesome.com/icons]


Config.AdditionalItemsPool = {
    ["weapon_pistol50"] = {
        onlyGiveOnce = true, -- If set to true, it will only give the first item pool, and then stop. | If set to false, it will try to give all items in the pool, and won't stop until the end

        [1] = {
            name = "pistol_ammo",
            chance = 20,
            min = 20
        },
        [2] = {
            name = "pistol50_extendedclip",
            chance = 3,
        }
    }
}

Config.LootPool = {
    ["food"] = {
        [1] = {
            name = "kurkakola",
            chance = 20 -- Chance in percentage
        },
        [2] = {
            name = "kurkakola",
            chance = 30,
            min = 2, -- If a min is provided and no max, it will always gives the minimum amount
            max = 4 -- If no max is provided it assumes a max of 1
        },
        [3] = {
            name = "kurkakola",
            chance = 40,
            max = 1 -- If not min is provided, it assumes a min of 1
        },
    },
    ["weapons"] = {
        onlyGiveOnce = true, -- If set to true, it will only give the first item pool, and then stop. | If set to false, it will try to give all items in the pool, and won't stop until the end

        [1] = {
            name = "weapon_pistol",
            chance = 20, -- Chance in percentage
            additionalItems = { -- Try to give additional items if this item is given to the player
                [1] = {
                    name = "pistol_ammo",
                    chance = 20,
                    min = 20
                },
                [2] = {
                    name = "pistol_flashlight",
                    chance = 5,
                }
            }
        },

        [2] = {
            name = "weapon_pistol50",
            chance = 5, -- Chance in percentage
            additionalItems = Config.AdditionalItemsPool["weapon_pistol50"] -- Alternative way to setup additional items
        },

        [3] = {
            name = "pistol50_extendedclip",
            chance = 40,
            max = 1 -- If not min is provided, it assumes a min of 1
        },
    },
}

-- Chance → Chance of spawning prop to loot in percentage
-- respawnTime → Time of prop respawn being able to respawn in minutes, if not set it will use Config.DefaultRespawnTime
-- lootText → qb-target text of interaction, if left empty, it defaults de default loot text
-- lootIcon → qb-target icon of interaction, if left empty, it defaults de default loot icon
Config.LootLocations = {
    [1] = { lootPool = Config.LootPool["food"], coords = vector3(-194.07, -998.85, 33.01), prop = "p_ld_heist_bag_s_1", chance = 50},
    [2] = { lootPool = Config.LootPool["weapons"], coords = vector3(1618.94, 2626.26, 45.56), prop = "prop_box_wood04a", lootText = "Open Box", lootIcon = "fas fa-box" , chance = 100, respawnTime = 120, retryRespawnTime = 20},
    [3] = { lootPool = Config.LootPool["food"], coords = vector3(1619.1, 2630.09, 45.56), prop = "prop_cs_heist_bag_02", lootText = "Open Bag", lootIcon = "fas fa-box" , chance = 100, respawnTime = 120, retryRespawnTime = 20},
    [4] = { lootPool = Config.LootPool["food"], coords = vector3(1619.24, 2632.42, 45.56), prop = "prop_beach_bag_01b",  lootText = "Open Bag", lootIcon = "fas fa-box" , chance = 100, respawnTime = 120, retryRespawnTime = 20},
    [5] = { lootPool = Config.LootPool["food"], coords = vector3(1621.87, 2634.32, 45.56), prop = "prop_michael_backpack", lootText = "Open Bag", lootIcon = "fas fa-box" , chance = 100, respawnTime = 120, retryRespawnTime = 20}
}