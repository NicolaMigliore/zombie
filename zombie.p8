pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- jack vs the apocalipse
-- by elfamir
#include scripts/main.lua
#include scripts/utils.lua
#include scripts/ui.lua
#include scripts/particles.lua

--scenes
#include scenes/title.lua
#include scenes/level.lua
#include scenes/death.lua
#include scenes/highscore.lua
#include scenes/title.lua

--ecs
#include ecs/components.lua
#include ecs/systems.lua
#include ecs/entities/camera.lua
#include ecs/entities/player.lua
#include ecs/entities/zombie.lua
#include ecs/entities/bullet.lua

__gfx__
00000000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700e000000e0000099999900000000009999990900000000000000000000000099999909000000099999909000000009999990900000000999999090000
00077000e000000e0000099999990900000009999999900000000999999090000000099999999000000099999999000000009999999900000000999999990000
00077000ee0deeee0000999ffff990000000999ffff9000000000999999990000000999ffff90000000999ffff900000000999ffff900000000999ffff900000
00700700ee00eeee000099ffffff0000000099ffffff00000000999ffff90000000099ffffff000000099ffffff0000000099ffffff0000000099ffffff00000
00000000eeeeeeee0000f9f7cf7cf0000000f9f7cf7cf000000099ffffff00000000f9f7cf7cf000000f9f7cf7cf0000000f9f7cf7cf0000000f9fffffff0000
00000000eeeeeeee0000fffffffff0000000fffffffff0000000f9f7cf7cf0000000fffffffff000000fffffffff0000000fffffffff0000000fffffffff0000
eeeeeeeeeeeeeeee00000fff77ff000000000fff77ff00000000fffffffff00000000fff77ff00000000fff77ff000000000fff77ff000000000fff77ff00000
eeeeee8eeee99eee000000fffff00000000000fffff0000000000ffff7ff0000000000fffff0000000000fffff00000000000fffff00000000000fffff006000
eeeee0e8ee9799ee00000447744000000000044774400000000000fffff000000000044774400000000004474400000000000044705550000000004470555600
eeee0ee8ee9999ee000040477404000000004047740400000000044774400000000040477404000000000447404000000000004444f000000000004444f06000
eee0eeeeee9799ee0000f047740f00000000f047740f0000000040477404000000005047740f00000000004f50f0000000000044700000000000004470000000
8e0eeeeeee9799ee000000cccc000000000000cccc0000000000f0cccc0f0000000050cccc000000000000cc50000000000000cccf000000000000cccf000000
e0eeeeeeee9999ee000000c00c000000000000c00c000000000000c00c000000000050c00c000000000000c0c0000000000000c0c0000000000000c0c0000000
eeeeeeeeeeeeeeee0000004004000000000000400400000000000040040000000000004004000000000000404000000000000040400000000000004040000000
00000000000000000000000000000000000000000000000000000999999000000000000000000000000000000000000000000000000000000000099999900000
00000000000000000000000000000000000000999999000000000999999909000000000000000000000000000000000000000099999900000000099999990900
0000009999990900000000000000000000000099999990900000999ffff990000000009999990900000000000000000000000099999990900000999ffff99000
0000009999999900000000099999909000000999ffff9900000099ffffff00000000009999999900000000000000000000000999ffff9900000099ffffff0000
00000999ffff900000000009999999900000099ffffff0000000f9f7cf7cf00000000999ffff900000000009999990900000099ffffff0000000f9f7cf7cf000
0000099ffffff000000000999ffff90000000f9f7cf7cf000000fffffffff0000000099ffffff000000000099999999000000f9f7cf7cf000000fffffffff000
00000f9f7cf7cf0000000099ffffff0000000fffffffff0000000fff77ff000000000f9f7cf7cf00000000999ffff90000000fffffffff0000000fff77ff0000
00000fffffffff00000000f9f7cf7cf0000000fff77ff000000000fffff0000000000fffffffff0000000099ffffff00000000fff77ff000000000fffff00000
000000fff77ff000000000fffffffff00000000fffff00000000004440000000000000fff77ff000000000f9f7cf7cf00000000fffff00000000004470000000
0000000fffff00000000000fff77ff00000000044700000000000d4474f000000000000fffff0000000000fffffffff00000000447000000000004447dd00000
000000444700000000000004fffff000000000d4470000000000d04470000000000000d4440000000000000fff77ff0000000044470000000000f04470000000
0000040447000000000000444700000000000d0447000000000000c4cdd0000000000d0444000000000000d4fffff00000000f0447000000000000d4ccc00000
00000f0447d00000000000f44700000000000004fd00000000004c00000d000000000d0444f00000000000d447000000000000044c0000000000dd0000040000
00000004ccc00000000000044c0000000000000c00d00000000000000000000000000004cdd0000000000000fc0000000000000d00c000000000000000000000
000000dd000400000000000dd0c000000000000c0d00000000000000000000000000004c000d000000000004c0d000000000000d040000000000000000000000
000000000000000000000000004000000000004000000000000000000000000000000000000000000000000000d00000000000d0000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00099999909000000000000000000000000000000000000000000000000000000000000000000000000009999990900000099999909000000000000000000000
00099999999000000099999909000000000000009999990900000000999999090000000099999909000009999999900000099999999000000099999909000000
00999ffff900000000999999990000000000000099999999000000009999999900000000999999990000999ffff9000000999ffff90000000099999999000000
0099ffffff0000000999ffff900000000000000999ffff900000000999ffff900000000999ffff90000099ffffff00000099ffffff0000000999ffff90000000
00f9f7cf7cf00000099ffffff0000000000000099ffffff0000000099ffffff0000000099ffffff00000f9f7cf7cf00000f9f7cf7cf00000099ffffff0000000
00fffffffff000000f9f7cf7cf0000000000000f9f7cf7cf0000000f9fffffff0000000f9f7cf7cf0000fffffffff00000fffffffff000000f9f7cf7cf000000
000fff77ff0000000fffffffff0000000000000fffffffff0000000fffffffff0000000fffffffff00000fff77ff0000000fff77ff0000000fffffffff000000
0000fffff000000000fff77ff000000000000000fff77ff000000000fff77ff000000000fff77ff0000000fffff000000000fffff000000000fff77ff0000000
0000047744400000000fffff00000000000000004fffff00000000044fffff00000000044fffff0000000447744000000000047744400000000fffff00000000
00004447700f0000000047744f0000000000000447400000000000f0444444f0000000f0444444f0000040477404000000004447700f0000500047744f000000
00004044770000000000447740000000000000044f400000000000044440070000000004444007000000f547740f000000004044770000000500447740000000
000f00cccc00000000f4004cc0000000000070ccc904f000000000ccc4007000000000ccc4000000000050cccc000000000f00cccc00000000f4044cc0000000
000000c00c000000000000cc0c00000000000c077c00000000000c000770000000000c000c070000000500c00c000000005000c00c000000000500cc0c000000
00000400040000000000040000400000000040004000000000004000400000000000400040000000005000400400000005000400040000000000040000400000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000660000000000000000000000000000000000000000000000000000000000033333300000000003333330000000000000000000000000033333300000
00000009996990900000009999990900000000999999090000000333333000000000333333330000000033333333000000000333333000000000333333330000
00000009999599900000009999999900000000999999990000003333333300000003333333333000000333333333300000003333333300000003333333333000
000000999f5ff90000000999ffff600000000999ffff6000000333333333300000033aa33333300000033aa333333000000333333333300000033aa333333000
00000099f5ffff000000099ffffff6000000099ffffff00000033aa33333300000033aa33aa3300000033aa33aa33000000333333333300000033aa33aa33000
000000f957cf7cf000000f9fffffff0000000f9f7cf7cf6000033aa33aa330000003333333333000000333333333300000033333333330000003333333333000
000000fffffffff000000fffffffff0000000fffffffff6000033333333330000003333333333000000333333333300000033aa33aa330000003333333333000
00000054ff77ff00000000fff77ff005000000fff77ff00500033333333330000000338883330000000033888333000000033333333330000000338883330000
00000004fffff0000000044fffff00500000044fffff005000003388833300000000033333300000000003333330000000003388833300000000033333300000
00000004700000000000f044440005000000f0444400050000000333333000000000023333200000000022333322000000000333333000000000003333000000
00000047744000000000044440405000000004444040500000000233332000000000202222020000000030222203000000000233332000000000022322000000
00000cccc04f00000000ccc4000f00000000ccc4000f000000002022220200000000302222030000000000222200000000002022220200000000002220230000
0000c000c0000000000c000c00500000000c000c0050000000003022220300000000002222000000000000222200000000003022220300000000002520000000
00040004000000000040004000000000004000400000000000000050050000000000005005000000000000500500000000000050050000000000000050000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000333333000000000000000000000000000000000000000000333333000000000000000000000000000000000000000000000000000000000000000000000
00003333333300000000000000000000000003333330000000003333333300000000000000000000000033333300000000333300000000000000000000000000
00033333333330000000033333300000000033333333000000033333333330000000033333300000000333333330000003333333000000000033330000000000
00033aa3333330000000333333330000000333333333300000033333333330000000333333330000003333333333000033333a33300000000333333300000000
00033aa33aa33000000333333333300000033aa33333300000033aa33aa3300000033aa3333330000033aa33333300003333a33330000000333a333330000000
000333333333300000033aa33aa3300000033aa33aa33000000333333333300000033aa33aa330000033aa33aa3300003333333333000000333a333330000000
00033333333330000003333333333000000333333333300000033333333330000003333333333000003333333333000033aa3333830000003333333833000000
00003388833300000003333333333000000333333333300000003388833300000003333333333000003333333333000033aa33383300000033aa338833000000
000003333330000000033333333330000000338883330000000003333330000000033333333330000003388833300000333333833300000033aa338833000000
00000033330000000000338883330000000003333330000000000033330000000000338883330000000033333300000003333333300000003333338333000000
00000223220000000000033333300000000000333300000000000222222300000000033333300000000022222200000000022222000000000333333330000000
00000022202300000000023333000000000002222223000000000023200000000000023333000000000020222200000000020222000000000002222200000000
00000022200000000000002322300000000000232000000000000022200000000000002320230000000003222230000000003222230000000020022220000000
00000022200000000000002220000000000000222500000000000022200000000000002220000000000000222200000000000022050000000003002235000000
00000005500000000000005050000000000000500000000000000050050000000000005050000000000000500500000000000500000000000000050000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006600333333000000000033333300000000003333330000000333333000000000000000000000000000000000000000000000000000000000000000000000
00060003333333300000000333333330000000033333333000003333333300000000033333300000000000000000000000000000000000000000000000000000
00600033333333330000003333333333000000333333333300033333333330000000333333330000000000000000000000000000000000000000000000000000
06000633333333330000003333333333000000333333333300033aa3333330000003333333333000000000003333330000000000000000000000000000000000
06006033aa33aa33000000333aa33aa3000000333aa33aa300033aa33aa33000000333aa33333000000000033333333000000000000000000000000000000000
0600003333333333000000333333333300000033363333330003333333333000000333aa33a33000000000333333333000000000000000000000000000000000
00000033388833330000003663888333000000333368833300033333333330000003333333333000000000333333333000000000000000000000000000000000
000003033888833000000063338888300000000333868830000033888333000000033333333330000000003333aa333000000000000000000000000000000000
000000203333330000000000233333000000000033363360000003333330000000003338883300000000003333aa333000000000000000000000000000000000
00000002233330000000000223333000000000022233300600003033333000000000033333300000000000338333330000000000033333000000000003333300
00000002222200000000000222220000000000022222000000000222220000000000303333300000000000233833300000000000333633300000000033333330
00000022222000000000002222200000000000222220000000000022200000000000022222000000000002223383000000000003363336330000000333333333
00000022250000000000002222000000000000222200000000000022200000000000002220000000000002322000000000003003336363330000300333333333
000005000000000000000500050000000000050005000000000000505000000000000022200000000005222200000000050000033836a33305222223383aa333
00000000aaaaa5a0155555510000000066666666e555555ee5e5e5e500070000eeeeeeee0000000000000000000000000000000067000000ee67777777777777
00000000aaaa5a5a55555555000000006666666655555555e5e5e5e500000000555555550000000000000000000000000000000067000000e666666666666666
00000000aaaaaaa0555555550000000066666666e565665ee5e5e5e500000000e565665e00000000000000000000000000000000670000006700000000000000
00000000aaaa5a5a555555557770000766666666e565665e5e5e5e5e00000000e565665e00000000000000000000000000000000670000006700000000000000
00000000aaaaa5a0555555550000000066666666e565665e5e5e5e5e00000000e565665e00000000000000000000000000000000670000006700000000000000
00000000aaaa5a5a555555550000000066666666e565665e5e5e5e5e00070000e565665e00000000000000000000000000000000670000006700000000000000
00000000aaaaaaa0555555550000000077777777e565665e5e5e5e5e00070000e565665e00000000000000000000000000000000670000006700000000000000
00000000aaaa5a5a155555510000000055555555ee5555eee5e5e5e500070000ee5555ee00000000000000000000000000000000670000006700000000000000
eeeeeeee009999000555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006700000000000000
ee8888ee09999990566bb66500000000000000000000000000000000000000000000000000000000000000000000000000000000000000006700000000000000
e88888ee99999999566bb66500000000000000000000000000000000000000000000000000000000000000000000000000000000000000006700000000000000
e888828e999999995bbbbbb500000000000000000000000000000000000000000000000000000000000000000000000000000000000000006700000000000000
e888888e099999905bbbbbb500000000000000000000000000000000000000000000000000000000000000000000000000000000000000006700000000000000
e88888ee00999900566bb66500000000000000000000000000000000000000000000000000000000000000000000000000000000000000006600000000000000
ee888eee00099000566bb6650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e667777777777777
ee222eee00090000055555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee66666666666666
0000000000000000000000000000000000000000000000000800000000000080000000000000000000000000000000000000000000000000ee77777777777777
0000000000000000000000000000000000000000000000000008080f00800808000000000000000000000000000000000000000000000000e666666666666666
00000000000000000000000000000000000000000000000000078840080700000000000000000000000000000000000000000000000000006600000000000000
000000000000000000000000000000000000000000000000404070000048700f000000000000000000000000000000000000000000000000600bbbbbbbbbbbbb
00000000000000000000000000000000000000000000000040477400004774040000000000000000000000000000000000000000000000006011333333333333
000000000000000000000000000000000000000000000000f0cccc0040cccc400000000000000000000000000000000000000000000000006001111111111111
00000000000000000000000000000000000000000000000000c00c0004c00c000000000000000000000000000000000000000000000000006600000000000000
00000000000000000000000000000000000000000000000000400400f0400400000000000000000000000000000000000000000000000000e667777777777777
00000800000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000008080f00000000008008080000000000080800000000080800000000000000000000000000000000000000000000000000000000000000000000000000
00000007884000000000080700000000000000800080000000800080000000800000000000000000000000000000000000000000000000000000000000000000
000040407000000000000048700f0000000000070800000000070800000800000000000000000000000000000000000000000000000000000000000000000000
00004047740000000000004774040000000080407000000080407000080008800000000000000000000000000000000000000000000000000000000000000000
0000f0cccc000000000040cccc400000000000477480000000477480080708000000000000000000000000000000000000000000000000000000000000000000
000000c00c000000000004c00c000000000000cccc04000000cccc04004870040000000000000000000000000000000000000000000000000000000000000000
00000040040000000000f040040000000000f4c00c400000f4c00c40f48774480000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000c0c1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000c0c1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c0c0c0c0c0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c0c1c0c0c1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c0c1c0c0c1c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c0c0c0c0c0c0000000c0c0c0c0c0c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c0c0c0c0c1c0000000c0c1c0c1c0c1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c0c2c0c0c1c0000000c0c1c0c1c0c1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000c50000000000000000000000c0c2c0c0c0c0c6c6c6c0c0c0c0c0c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c4c4c4c4c4c4c4c4c4c4c4c4c4c4c4c40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000c3c3c3c3c3c3c3c3c3c3c3c3c3c3c3c30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00100010117501175011750117501175011750137501375016750167500c7500c7500c75027000270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010001029104291003510029104291001f1001f1001f10429104291003510029104291001f1001f1001f10400000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600002205122051220542705627056270541f0002b0512b0512e0542e055290002700027000290002900024000250002500027000290002a00000000000000000000000000003000031000320003400035000
000400003a6253a62535634356343a6353a63535624356243a6253a63500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001f0552205522054350543a0552905529054290543005530055030050a0050a005330053a0053a005000051f0051d0051d005240051d0051d0051d0051d0051b0051b0050000500005000050000500005
010200000f6530f6530f6430f6450f6350f6350763507625006250061524600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000500001b6041b6041b6111b6211b6211f6311f6311f6211f6230f6531f6001e600006000060000600006001d6001d6001d6001d6001d6001d60000600006000060000600006000060000600006000060000600
000200003f6533f6533f6321963519600186001860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0103000023150261501b1002b1501b1001f1011f1011f1011f1030f10300100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
01030000171501a1501b1001f15500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 40414344

