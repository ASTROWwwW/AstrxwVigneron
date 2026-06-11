ESX = exports["es_extended"]:getSharedObject()

local DutyState = {}
local Cooldowns = {}

local function astrxwSendDiscordEmbed(description)
    local url = Config.DiscordWebhookURL
    if not url or url == '' or url == 'TON WEBHOOK' then
        return
    end

    local embed = {
        {
            title = Config.Embed.title,
            description = description,
            color = Config.Embed.color,
            footer = {
                text = Config.Embed.footer.text,
                icon_url = Config.Embed.footer.icon_url
            }
        }
    }

    PerformHttpRequest(url, function(err, text, headers) end, 'POST', json.encode({embeds = embed}), { ['Content-Type'] = 'application/json' })
end

local function astrxwOnCooldown(identifier, action, delay)
    local now = GetGameTimer()
    Cooldowns[identifier] = Cooldowns[identifier] or {}
    local last = Cooldowns[identifier][action]
    if last and (now - last) < delay then
        return true
    end
    Cooldowns[identifier][action] = now
    return false
end

local function astrxwIsNearPoint(xPlayer, points, radius)
    local ped = GetPlayerPed(xPlayer.source)
    if not ped or ped == 0 then return false end
    local pc = GetEntityCoords(ped)
    for _, p in ipairs(points) do
        local px = p.x or (p.Pos and p.Pos.x)
        local py = p.y or (p.Pos and p.Pos.y)
        local pz = p.z or (p.Pos and p.Pos.z)
        if px then
            local dx, dy, dz = pc.x - px, pc.y - py, pc.z - pz
            if (dx * dx + dy * dy + dz * dz) <= (radius * radius) then
                return true
            end
        end
    end
    return false
end

local function astrxwGetZonePoints()
    local points = {}
    for _, v in pairs(Config.Zones) do
        table.insert(points, v.Pos)
    end
    return points
end

RegisterServerEvent('vigneron:notifyService')
AddEventHandler('vigneron:notifyService', function(onDuty)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not xPlayer or xPlayer.job.name ~= 'vigneron' then
        return
    end
    if astrxwOnCooldown(xPlayer.identifier, 'notifyService', 3000) then
        return
    end

    onDuty = onDuty and true or false
    DutyState[xPlayer.identifier] = onDuty

    TriggerClientEvent('vigneron:updateDutyStatus', _source, onDuty)
    if onDuty then
        TriggerClientEvent('esx:showNotification', _source, '~g~Vous avez pris votre service.')
        astrxwSendDiscordEmbed("Prise de service par " .. xPlayer.getName())
    else
        TriggerClientEvent('esx:showNotification', _source, '~r~Vous avez quitté votre service.')
        astrxwSendDiscordEmbed("Fin de service par " .. xPlayer.getName())
    end
end)

RegisterServerEvent('vigneron:startVente')
AddEventHandler('vigneron:startVente', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or xPlayer.job.name ~= 'vigneron' then
        return
    end

    if astrxwOnCooldown(xPlayer.identifier, 'vente', Config.VenteCooldown or 60000) then
        TriggerClientEvent('esx:showNotification', source, '~r~Vous devez attendre avant de vendre à nouveau.')
        return
    end

    if not astrxwIsNearPoint(xPlayer, Config.VentePoints, 5.0) then
        TriggerClientEvent('esx:showNotification', source, "~r~Vous n'êtes pas à un point de vente.")
        return
    end

    local vine = xPlayer.getInventoryItem('vine')
    if not vine or vine.count <= 0 then
        TriggerClientEvent('esx:showNotification', source, "~r~Vous n'avez pas de vin à vendre.")
        return
    end

    xPlayer.removeInventoryItem('vine', 1)
    local amount = Config.VentePricePerItem
    xPlayer.addMoney(amount)
    TriggerClientEvent('esx:showNotification', source, 'Vous avez vendu ~g~1 bouteille~s~ pour ~g~$' .. amount)
    astrxwSendDiscordEmbed("Vente par " .. xPlayer.getName() .. " pour $" .. amount)
end)


