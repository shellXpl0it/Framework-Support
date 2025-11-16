fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
node_version '22'
games { 'gta5' }
description 'Framework Support Menu for Entys Framework'

name 'framework-support'
author 'Arctis'
version '1.0.0'
license 'Proprietary'
repository 'https://github.com/shellxpl0it/framework-support'
description 'A support tool for server administration.'

dependencies { '/server:7290', '/onesync', 'ox_lib' }

server_scripts { '@ox_lib/init.lua', 'server/**/*' }
shared_scripts { '@ox_lib/init.lua', 'shared/**/*' }
client_scripts { 'client/**/*' }