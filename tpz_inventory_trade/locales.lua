Locales = {}

Locales = {

    ['REQUEST_BY_SENDER']                       = "Request Sent By %s",
    ['SENT_ITEM_REQUEST_NO_COST']               = 'The specified item does not have any cost required.',
   
    ['DIALOG_INPUT_REQUIRED_ITEM_QUANTITY']     = "How much quantity would you like to give?",
    ['DIALOG_INPUT_REQUIRED_READABLE_QUANTITY'] = "The quantity is only readable.",
    ['DIALOG_INPUT_REQUIRED_MONEY_QUANTITY']    = "How much money would you like to give?",
    ['DIALOG_INPUT_REQUIRED_ACCOUNT_COST']      = "What is the cost and the account for the player pay to?",
   
    ['DEVTOOLS_INJECTION_DETECTED_TITLE_LOG']   = "DevTools / Injection Cheat Found!",
    ['DEVTOOLS_INJECTION_DETECTED']             = "You have been kicked due to cheating by using DevTools or Injection cheat.",

    ['REQUEST_BY_SENDER_DOLLARS']               = "The cost is %s $Dollars.",
    ['REQUEST_BY_SENDER_GOLD']                  = "The cost is %s Gold Coins.",

    -- ACCOUNTS
    [0] = 'Dollars',
    [1] = 'Gold',
    [2] = 'Black Money',

    -- TPZ NOTIFY
    ['TARGET_ALREADY_ON_TRADING_TRANSACTION'] = {
        title = "Trading", 
        message = "The trading request has been rejected, the target has already a trading transaction active.",
        icon = "trading",
        duration = 5
    },

    ['NOT_ENOUGH_QUANTITY'] = {
        title   = "Trading",
        message = "The trading request has been rejected, you don't have enough of the input quantity.",
        icon = "trading",
        duration = 5
    },

    ['CANCELLED_TRADING_PROCESS'] = { 
        title = "Trading", 
        message = "You have cancelled the trading process.",
        icon = "trading",
        duration = 5
    },

    ['PLAYER_ACCEPTED_TRADE'] = { 
        title = "Trading", 
        message = "%s has accepted your trading request.",
        icon = "trading",
        duration = 5
    },

    ['PLAYER_DECLINED_TRADE'] = { 
        title = "Trading", 
        message = "%s has declined your trading request.",
        icon = "trading",
        duration = 5
    },

    ['TIME_OUT'] = {
        title = "Trading", 
        message = "The trading request has been automatically cancelled, timed out.",
        icon = "trading",
        duration = 5
    },

    ['CANNOT_REQUEST_WHILE_UNCONSCIOUS' ] = {
        title   = "Trading",
        message = "You cannot request for trade while this person is unconscious.",
        icon = "trading",
        duration = 5
    },

    ['NOT_ENOUGH_MONEY' ] = {
        title   = "Trading",
        message = "Your trading request has been cancelled, this person does not have enough money.",
        target_message = "The trading request has been cancelled, you don't have enough money.",
        icon = "trading",
        duration = 5
    },

    ['NOT_ENOUGH_INVENTORY_WEIGHT' ] = {
        title   = "Trading",
        message = "Your trading request has been cancelled, this person does not have enough inventory weight space.",
        target_message = "The trading request has been cancelled, you don't have enough inventory weight space.",
        icon = "trading",
        duration = 5
    },

    ['TRADE_SUCCESSFULL' ] = {
        title   = "Trading",
        message = "The transaction has been successfully completed.",
        icon = "trading",
        duration = 5
    },
}