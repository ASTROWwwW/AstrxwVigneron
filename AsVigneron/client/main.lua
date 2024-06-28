ESX = exports["es_extended"]:getSharedObject()
local createdBlips = {}
local PlayerData = {}
local currentZone = nil

local onDuty = false

-- Fonction pour afficher une notification native
local function ShowNativeNotification(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(msg)
    DrawNotification(false, true)
end

-- Fonction pour afficher une notification normale
local function ShowHelpNotification(msg)
    SetTextComponentFormat('STRING')
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Fonction pour jouer l'animation de récolte
local function PlayHarvestAnimation()
    local playerPed = PlayerPedId()
    RequestAnimDict("amb@prop_human_bum_bin@base")
    while not HasAnimDictLoaded("amb@prop_human_bum_bin@base") do
        Citizen.Wait(100)
    end
    TaskPlayAnim(playerPed, "amb@prop_human_bum_bin@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
    exports['mythic_progbar']:Progress({
        name = "harvest_grapes",
        duration = 8000,  -- Durée de la récolte en ms
        label = "Récolte des raisins...",
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "amb@prop_human_bum_bin@base",
            anim = "base",
            flags = 49,
        },
    }, function(status)
        if not status then
            ClearPedTasks(playerPed)
            TriggerServerEvent('vigneron:startHarvest')
        end
    end)
end







-- Fonction pour jouer l'animation de traitement
local function PlayTreatmentAnimation()
    local playerPed = PlayerPedId()
    RequestAnimDict("amb@prop_human_bum_bin@base")
    while not HasAnimDictLoaded("amb@prop_human_bum_bin@base") do
        Citizen.Wait(100)
    end
    TaskPlayAnim(playerPed, "amb@prop_human_bum_bin@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
    exports['mythic_progbar']:Progress({
        name = "process_grapes",
        duration = 5000,  -- Durée du traitement en ms
        label = "Traitement des raisins...",
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "amb@prop_human_bum_bin@base",
            anim = "base",
            flags = 49,
        },
    }, function(status)
        if not status then
            ClearPedTasks(playerPed)
            TriggerServerEvent('vigneron:startProcessing')
        end
    end)
end


















function CreateBlipsForJob()
    -- Nettoyer les blips existants
    for _, blip in pairs(createdBlips) do
        RemoveBlip(blip)
    end
    createdBlips = {}

    -- Créer les nouveaux blips
    for k, v in pairs(Config.Zones) do
        if Config.BlipsVisibleForAll or (PlayerData.job and PlayerData.job.name == 'vigneron') then
            local blip = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)
            SetBlipSprite(blip, v.Blip.Sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, v.Blip.Scale)
            SetBlipColour(blip, v.Blip.Color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.Blip.Name)
            EndTextCommandSetBlipName(blip)
            table.insert(createdBlips, blip)
        end
    end
end


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job

    CreateBlipsForJob()
end)



function CreateBlipsForJob()
    for k, v in pairs(Config.Zones) do
        if Config.BlipsVisibleForAll or (PlayerData.job and PlayerData.job.name == 'vigneron') then
            local blip = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)
            SetBlipSprite(blip, v.Blip.Sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, v.Blip.Scale)
            SetBlipColour(blip, v.Blip.Color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.Blip.Name)
            EndTextCommandSetBlipName(blip)
        end
    end
end
-- Mise à jour de l'état de service
RegisterNetEvent('vigneron:updateDutyStatus')
AddEventHandler('vigneron:updateDutyStatus', function(status)
    onDuty = status
end)

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(0)
    end

    PlayerData = ESX.GetPlayerData()
    CreateBlipsForJob()
    while true do
        Citizen.Wait(0)
        local playerPed = GetPlayerPed(-1)
        local pos = GetEntityCoords(playerPed)
        
        if PlayerData.job and PlayerData.job.name == 'vigneron' then
            for k, v in pairs(Config.Zones) do
                local dist = Vdist(pos.x, pos.y, pos.z, v.Pos.x, v.Pos.y, v.Pos.z)
                if dist < v.Size.x then
                    currentZone = k
                    DrawMarker(v.Marker.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0, 0, 0, 0, 0, 0, v.Marker.Scale.x, v.Marker.Scale.y, v.Marker.Scale.z, v.Marker.Color.r, v.Marker.Color.g, v.Marker.Color.b, v.Marker.Color.a, true, true, 2, nil, nil, false)
                    if dist < 1.5 then
                        isInMarker = true
                        if onDuty then
                            if currentZone == "Vignoble" then
                                ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour récolter du raisin.')
                                if IsControlJustPressed(1, 38) then
                                    PlayHarvestAnimation()
                                end
                            elseif currentZone == "TraitementVin" then
                                ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour traiter les raisins.')
                                if IsControlJustPressed(1, 38) then
                                    PlayTreatmentAnimation()
                                end
                            end
                        else
                            ShowNativeNotification('~r~Vous devez être en service pour récolter ou traiter.')
                        end
                    else
                        isInMarker = false
                    end
                end
            end
        end
    end
end)



