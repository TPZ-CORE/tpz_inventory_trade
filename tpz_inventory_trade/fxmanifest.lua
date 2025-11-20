fx_version "adamant"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Nosmakos'
description 'TPZ-CORE - Inventory Trading (Money, Items & Weapons)'
version '1.0.1'

ui_page 'html/index.html'

shared_scripts { 'config.lua', 'locales.lua'   }
client_scripts { 'client/*.lua' }
server_scripts { 'server/*.lua' }

files { 'html/**/*' }

dependency { 'tpz_core', 'tpz_characters', 'tpz_inventory', 'tpz_notify' }