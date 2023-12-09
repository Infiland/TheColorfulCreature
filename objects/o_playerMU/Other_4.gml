multiplayerplayerskin = global.multiplayerplayerskin[multiplayerplayer-1]
multiplayerplayerhat = global.multiplayerplayerhat[multiplayerplayer-1]
multiplayerplayeritem = global.multiplayerplayeritem[multiplayerplayer-1]

//Skins
switch(multiplayerplayerskin) {
case 14: sprite_index = s_kindadeadplayerskin break;
case 23: sprite_index = s_forseneplayerskin break;
case 24:
xchange += 16
ychange += 16
x += xchange
y += ychange
sprite_index = s_redballplayerskin
break;
case 26: sprite_index = s_hitboxplayerskin break;
case 27: sprite_index = s_metallicplayerskin break;
case 28: sprite_index = s_playerred break;
case 29: sprite_index = s_japaneseplayerskin break;
case 31: sprite_index = s_upsidedownplayerskin break;
case 36: sprite_index = s_arrowplayerskin break;
case 37: sprite_index = s_spikeplayerskin break;
case 38: sprite_index = s_splitplayerskin break;
}