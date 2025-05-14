Config = {}

---------------------------------------------------------------
--[[ General Settings ]]--
---------------------------------------------------------------

-- Time is in seconds (How long should the trading be active without actions)
-- If it will reach the maximum trading duration, it will automatically close it.
Config.TradingDuration = 30

-- The accounts are for safety reasons, 0 returns cash, 1 returns gold (2 returns blackmoney but its not enabled by default)
Config.Accounts = { 0, 1 }

---------------------------------------------------------------
--[[ Webhooks ]]--
---------------------------------------------------------------

Config.Webhooks = {
    
    ['DEVTOOLS_INJECTION_CHEAT'] = { -- Warnings and Logs about players who used or atleast tried to use devtools injection.
        Enabled = false, 
        Url = "", 
        Color = 10038562,
    },

    ['TRADING_TRANSFER_SUCCESS'] = {
        Enabled = false, 
        Url = "", 
        Color = 10038562,
    },

}