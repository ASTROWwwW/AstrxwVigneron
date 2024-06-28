local RMenu = RMenu or {}
local bannerColor = Config.BannerColor
RMenu.GestionMenu = RageUI.CreateMenu("Gestion Vigneron", "Options de gestion")
RMenu.EmployeeOptionsMenu = RageUI.CreateSubMenu(RMenu.GestionMenu, "Gestion Vigneron", "Options de l'employé")
RMenu.GestionMenu:SetRectangleBanner(table.unpack(bannerColor))
RMenu.EmployeeOptionsMenu:SetRectangleBanner(table.unpack(bannerColor))

RMenu.GestionMenu.Closed = function()
    isGestionMenuOpen = false
end
RMenu.EmployeeOptionsMenu.Closed = function()
    isGestionMenuOpen = false
end

local isGestionMenuOpen = false
local employees = {}
local selectedEmployee = nil
local canInteract = true

-- Fonction pour afficher une notification native
local function astrxwShowNativeNotification(msg)
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Fonction pour ouvrir et fermer le menu
local function astrxwToggleGestionMenu()
    isGestionMenuOpen = not isGestionMenuOpen
    if isGestionMenuOpen then
        RageUI.Visible(RMenu.GestionMenu, true)
    else
        RageUI.Visible(RMenu.GestionMenu, false)
    end
end

local function astrxwLoadEmployees(cb)
    ESX.TriggerServerCallback('vigneron:getEmployees', function(data)
        employees = data
        if cb then cb() end
    end)
end


local function astrxwShowEmployees()
    for _, employee in ipairs(employees) do
        RageUI.Button(employee.firstname .. " " .. employee.lastname, "Grade: " .. employee.job_grade, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
            if Selected then
                selectedEmployee = employee
                canInteract = false
                RageUI.Visible(RMenu.EmployeeOptionsMenu, true)
                Citizen.SetTimeout(1000, function()
                    canInteract = true
                end)
            end
        end)
    end
end


local function astrxwShowEmployeeOptions()
    RageUI.Button("Promouvoir", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
        if Selected and canInteract then
            canInteract = false
            ESX.TriggerServerCallback('vigneron:checkJob', function(isBoss)
                if isBoss then
                    TriggerServerEvent('vigneron:promoteEmployee', selectedEmployee.identifier)
                    astrxwShowNativeNotification("Employé promu.")
                    RageUI.Visible(RMenu.EmployeeOptionsMenu, false)
                    astrxwLoadEmployees(function()
                        RageUI.Visible(RMenu.GestionMenu, true)
                        Citizen.SetTimeout(1000, function()
                            canInteract = true
                        end)
                    end)
                else
                    astrxwShowNativeNotification("~r~Vous n'avez pas les permissions.")
                end
            end)
        end
    end)

    RageUI.Button("Rétrograder", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
        if Selected and canInteract then
            canInteract = false
            ESX.TriggerServerCallback('vigneron:checkJob', function(isBoss)
                if isBoss then
                    TriggerServerEvent('vigneron:demoteEmployee', selectedEmployee.identifier)
                    astrxwShowNativeNotification("Employé rétrogradé.")
                    RageUI.Visible(RMenu.EmployeeOptionsMenu, false)
                    astrxwLoadEmployees(function()
                        RageUI.Visible(RMenu.GestionMenu, true)
                        Citizen.SetTimeout(1000, function()
                            canInteract = true
                        end)
                    end)
                else
                    astrxwShowNativeNotification("~r~Vous n'avez pas les permissions.")
                end
            end)
        end
    end)

    RageUI.Button("Licencier", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
        if Selected and canInteract then
            canInteract = false
            ESX.TriggerServerCallback('vigneron:checkJob', function(isBoss)
                if isBoss then
                    TriggerServerEvent('vigneron:fireEmployee', selectedEmployee.identifier)
                    astrxwShowNativeNotification("Employé licencié.")
                    RageUI.Visible(RMenu.EmployeeOptionsMenu, false)
                    astrxwLoadEmployees(function()
                        RageUI.Visible(RMenu.GestionMenu, true)
                        Citizen.SetTimeout(1000, function()
                            canInteract = true
                        end)
                    end)
                else
                    astrxwShowNativeNotification("~r~Vous n'avez pas les permissions.")
                end
            end)
        end
    end)
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
        local dist = Vdist(coords.x, coords.y, coords.z, Config.BossMarker.Pos.x, Config.BossMarker.Pos.y, Config.BossMarker.Pos.z)

       
        if PlayerData.job and PlayerData.job.name == 'vigneron' and PlayerData.job.grade_name == 'boss' then
            if dist < 10.0 then
                DrawMarker(Config.BossMarker.Type, Config.BossMarker.Pos.x, Config.BossMarker.Pos.y, Config.BossMarker.Pos.z - 1.0, 0, 0, 0, 0, 0, 0, Config.BossMarker.Size.x, Config.BossMarker.Size.y, Config.BossMarker.Size.z, Config.BossMarker.Color.r, Config.BossMarker.Color.g, Config.BossMarker.Color.b, 100, false, true, 2, nil, nil, false)
                
                if dist < Config.BossMarker.Size.x then
                    astrxwShowNativeNotification("Appuyez sur ~INPUT_CONTEXT~ pour accéder à la gestion.")
                    if IsControlJustPressed(1, 38) then -- Touche E
                        ESX.TriggerServerCallback('vigneron:checkJob', function(isBoss)
                            if isBoss then
                                astrxwLoadEmployees(function()
                                    astrxwToggleGestionMenu()
                                end)
                            else
                                astrxwShowNativeNotification("~r~Vous n'avez pas les permissions.")
                            end
                        end)
                    end
                end
            end
        end
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isGestionMenuOpen then
            RageUI.IsVisible(RMenu.GestionMenu, true, true, true, function()
                astrxwShowEmployees()
            end, function()
            end)

            RageUI.IsVisible(RMenu.EmployeeOptionsMenu, true, true, true, function()
                astrxwShowEmployeeOptions()
            end, function()
            end)
        end
    end
end)
