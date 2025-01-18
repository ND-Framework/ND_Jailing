-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy"
description "Send players to jail"
version "1.0.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

files {
    "data/jobs.lua",
    "data/peds.lua"
}

shared_scripts {
    "@ox_lib/init.lua",
    "@ND_Core/init.lua"
}

server_scripts {
    "server/**"
}

client_scripts {
    "client/**"
}
