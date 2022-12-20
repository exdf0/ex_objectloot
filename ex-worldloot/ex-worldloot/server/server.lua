local QBCore = exports['qb-core']:GetCoreObject()

local spawnedLocations = {}

for k,lootLocation in ipairs(Config.LootLocations) do
    spawnedLocations[k] = {}
    spawnedLocations[k].spawned = false
    spawnedLocations[k].spawnTime = os.time() - ((lootLocation.respawnTime or Config.DefaultRespawnTime) * 60)
    spawnedLocations[k].failedSpawnChance = false
    spawnedLocations[k].forceSpawn = false
end

-- Callbacks

QBCore.Functions.CreateCallback('qb-worldloot:callback:getSpawnedLocations', function(source, cb)
    cb(spawnedLocations)
end)

-- Need major refactoring, highly inefficient
QBCore.Functions.CreateCallback('qb-worldloot:callback:getOsTime', function(source, cb)
    cb(os.time())
end)

-- Events

RegisterNetEvent("qb-worldloot:server:syncSpawnObject", function(lootObjectKey)
    Citizen.CreateThread(function()

        spawnedLocations[lootObjectKey].spawned = true
        spawnedLocations[lootObjectKey].spawnTime = os.time()
        spawnedLocations[lootObjectKey].failedSpawnChance = false

        TriggerClientEvent('qb-worldloot:client:syncSpawnObject', -1, lootObjectKey, os.time())
    end)
end)


RegisterNetEvent("qb-worldloot:server:syncRemoveObject", function(lootObjectKey)
    Citizen.CreateThread(function()

        spawnedLocations[lootObjectKey].spawned = false
        spawnedLocations[lootObjectKey].spawnTime = os.time()
        spawnedLocations[lootObjectKey].failedSpawnChance = false

        TriggerClientEvent('qb-worldloot:client:syncRemoveObject', -1, lootObjectKey, os.time())
    end)
end)


