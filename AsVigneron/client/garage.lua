local RMenu = RMenu or {}
local bannerColor = Config.BannerColor
RMenu.GarageMenu = RageUI.CreateMenu("Garage", "Véhicules de l'entreprise")
RMenu.GarageMenu:SetRectangleBanner(table.unpack(bannerColor))
local isMenuOpen = false
local PlayerData = {}


local function astrxwShowNativeNotification(msg)
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end


local function astrxwToggleGarageMenu()
    isMenuOpen = not isMenuOpen
    if isMenuOpen then
        RageUI.Visible(RMenu.GarageMenu, true)
    else
        RageUI.Visible(RMenu.GarageMenu, false)
    end
end

local function astrxwSpawnVehicle(model)
    local playerPed = PlayerPedId()
    ESX.Game.SpawnVehicle(model, Config.SpawnPoint.Pos, Config.SpawnPoint.Heading, function(veh)
        TaskWarpPedIntoVehicle(playerPed, veh, -1)
    end)
    ESX.ShowNotification("~g~" .. model .. " sorti du garage.")
end


local function astrxwDeleteVehicle()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle and vehicle ~= 0 then
        ESX.Game.DeleteVehicle(vehicle)
        ESX.ShowNotification("~r~Véhicule retourné au garage.")
    else
        ESX.ShowNotification("~r~Vous n'êtes pas dans un véhicule.")
    end
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

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local dist = Vdist(coords.x, coords.y, coords.z, Config.GarageMarker.Pos.x, Config.GarageMarker.Pos.y, Config.GarageMarker.Pos.z)

        if dist < 100.0 then
            DrawMarker(Config.GarageMarker.Type, Config.GarageMarker.Pos.x, Config.GarageMarker.Pos.y, Config.GarageMarker.Pos.z - 1.0, 0, 0, 0, 0, 0, 0, Config.GarageMarker.Size.x, Config.GarageMarker.Size.y, Config.GarageMarker.Size.z, Config.GarageMarker.Color.r, Config.GarageMarker.Color.g, Config.GarageMarker.Color.b, 100, false, true, 2, nil, nil, false)
            
            if dist < Config.GarageMarker.Size.x then
                astrxwShowNativeNotification("Appuyez sur ~INPUT_CONTEXT~ pour ouvrir le garage.")
                if IsControlJustPressed(1, 38) then -- Touche E
                    if PlayerData.job and PlayerData.job.name == 'vigneron' then
                        astrxwToggleGarageMenu()
                    else
                        ESX.ShowNotification("~r~Vous n'avez pas le job Vigneron.")
                    end
                end
            end
        end

       
        local deleteDist = Vdist(coords.x, coords.y, coords.z, Config.DeletePoint.Pos.x, Config.DeletePoint.Pos.y, Config.DeletePoint.Pos.z)
        if deleteDist < Config.DeletePoint.Size.x then
            DrawMarker(Config.DeletePoint.Type, Config.DeletePoint.Pos.x, Config.DeletePoint.Pos.y, Config.DeletePoint.Pos.z - 1.0, 0, 0, 0, 0, 0, 0, Config.DeletePoint.Size.x, Config.DeletePoint.Size.y, Config.DeletePoint.Size.z, Config.DeletePoint.Color.r, Config.DeletePoint.Color.g, Config.DeletePoint.Color.b, 100, false, true, 2, nil, nil, false)
            
            if deleteDist < Config.DeletePoint.Size.x then
                astrxwShowNativeNotification("Appuyez sur ~INPUT_CONTEXT~ pour retourner le véhicule au garage.")
                if IsControlJustPressed(1, 38) then -- Touche E
                    astrxwDeleteVehicle()
                end
            end
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isMenuOpen then
            RageUI.IsVisible(RMenu.GarageMenu, true, true, true, function()
                for _, vehicle in ipairs(Config.EntrepriseVehicles) do
                    RageUI.Button(vehicle.label, nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            astrxwSpawnVehicle(vehicle.model)
                            astrxwToggleGarageMenu()
                        end
                    end)
                end
            end, function()
            end)
        end
    end
end)
