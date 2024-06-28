ESX = exports["es_extended"]:getSharedObject()
local function astrxwSendDiscordEmbed(description)
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

    PerformHttpRequest(Config.DiscordWebhookURL, function(err, text, headers) end, 'POST', json.encode({embeds = embed}), { ['Content-Type'] = 'application/json' })
end

RegisterServerEvent('vigneron:notifyService')
AddEventHandler('vigneron:notifyService', function(onDuty)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer then
        TriggerClientEvent('vigneron:updateDutyStatus', _source, onDuty)
        if onDuty then
            TriggerClientEvent('esx:showNotification', _source, '~g~Vous avez pris votre service.')
            astrxwSendDiscordEmbed("Prise de service par " .. xPlayer.getName())
        else
            TriggerClientEvent('esx:showNotification', _source, '~r~Vous avez quitté votre service.')
            astrxwSendDiscordEmbed("Fin de service par " .. xPlayer.getName())
        end
    end
end)

RegisterServerEvent('vigneron:startVente')
AddEventHandler('vigneron:startVente', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer then
        local grapes = xPlayer.getInventoryItem('raisin').count
        if grapes >= 1 then
        Citizen.Wait(2000)
        local grapes = math.random(1, 5)
        xPlayer.removeInventoryItem('vine', 2)
        astrxwSendDiscordEmbed("Vente démarrée par " .. xPlayer.getName())
    end
end
end)


RegisterServerEvent('vigneron:startHarvest')
AddEventHandler('vigneron:startHarvest', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer then
        Citizen.Wait(2000)
        local grapes = math.random(1, 5)
        xPlayer.addInventoryItem('raisin', grapes)
        TriggerClientEvent('esx:showNotification', _source, 'Vous avez récolté ~g~' .. grapes .. ' ~s~raisins.')
    end
end)

RegisterServerEvent('vigneron:startProcessing')
AddEventHandler('vigneron:startProcessing', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer then
        local grapes = xPlayer.getInventoryItem('raisin').count
        if grapes >= 1 then
            xPlayer.removeInventoryItem('raisin', 1)
            Citizen.Wait(2000)
            xPlayer.addInventoryItem('vine', 1)
            TriggerClientEvent('esx:showNotification', _source, 'Vous avez produit ~g~1 bouteille de vin~s~.')
        else
            TriggerClientEvent('esx:showNotification', _source, '~r~Vous n\'avez pas assez de raisins pour traiter.')
        end
    end
end)





ESX = exports["es_extended"]:getSharedObject()

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

    MySQL.Async.fetchScalar('SELECT job_grade FROM users WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(currentGrade)
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

    MySQL.Async.fetchScalar('SELECT job_grade FROM users WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(currentGrade)
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

    MySQL.Async.execute('UPDATE users SET job = @job, job_grade = 0 WHERE identifier = @identifier', {
        ['@identifier'] = identifier,
        ['@job'] = 'unemployed'
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


ESX.RegisterServerCallback('vigneron:checkJob', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and xPlayer.job and xPlayer.job.name == 'vigneron' and xPlayer.job.grade_name == 'boss' then
        cb(true)
    else
        cb(false)
    end
end)



RegisterServerEvent('vigneron:payPlayer')
AddEventHandler('vigneron:payPlayer', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local amount = Config.VentePricePerItem
        xPlayer.addMoney(amount)
        TriggerClientEvent('esx:showNotification', source, "Vous avez reçu ~g~$" .. amount)
        astrxwSendDiscordEmbed("Vente terminée par " .. xPlayer.getName() .. " pour $" .. amount)
    end
end)

