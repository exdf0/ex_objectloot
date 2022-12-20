local QBCore = exports['qb-core']:GetCoreObject()

local PlayerData = {}
local PlayerJob = {}
local spawnedLocations = nil
local entityList = {}

QBCore.Functions.TriggerCallback('qb-worldloot:callback:getSpawnedLocations', function(spawnedLocs)
    spawnedLocations = spawnedLocs
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    PlayerData = QBCore.Functions.GetPlayerData()
    PlayerJob = QBCore.Functions.GetPlayerData().job


end)


RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    PlayerJob = {}
end)

RegisterNetEvent("QBCore:Client:OnJobUpdate", function(JobInfo)
    PlayerData = QBCore.Functions.GetPlayerData()
    PlayerJob = JobInfo

    QBCore.Functions.TriggerCallback('qb-worldloot:callback:getSpawnedLocations', function(spawnedLocs)
        spawnedLocations = spawnedLocs
    end)
end)

RegisterNetEvent("qb-worldloot:client:syncSpawnObject", function(lootObjectKey, osTime)
    spawnedLocations[lootObjectKey].forceSpawn = true
    spawnedLocations[lootObjectKey].spawnTime = osTime
end)

RegisterNetEvent("qb-worldloot:client:syncRemoveObject", function(lootObjectKey, osTime)
    spawnedLocations[lootObjectKey].spawned = false
    spawnedLocations[lootObjectKey].spawnTime = osTime
    spawnedLocations[lootObjectKey].failedSpawnChance = false
    RemoveLootNoSync(lootObjectKey)
end)

RegisterNetEvent("qb-worldloot:client:lootLocation", function(lootObjectKey, osTime)
    spawnedLocations[lootObjectKey].forceSpawn = true
    spawnedLocations[lootObjectKey].spawnTime = osTime
end)


---This function prints debug text
---@param text string
local function Debug(text)
    if Config.Debug then
        print(text)
    end
end


---This function spawns a loot object based on it's key, and syncs the data with the server
---@param lootObject table
local function SpawnLootObject(lootObjectKey)
    Debug("Spawning object sync")
    local lootObject = Config.LootLocations[lootObjectKey]
    local object = CreateObjectNoOffset(GetHashKey(lootObject.prop), lootObject.coords.xyz, true, false)
    entityList[lootObjectKey] = object
    PlaceObjectOnGroundProperly(object)
    Wait(1000)
    FreezeEntityPosition(object, true)

    repeat Wait(5) until DoesEntityExist(object)

    TriggerServerEvent("qb-worldloot:server:syncSpawnObject", lootObjectKey)
end

---This function spawns a loot object based on it's key
---@param lootObject table
local function SpawnLootObjectNoSync(lootObjectKey)
    Debug("Spawning object no sync")
    local lootObject = Config.LootLocations[lootObjectKey]
    CreateObjectNoOffset(GetHashKey(lootObject.prop), lootObject.coords.xyz, true, false)
    entityList[lootObjectKey] = object
    PlaceObjectOnGroundProperly(object)
    Wait(1000)
    FreezeEntityPosition(object, true)

    repeat Wait(5) until DoesEntityExist(object)

end

---Function that processes all lootPool items
---@param lootPool table
local function ProcessLootPool(lootPool)
    local lootItemsTemp = {}
    for _,item in ipairs(lootPool) do
        local chance = math.random() * 100

        if item.chance >= chance then

            local itemAmount = 1
            if item.min and not item.max then
                itemAmount = item.min
            elseif item.min and item.max then
                itemAmount = math.random(item.min,item.max)
            elseif item.max and not item.min then
                itemAmount = math.random(1, item.max)
            end

            lootItemsTemp[#lootItemsTemp +1] = {
                name = item.name,
                amount = itemAmount,
                additionalItems = (item.additionalItems or {})
            }

            if lootPool.onlyGiveOnce then break end

        end
    end


    for _,item in ipairs(lootItemsTemp) do
        
		for _, additionalItem in ipairs(item.additionalItems or {}) do
            local chance = math.random() * 100

            if additionalItem.chance >= chance then

                local itemAmount = 1
                if additionalItem.min and not additionalItem.max then
                    itemAmount = additionalItem.min
                elseif additionalItem.min and additionalItem.max then
                    itemAmount = math.random(additionalItem.min,additionalItem.max)
                elseif additionalItem.max and not additionalItem.min then
                    itemAmount = math.random(1, additionalItem.max)
                end

                lootItemsTemp[#lootItemsTemp +1] = {
                    name = additionalItem.name,
                    amount = itemAmount
                }

                if additionalItem.onlyGiveOnce then break end

            end
        end
    end

    -- Last pass to remove additionalItems from table
    local lootItems = {}
    for _,item in ipairs(lootItemsTemp) do
        lootItems[#lootItems+1] = {
            name = item.name,
            amount = item.amount
        }
    end

    return lootItems
end

---Function that removes loot prop from map, and syncs with server
---@param key number
function RemoveLoot(key)
    Debug("Removing loot sync")
    DeleteObject(entityList[key])

    TriggerServerEvent("qb-worldloot:server:syncRemoveObject", key)
end

---Function that removes loot prop from map
---@param key number
function RemoveLootNoSync(key)
    Debug("Removing loot no sync")
    DeleteObject(entityList[key])
end