RegisterServerEvent('vigneron:startHarvest')
AddEventHandler('vigneron:startHarvest', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not xPlayer then return end

    if xPlayer.job.name ~= 'vigneron' then
        return
    end
    if not DutyState[xPlayer.identifier] then
        TriggerClientEvent('esx:showNotification', _source, '~r~Vous devez être en service.')
        return
    end
    if not astrxwIsNearPoint(xPlayer, astrxwGetZonePoints(), 20.0) then
        return
    end
    if astrxwOnCooldown(xPlayer.identifier, 'harvest', 2000) then
        return
    end

    local grapes = math.random(1, 5)
    xPlayer.addInventoryItem('raisin', grapes)
    TriggerClientEvent('esx:showNotification', _source, 'Vous avez récolté ~g~' .. grapes .. ' ~s~raisins.')
end)

RegisterServerEvent('vigneron:startProcessing')
AddEventHandler('vigneron:startProcessing', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not xPlayer then return end

    if xPlayer.job.name ~= 'vigneron' then
        return
    end
    if not DutyState[xPlayer.identifier] then
        TriggerClientEvent('esx:showNotification', _source, '~r~Vous devez être en service.')
        return
    end
    if not astrxwIsNearPoint(xPlayer, astrxwGetZonePoints(), 20.0) then
        return
    end
    if astrxwOnCooldown(xPlayer.identifier, 'processing', 2000) then
        return
    end

    local raisin = xPlayer.getInventoryItem('raisin')
    if raisin and raisin.count >= 1 then
        xPlayer.removeInventoryItem('raisin', 1)
        xPlayer.addInventoryItem('vine', 1)
        TriggerClientEvent('esx:showNotification', _source, 'Vous avez produit ~g~1 bouteille de vin~s~.')
    else
        TriggerClientEvent('esx:showNotification', _source, '~r~Vous n\'avez pas assez de raisins pour traiter.')
    end
end)

