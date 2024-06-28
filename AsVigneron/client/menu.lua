local RMenu = RMenu or {}
local bannerColor = Config.BannerColor
RMenu.VigneronMenu = RageUI.CreateMenu("Vigneron", "Options")
RMenu.VigneronMenu:SetRectangleBanner(table.unpack(bannerColor))
local isMenuOpen = false
local PlayerData = {}
local onDuty = false
local ventePoint = nil
local venteBlip = nil


local function astrxwShowNativeNotification(msg, icon, iconType)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(msg)
    SetNotificationMessage(icon, icon, false, iconType, "Vigneron", "")
    DrawNotification(false, true)
end


local function astrxwCreateBlip(coords, name)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 1)  
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 5)  
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)
    return blip
end


local function astrxwGenerateRandomVentePoint()
    local randomIndex = math.random(1, #Config.VentePoints)
    return Config.VentePoints[randomIndex]
end

local function astrxwOpenVenteMenu()
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        local vehicleModel = GetEntityModel(vehicle)
        if vehicleModel == GetHashKey(Config.VenteVehicle) then
            ventePoint = astrxwGenerateRandomVentePoint()
            venteBlip = astrxwCreateBlip(ventePoint, "Point de Vente")
            SetNewWaypoint(ventePoint.x, ventePoint.y)
            astrxwShowNativeNotification("Allez au point de vente marqué sur la carte.", "CHAR_SOCIAL_CLUB", 1)
            TriggerServerEvent('vigneron:startVente')
        else
            astrxwShowNativeNotification("~r~Vous devez être dans un " .. Config.VenteVehicle .. " pour commencer la vente.", "CHAR_SOCIAL_CLUB", 1)
        end
    else
        astrxwShowNativeNotification("~r~Vous devez être dans un véhicule pour commencer la vente.", "CHAR_SOCIAL_CLUB", 1)
    end
end


local function astrxwDisableVenteMode()
    if venteBlip then
        RemoveBlip(venteBlip)
        venteBlip = nil
    end
    ventePoint = nil
    ClearGpsPlayerWaypoint()
    astrxwShowNativeNotification("Le mode vente a été désactivé.", "CHAR_SOCIAL_CLUB", 1)
end


local function astrxwCompleteVente()
    astrxwShowNativeNotification("La vente vous a rapporté " .. Config.VentePricePerItem .. "$", "CHAR_SOCIAL_CLUB", 1)
    TriggerServerEvent('vigneron:payPlayer')
end


Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(0)
    end
    PlayerData = ESX.GetPlayerData()
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)


local function astrxwToggleVigneronMenu()
    isMenuOpen = not isMenuOpen
    if isMenuOpen then
        RageUI.Visible(RMenu.VigneronMenu, true)
    else
        RageUI.Visible(RMenu.VigneronMenu, false)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(1, 167) then -- Touche F6
            if PlayerData.job and PlayerData.job.name == 'vigneron' then
                astrxwToggleVigneronMenu()
            else
                astrxwShowNativeNotification("~r~Vous n'avez pas le job Vigneron.", "CHAR_SOCIAL_CLUB", 1)
            end
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isMenuOpen then
            RageUI.IsVisible(RMenu.VigneronMenu, true, true, true, function()
                RageUI.Checkbox("Prise de service", "Activer/Désactiver la prise de service", onDuty, {}, function(Hovered, Active, Selected, Checked)
                    if Selected then
                        onDuty = Checked
                        if onDuty then
                            astrxwShowNativeNotification("~g~Vous avez pris votre service.", "CHAR_SOCIAL_CLUB", 1)
                        else
                            astrxwShowNativeNotification("~r~Vous avez quitté votre service.", "CHAR_SOCIAL_CLUB", 1)
                        end
                        TriggerServerEvent('vigneron:notifyService', onDuty)
                    end
                end)

                if onDuty then
                    RageUI.Button("Vente", "Vendre des produits", {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            astrxwOpenVenteMenu()
                        end
                    end)
                    
                    RageUI.Button("Désactiver Mode Vente", "Annuler la vente en cours", {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            astrxwDisableVenteMode()
                        end
                    end)
                    
                    RageUI.Button("Ouverture", "Annoncez l'ouverture du Vigneron", {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            astrxwShowNativeNotification("~g~Le Vigneron est maintenant ouvert.", "CHAR_SOCIAL_CLUB", 1)
                            TriggerServerEvent('vigneron:announceStatus', true)
                        end
                    end)
                    
                    RageUI.Button("Fermeture", "Annoncez la fermeture du Vigneron", {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            astrxwShowNativeNotification("~r~Le Vigneron est maintenant fermé.", "CHAR_SOCIAL_CLUB", 1)
                            TriggerServerEvent('vigneron:announceStatus', false)
                        end
                    end)
                end
            end, function()
            end)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if ventePoint then
            local playerPed = PlayerPedId()
            local pos = GetEntityCoords(playerPed)
            local dist = Vdist(pos.x, pos.y, pos.z, ventePoint.x, ventePoint.y, ventePoint.z)
            if dist < 10.0 then
                DrawMarker(1, ventePoint.x, ventePoint.y, ventePoint.z - 1.0, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 1.0, 0, 255, 0, 100, false, true, 2, false, nil, nil, false)
                if dist < 1.5 then
                    astrxwShowNativeNotification("Appuyez sur ~INPUT_CONTEXT~ pour vendre vos produits.", "CHAR_SOCIAL_CLUB", 1)
                    if IsControlJustPressed(1, 38) then
                        astrxwCompleteVente()
                        ventePoint = astrxwGenerateRandomVentePoint()
                        SetNewWaypoint(ventePoint.x, ventePoint.y)
                        RemoveBlip(venteBlip)
                        venteBlip = astrxwCreateBlip(ventePoint, "Point de Vente")
                    end
                end
            end
        end
    end
end)
