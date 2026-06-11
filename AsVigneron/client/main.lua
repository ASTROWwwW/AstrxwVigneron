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

-- Fix: factored the duplicated harvest/treatment animation into one helper
local function PlayWorkAnimation(name, duration, label, serverEvent)
    local playerPed = PlayerPedId()
    RequestAnimDict("amb@prop_human_bum_bin@base")
    while not HasAnimDictLoaded("amb@prop_human_bum_bin@base") do
        Citizen.Wait(100)
    end
    TaskPlayAnim(playerPed, "amb@prop_human_bum_bin@base", "base", 8.0, -8.0, -1, 1, 0, false, false, false)
    exports['mythic_progbar']:Progress({
        name = name,
        duration = duration,
        label = label,
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
            TriggerServerEvent(serverEvent)
        end
    end)
end

-- Fonction pour jouer l'animation de récolte
local function PlayHarvestAnimation()
    PlayWorkAnimation("harvest_grapes", 8000, "Récolte des raisins...", 'vigneron:startHarvest')
end







-- Fonction pour jouer l'animation de traitement
local function PlayTreatmentAnimation()
    PlayWorkAnimation("process_grapes", 5000, "Traitement des raisins...", 'vigneron:startProcessing')
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

    -- Fix: track help-notif transitions so we don't spam DisplayHelpText every frame
    local helpShown = false

    while true do
        -- Fix: default to a long sleep; only drop to Wait(0) when actually near a zone
        local sleep = 1000

        -- Fix: skip all per-frame work entirely when not a vigneron
        if PlayerData.job and PlayerData.job.name == 'vigneron' then
            local playerPed = PlayerPedId() -- Fix: PlayerPedId() instead of GetPlayerPed(-1)
            local pos = GetEntityCoords(playerPed)

            -- Fix: reset currentZone each iteration so it clears when leaving zones
            currentZone = nil

            for k, v in pairs(Config.Zones) do
                local dist = Vdist(pos.x, pos.y, pos.z, v.Pos.x, v.Pos.y, v.Pos.z)
                if dist < v.Size.x then
                    sleep = 0 -- Fix: only render markers at Wait(0) when in range
                    currentZone = k
                    DrawMarker(v.Marker.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0, 0, 0, 0, 0, 0, v.Marker.Scale.x, v.Marker.Scale.y, v.Marker.Scale.z, v.Marker.Color.r, v.Marker.Color.g, v.Marker.Color.b, v.Marker.Color.a, true, true, 2, nil, nil, false)
                    if dist < 1.5 then
                        if onDuty then
                            if k == "Vignoble" then
                                ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour récolter du raisin.')
                                if IsControlJustPressed(1, 38) then
                                    PlayHarvestAnimation()
                                end
                            elseif k == "TraitementVin" then
                                ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour traiter les raisins.')
                                if IsControlJustPressed(1, 38) then
                                    PlayTreatmentAnimation()
                                end
                            end
                        elseif not helpShown then
                            -- Fix: show the duty warning once per entry, not every frame
                            ShowNativeNotification('~r~Vous devez être en service pour récolter ou traiter.')
                        end
                        helpShown = true
                    end
                    break -- Fix: stop after the matched zone
                end
            end

            if currentZone == nil then
                helpShown = false
            end
        end

        Citizen.Wait(sleep)
    end
end)



