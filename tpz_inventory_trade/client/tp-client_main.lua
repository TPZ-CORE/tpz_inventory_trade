
local PlayerData = { 
    IsTrading = false, 
    IsBusy    = false, 
    Cooldown  = Config.TradingDuration,  
    ItemData  = {},
}

local TradingData = { 
    senderId = 0, 
    senderUsername = nil,

    targetId = 0, 
    targetUsername = nil,

    cost        = 0, 
    account     = 0,
    
    quantity    = 0,
    maxQuantity = 0,
}

local loadedTasks = false

-----------------------------------------------------------
--[[ Function Getters ]]--
-----------------------------------------------------------

function GetPlayerData()
    return PlayerData
end

function ResetPlayerData()

    PlayerData = nil

    PlayerData = { 
        IsTrading = false, 
        IsBusy    = false, 
        Cooldown  = Config.TradingDuration,  
        ItemData  = {},
    }

end

function GetTradingData()
    return TradingData
end

function ResetTradingData()

    TradingData = nil

    TradingData = { 
        senderId = 0, 
        senderUsername = nil,
    
        targetId = 0, 
        targetUsername = nil,
    
        cost        = 0, 
        account     = 0,
        
        quantity    = 0,
        maxQuantity = 0,
    }
end

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

-- what does data return?
function StartTradingProcess(targetId, data, quantity)

    if PlayerData.IsBusy then
        -- busy already
        return
    end

    PlayerData.ItemData     = data
    TradingData.targetId    = tonumber(targetId)
    TradingData.maxQuantity = tonumber(quantity)

    PlayerData.IsBusy       = true

    TriggerEvent('tpz_inventory_trade:client:tasks')

    SendNUIMessage({ action = 'startTradingTransactionProcess' })

    Wait(250)

    local isReadable = false

    local quantityInputDescription = Locales['DIALOG_INPUT_REQUIRED_ITEM_QUANTITY']

    if data.type == 'money' or data.type == 'gold' or data.type == 'blackmoney' then
        quantityInputDescription = Locales['DIALOG_INPUT_REQUIRED_MONEY_QUANTITY']
    end

    if quantity == 1 or data.type == 'weapon' then
        quantityInputDescription = Locales['DIALOG_INPUT_REQUIRED_READABLE_QUANTITY']
        isReadable = true
    end

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_core:getPlayerData", function(cb)

        TradingData.senderId = cb.source

        SendNUIMessage({ 
            action = 'startTradingTransactionProcess', 

            title                 = data.label,
            item_quantity         = quantity,
            quantity_description  = quantityInputDescription,
            cost_description      = Locales['DIALOG_INPUT_REQUIRED_ACCOUNT_COST'],
            isReadable            = isReadable,
        })
    
        Wait(250)
        ToggleUI(true)

    end)

end

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

RegisterNetEvent('tpz_inventory_trade:client:setPlayerBusy')
AddEventHandler('tpz_inventory_trade:client:setPlayerBusy', function(cb)

    PlayerData.IsBusy = cb

    if not PlayerData.IsBusy and PlayerData.IsTrading then
        CloseUI()

        PlayerData.IsTrading = false
    end

end)

RegisterNetEvent('tpz_inventory_trade:client:startTargetTradingProcess')
AddEventHandler('tpz_inventory_trade:client:startTargetTradingProcess', function(sender_id, target_id, targetUsername, senderUsername, itemData, cost, account, quantity)

    ResetTradingData()

    local player = PlayerPedId()
    local isDead = IsEntityDead(player)

    if not PlayerData.IsTrading then

        if not isDead then
        
            Wait(250)

            PlayerData.IsTrading       = true

            PlayerData.ItemData        = itemData
            
            TradingData.senderId       = sender_id
            TradingData.targetId       = target_id

            TradingData.senderUsername = senderUsername
            TradingData.targetUsername = targetUsername

            TradingData.cost           = cost
            TradingData.account        = account
            TradingData.quantity       = quantity

            local costDisplay          = Locales['SENT_ITEM_REQUEST_NO_COST']

            if cost > 0 then

                local accountType = ''

                if account == 0 then
                    accountType = 'DOLLARS'

                elseif account == 1 then
                    accountType = 'GOLD'
                end

                costDisplay = string.format(Locales['REQUEST_BY_SENDER_' .. accountType], cost)
            end

            SendNUIMessage(
                { 
                    action          = 'onInventoryGiveTransactionAwaiting', 
                    item_data       = itemData, 
                    sender_username = string.format(Locales['REQUEST_BY_SENDER'], senderUsername),
                    cost            = cost,
                    cost_display    = costDisplay,
                    count           = quantity,
                } 
            )
        
            Wait(250)
            ToggleUI(true)

            PlayerData.IsBusy = true

            TriggerEvent('tpz_inventory_trade:client:tasks')
        else

            local notifyData = Locales['CANNOT_REQUEST_WHILE_UNCONSCIOUS']
            TriggerServerEvent("tpz_notify:sendNotificationTo", sender_id, notifyData.title, string.format(notifyData.message, targetUsername), notifyData.icon, "error", notifyData.duration)

            TriggerServerEvent("tpz_inventory_trade:server:cancelTradeTransaction")
        end

    end

end)

AddEventHandler('tpz_inventory_trade:client:tasks', function()

    if loadedTasks then 
        return 
    end

    loadedTasks = true 

    Citizen.CreateThread(function()

        while PlayerData.IsBusy do 

            Wait(100)
            TriggerEvent('tpz_inventory:closePlayerInventory')
        end
    
    end)

end)
