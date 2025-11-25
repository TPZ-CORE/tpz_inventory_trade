

local TPZ = exports.tpz_core:getCoreAPI()

local TransactionsList = {}

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

-- @GetTableLength returns the length of a table.
local function GetTableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local function GetPlayerData(source)
	local _source = source
  local xPlayer = TPZ.GetPlayer(_source)

	return {
    steamName      = GetPlayerName(_source),
    username       = xPlayer.getFirstName() .. ' ' .. xPlayer.getLastName(),
    identifier     = xPlayer.getIdentifier(),
    charIdentifier = xPlayer.getCharacterIdentifier(),
	}

end

local function DoesAccountExist(accountInput)

  for _, account in pairs (Config.Accounts) do

    if accountInput == account then
      return true
    end

  end

  return false

end


local function DoesPlayerHasTransactionActive(inputSource)

  if GetTableLength(TransactionsList) <= 0 then
    return false, nil
  end

  for _, transaction in pairs (TransactionsList) do

    if transaction.senderId == inputSource or transaction.targetId == inputSource then

      return true, transaction.id

    end

  end

  return false, nil


end

-----------------------------------------------------------
--[[ Base Events ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end


  TransactionsList = nil -- clearing all data
end)

-----------------------------------------------------------
--[[ General Events ]]--
-----------------------------------------------------------

-- The following event is called to set the player busy status as true / false.
RegisterServerEvent("tpz_inventory_trade:setPlayerStatus")
AddEventHandler("tpz_inventory_trade:setPlayerStatus", function(targetId, cb)
  targetId = tonumber(targetId)

  TriggerClientEvent("tpz_inventory_trade:client:setPlayerBusy", targetId, cb)
end)

RegisterServerEvent("tpz_inventory_trade:server:cancelTradeTransaction")
AddEventHandler("tpz_inventory_trade:server:cancelTradeTransaction", function()
  local _source = source

  local hasTransactionActive, transactionId = DoesPlayerHasTransactionActive(_source)

  if not hasTransactionActive then
    return
  end

  local TransactionData = TransactionsList[transactionId]

  TriggerClientEvent("tpz_inventory_trade:client:setPlayerBusy", TransactionData.senderId, false)
  TriggerClientEvent("tpz_inventory_trade:client:setPlayerBusy", TransactionData.targetId, false)

  TransactionsList[transactionId] = nil

end)

-- The following event is called and used after the sender accepts and wants to start a trade with the selected target.
-- At the same time the event is also sending credentials.
RegisterServerEvent('tpz_inventory_trade:server:requestTargetTradingProcessResponse')
AddEventHandler('tpz_inventory_trade:server:requestTargetTradingProcessResponse', function(id, itemData, cost, account, quantity)

  local _source        = source
  local _tsource       = tonumber(id)

  local xPlayer        = TPZ.GetPlayer(_source)

  if xPlayer.hasLostConnection() then
    return 
  end
		
  local senderUsername = xPlayer.getFirstName() .. " " .. xPlayer.getLastName() -- sender username.

  local tPlayer        = TPZ.GetPlayer(_tsource)
  local hasTargetTransactionActive, targetTransactionId = DoesPlayerHasTransactionActive(_tsource)

  -- We check if the target has already another trade transaction active, we don't want the players to glitch or bug the trading.
  -- We also prevent it from running and we set the busy state to false for the sender.
  if hasTargetTransactionActive then
    TriggerClientEvent("tpz_inventory_trade:client:setPlayerBusy", _source, false)

    local NotifyData = Locales['TARGET_ALREADY_ON_TRADING_TRANSACTION']
    TriggerClientEvent("tpz_notify:sendNotification", _source, NotifyData.title, NotifyData.message, NotifyData.icon, "error", NotifyData.duration)

    return
  end
  
  if itemData.type == 'item' then
    local currentSenderItemQuantity = xPlayer.getItemQuantity(itemData.item)

    if currentSenderItemQuantity == nil or currentSenderItemQuantity < quantity then
  
      TriggerClientEvent("tpz_inventory_trade:client:setPlayerBusy", _source, false)
  
      local NotifyData = Locales['NOT_ENOUGH_QUANTITY']
      TriggerClientEvent("tpz_notify:sendNotification", _source, NotifyData.title, NotifyData.message, NotifyData.icon, "error", NotifyData.duration)
  
      return
    end

  elseif itemData.type == 'money' or itemData.type == 'gold' or itemData.type == 'blackmoney' then

    local doesSenderHaveMoney = false

    if itemData.type == 'money' then

      local currentSenderMoney = xPlayer.getAccount(0)
  
      if quantity <= currentSenderMoney then
        doesSenderHaveMoney = true
      end
  
    elseif itemData.type == 'gold' then
  
      local currentSenderGold = xPlayer.getAccount(1)
  
      if quantity <= currentSenderGold then
        doesSenderHaveMoney = true
      end
  
    elseif itemData.type == 'blackmoney' then
  
      local currentSenderBlackMoney = xPlayer.getAccount(2)
  
      if quantity <= currentSenderBlackMoney then
        doesSenderHaveMoney = true
      end

    end

    if not doesSenderHaveMoney then

      TriggerClientEvent("tpz_inventory_trade:client:setPlayerBusy", _source, false)

      local NotifyData = Locales['NOT_ENOUGH_MONEY']
      TriggerClientEvent("tpz_notify:sendNotification", _source, NotifyData.title, NotifyData.target_message, NotifyData.icon, "error", NotifyData.duration)
      return
    end

  end

  local targetUsername = tPlayer.getFirstName() .. " " .. tPlayer.getLastName() -- target username

  local generatedTransactionId = os.date('%H'), os.date('%M'), os.date('%S')
  
  TransactionsList[generatedTransactionId] = { 
    id        = generatedTransactionId, 
    senderId  = _source, 
    targetId  = _tsource, 
    cooldown  = Config.TradingDuration,
    triggered = false,
  }

  TriggerClientEvent('tpz_inventory:closePlayerInventory', _tsource)

  TriggerClientEvent('tpz_inventory_trade:client:startTargetTradingProcess', _tsource, _source, _tsource, targetUsername, senderUsername, itemData, cost, account, quantity)
end)

-- The following event is called when the target accepts the trade and the system checks
-- if the target has enough money and enough weight to accept it.
RegisterServerEvent("tpz_inventory_trade:server:onServerTradingAccept")
AddEventHandler("tpz_inventory_trade:server:onServerTradingAccept", function(itemData, senderId, cost, account, quantity)
  local target_source = source -- target source
  local sender_source = tonumber(senderId) -- sender source

  math.randomseed(os.time()) -- diffenet cooldown for netbug
  Wait(500, 1000) -- diffenet cooldown for netbug

  local xPlayer = TPZ.GetPlayer(target_source)
  local sPlayer = TPZ.GetPlayer(sender_source)
		
  if xPlayer.hasLostConnection() then
    return 
  end
		
  account = tonumber(account)

  local accountExist = DoesAccountExist(account)
  local targetHasTransactionActive, targetTransactionId = DoesPlayerHasTransactionActive(target_source)
  local senderHasTransactionActive, senderTransactionId = DoesPlayerHasTransactionActive(sender_source)

  if ( target_source == sender_source ) or ( not targetHasTransactionActive ) or ( not senderHasTransactionActive ) or ( targetTransactionId ~= senderTransactionId ) or ( not accountExist ) or (itemData.type == nil ) or (itemData.type == 'weapon' and itemData.itemId == nil) then

    if Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Enabled then

      local TargetPlayerData = GetPlayerData(target_source)

      local _w, _c      = Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Url, Config.Webhooks['DEVTOOLS_INJECTION_CHEAT'].Color
      local description = 'The specified user attempted to use devtools / injection or netbug cheat on inventory trading.'

      -- Target Source
      TPZ.SendToDiscordWithPlayerParameters(_w, Locales['DEVTOOLS_INJECTION_DETECTED_TITLE_LOG'], target_source, TargetPlayerData.steamName, TargetPlayerData.username, TargetPlayerData.identifier, TargetPlayerData.charIdentifier, description, _c)
      
      -- Sender Source
      if target_source ~= sender_source then
        local SenderPlayerData = GetPlayerData(sender_source)

        TPZ.SendToDiscordWithPlayerParameters(_w, Locales['DEVTOOLS_INJECTION_DETECTED_TITLE_LOG'], sender_source, SenderPlayerData.steamName, SenderPlayerData.username, SenderPlayerData.identifier, SenderPlayerData.charIdentifier, description, _c)
      end
    end

    TransactionsList[targetTransactionId] = nil
    TransactionsList[senderTransactionId] = nil

    xPlayer.ban(Locales['DEVTOOLS_INJECTION_DETECTED'], -1)

    if target_source ~= sender_source then
      sPlayer.ban(Locales['DEVTOOLS_INJECTION_DETECTED'], -1)
    end

    return
  end

  if TransactionsList[targetTransactionId].triggered then -- a protection for ethernet cable dup.
    return
  end
  
  TransactionsList[targetTransactionId].triggered = true

  local doesSenderHaveItemQuantity = false

  -- Checking if the player sends money or item, to see if indeed the player has the input quantity based on the type.
  if itemData.type == 'money' then

    local currentSenderMoney = sPlayer.getAccount(0)

    if quantity <= currentSenderMoney then
      doesSenderHaveItemQuantity = true
    end

  elseif itemData.type == 'gold' then

    local currentSenderGold = sPlayer.getAccount(1)

    if quantity <= currentSenderGold then
      doesSenderHaveItemQuantity = true
    end

  elseif itemData.type == 'blackmoney' then

    local currentSenderBlackMoney = sPlayer.getAccount(2)

    if quantity <= currentSenderBlackMoney then
      doesSenderHaveItemQuantity = true
    end

  else -- checking items or weapons

    local currentSenderItemQuantity = sPlayer.getItemQuantity(itemData.item)

    if currentSenderBlackMoney and quantity <= currentSenderItemQuantity then
      doesSenderHaveItemQuantity = true
    end

  end

  -- Checking if the target source has the required account money
  local currentMoney = xPlayer.getAccount(account)

  if currentMoney < cost then

    local NoMoneyNotify = Locales['NOT_ENOUGH_MONEY']

    TriggerClientEvent("tpz_notify:sendNotification", target_source, NoMoneyNotify.title, NoMoneyNotify.target_message, NoMoneyNotify.icon, "error", NoMoneyNotify.duration)
    TriggerClientEvent("tpz_notify:sendNotification", sender_source, NoMoneyNotify.title, NoMoneyNotify.message, NoMoneyNotify.icon, "error", NoMoneyNotify.duration)

    TriggerClientEvent("tpz_inventory_trade:client:setPlayerBusy", target_source, false)
    TriggerClientEvent("tpz_inventory_trade:client:setPlayerBusy", sender_source, false)

    TransactionsList[targetTransactionId] = nil

    return
  end

  local canCarry  = true

  if itemData.type == "item" then
    canCarry = xPlayer.canCarryItem(itemData.item, quantity)

  elseif itemData.type == "weapon" then
    canCarry = xPlayer.canCarryWeapon(itemData.item)
  end

  -- check for netbug (add item or money or weapon to list, or player because he cannot do another trade within 5 seconds that fast, not even 10 seconds.)
  Wait(500)

  if not canCarry then

    local nNoWeightData = Locales['NOT_ENOUGH_INVENTORY_WEIGHT']
    TriggerClientEvent("tpz_notify:sendNotification", target_source, nNoWeightData.title, nNoWeightData.target_message, nNoWeightData.icon, "error", nNoWeightData.duration)
    TriggerClientEvent("tpz_notify:sendNotification", sender_source, nNoWeightData.title, nNoWeightData.message, nNoWeightData.icon, "error", nNoWeightData.duration)

    TriggerClientEvent("tpz_inventory_trade:client:setPlayerBusy", target_source, false)
    TriggerClientEvent("tpz_inventory_trade:client:setPlayerBusy", sender_source, false)

    TransactionsList[targetTransactionId] = nil

    return
  end

  local TargetPlayerData = GetPlayerData(target_source)
  local SenderPlayerData = GetPlayerData(sender_source)

  local webhookDescription = string.format("**Online Player Sender ID:** `%s`\n**Sender Steam Name:** `%s`\n**Sender First & Last Name**: `%s`\n**Sender Steam Identifier:** `%s`\n**Sender Character Id:** `%s`\n\n**Online Player Target ID:** `%s`\n**Target Steam Name:** `%s`\n**Target First & Last Name**: `%s`\n**Target Steam Identifier:** `%s`\n**Target Character Id:** `%s`\n\n**Description:**\n", sender_source, SenderPlayerData.steamName, SenderPlayerData.username, SenderPlayerData.identifier, SenderPlayerData.charIdentifier, target_source, TargetPlayerData.steamName, TargetPlayerData.username, TargetPlayerData.identifier, TargetPlayerData.charIdentifier)

  if itemData.type == "item" then
      
    sPlayer.removeItem(itemData.item, quantity, itemData.itemId)
    xPlayer.addItem(itemData.item, quantity, itemData.metadata)

    local itemLabel = exports.tpz_inventory:getInventoryAPI().getItemLabel(itemData.item)

    webhookDescription = webhookDescription .. string.format('The target player received **X%s %s** and paid **%s %s** for the transaction.', quantity, itemLabel, cost, Locales[tonumber(account)])

  elseif itemData.type == "weapon" then

    sPlayer.removeWeapon(itemData.item, itemData.itemId)
    xPlayer.addWeapon(itemData.item, itemData.itemId, itemData.metadata)

    local weaponLabel = exports.tpz_inventory:getInventoryAPI().getWeaponLabel(itemData.item)

    webhookDescription = webhookDescription .. string.format('The target player received **X1 %s** and paid **%s %s** for the transaction.', weaponLabel, cost, Locales[tonumber(account)])
     
  elseif itemData.type == "money" or itemData.type == "gold" or itemData.type == "blackmoney" then

    local accountRewardType = 0 -- cash by default

    if itemData.type == 'money' then

      webhookDescription = webhookDescription .. string.format('The target player received **%s Dollars** and paid **%s %s** for the transaction.', quantity, cost, Locales[tonumber(account)])

    elseif itemData.type == 'gold' then
      accountRewardType = 1

      webhookDescription = webhookDescription .. string.format('The target player received **%s Gold** and paid **%s %s** for the transaction.', quantity, cost, Locales[tonumber(account)])

    elseif itemData.type == 'blackmoney' then
      accountRewardType = 2
      
      webhookDescription = webhookDescription .. string.format('The target player received **%s Blackmoney** and paid **%s %s** for the transaction.', quantity, cost, Locales[tonumber(account)])
    end

    xPlayer.addAccount(accountRewardType, quantity)
    sPlayer.removeAccount(accountRewardType, quantity)

  end

  if cost ~= 0 then
    xPlayer.removeAccount(account, cost)
    sPlayer.addAccount(account, cost)
  end

  local successNotify = Locales['TRADE_SUCCESSFULL']
  TriggerClientEvent("tpz_notify:sendNotification", target_source, successNotify.title, successNotify.message, successNotify.icon, "success", successNotify.duration)
  TriggerClientEvent("tpz_notify:sendNotification", sender_source, successNotify.title, successNotify.message, successNotify.icon, "success", successNotify.duration)

  -- We reset listed players (sender and target) and we also set their busy status state as false.
  TransactionsList[targetTransactionId] = nil

  TriggerClientEvent("tpz_inventory_trade:client:setPlayerBusy", target_source, false)
  TriggerClientEvent("tpz_inventory_trade:client:setPlayerBusy", sender_source, false)
  
  if Config.Webhooks['TRADING_TRANSFER_SUCCESS'].Enabled then

    local TargetPlayerData = GetPlayerData(target_source)

    local _w, _c = Config.Webhooks['TRADING_TRANSFER_SUCCESS'].Url, Config.Webhooks['TRADING_TRANSFER_SUCCESS'].Color

    TPZ.SendToDiscord(_w, 'Trading Transactions', webhookDescription, _c)

  end

end)

-----------------------------------------------------------
--[[ Threads ]]--
-----------------------------------------------------------

-- The specified thread in server is removing a cooldown from active transactions as a timeout system.
Citizen.CreateThread(function ()
  while true do
    Wait(1000)
      
    if TransactionsList and GetTableLength(TransactionsList) > 0 then
        
      for index, transaction in pairs (TransactionsList) do 

        transaction.cooldown = transaction.cooldown - 1

        if transaction.cooldown <= 0 then

          local notifyData = Locales['TIME_OUT']

          TriggerClientEvent("tpz_notify:sendNotification", transaction.targetId, notifyData.title, notifyData.message, notifyData.icon, "error", notifyData.duration)
          TriggerClientEvent("tpz_notify:sendNotification", transaction.senderId, notifyData.title, notifyData.message, notifyData.icon, "error", notifyData.duration)

          TriggerClientEvent("tpz_inventory_trade:client:setPlayerBusy", transaction.targetId, false)
          TriggerClientEvent("tpz_inventory_trade:client:setPlayerBusy", transaction.senderId, false)

          TransactionsList[transaction.id] = nil

        end

      end

    end

  end

end)