local function LootTarget(key, lootLocation)
    if #(lootLocation.coords - GetEntityCoords(PlayerPedId())) < 5 then

        local lootPool = lootLocation.lootPool
        local lootContainer = {}

        lootContainer.items = ProcessLootPool(lootPool)
        lootContainer.label = "Loot"

        for k,_ in ipairs(lootContainer.items) do
            lootContainer.items[k].slot = k
        end

        Debug("Opening container with the following data: ")
        Debug(json.encode(lootContainer))

        TriggerServerEvent("inventory:server:OpenInventory", "container", lootContainer.label .. "_" .. key, lootContainer)

        RemoveLoot(key)

    end
end

Citizen.CreateThread(function()
    local createdTarget = {}
    local createdTargetProp = {}
    local createdTargetLabel = {}

    while true do
        local sleep = 1000

        local pedCds = GetEntityCoords(PlayerPedId())

        repeat Wait(5) until spawnedLocations ~= nil


        --for k,_ in ipairs(Config.LootLocations) do
        --    createdTarget[k] = false
        --    createdTargetProp[k] = nil
        --    createdTargetLabel[k] = nil
        --end

        for k,lootLocation in ipairs(Config.LootLocations) do
            local dist = #(pedCds - lootLocation.coords.xyz)
            if dist < 10 then
                local lootLabel = (lootLocation.lootText or Config.DefaultLootText)
                local lootIcon = (lootLocation.lootIcon or Config.DefaultLootIcon)

                if not createdTarget[k] and spawnedLocations[k].spawned then
                    Debug("Creating qb-target target model")

                    createdTarget[k] = true
                    createdTargetProp[k] = lootLocation.prop
                    createdTargetLabel[k] = lootLabel

                    exports['qb-target']:AddTargetModel(lootLocation.prop, {
                        options = {
                            {
                                icon = lootIcon,
                                label = lootLabel,
                                action = function()
                                    LootTarget(k,lootLocation)
                                end
                            },
                        },
                        distance = 2.5,
                    })

                end
            elseif createdTarget[k] then
                Debug("Removing qb-target target model")
                exports['qb-target']:RemoveTargetModel(createdTargetProp, createdTargetLabel)
                createdTarget[k] = false
                createdTargetProp[k] = nil
                createdTargetLabel[k] = nil
            end

        end
        Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do


        local coords = GetEntityCoords(PlayerPedId())

        for k,lootLocation in ipairs(Config.LootLocations) do
                if #(coords - lootLocation.coords) < 50 then

                    local osTime
                    QBCore.Functions.TriggerCallback('qb-worldloot:callback:getOsTime', function(ostime)
                        osTime = ostime
                    end)

                    repeat Wait(30) until osTime ~= nil

                    --Debug("Near loot location " .. lootLocation.coords.xyz)
                    if spawnedLocations[k].forceSpawn then
                        if not DoesEntityExist(entityList[k]) then
                            Debug("Object doesn't exist, spawn it")
                            SpawnLootObjectNoSync(k)
                            spawnedLocations[k].forceSpawn = false
                            spawnedLocations[k].spawned = true
                            spawnedLocations[k].spawnTime = osTime
                        else
                            Debug("Object already existed, mark as spawned")
                            spawnedLocations[k].forceSpawn = false
                            spawnedLocations[k].spawned = true
                        end
                    end

                    local respawnTime = (lootLocation.respawnTime or Config.DefaultRespawnTime) * 60
                    if not spawnedLocations[k].failedSpawnChance then
                        if not spawnedLocations[k].spawned and (spawnedLocations[k].spawnTime + respawnTime) <= osTime then
                            Debug("Trying to spawn Loot Location " .. lootLocation.coords.xyz)
                            if lootLocation.chance >= math.random(0,100) then
                                Debug("Spawning object of loot location " .. lootLocation.coords.xyz)
                                spawnedLocations[k].spawned = true
                                spawnedLocations[k].spawnTime = osTime
                                spawnedLocations[k].failedSpawnChance = false
                                SpawnLootObject(k)
                            else
                                local retryRespawnTime = (lootLocation.retryRespawnTime or Config.DefaultRetryRespawnTime) * 60
                                Debug("Loot location " .. lootLocation.coords.xyz .. " failed spawn , trying again in " .. (retryRespawnTime / 60) .. " minutes")
                                spawnedLocations[k].spawnTime = osTime
                                spawnedLocations[k].failedSpawnChance = true
                            end
                        end
                    else
                        local retryRespawnTime = (lootLocation.retryRespawnTime or Config.DefaultRetryRespawnTime) * 60
                        if (spawnedLocations[k].spawnTime + retryRespawnTime) <= osTime then

                            if lootLocation.chance >= math.random(0,100) then
                                Debug("Reattempt of loot location " .. lootLocation.coords.xyz .. " successful, now spawning object")
                                spawnedLocations[k].spawned = true
                                spawnedLocations[k].spawnTime = osTime
                                spawnedLocations[k].failedSpawnChance = false
                                SpawnLootObject(k)
                            else
                                local retryRespawnTime = (lootLocation.retryRespawnTime or Config.DefaultRetryRespawnTime) * 60
                                Debug("Loot location " .. lootLocation.coords.xyz .. " failed spawn reattempt, trying again in " .. (retryRespawnTime / 60) .. " minutes")
                                spawnedLocations[k].spawnTime = osTime
                                spawnedLocations[k].failedSpawnChance = true
                            end
                        end
                    end
                end
            end

        Wait(1000)
    end
end)