fx_version "bodacious"
game "gta5"
lua54 "yes"

author "Fafnir Solutions | https://discord.gg/dRg5grEZFc"
description "Hud Free"

ui_page "web/index.html"

shared_scripts {
	"shared/*"
}

client_scripts {
	"@vrp/config/Native.lua",
	"@vrp/config/Item.lua",
	"@vrp/lib/Utils.lua",
	"client/*"
}

server_scripts {
	"@vrp/config/Item.lua",
	"@vrp/lib/Utils.lua",
	"server/*"
}

files {
	"web/*",
	"web/**/*"
}