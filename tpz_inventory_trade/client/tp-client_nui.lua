local Cooldown = false -- Cooldown is required to prevent players do multiple clicks within a second and cause a glitch.

-----------------------------------------------------------
--[[ Base Events ]]--
-----------------------------------------------------------

RegisterNetEvent('tpz_inventory_trade:close')
AddEventHandler('tpz_inventory_trade:close', function()
    CloseUI()
end)

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

ToggleUI = function(display)
    
    SetNuiFocus(display,display)

    SendNUIMessage({ action = 'toggle', toggle = display })
end

CloseUI = function()
    SendNUIMessage({action = 'close'})
end

-----------------------------------------------------------
--[[ NUI Callbacks ]]--
-----------------------------------------------------------

-- After the sender selects the cost and the account type, we send a trading process to the target.
RegisterNUICallback('startTradingProcess', function(data)
    local PlayerData     = GetPlayerData()
    local TradingData    = GetTradingData()
    
    TradingData.quantity = tonumber(data.quantity)
    TradingData.cost     = tonumber(data.cost)
    TradingData.account  = tonumber(data.account)

    TriggerServerEvent('tpz_inventory_trade:server:requestTargetTradingProcessResponse', TradingData.targetId, PlayerData.ItemData, tonumber(data.cost), tonumber(data.account), tonumber(data.quantity) )

    PlayerData.IsBusy = true
    CloseUI()
end)

-- The specified NUI Callbacks is when the sender is cancelling the process in case the player regret or added wrong item.
RegisterNUICallback('cancelTradingProcess', function(data)

    ResetTradingData()
    ResetPlayerData()

    local notifyData = Locales['CANCELLED_TRADING_PROCESS']
    TriggerEvent("tpz_notify:sendNotification", notifyData.title, notifyData.message, notifyData.icon, "error", notifyData.duration)

    CloseUI()
end)

-- The specified NUI Callback is when the target player accepts the trading process to pay and receive the item, weapon or money.
RegisterNUICallback('accept', function()
    local PlayerData  = GetPlayerData()
    local TradingData = GetTradingData()

    if Cooldown then
        return
    end

    Cooldown = true

    TriggerServerEvent("tpz_inventory_trade:server:onServerTradingAccept", PlayerData.ItemData, TradingData.senderId, TradingData.cost, TradingData.account, tonumber(TradingData.quantity))
    
    local notifyData = Locales['PLAYER_ACCEPTED_TRADE']
    TriggerEvent("tpz_notify:sendNotification", notifyData.title, string.format(notifyData.message, TradingData.targetUsername), notifyData.icon, "success", notifyData.duration)

    PlayerData.IsBusy = false
    CloseUI()

    Wait(4000)
    Cooldown = false
end)

-- The specified NUI Callback is when the target player cancels the trading process for any reason.
RegisterNUICallback('decline', function()
    local PlayerData  = GetPlayerData()
    local TradingData = GetTradingData()
    
    local notifyData = Locales['PLAYER_DECLINED_TRADE']
    TriggerEvent("tpz_notify:sendNotification", notifyData.title, string.format(notifyData.message, TradingData.targetUsername), notifyData.icon, "error", notifyData.duration)

    TriggerServerEvent("tpz_inventory_trade:server:cancelTradeTransaction")

    PlayerData.IsBusy = false

    CloseUI()
end)

-- Closing the NUI Window.
RegisterNUICallback('close', function()
	ToggleUI(false)
end)