AddEventHandler('esx:playerDropped', function(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        DutyState[xPlayer.identifier] = nil
        Cooldowns[xPlayer.identifier] = nil
    end
end)





ESX.RegisterServerCallback('vigneron:getEmployees', function(source, cb)
    local employees = {}
    local xPlayers = ESX.GetExtendedPlayers()

    for _, xPlayer in ipairs(xPlayers) do
        if xPlayer.job.name == 'vigneron' then
            table.insert(employees, {
                firstname = xPlayer.get('firstName'),
                lastname = xPlayer.get('lastName'),
                job_grade = xPlayer.job.grade,
                identifier = xPlayer.identifier
            })
        end
    end
    cb(employees)
end)


RegisterNetEvent('vigneron:promoteEmployee')
AddEventHandler('vigneron:promoteEmployee', function(identifier)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or xPlayer.job.name ~= 'vigneron' or xPlayer.job.grade_name ~= 'boss' then
        TriggerClientEvent('esx:showNotification', source, "~r~Vous n'avez pas les permissions.")
        return
    end

    MySQL.Async.fetchScalar('SELECT job_grade FROM users WHERE identifier = @identifier AND job = @job', {
        ['@identifier'] = identifier,
        ['@job'] = 'vigneron'
    }, function(currentGrade)
        if currentGrade == nil then
            TriggerClientEvent('esx:showNotification', xPlayer.source, '~r~Employé introuvable.')
            return
        end
        MySQL.Async.fetchScalar('SELECT MAX(grade) FROM job_grades WHERE job_name = @job_name', {
            ['@job_name'] = 'vigneron'
        }, function(maxGrade)
            if currentGrade < maxGrade then
                MySQL.Async.execute('UPDATE users SET job_grade = job_grade + 1 WHERE identifier = @identifier AND job = @job', {
                    ['@identifier'] = identifier,
                    ['@job'] = 'vigneron'
                }, function(rowsChanged)
                    if rowsChanged > 0 then
                        local promotedPlayer = ESX.GetPlayerFromIdentifier(identifier)
                        if promotedPlayer then
                            promotedPlayer.setJob('vigneron', currentGrade + 1)
                        end
                        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Employé promu.')
                    else
                        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Impossible de promouvoir cet employé.')
                    end
                end)
            else
                TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous ne pouvez pas promouvoir plus haut.')
            end
        end)
    end)
end)


RegisterNetEvent('vigneron:demoteEmployee')
AddEventHandler('vigneron:demoteEmployee', function(identifier)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or xPlayer.job.name ~= 'vigneron' or xPlayer.job.grade_name ~= 'boss' then
        TriggerClientEvent('esx:showNotification', source, "~r~Vous n'avez pas les permissions.")
        return
    end

    MySQL.Async.fetchScalar('SELECT job_grade FROM users WHERE identifier = @identifier AND job = @job', {
        ['@identifier'] = identifier,
        ['@job'] = 'vigneron'
    }, function(currentGrade)
        if currentGrade == nil then
            TriggerClientEvent('esx:showNotification', xPlayer.source, '~r~Employé introuvable.')
            return
        end
        if currentGrade > 0 then
            MySQL.Async.execute('UPDATE users SET job_grade = job_grade - 1 WHERE identifier = @identifier AND job = @job', {
                ['@identifier'] = identifier,
                ['@job'] = 'vigneron'
            }, function(rowsChanged)
                if rowsChanged > 0 then
                    local demotedPlayer = ESX.GetPlayerFromIdentifier(identifier)
                    if demotedPlayer then
                        demotedPlayer.setJob('vigneron', currentGrade - 1)
                    end
                    TriggerClientEvent('esx:showNotification', xPlayer.source, 'Employé rétrogradé.')
                else
                    TriggerClientEvent('esx:showNotification', xPlayer.source, 'Impossible de rétrograder cet employé.')
                end
            end)
        else
            TriggerClientEvent('esx:showNotification', xPlayer.source, 'Cet employé est déjà au grade le plus bas.')
        end
    end)
end)

RegisterNetEvent('vigneron:fireEmployee')
AddEventHandler('vigneron:fireEmployee', function(identifier)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or xPlayer.job.name ~= 'vigneron' or xPlayer.job.grade_name ~= 'boss' then
        TriggerClientEvent('esx:showNotification', source, "~r~Vous n'avez pas les permissions.")
        return
    end

    MySQL.Async.execute('UPDATE users SET job = @newjob, job_grade = 0 WHERE identifier = @identifier AND job = @oldjob', {
        ['@identifier'] = identifier,
        ['@newjob'] = 'unemployed',
        ['@oldjob'] = 'vigneron'
    }, function(rowsChanged)
        if rowsChanged > 0 then

            local firedPlayer = ESX.GetPlayerFromIdentifier(identifier)
            if firedPlayer then
                firedPlayer.setJob('unemployed', 0)
            end
            TriggerClientEvent('esx:showNotification', xPlayer.source, 'Employé licencié.')
        else
            TriggerClientEvent('esx:showNotification', xPlayer.source, 'Impossible de licencier cet employé.')
        end
    end)
end)


RegisterServerEvent('vigneron:announceStatus')
AddEventHandler('vigneron:announceStatus', function(isOpen)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if not xPlayer or xPlayer.job.name ~= 'vigneron' then
        return
    end
    if astrxwOnCooldown(xPlayer.identifier, 'announce', 5000) then
        return
    end

    isOpen = isOpen and true or false
    local msg = isOpen and '~g~Le Vigneron est maintenant ouvert.' or '~r~Le Vigneron est maintenant fermé.'
    TriggerClientEvent('esx:showNotification', -1, msg)
    astrxwSendDiscordEmbed((isOpen and "Ouverture" or "Fermeture") .. " du Vigneron par " .. xPlayer.getName())
end)


ESX.RegisterServerCallback('vigneron:checkJob', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and xPlayer.job and xPlayer.job.name == 'vigneron' and xPlayer.job.grade_name == 'boss' then
        cb(true)
    else
        cb(false)
    end
end)



