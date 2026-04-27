script_name('ImGui Scoreboard Enhanced')
script_description('ImGui SA:MP Scoreboard - Editie Imbunatatita cu Teme Multiple')
script_dependencies('SAMPFUNCS', 'Dear ImGui')
script_moonloader(025)

require 'moonloader'
require 'SAMPFUNCS'
local imgui = require 'imgui'
local notf
if doesFileExist(getWorkingDirectory() .. "\\imgui_notf.lua") then
	notf = import 'imgui_notf.lua'
end
local vkeys = require 'vkeys'
local bitex = require 'bitex'
local SE = require 'lib.samp.events'
local memory = require 'memory'
local encoding = require 'encoding'
local inicfg = require 'inicfg'
u8 = encoding.UTF8
encoding.default = 'CP1251'

local russian_characters = {
	[168] = '', [184] = '', [192] = '', [193] = '', [194] = '', [195] = '', [196] = '', [197] = '', [198] = '', [199] = '', [200] = '', [201] = '', [202] = '', [203] = '', [204] = '', [205] = '', [206] = '', [207] = '', [208] = '', [209] = '', [210] = '', [211] = '', [212] = '', [213] = '', [214] = '', [215] = '', [216] = '', [217] = '', [218] = '', [219] = '', [220] = '', [221] = '', [222] = '', [223] = '', [224] = '', [225] = '', [226] = '', [227] = '', [228] = '', [229] = '', [230] = '', [231] = '', [232] = '', [233] = '', [234] = '', [235] = '', [236] = '', [237] = '', [238] = '', [239] = '', [240] = '', [241] = '', [242] = '', [243] = '', [244] = '', [245] = '', [246] = '', [247] = '', [248] = '', [249] = '', [250] = '', [251] = '', [252] = '', [253] = '', [254] = '', [255] = '',
}
local quitReason = {
  "a iesit / s-a blocat",
  "a parasit jocul",
  "dat afara / banat"
}

-- ============================================================
-- SISTEM DE TEME IMBUNATATIT - Teme Multiple Incorporate
-- ============================================================
local builtInThemes = {
	["Classic Gold"] = {
		colors = {
			[1] = imgui.ImColor(240, 240, 240, 240):GetU32(),
			[3] = imgui.ImColor(15, 15, 10, 235):GetU32(),
			[8] = imgui.ImColor(210, 180, 0, 100):GetU32(),
			[6] = imgui.ImColor(120, 100, 50, 150):GetU32(),
			[9] = imgui.ImColor(210, 180, 0, 160):GetU32(),
			[10] = imgui.ImColor(210, 180, 0, 80):GetU32(),
			[12] = imgui.ImColor(140, 120, 0, 240):GetU32(),
			[23] = imgui.ImColor(180, 150, 0, 180):GetU32(),
			[24] = imgui.ImColor(200, 170, 0, 120):GetU32(),
			[25] = imgui.ImColor(160, 130, 0, 100):GetU32(),
			[26] = imgui.ImColor(180, 160, 100, 60):GetU32(),
			[27] = imgui.ImColor(200, 180, 120, 80):GetU32(),
			[28] = imgui.ImColor(160, 140, 80, 40):GetU32()
		},
		accent = {210, 180, 0}
	},
	["Neon Blue"] = {
		colors = {
			[1] = imgui.ImColor(230, 245, 255, 245):GetU32(),
			[3] = imgui.ImColor(5, 15, 30, 240):GetU32(),
			[8] = imgui.ImColor(0, 150, 255, 100):GetU32(),
			[6] = imgui.ImColor(0, 100, 180, 150):GetU32(),
			[9] = imgui.ImColor(0, 180, 255, 160):GetU32(),
			[10] = imgui.ImColor(0, 120, 220, 80):GetU32(),
			[12] = imgui.ImColor(0, 80, 160, 245):GetU32(),
			[23] = imgui.ImColor(0, 120, 220, 180):GetU32(),
			[24] = imgui.ImColor(0, 150, 255, 140):GetU32(),
			[25] = imgui.ImColor(0, 100, 200, 100):GetU32(),
			[26] = imgui.ImColor(50, 130, 200, 60):GetU32(),
			[27] = imgui.ImColor(70, 150, 220, 80):GetU32(),
			[28] = imgui.ImColor(30, 110, 180, 40):GetU32()
		},
		accent = {0, 150, 255}
	},
	["Crimson Red"] = {
		colors = {
			[1] = imgui.ImColor(255, 240, 240, 245):GetU32(),
			[3] = imgui.ImColor(25, 5, 5, 240):GetU32(),
			[8] = imgui.ImColor(200, 30, 50, 100):GetU32(),
			[6] = imgui.ImColor(150, 30, 40, 150):GetU32(),
			[9] = imgui.ImColor(220, 50, 70, 160):GetU32(),
			[10] = imgui.ImColor(180, 20, 40, 80):GetU32(),
			[12] = imgui.ImColor(140, 20, 30, 245):GetU32(),
			[23] = imgui.ImColor(180, 30, 50, 180):GetU32(),
			[24] = imgui.ImColor(200, 50, 70, 140):GetU32(),
			[25] = imgui.ImColor(160, 20, 40, 100):GetU32(),
			[26] = imgui.ImColor(180, 80, 90, 60):GetU32(),
			[27] = imgui.ImColor(200, 100, 110, 80):GetU32(),
			[28] = imgui.ImColor(160, 60, 70, 40):GetU32()
		},
		accent = {200, 40, 60}
	},
	["Emerald Green"] = {
		colors = {
			[1] = imgui.ImColor(240, 255, 245, 245):GetU32(),
			[3] = imgui.ImColor(5, 25, 15, 240):GetU32(),
			[8] = imgui.ImColor(20, 180, 80, 100):GetU32(),
			[6] = imgui.ImColor(20, 130, 60, 150):GetU32(),
			[9] = imgui.ImColor(30, 200, 100, 160):GetU32(),
			[10] = imgui.ImColor(15, 160, 70, 80):GetU32(),
			[12] = imgui.ImColor(15, 120, 55, 245):GetU32(),
			[23] = imgui.ImColor(25, 160, 75, 180):GetU32(),
			[24] = imgui.ImColor(35, 185, 95, 140):GetU32(),
			[25] = imgui.ImColor(20, 140, 65, 100):GetU32(),
			[26] = imgui.ImColor(80, 170, 110, 60):GetU32(),
			[27] = imgui.ImColor(100, 190, 130, 80):GetU32(),
			[28] = imgui.ImColor(60, 150, 90, 40):GetU32()
		},
		accent = {30, 180, 90}
	},
	["Purple Galaxy"] = {
		colors = {
			[1] = imgui.ImColor(250, 240, 255, 245):GetU32(),
			[3] = imgui.ImColor(20, 10, 35, 240):GetU32(),
			[8] = imgui.ImColor(140, 60, 200, 100):GetU32(),
			[6] = imgui.ImColor(100, 50, 150, 150):GetU32(),
			[9] = imgui.ImColor(160, 80, 220, 160):GetU32(),
			[10] = imgui.ImColor(120, 50, 180, 80):GetU32(),
			[12] = imgui.ImColor(90, 40, 140, 245):GetU32(),
			[23] = imgui.ImColor(130, 60, 190, 180):GetU32(),
			[24] = imgui.ImColor(155, 80, 215, 140):GetU32(),
			[25] = imgui.ImColor(110, 50, 170, 100):GetU32(),
			[26] = imgui.ImColor(150, 100, 180, 60):GetU32(),
			[27] = imgui.ImColor(170, 120, 200, 80):GetU32(),
			[28] = imgui.ImColor(130, 80, 160, 40):GetU32()
		},
		accent = {140, 70, 200}
	},
	["Orange Sunset"] = {
		colors = {
			[1] = imgui.ImColor(255, 250, 240, 245):GetU32(),
			[3] = imgui.ImColor(30, 15, 5, 240):GetU32(),
			[8] = imgui.ImColor(255, 130, 30, 100):GetU32(),
			[6] = imgui.ImColor(200, 100, 30, 150):GetU32(),
			[9] = imgui.ImColor(255, 150, 50, 160):GetU32(),
			[10] = imgui.ImColor(230, 110, 20, 80):GetU32(),
			[12] = imgui.ImColor(180, 80, 15, 245):GetU32(),
			[23] = imgui.ImColor(240, 120, 25, 180):GetU32(),
			[24] = imgui.ImColor(255, 145, 45, 140):GetU32(),
			[25] = imgui.ImColor(220, 100, 20, 100):GetU32(),
			[26] = imgui.ImColor(230, 160, 100, 60):GetU32(),
			[27] = imgui.ImColor(250, 180, 120, 80):GetU32(),
			[28] = imgui.ImColor(210, 140, 80, 40):GetU32()
		},
		accent = {255, 140, 40}
	},
	["Midnight Dark"] = {
		colors = {
			[1] = imgui.ImColor(200, 210, 220, 245):GetU32(),
			[3] = imgui.ImColor(10, 12, 18, 250):GetU32(),
			[8] = imgui.ImColor(60, 80, 120, 100):GetU32(),
			[6] = imgui.ImColor(50, 60, 90, 150):GetU32(),
			[9] = imgui.ImColor(80, 100, 140, 160):GetU32(),
			[10] = imgui.ImColor(50, 70, 110, 80):GetU32(),
			[12] = imgui.ImColor(30, 40, 60, 250):GetU32(),
			[23] = imgui.ImColor(70, 90, 130, 180):GetU32(),
			[24] = imgui.ImColor(90, 110, 150, 140):GetU32(),
			[25] = imgui.ImColor(60, 80, 120, 100):GetU32(),
			[26] = imgui.ImColor(80, 95, 130, 60):GetU32(),
			[27] = imgui.ImColor(100, 115, 150, 80):GetU32(),
			[28] = imgui.ImColor(60, 75, 110, 40):GetU32()
		},
		accent = {80, 100, 150}
	},
	["Cyber Pink"] = {
		colors = {
			[1] = imgui.ImColor(255, 240, 250, 245):GetU32(),
			[3] = imgui.ImColor(25, 10, 25, 240):GetU32(),
			[8] = imgui.ImColor(255, 50, 150, 100):GetU32(),
			[6] = imgui.ImColor(200, 40, 120, 150):GetU32(),
			[9] = imgui.ImColor(255, 70, 170, 160):GetU32(),
			[10] = imgui.ImColor(230, 40, 130, 80):GetU32(),
			[12] = imgui.ImColor(180, 30, 100, 245):GetU32(),
			[23] = imgui.ImColor(240, 50, 140, 180):GetU32(),
			[24] = imgui.ImColor(255, 70, 160, 140):GetU32(),
			[25] = imgui.ImColor(220, 40, 120, 100):GetU32(),
			[26] = imgui.ImColor(230, 100, 160, 60):GetU32(),
			[27] = imgui.ImColor(250, 120, 180, 80):GetU32(),
			[28] = imgui.ImColor(210, 80, 140, 40):GetU32()
		},
		accent = {255, 60, 150}
	},
	["Ocean Teal"] = {
		colors = {
			[1] = imgui.ImColor(240, 255, 255, 245):GetU32(),
			[3] = imgui.ImColor(5, 25, 30, 240):GetU32(),
			[8] = imgui.ImColor(0, 180, 180, 100):GetU32(),
			[6] = imgui.ImColor(0, 130, 140, 150):GetU32(),
			[9] = imgui.ImColor(0, 200, 200, 160):GetU32(),
			[10] = imgui.ImColor(0, 160, 165, 80):GetU32(),
			[12] = imgui.ImColor(0, 110, 120, 245):GetU32(),
			[23] = imgui.ImColor(0, 165, 170, 180):GetU32(),
			[24] = imgui.ImColor(0, 190, 195, 140):GetU32(),
			[25] = imgui.ImColor(0, 145, 150, 100):GetU32(),
			[26] = imgui.ImColor(60, 170, 175, 60):GetU32(),
			[27] = imgui.ImColor(80, 190, 195, 80):GetU32(),
			[28] = imgui.ImColor(40, 150, 155, 40):GetU32()
		},
		accent = {0, 180, 185}
	},
	["Royal Blue"] = {
		colors = {
			[1] = imgui.ImColor(240, 245, 255, 245):GetU32(),
			[3] = imgui.ImColor(10, 15, 35, 240):GetU32(),
			[8] = imgui.ImColor(65, 105, 225, 100):GetU32(),
			[6] = imgui.ImColor(50, 80, 180, 150):GetU32(),
			[9] = imgui.ImColor(85, 125, 245, 160):GetU32(),
			[10] = imgui.ImColor(55, 95, 215, 80):GetU32(),
			[12] = imgui.ImColor(40, 65, 160, 245):GetU32(),
			[23] = imgui.ImColor(60, 100, 220, 180):GetU32(),
			[24] = imgui.ImColor(80, 120, 240, 140):GetU32(),
			[25] = imgui.ImColor(50, 90, 200, 100):GetU32(),
			[26] = imgui.ImColor(100, 130, 200, 60):GetU32(),
			[27] = imgui.ImColor(120, 150, 220, 80):GetU32(),
			[28] = imgui.ImColor(80, 110, 180, 40):GetU32()
		},
		accent = {65, 105, 225}
	},
	["Forest Night"] = {
		colors = {
			[1] = imgui.ImColor(220, 240, 220, 245):GetU32(),
			[3] = imgui.ImColor(10, 20, 15, 245):GetU32(),
			[8] = imgui.ImColor(50, 120, 70, 100):GetU32(),
			[6] = imgui.ImColor(40, 90, 55, 150):GetU32(),
			[9] = imgui.ImColor(65, 140, 85, 160):GetU32(),
			[10] = imgui.ImColor(45, 110, 65, 80):GetU32(),
			[12] = imgui.ImColor(30, 70, 45, 250):GetU32(),
			[23] = imgui.ImColor(55, 130, 75, 180):GetU32(),
			[24] = imgui.ImColor(70, 150, 90, 140):GetU32(),
			[25] = imgui.ImColor(45, 115, 65, 100):GetU32(),
			[26] = imgui.ImColor(80, 140, 95, 60):GetU32(),
			[27] = imgui.ImColor(100, 160, 115, 80):GetU32(),
			[28] = imgui.ImColor(60, 120, 75, 40):GetU32()
		},
		accent = {60, 130, 80}
	},
	["Fantasy"] = {
		colors = {
			[1] = imgui.ImColor(245, 235, 255, 245):GetU32(),
			[3] = imgui.ImColor(18, 10, 36, 242):GetU32(),
			[8] = imgui.ImColor(128, 0, 204, 100):GetU32(),
			[6] = imgui.ImColor(90, 40, 140, 150):GetU32(),
			[9] = imgui.ImColor(178, 51, 255, 160):GetU32(),
			[10] = imgui.ImColor(51, 128, 255, 80):GetU32(),
			[12] = imgui.ImColor(100, 0, 160, 245):GetU32(),
			[23] = imgui.ImColor(128, 0, 204, 163):GetU32(),
			[24] = imgui.ImColor(178, 51, 255, 140):GetU32(),
			[25] = imgui.ImColor(51, 128, 255, 100):GetU32(),
			[26] = imgui.ImColor(140, 80, 180, 60):GetU32(),
			[27] = imgui.ImColor(160, 100, 200, 80):GetU32(),
			[28] = imgui.ImColor(120, 60, 160, 40):GetU32()
		},
		accent = {128, 0, 204}
	},
	["Ice Mint"] = {
		colors = {
			[1] = imgui.ImColor(240, 255, 255, 245):GetU32(),
			[3] = imgui.ImColor(15, 31, 31, 242):GetU32(),
			[8] = imgui.ImColor(0, 178, 153, 100):GetU32(),
			[6] = imgui.ImColor(0, 120, 110, 150):GetU32(),
			[9] = imgui.ImColor(51, 230, 191, 160):GetU32(),
			[10] = imgui.ImColor(102, 255, 217, 80):GetU32(),
			[12] = imgui.ImColor(0, 140, 120, 245):GetU32(),
			[23] = imgui.ImColor(0, 178, 153, 163):GetU32(),
			[24] = imgui.ImColor(51, 230, 191, 140):GetU32(),
			[25] = imgui.ImColor(102, 255, 217, 100):GetU32(),
			[26] = imgui.ImColor(80, 180, 160, 60):GetU32(),
			[27] = imgui.ImColor(100, 200, 180, 80):GetU32(),
			[28] = imgui.ImColor(60, 160, 140, 40):GetU32()
		},
		accent = {0, 178, 153}
	},
	["Cyberpunk"] = {
		colors = {
			[1] = imgui.ImColor(255, 240, 250, 245):GetU32(),
			[3] = imgui.ImColor(13, 0, 26, 242):GetU32(),
			[8] = imgui.ImColor(255, 0, 153, 100):GetU32(),
			[6] = imgui.ImColor(180, 0, 110, 150):GetU32(),
			[9] = imgui.ImColor(255, 51, 204, 160):GetU32(),
			[10] = imgui.ImColor(0, 255, 230, 80):GetU32(),
			[12] = imgui.ImColor(200, 0, 120, 245):GetU32(),
			[23] = imgui.ImColor(255, 0, 153, 163):GetU32(),
			[24] = imgui.ImColor(255, 51, 204, 140):GetU32(),
			[25] = imgui.ImColor(0, 255, 230, 100):GetU32(),
			[26] = imgui.ImColor(200, 80, 160, 60):GetU32(),
			[27] = imgui.ImColor(220, 100, 180, 80):GetU32(),
			[28] = imgui.ImColor(180, 60, 140, 40):GetU32()
		},
		accent = {255, 0, 153}
	},
	["Sunset Orange"] = {
		colors = {
			[1] = imgui.ImColor(255, 250, 240, 245):GetU32(),
			[3] = imgui.ImColor(51, 20, 8, 242):GetU32(),
			[8] = imgui.ImColor(242, 102, 26, 100):GetU32(),
			[6] = imgui.ImColor(180, 80, 30, 150):GetU32(),
			[9] = imgui.ImColor(255, 140, 51, 160):GetU32(),
			[10] = imgui.ImColor(255, 180, 90, 80):GetU32(),
			[12] = imgui.ImColor(200, 70, 20, 245):GetU32(),
			[23] = imgui.ImColor(242, 102, 26, 163):GetU32(),
			[24] = imgui.ImColor(255, 140, 51, 140):GetU32(),
			[25] = imgui.ImColor(255, 180, 90, 100):GetU32(),
			[26] = imgui.ImColor(220, 140, 90, 60):GetU32(),
			[27] = imgui.ImColor(240, 160, 110, 80):GetU32(),
			[28] = imgui.ImColor(200, 120, 70, 40):GetU32()
		},
		accent = {242, 102, 26}
	},
	["Rose Gold"] = {
		colors = {
			[1] = imgui.ImColor(255, 245, 248, 245):GetU32(),
			[3] = imgui.ImColor(46, 30, 32, 242):GetU32(),
			[8] = imgui.ImColor(191, 102, 115, 100):GetU32(),
			[6] = imgui.ImColor(150, 80, 90, 150):GetU32(),
			[9] = imgui.ImColor(217, 128, 140, 160):GetU32(),
			[10] = imgui.ImColor(230, 160, 170, 80):GetU32(),
			[12] = imgui.ImColor(160, 90, 100, 245):GetU32(),
			[23] = imgui.ImColor(191, 102, 115, 163):GetU32(),
			[24] = imgui.ImColor(217, 128, 140, 140):GetU32(),
			[25] = imgui.ImColor(230, 160, 170, 100):GetU32(),
			[26] = imgui.ImColor(200, 140, 150, 60):GetU32(),
			[27] = imgui.ImColor(220, 160, 170, 80):GetU32(),
			[28] = imgui.ImColor(180, 120, 130, 40):GetU32()
		},
		accent = {191, 102, 115}
	},
	["Arctic Blue"] = {
		colors = {
			[1] = imgui.ImColor(240, 250, 255, 245):GetU32(),
			[3] = imgui.ImColor(10, 20, 35, 242):GetU32(),
			[8] = imgui.ImColor(100, 180, 230, 100):GetU32(),
			[6] = imgui.ImColor(70, 140, 190, 150):GetU32(),
			[9] = imgui.ImColor(130, 200, 250, 160):GetU32(),
			[10] = imgui.ImColor(160, 220, 255, 80):GetU32(),
			[12] = imgui.ImColor(60, 130, 180, 245):GetU32(),
			[23] = imgui.ImColor(100, 180, 230, 163):GetU32(),
			[24] = imgui.ImColor(130, 200, 250, 140):GetU32(),
			[25] = imgui.ImColor(160, 220, 255, 100):GetU32(),
			[26] = imgui.ImColor(130, 190, 230, 60):GetU32(),
			[27] = imgui.ImColor(150, 210, 250, 80):GetU32(),
			[28] = imgui.ImColor(110, 170, 210, 40):GetU32()
		},
		accent = {100, 180, 230}
	},
	["Blood Moon"] = {
		colors = {
			[1] = imgui.ImColor(255, 235, 230, 245):GetU32(),
			[3] = imgui.ImColor(30, 5, 10, 245):GetU32(),
			[8] = imgui.ImColor(180, 20, 40, 100):GetU32(),
			[6] = imgui.ImColor(130, 20, 35, 150):GetU32(),
			[9] = imgui.ImColor(200, 40, 60, 160):GetU32(),
			[10] = imgui.ImColor(160, 15, 30, 80):GetU32(),
			[12] = imgui.ImColor(120, 15, 25, 250):GetU32(),
			[23] = imgui.ImColor(180, 25, 45, 180):GetU32(),
			[24] = imgui.ImColor(200, 45, 65, 140):GetU32(),
			[25] = imgui.ImColor(160, 20, 35, 100):GetU32(),
			[26] = imgui.ImColor(170, 70, 85, 60):GetU32(),
			[27] = imgui.ImColor(190, 90, 105, 80):GetU32(),
			[28] = imgui.ImColor(150, 50, 65, 40):GetU32()
		},
		accent = {180, 30, 50}
	},
	["Lavender Dream"] = {
		colors = {
			[1] = imgui.ImColor(250, 245, 255, 245):GetU32(),
			[3] = imgui.ImColor(25, 20, 35, 240):GetU32(),
			[8] = imgui.ImColor(180, 150, 220, 100):GetU32(),
			[6] = imgui.ImColor(140, 110, 180, 150):GetU32(),
			[9] = imgui.ImColor(200, 170, 240, 160):GetU32(),
			[10] = imgui.ImColor(220, 190, 255, 80):GetU32(),
			[12] = imgui.ImColor(130, 100, 170, 245):GetU32(),
			[23] = imgui.ImColor(180, 150, 220, 163):GetU32(),
			[24] = imgui.ImColor(200, 170, 240, 140):GetU32(),
			[25] = imgui.ImColor(220, 190, 255, 100):GetU32(),
			[26] = imgui.ImColor(190, 165, 220, 60):GetU32(),
			[27] = imgui.ImColor(210, 185, 240, 80):GetU32(),
			[28] = imgui.ImColor(170, 145, 200, 40):GetU32()
		},
		accent = {180, 150, 220}
	},
	["Matrix Green"] = {
		colors = {
			[1] = imgui.ImColor(200, 255, 200, 245):GetU32(),
			[3] = imgui.ImColor(5, 15, 5, 250):GetU32(),
			[8] = imgui.ImColor(0, 200, 0, 100):GetU32(),
			[6] = imgui.ImColor(0, 150, 0, 150):GetU32(),
			[9] = imgui.ImColor(0, 255, 0, 160):GetU32(),
			[10] = imgui.ImColor(0, 180, 0, 80):GetU32(),
			[12] = imgui.ImColor(0, 130, 0, 250):GetU32(),
			[23] = imgui.ImColor(0, 200, 0, 180):GetU32(),
			[24] = imgui.ImColor(0, 255, 0, 140):GetU32(),
			[25] = imgui.ImColor(0, 180, 0, 100):GetU32(),
			[26] = imgui.ImColor(50, 180, 50, 60):GetU32(),
			[27] = imgui.ImColor(70, 200, 70, 80):GetU32(),
			[28] = imgui.ImColor(30, 160, 30, 40):GetU32()
		},
		accent = {0, 220, 0}
	},
	["Toxic Lime"] = {
		colors = {
			[1] = imgui.ImColor(220, 255, 180, 245):GetU32(),
			[3] = imgui.ImColor(15, 25, 5, 245):GetU32(),
			[8] = imgui.ImColor(180, 255, 0, 100):GetU32(),
			[6] = imgui.ImColor(140, 200, 0, 150):GetU32(),
			[9] = imgui.ImColor(200, 255, 50, 160):GetU32(),
			[10] = imgui.ImColor(160, 230, 0, 80):GetU32(),
			[12] = imgui.ImColor(120, 180, 0, 250):GetU32(),
			[23] = imgui.ImColor(180, 255, 0, 180):GetU32(),
			[24] = imgui.ImColor(200, 255, 50, 140):GetU32(),
			[25] = imgui.ImColor(160, 230, 0, 100):GetU32(),
			[26] = imgui.ImColor(170, 220, 80, 60):GetU32(),
			[27] = imgui.ImColor(190, 240, 100, 80):GetU32(),
			[28] = imgui.ImColor(150, 200, 60, 40):GetU32()
		},
		accent = {180, 255, 0}
	},
	["Deep Ocean"] = {
		colors = {
			[1] = imgui.ImColor(200, 230, 255, 245):GetU32(),
			[3] = imgui.ImColor(5, 20, 40, 248):GetU32(),
			[8] = imgui.ImColor(20, 100, 180, 100):GetU32(),
			[6] = imgui.ImColor(15, 70, 140, 150):GetU32(),
			[9] = imgui.ImColor(40, 130, 210, 160):GetU32(),
			[10] = imgui.ImColor(30, 110, 190, 80):GetU32(),
			[12] = imgui.ImColor(10, 60, 130, 250):GetU32(),
			[23] = imgui.ImColor(25, 105, 185, 180):GetU32(),
			[24] = imgui.ImColor(45, 135, 215, 140):GetU32(),
			[25] = imgui.ImColor(35, 115, 195, 100):GetU32(),
			[26] = imgui.ImColor(60, 130, 190, 60):GetU32(),
			[27] = imgui.ImColor(80, 150, 210, 80):GetU32(),
			[28] = imgui.ImColor(40, 110, 170, 40):GetU32()
		},
		accent = {30, 110, 190}
	},
	["Cherry Blossom"] = {
		colors = {
			[1] = imgui.ImColor(255, 245, 250, 245):GetU32(),
			[3] = imgui.ImColor(40, 20, 30, 240):GetU32(),
			[8] = imgui.ImColor(255, 150, 180, 100):GetU32(),
			[6] = imgui.ImColor(220, 120, 150, 150):GetU32(),
			[9] = imgui.ImColor(255, 180, 200, 160):GetU32(),
			[10] = imgui.ImColor(255, 160, 185, 80):GetU32(),
			[12] = imgui.ImColor(200, 100, 130, 245):GetU32(),
			[23] = imgui.ImColor(255, 155, 185, 180):GetU32(),
			[24] = imgui.ImColor(255, 185, 205, 140):GetU32(),
			[25] = imgui.ImColor(255, 165, 190, 100):GetU32(),
			[26] = imgui.ImColor(240, 170, 190, 60):GetU32(),
			[27] = imgui.ImColor(255, 190, 210, 80):GetU32(),
			[28] = imgui.ImColor(220, 150, 170, 40):GetU32()
		},
		accent = {255, 160, 190}
	},
	["Golden Hour"] = {
		colors = {
			[1] = imgui.ImColor(255, 250, 235, 245):GetU32(),
			[3] = imgui.ImColor(45, 30, 10, 242):GetU32(),
			[8] = imgui.ImColor(255, 200, 100, 100):GetU32(),
			[6] = imgui.ImColor(220, 170, 80, 150):GetU32(),
			[9] = imgui.ImColor(255, 220, 130, 160):GetU32(),
			[10] = imgui.ImColor(255, 210, 110, 80):GetU32(),
			[12] = imgui.ImColor(200, 150, 60, 245):GetU32(),
			[23] = imgui.ImColor(255, 205, 105, 180):GetU32(),
			[24] = imgui.ImColor(255, 225, 135, 140):GetU32(),
			[25] = imgui.ImColor(255, 215, 115, 100):GetU32(),
			[26] = imgui.ImColor(240, 200, 120, 60):GetU32(),
			[27] = imgui.ImColor(255, 220, 140, 80):GetU32(),
			[28] = imgui.ImColor(220, 180, 100, 40):GetU32()
		},
		accent = {255, 200, 100}
	},
	["Aquamarine"] = {
		colors = {
			[1] = imgui.ImColor(235, 255, 250, 245):GetU32(),
			[3] = imgui.ImColor(10, 35, 30, 242):GetU32(),
			[8] = imgui.ImColor(80, 220, 200, 100):GetU32(),
			[6] = imgui.ImColor(60, 180, 165, 150):GetU32(),
			[9] = imgui.ImColor(100, 240, 220, 160):GetU32(),
			[10] = imgui.ImColor(90, 230, 210, 80):GetU32(),
			[12] = imgui.ImColor(50, 160, 145, 245):GetU32(),
			[23] = imgui.ImColor(85, 225, 205, 180):GetU32(),
			[24] = imgui.ImColor(105, 245, 225, 140):GetU32(),
			[25] = imgui.ImColor(95, 235, 215, 100):GetU32(),
			[26] = imgui.ImColor(110, 210, 195, 60):GetU32(),
			[27] = imgui.ImColor(130, 230, 215, 80):GetU32(),
			[28] = imgui.ImColor(90, 190, 175, 40):GetU32()
		},
		accent = {80, 220, 200}
	},
	["Coral Reef"] = {
		colors = {
			[1] = imgui.ImColor(255, 248, 245, 245):GetU32(),
			[3] = imgui.ImColor(40, 20, 15, 242):GetU32(),
			[8] = imgui.ImColor(255, 127, 80, 100):GetU32(),
			[6] = imgui.ImColor(220, 100, 60, 150):GetU32(),
			[9] = imgui.ImColor(255, 150, 110, 160):GetU32(),
			[10] = imgui.ImColor(255, 140, 95, 80):GetU32(),
			[12] = imgui.ImColor(200, 90, 55, 245):GetU32(),
			[23] = imgui.ImColor(255, 132, 85, 180):GetU32(),
			[24] = imgui.ImColor(255, 155, 115, 140):GetU32(),
			[25] = imgui.ImColor(255, 145, 100, 100):GetU32(),
			[26] = imgui.ImColor(240, 150, 115, 60):GetU32(),
			[27] = imgui.ImColor(255, 170, 135, 80):GetU32(),
			[28] = imgui.ImColor(220, 130, 95, 40):GetU32()
		},
		accent = {255, 127, 80}
	},
	["Sapphire Night"] = {
		colors = {
			[1] = imgui.ImColor(220, 230, 255, 245):GetU32(),
			[3] = imgui.ImColor(10, 15, 40, 250):GetU32(),
			[8] = imgui.ImColor(15, 82, 186, 100):GetU32(),
			[6] = imgui.ImColor(10, 60, 150, 150):GetU32(),
			[9] = imgui.ImColor(30, 100, 210, 160):GetU32(),
			[10] = imgui.ImColor(20, 90, 195, 80):GetU32(),
			[12] = imgui.ImColor(8, 50, 130, 250):GetU32(),
			[23] = imgui.ImColor(18, 85, 190, 180):GetU32(),
			[24] = imgui.ImColor(35, 105, 215, 140):GetU32(),
			[25] = imgui.ImColor(25, 95, 200, 100):GetU32(),
			[26] = imgui.ImColor(50, 110, 190, 60):GetU32(),
			[27] = imgui.ImColor(70, 130, 210, 80):GetU32(),
			[28] = imgui.ImColor(30, 90, 170, 40):GetU32()
		},
		accent = {15, 82, 186}
	},
	["Amber Glow"] = {
		colors = {
			[1] = imgui.ImColor(255, 250, 240, 245):GetU32(),
			[3] = imgui.ImColor(40, 25, 5, 245):GetU32(),
			[8] = imgui.ImColor(255, 191, 0, 100):GetU32(),
			[6] = imgui.ImColor(220, 160, 0, 150):GetU32(),
			[9] = imgui.ImColor(255, 210, 50, 160):GetU32(),
			[10] = imgui.ImColor(255, 200, 30, 80):GetU32(),
			[12] = imgui.ImColor(200, 140, 0, 250):GetU32(),
			[23] = imgui.ImColor(255, 195, 10, 180):GetU32(),
			[24] = imgui.ImColor(255, 215, 55, 140):GetU32(),
			[25] = imgui.ImColor(255, 205, 35, 100):GetU32(),
			[26] = imgui.ImColor(240, 195, 60, 60):GetU32(),
			[27] = imgui.ImColor(255, 215, 80, 80):GetU32(),
			[28] = imgui.ImColor(220, 175, 40, 40):GetU32()
		},
		accent = {255, 191, 0}
	},
	["Neon Magenta"] = {
		colors = {
			[1] = imgui.ImColor(255, 240, 255, 245):GetU32(),
			[3] = imgui.ImColor(30, 5, 30, 245):GetU32(),
			[8] = imgui.ImColor(255, 0, 255, 100):GetU32(),
			[6] = imgui.ImColor(200, 0, 200, 150):GetU32(),
			[9] = imgui.ImColor(255, 50, 255, 160):GetU32(),
			[10] = imgui.ImColor(230, 20, 230, 80):GetU32(),
			[12] = imgui.ImColor(180, 0, 180, 250):GetU32(),
			[23] = imgui.ImColor(255, 10, 255, 180):GetU32(),
			[24] = imgui.ImColor(255, 55, 255, 140):GetU32(),
			[25] = imgui.ImColor(235, 25, 235, 100):GetU32(),
			[26] = imgui.ImColor(220, 80, 220, 60):GetU32(),
			[27] = imgui.ImColor(240, 100, 240, 80):GetU32(),
			[28] = imgui.ImColor(200, 60, 200, 40):GetU32()
		},
		accent = {255, 0, 255}
	},
	["Silver Steel"] = {
		colors = {
			[1] = imgui.ImColor(240, 242, 245, 245):GetU32(),
			[3] = imgui.ImColor(25, 28, 32, 248):GetU32(),
			[8] = imgui.ImColor(150, 160, 175, 100):GetU32(),
			[6] = imgui.ImColor(120, 130, 145, 150):GetU32(),
			[9] = imgui.ImColor(170, 180, 195, 160):GetU32(),
			[10] = imgui.ImColor(160, 170, 185, 80):GetU32(),
			[12] = imgui.ImColor(100, 110, 125, 250):GetU32(),
			[23] = imgui.ImColor(155, 165, 180, 180):GetU32(),
			[24] = imgui.ImColor(175, 185, 200, 140):GetU32(),
			[25] = imgui.ImColor(165, 175, 190, 100):GetU32(),
			[26] = imgui.ImColor(160, 168, 180, 60):GetU32(),
			[27] = imgui.ImColor(180, 188, 200, 80):GetU32(),
			[28] = imgui.ImColor(140, 148, 160, 40):GetU32()
		},
		accent = {150, 160, 175}
	},
	["Volcano Red"] = {
		colors = {
			[1] = imgui.ImColor(255, 245, 235, 245):GetU32(),
			[3] = imgui.ImColor(35, 10, 5, 245):GetU32(),
			[8] = imgui.ImColor(230, 80, 20, 100):GetU32(),
			[6] = imgui.ImColor(180, 60, 20, 150):GetU32(),
			[9] = imgui.ImColor(250, 100, 40, 160):GetU32(),
			[10] = imgui.ImColor(210, 70, 15, 80):GetU32(),
			[12] = imgui.ImColor(160, 50, 10, 250):GetU32(),
			[23] = imgui.ImColor(220, 75, 20, 180):GetU32(),
			[24] = imgui.ImColor(245, 95, 35, 140):GetU32(),
			[25] = imgui.ImColor(200, 65, 15, 100):GetU32(),
			[26] = imgui.ImColor(210, 120, 80, 60):GetU32(),
			[27] = imgui.ImColor(230, 140, 100, 80):GetU32(),
			[28] = imgui.ImColor(190, 100, 60, 40):GetU32()
		},
		accent = {230, 85, 25}
	}
}

local themsDir = getWorkingDirectory() .. "\\resource\\scoreboard"
local allset = inicfg.load({
	set = {
		curTheme = "Auriu Clasic",
		type = 1,
		titlebar = 0,
		streamcheck = false,
		npcshow = false,
		fontSize = 2,
		nickType = 0,
		list = 0,
		windowStyle = 0,
		showPlayerStats = true,
		animatedHeader = false
	},
	cheat = {
		clog = false
	},
	groups = {
		friend = {},
		admin = {},
		enemy = {}
	}
}, "scoreboard_ro")

if allset.set.fontSize < 0 or allset.set.fontSize > 4 then
	allset.set.fontSize = 2
end

local cfg = nil
local copColor = {
	[12] = {11},
	[6] = {29},
	[3] = {5, 19},
	[8] = {15},
	[23] = {16},
	[24] = {17},
	[25] = {18}
}

local setTable = {
	["Tablou scor / marcator"] = {
		[8] = "Fara efecte",
		[9] = "La trecere",
		[10] = "Cand e apasat"
	},
	["Lista"] = {
		[26] = "Fara efecte",
		[27] = "La trecere",
		[28] = "Cand e apasat"
	},
	["Fereastra"] = {
		[12] = "Titlu",
		[3] = "Fundal fereastra",
		[6] = "Separatoare",
		[1] = "Text"
	},
	["Buton"] = {
		[23] = "Fara efecte",
		[24] = "La trecere",
		[25] = "Cand e apasat"
	}
}

local sizesFont = {"12", "13", "14", "15", "16"}
local sFont = {}
local style = imgui.GetStyle()
local colors = style.Colors
local clr = imgui.Col
local ImVec4 = imgui.ImVec4
local background = nil
local bgImage = imgui.ImBool(false)

-- Optiuni stil fereastra
local windowStyles = {
	"Clasic",
	"Modern",
	"Compact",
	"Glass"
}

function loadBuiltInTheme(name)
	local theme = builtInThemes[name]
	if not theme then
		theme = builtInThemes["Auriu Clasic"]
		name = "Auriu Clasic"
	end

	cfg = {
		colors = {},
		set = {
			bgimg = false,
			imageColor = imgui.ImColor(255, 255, 255, 255):GetU32()
		}
	}

	for k, v in pairs(theme.colors) do
		cfg.colors[k] = v
	end

	bgImage.v = cfg.set.bgimg
	for k, v in pairs(cfg.colors) do
		colors[k] = imgui.ImColor(v):GetVec4()
	end
	for k, v in pairs(copColor) do
		for _, iv in ipairs(copColor[k]) do
			colors[iv] = colors[k]
		end
	end

	-- Verifica imaginea de fundal personalizata
	if doesFileExist(themsDir .. "\\" .. name .. "\\scoreboard.png") then
		background = imgui.CreateTextureFromFile(themsDir .. "\\" .. name .. "\\scoreboard.png")
	else
		background = nil
	end
end

function loadTheme(name)
	-- Mai intai verifica daca este o tema incorporata
	if builtInThemes[name] then
		loadBuiltInTheme(name)
		return
	end

	-- Altfel incarca din fisier
	cfg = inicfg.load({
		colors = {
			[1] = imgui.ImColor(240, 240, 240, 240):GetU32(),
			[3] = imgui.ImColor(3, 3, 0, 230):GetU32(),
			[8] = imgui.ImColor(210, 210, 0, 100):GetU32(),
			[6] = imgui.ImColor(110, 110, 127, 127):GetU32(),
			[9] = imgui.ImColor(210, 210, 0, 140):GetU32(),
			[10] = imgui.ImColor(210, 210, 0, 70):GetU32(),
			[12] = imgui.ImColor(120, 120, 0, 232):GetU32(),
			[23] = imgui.ImColor(180, 180, 0, 163):GetU32(),
			[24] = imgui.ImColor(180, 180, 0, 100):GetU32(),
			[25] = imgui.ImColor(180, 180, 0, 100):GetU32(),
			[26] = imgui.ImColor(160, 160, 160, 60):GetU32(),
			[27] = imgui.ImColor(160, 160, 160, 60):GetU32(),
			[28] = imgui.ImColor(160, 160, 160, 30):GetU32()
		},
		set = {
			bgimg = false,
			imageColor = imgui.ImColor(255, 255, 255, 255):GetU32()
		}
	}, name and (themsDir .. "\\" .. name .. "\\data.ini") or ("moonloader\\resource\\scoreboard\\main\\data.ini"))
	bgImage.v = cfg.set.bgimg
	for k, v in pairs(cfg.colors) do
		colors[k] = imgui.ImColor(v):GetVec4()
	end
	for k, v in pairs(copColor) do
		for _, iv in ipairs(copColor[k]) do
			colors[iv] = colors[k]
		end
	end
	if doesFileExist(name and (themsDir .. "\\" .. name .. "\\scoreboard.png") or ("moonloader\\resource\\scoreboard\\main\\scoreboard.png")) then
		background = imgui.CreateTextureFromFile(name and (themsDir .. "\\" .. name .. "\\scoreboard.png") or ("moonloader\\resource\\scoreboard\\main\\scoreboard.png"))
	else
		background = nil
	end
end

local ToScreen = convertGameScreenCoordsToWindowScreenCoords
local show_main_window = imgui.ImBool(false)
local show_set_window = imgui.ImBool(false)
local searchBuf = imgui.ImBuffer(256)
local createThemBuf = imgui.ImBuffer(32)
local playerCount = 0
local streamCheck = imgui.ImBool(allset.set.streamcheck)
local cStyle = imgui.ImInt(0)
local cType = imgui.ImInt(allset.set.type)
local bTitlebar = imgui.ImInt(allset.set.titlebar)
local cSize = imgui.ImInt(allset.set.fontSize)
local cNType = imgui.ImInt(allset.set.nickType)
local bNpcShow = imgui.ImBool(allset.set.npcshow)
local bConnectLog = imgui.ImBool(allset.cheat.clog)
local logConFilter = imgui.ImBuffer(128)
local ScrollToButton = false
local logConnect = {}
local thems = {}
local themsId = {}
local notThems = false
local focusId = -1
local scrollToId = false
local gameInit = false
local pMarker = {}
local bMarkPlayer = imgui.ImBool(false)
local mColor = {}
local cFilter = imgui.ImInt(allset.set.list)
local cSetGroup = imgui.ImInt(0)
local cWindowStyle = imgui.ImInt(allset.set.windowStyle or 0)
local bShowPlayerStats = imgui.ImBool(allset.set.showPlayerStats ~= false)
local bAnimatedHeader = imgui.ImBool(allset.set.animatedHeader or false)

-- Initializeaza lista de teme cu temele incorporate
for name, _ in pairs(builtInThemes) do
	table.insert(thems, name)
end
table.sort(thems)

-- Seteaza ID-urile temelor
for i, name in ipairs(thems) do
	themsId[name] = i
	if allset.set.curTheme == name then
		cStyle.v = i - 1
	end
end

loadTheme(allset.set.curTheme)
bgImage.v = cfg.set.bgimg

if not doesDirectoryExist("moonloader\\resource") then
	createDirectory("moonloader\\resource")
end
if not doesDirectoryExist("moonloader\\resource\\scoreboard") then
	createDirectory("moonloader\\resource\\scoreboard")
end

do
function apply_custom_style()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4

	-- Aplica stilul ferestrei bazat pe selectie
	local ws = cWindowStyle.v
	if ws == 0 then -- Clasic
		style.WindowRounding = 8.0
		style.ChildWindowRounding = 6.0
		style.FrameRounding = 5.0
		style.ScrollbarRounding = 6.0
		style.GrabRounding = 5.0
	elseif ws == 1 then -- Modern Rotunjit
		style.WindowRounding = 15.0
		style.ChildWindowRounding = 12.0
		style.FrameRounding = 10.0
		style.ScrollbarRounding = 12.0
		style.GrabRounding = 10.0
	elseif ws == 2 then -- Compact
		style.WindowRounding = 3.0
		style.ChildWindowRounding = 2.0
		style.FrameRounding = 2.0
		style.ScrollbarRounding = 2.0
		style.GrabRounding = 2.0
	elseif ws == 3 then -- Glass 
		style.WindowRounding = 20.0
		style.ChildWindowRounding = 15.0
		style.FrameRounding = 12.0
		style.ScrollbarRounding = 15.0
		style.GrabRounding = 12.0
	end

	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
	style.ScrollbarSize = 13.0
	style.GrabMinSize = 8.0
	style.WindowPadding = imgui.ImVec2(0.0, 0.0)
	style.FramePadding = imgui.ImVec2(2.5, 3.5)
	style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.05, 0.05, 0.05, 0.79)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.28, 0.28, 0.28, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.35, 0.35, 0.35, 1.00)
	colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.10, 0.10, 0.10, 0.35)
end
apply_custom_style()
end

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(0) end

	-- Scaneaza temele personalizate din director
	local h, n = findFirstFile('moonloader\\resource\\scoreboard\\*')
	while true do
		wait(0)
		if h then
			if n then
				if doesDirectoryExist("moonloader\\resource\\scoreboard\\" .. n) and n ~= "." and n ~= ".." then
					-- Adauga temele personalizate care nu sunt incorporate
					if not builtInThemes[n] and themsId[n] == nil then
						table.insert(thems, n)
						themsId[n] = #thems
					end
				end
				n = findNextFile(h)
			else
				findClose(h)
				h = nil
				if #thems == 0 then
					thems[1] = "Auriu Clasic"
					themsId["Auriu Clasic"] = 1
				end
			end
		end
		imgui.Process = show_main_window.v
		if wasKeyPressed(VK_TAB) and not isPauseMenuActive() then
			if not show_main_window.v then
				if not sampIsChatInputActive() then
					toggleScoreboard(true)
				end
			else
				toggleScoreboard(false)
			end
		end
		for k, v in pairs(pMarker) do
			local result, ped = sampGetCharHandleBySampPlayerId(k)
			if result then
				local color = sampGetPlayerColor(k)
				if doesBlipExist(pMarker[k]) then
					if mColor[v] ~= color then
						removeBlip(v)
						pMarker[k] = addBlipForChar(ped)
						mColor[pMarker[k]] = color
						changeBlipColour(pMarker[k], alpha255(color))
						changeBlipDisplay(pMarker[k], 3)
						setBlipAlwaysDisplayOnZoomedRadar(pMarker[k], true)
					end
				else
					pMarker[k] = addBlipForChar(ped)
					mColor[pMarker[k]] = color
					changeBlipColour(pMarker[k], alpha255(color))
					changeBlipDisplay(pMarker[k], 3)
					setBlipAlwaysDisplayOnZoomedRadar(pMarker[k], true)
				end
			end
		end
	end
end

function toggleScoreboard(flag)
	if type(flag) == 'boolean' then
		show_main_window.v = flag
	else
		show_main_window.v = not show_main_window.v
	end
	if show_main_window.v then
		if focusId > -1 then
			scrollToId = true
		end
		if bConnectLog.v then
			ScrollToButton = true
		end
	end
end

function getLocalPlayerId()
	local _, id = sampGetPlayerIdByCharHandle(playerPed)
	return id
end

function onWindowMessage(msg, wparam, lparam)
	if(msg == 0x100 or msg == 0x101) then
		if wparam == VK_TAB then
			consumeWindowMessage(true, false)
		end
		if(wparam == VK_ESCAPE and show_main_window.v) and not isPauseMenuActive() then
			consumeWindowMessage(true, false)
			if(msg == 0x101)then
				toggleScoreboard(false)
			end
		end
	end
end


local glyph_ranges = nil
function imgui.BeforeDrawFrame()
    if not fontChanged then
        fontChanged = true
        glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
        imgui.GetIO().Fonts:Clear()
        imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\arialbd.ttf', 14, nil, glyph_ranges)
				for _, v in ipairs(sizesFont) do
					sFont[tonumber(v)] = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\arialbd.ttf', tonumber(v), nil, glyph_ranges)
				end
				imgui.RebuildFonts()
    end
end

function imgui.OnDrawFrame()
	if show_main_window.v then
		if show_set_window.v then
			local x, y = ToScreen(510, 30)
			local w, h = ToScreen(680, 175)
			imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(4.0, 4.0))
			imgui.SetNextWindowPos(imgui.ImVec2(w-260, y), imgui.Cond.FirstUseEver, imgui.ImVec2(0.0, 0.0))
			imgui.SetNextWindowSize(imgui.ImVec2(260, 340), imgui.Cond.FirstUseEver)
			imgui.Begin(u8'Setari', show_set_window, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize)
			imgui.Separator()

			-- Sectiunea de Selectare Tema
			imgui.AlignTextToFramePadding()
			imgui.TextColored(imgui.ImVec4(1, 0.8, 0.2, 1), u8"TEMA")
			imgui.Separator()

			imgui.AlignTextToFramePadding()
			imgui.Text(u8"Curenta:")
			imgui.SameLine()
			imgui.PushItemWidth(150)
			local rThems = {}
			for k, v in ipairs(thems) do
				rThems[k] = u8(v)
			end
			if imgui.Combo("##thems", cStyle, rThems) and #thems > 0 then
				allset.set.curTheme = thems[cStyle.v + 1]
				inicfg.save(allset, "scoreboard_ro")
				loadTheme(allset.set.curTheme)
				apply_custom_style()
			end
			imgui.PopItemWidth()
			imgui.SameLine()
			if imgui.Button(u8"+", imgui.ImVec2(25, 0)) then
				imgui.OpenPopup(u8"Creeaza tema")
			end
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.Text(u8"Creeaza tema personalizata")
				imgui.EndTooltip()
			end

			if imgui.BeginPopupModal(u8"Creeaza tema", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove) then
				imgui.Text(u8"Numele temei:")
				imgui.InputText("##createThemBuf", createThemBuf, imgui.InputTextFlags.CharsNoBlank)
				if imgui.Button(u8"Creeaza", imgui.ImVec2(100, 0)) then
					imgui.CloseCurrentPopup()
					if createThemBuf.v:len() > 0 and themsId[tostring(u8:decode(createThemBuf.v))] == nil then
						createDirectory(themsDir .. "\\" .. u8:decode(createThemBuf.v))
						themsId[tostring(u8:decode(createThemBuf.v))] = #themsId
						thems[#thems+1] = u8:decode(createThemBuf.v)
					end
				end
				imgui.SameLine()
				if imgui.Button(u8"Anuleaza", imgui.ImVec2(100, 0)) then
					imgui.CloseCurrentPopup()
				end
				imgui.EndPopup()
			end

			imgui.Separator()
			imgui.TextColored(imgui.ImVec4(1, 0.8, 0.2, 1), u8"ASPECT")
			imgui.Separator()

			if imgui.CollapsingHeader(u8"Setari Fereastra") then
				imgui.AlignTextToFramePadding()
				imgui.Text(u8"Marime:")
				imgui.SameLine()
				imgui.PushItemWidth(140)
				if imgui.Combo("##type", cType, {u8"Mica", u8"Medie", u8"Mare", u8"Ecran complet"}) and #thems > 0 then
					allset.set.type = cType.v
				end
				imgui.PopItemWidth()

				imgui.AlignTextToFramePadding()
				imgui.Text(u8"Stil:")
				imgui.SameLine()
				imgui.PushItemWidth(140)
				local styleNames = {}
				for _, v in ipairs(windowStyles) do
					table.insert(styleNames, u8(v))
				end
				if imgui.Combo("##windowStyle", cWindowStyle, styleNames) then
					allset.set.windowStyle = cWindowStyle.v
					apply_custom_style()
				end
				imgui.PopItemWidth()

				imgui.AlignTextToFramePadding()
				imgui.Text(u8"Antet:")
				imgui.SameLine()
				imgui.PushItemWidth(140)
				if imgui.Combo("##header", bTitlebar, {u8"Standard", u8"Doar text", u8"Ascuns"}) then
					allset.set.titlebar = bTitlebar.v
				end
				imgui.PopItemWidth()

				imgui.AlignTextToFramePadding()
				imgui.Text(u8"Marime text:")
				imgui.SameLine()
				imgui.PushItemWidth(140)
				if imgui.Combo("##size", cSize, sizesFont) then
					allset.set.fontSize = cSize.v
				end
				imgui.PopItemWidth()
			end

			if imgui.CollapsingHeader(u8"Afisare Jucatori") then
				imgui.AlignTextToFramePadding()
				imgui.Text(u8"Numele:")
				imgui.SameLine()
				imgui.PushItemWidth(140)
				if imgui.Combo("##ntype", cNType, {u8"Standard", u8"Culoare separata", u8"Fara culoare"}) then
					allset.set.nickType = cNType.v
				end
				imgui.PopItemWidth()

				if imgui.Checkbox(u8"Arata statistici jucator la trecere", bShowPlayerStats) then
					allset.set.showPlayerStats = bShowPlayerStats.v
				end
			end

			imgui.Separator()
			if imgui.CollapsingHeader(u8"Imagine de Fundal") then
				if imgui.Checkbox(u8"Activeaza fundalul", bgImage) then
					cfg.set.bgimg = bgImage.v
				end
				local color = imgui.ImFloat4(imgui.ImColor(cfg.set.imageColor):GetFloat4())
				imgui.AlignTextToFramePadding()
				if bgImage.v then imgui.Text(u8("Culoare nuanta")) else imgui.TextDisabled(u8"Culoare nuanta") end
				imgui.SameLine(200)
				if imgui.ColorEdit4("##imageColor", color, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.AlphaBar) then
					cfg.set.imageColor = imgui.ImColor.FromFloat4(color.v[1], color.v[2], color.v[3], color.v[4]):GetU32()
				end
			end

			-- Personalizare culori (doar pentru teme non-incorporate sau utilizatori avansati)
			for k, v in pairs(setTable) do
				if imgui.CollapsingHeader(u8(k)) then
					for sk, sv in pairs(v) do
						local color = imgui.ImFloat4(imgui.ImColor(cfg.colors[sk]):GetFloat4())
						imgui.AlignTextToFramePadding()
						imgui.Text(u8(sv))
						imgui.SameLine(200)
						if imgui.ColorEdit4("##" .. sk, color, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoLabel + imgui.ColorEditFlags.AlphaBar) then
							local newColor = imgui.ImColor.FromFloat4(color.v[1], color.v[2], color.v[3], color.v[4]):GetVec4()
							cfg.colors[sk] = imgui.ImColor(newColor):GetU32()
							colors[sk] = newColor
							if copColor[sk] then
								for _, iv in ipairs(copColor[sk]) do
									colors[iv] = newColor
								end
							end
						end
					end
				end
			end

			imgui.Separator()
			imgui.TextColored(imgui.ImVec4(1, 0.8, 0.2, 1), u8"OPTIUNI")
			imgui.Separator()

			if imgui.Checkbox(u8"Jurnal conexiuni", bConnectLog) then
				allset.cheat.clog = bConnectLog.v
			end
			if imgui.Checkbox(u8"Arata NPC", bNpcShow) then
				allset.set.npcshow = bNpcShow.v
			end

			imgui.Separator()
			if imgui.Button(u8"Salveaza modificarile", imgui.ImVec2(248, 0)) then
				if not builtInThemes[allset.set.curTheme] then
					if notThems then
						inicfg.save(cfg, "..\\resource\\scoreboard\\main\\data.ini")
						notThems = false
					else
						inicfg.save(cfg, "..\\resource\\scoreboard\\" .. allset.set.curTheme .. "\\data.ini")
					end
				end
				inicfg.save(allset, "scoreboard_ro")
				if notf then
					notf.addNotification("Setarile au fost salvate cu succes", 5)
				end
			end
			imgui.End()
			imgui.PopStyleVar()
		end
		playerCount = 0
		local xOffset = 0
		if bConnectLog.v then
			local x, y = ToScreen(0, 0)
			local w, h = ToScreen(180, 448)
			xOffset = w-x
			imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(4.0, 4.0))
			imgui.SetNextWindowPos(imgui.ImVec2(x, y), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowSize(imgui.ImVec2(w-x, h), imgui.Cond.FirstUseEver)
			imgui.Begin(u8"##connectLogBar", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)
			imgui.SetWindowFontScale(1.05)
			imgui.AlignTextToFramePadding()
			imgui.Text(u8"Jurnal conexiuni:")
			imgui.SetWindowFontScale(1.0)
			imgui.SameLine(w-x-153)
			imgui.PushItemWidth(150)
			imgui.InputText("##logConFilter", logConFilter)
			if not imgui.IsItemActive() and logConFilter.v:len() == 0 then
				local r, g, b, a = imgui.ImColor(colors[1]):GetRGBA()
				imgui.SameLine(w-x-150)
				imgui.TextColored(imgui.ImColor(r, g, b, 180):GetVec4(), u8"Cauta...")
			end
			imgui.PopItemWidth()
			imgui.Separator()
			local _, hb = ToScreen(_, 428)
			imgui.BeginChild("##connectLog", imgui.ImVec2(w-x-4, hb))
			imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(1, 2))
			if #logConnect > 0 then
				local fCount = 0
				local viewLog = {}
				for k, v in ipairs(logConnect) do
					if logConFilter.v:len() > 0 then
						if string.find(string.rlower(v), string.rlower(u8:decode(logConFilter.v)), 1, true) then
							table.insert(viewLog, v)
							fCount = fCount + 1
						end
					else
						table.insert(viewLog, v)
					end
				end
				local clipper = imgui.ImGuiListClipper(#viewLog)
				while clipper:Step() do
					for i = clipper.DisplayStart + 1, clipper.DisplayEnd do
						imgui.Text(u8(viewLog[i]))
						if (imgui.IsItemClicked(0) or imgui.IsItemClicked(1)) and (logConFilter.v:len() == 0 or fCount > 0) then
							setClipboardText(viewLog[i])
						end
					end
				end
				if logConFilter.v:len() > 0 and fCount == 0 then
					imgui.Text(u8"Nicio potrivire gasita...")
				end
			else
				imgui.Text(u8"Jurnalul este gol...")
			end
			if ScrollToButton then
				imgui.SetScrollHere()
				ScrollToButton = false
			end
			imgui.PopStyleVar()
			imgui.EndChild()
			imgui.End()
			imgui.PopStyleVar()
		end
		if allset.set.type == 0 then
			x, y = ToScreen(160, 90)
			w, h = ToScreen(480, 358)
			if bConnectLog.v then
				x = x + xOffset / 2
				w = w + xOffset / 2
			end
		elseif allset.set.type == 1 then
			x, y = ToScreen(130, 60)
			w, h = ToScreen(510, 388)
			if bConnectLog.v then
				x = x + xOffset / 2
				w = w + xOffset / 2
			end
		elseif allset.set.type == 2 then
			x, y = ToScreen(100, 30)
			w, h = ToScreen(540, 418)
			if bConnectLog.v then
				x = x + xOffset / 2
				w = w + xOffset / 2
			end
		elseif allset.set.type == 3 then
			if bConnectLog.v then
				x, y = ToScreen(181, 0)
				w, h = ToScreen(640, 448)
			else
				x, y = ToScreen(0, 0)
				w, h = ToScreen(640, 448)
			end
		end
		imgui.SetNextWindowPos(imgui.ImVec2(x, y), _, imgui.ImVec2(0.0, 0.0))
		imgui.SetNextWindowSize(imgui.ImVec2(w-x , h-y))
		local servername = u8(sampGetCurrentServerName())
		imgui.PushFont(sFont[tonumber(sizesFont[allset.set.fontSize + 1])])
		imgui.Begin(servername, show_main_window, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoScrollbar + (bTitlebar.v > 0 and imgui.WindowFlags.NoTitleBar or 0))

		if background and bgImage.v then
			local size = imgui.GetWindowSize()
			local bColor = cfg.set.imageColor
			imgui.Image(background, imgui.ImVec2(size.x , size.y-(bTitlebar.v == 0 and 21 or 0)), imgui.ImVec2(0, 0), imgui.ImVec2(1, 1), imgui.ImColor(bColor):GetVec4())
		end
		local snSize
		if bTitlebar.v == 1 then
			snSize = imgui.CalcTextSize(servername)
		end
		imgui.SetCursorPos(imgui.ImVec2(bTitlebar.v == 1 and ((w-x) / 2) - (snSize.x / 2) or 6, bTitlebar.v == 0 and 24 or 3))
		if bTitlebar.v == 1 then
			imgui.Text(servername)
			imgui.Separator()
		end
		imgui.AlignTextToFramePadding()
		imgui.Indent(4); imgui.Text(u8('Total: ' .. sampGetPlayerCount(false) .. ' | Aproape: ' .. sampGetPlayerCount(true)-1))
		local bText = u8"Setari"
		local sText = u8"Cauta..."
		local stText = u8"Jucatori in apropiere"
		local bSize = imgui.CalcTextSize(bText)
		local sSize = imgui.CalcTextSize(sText)
		local stSize = imgui.CalcTextSize(stText)
		local cColumns = 4
		if streamCheck.v then
			cColumns = cColumns + 2
		end
		if cNType.v == 1 then
			cColumns = cColumns + 1
		end
		if cFilter.v > 0 then
			cColumns = cColumns + 1
		end
		-- Cautare
		imgui.SameLine(w-x-155)
		imgui.PushItemWidth(150)
		imgui.PushAllowKeyboardFocus(false)
		imgui.InputText("##search", searchBuf, imgui.InputTextFlags.EnterReturnsTrue + imgui.InputTextFlags.CharsNoBlank)
		local iSize = imgui.GetItemRectSize()
		imgui.PopAllowKeyboardFocus()
		imgui.PopItemWidth()
		if not imgui.IsItemActive() and #searchBuf.v == 0 then
			local r, g, b, a = imgui.ImColor(colors[1]):GetRGBA()
			imgui.SameLine(w-x-153)
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(r, g, b, 180):GetVec4())
			imgui.Text(sText)
			imgui.PopStyleColor()
		end
		-- Buton
		imgui.SameLine(w-x-(bSize.x + 155 + 9))
		if imgui.Button(bText) then
			show_set_window.v = not show_set_window.v
		end
		-- Combo
		imgui.SameLine(w-x-(bSize.x + 155 + 115 + 9))
		imgui.PushItemWidth(110)
		if imgui.Combo("##PlayerListFilter", cFilter, {u8"Fara grupuri", u8"Toti jucatorii", u8"Prieteni", u8"Admini", u8"Dusmani", u8"Waypoints"}) then
			allset.set.list = cFilter.v
		end
		imgui.PopItemWidth()
		-- Checkbox
		imgui.SameLine(w-x-(stSize.x + bSize.x + 155 + 115 + 9 + 30))
		if imgui.Checkbox(stText, streamCheck) then
			allset.set.streamcheck = streamCheck.v
		end

		imgui.Columns(cColumns)
		imgui.Separator()
		imgui.NewLine()
		imgui.SameLine(2)
		imgui.SetColumnWidth(-1, 32); imgui.Text('ID'); imgui.NextColumn()
		imgui.SetColumnWidth(-1, w-x-(streamCheck.v and 280 or 160)-(cFilter.v > 0 and 70 or 0)-(cNType.v == 1 and 90 or 0)); imgui.Text(u8'Nume'); imgui.NextColumn()
		if cFilter.v > 0 then
			imgui.SetColumnWidth(-1, 70); imgui.Text(u8'Grup'); imgui.NextColumn()
		end
		if streamCheck.v then
			imgui.SetColumnWidth(-1, 40); imgui.Text(u8'Afk'); imgui.NextColumn()
			imgui.SetColumnWidth(-1, 80); imgui.Text(u8'Distanta'); imgui.NextColumn()
		end
		if cNType.v == 1 then
			imgui.SetColumnWidth(-1, 90); imgui.Text(u8'Culoare'); imgui.NextColumn()
		end
		imgui.SetColumnWidth(-1, 70); imgui.Text(u8'Nivel'); imgui.NextColumn()
		imgui.SetColumnWidth(-1, 70); imgui.Text(u8'Ping'); imgui.NextColumn()
		imgui.Columns(1)
		imgui.Separator()
		imgui.BeginChild("##scroll", imgui.ImVec2(0, 0), false)
		imgui.Columns(cColumns)
		imgui.SetColumnWidth(-1, 32);imgui.NextColumn()
		imgui.SetColumnWidth(-1, w-x-(streamCheck.v and 280 or 160)-(cFilter.v > 0 and 70 or 0)-(cNType.v == 1 and 70 or 0)); imgui.NextColumn()
		if cFilter.v > 0 then
			imgui.SetColumnWidth(-1, 70); imgui.NextColumn()
		end
		if streamCheck.v then
			imgui.SetColumnWidth(-1, 40); imgui.NextColumn()
			imgui.SetColumnWidth(-1, 80); imgui.NextColumn()
		end
		if cNType.v == 1 then
			imgui.SetColumnWidth(-1, 90); imgui.NextColumn()
		end
		imgui.SetColumnWidth(-1, 70);imgui.NextColumn()
		imgui.SetColumnWidth(-1, 70); imgui.NextColumn()
		local local_player_id = getLocalPlayerId()
		if(#searchBuf.v < 1 and not streamCheck.v and cFilter.v < 2) then
			drawScoreboardPlayer(local_player_id)
		else
			if (string.find(sampGetPlayerNickname(local_player_id):lower(), searchBuf.v:lower(), 1, true) or local_player_id == tonumber(searchBuf.v)) and not streamCheck.v and cFilter.v < 2 then
				drawScoreboardPlayer(local_player_id)
			end
		end
		local viewPlayers = {}
		for i = 0, sampGetMaxPlayerId(false) do
			if local_player_id ~= i and sampIsPlayerConnected(i) and (not bNpcShow.v and not sampIsPlayerNpc(i) or bNpcShow.v) then
				local isInStream = sampGetCharHandleBySampPlayerId(i)
				if(#searchBuf.v > 0) then
					if(string.find(sampGetPlayerNickname(i):lower(), searchBuf.v:lower(), 1, true) or i == tonumber(searchBuf.v))then
						if not streamCheck.v or (streamCheck.v and isInStream) then
							local nickname = encoding.UTF8(sampGetPlayerNickname(i))
							local group, gId = getPlayerSGroup(nickname)
							if not ((cFilter.v > 1 and cFilter.v < 5 and gId ~= cFilter.v - 1) or (cFilter.v == 5 and pMarker[i] == nil)) then
								table.insert(viewPlayers, i)
							end
						end
					end
				else
					if not streamCheck.v or (streamCheck.v and isInStream) then
						local nickname = encoding.UTF8(sampGetPlayerNickname(i))
						local group, gId = getPlayerSGroup(nickname)
						if not ((cFilter.v > 1 and cFilter.v < 5 and gId ~= cFilter.v - 1) or (cFilter.v == 5 and pMarker[i] == nil)) then
							table.insert(viewPlayers, i)
						end
					end
				end
			end
		end
		if #viewPlayers > 0 then
			local clipper = imgui.ImGuiListClipper(#viewPlayers)
			while clipper:Step() do
				for i = clipper.DisplayStart + 1, clipper.DisplayEnd do
					drawScoreboardPlayer(viewPlayers[i])
				end
			end
		end

		imgui.Columns(1)
		if(playerCount == 0)then
			imgui.SameLine(5.0); imgui.Text(u8"Niciun jucator gasit...")
		end
		imgui.Separator()
		imgui.EndChild()

		imgui.End()
		imgui.PopFont()
	end
end

function getPlayerSGroup(name)
	local name = tostring(name)
	if #name < 1 then
		return nil
	end
	local group, groupId = nil, 0
	if allset.groups.friend[name] then
		group = "Prieten"
		groupId = 1
	elseif allset.groups.admin[name] then
		group = "Admin"
		groupId = 2
	elseif allset.groups.enemy[name] then
		group = "Dusman"
		groupId = 3
	end
	return group, groupId
end

function getDistanceToPlayer(playerId)
	if sampIsPlayerConnected(playerId) then
		local result, ped = sampGetCharHandleBySampPlayerId(playerId)
		if result and doesCharExist(ped) then
			local myX, myY, myZ = getCharCoordinates(playerPed)
			local playerX, playerY, playerZ = getCharCoordinates(ped)
			return getDistanceBetweenCoords3d(myX, myY, myZ, playerX, playerY, playerZ)
		end
	end
	return nil
end

function drawScoreboardPlayer(id)
	local pop
	local playerInStream, ped = sampGetCharHandleBySampPlayerId(id)
	local nickname = encoding.UTF8(sampGetPlayerNickname(id))
	local group, gId = getPlayerSGroup(nickname)
	local score = sampGetPlayerScore(id)
	local ping = sampGetPlayerPing(id)
	local color = sampGetPlayerColor(id)
	local health = playerInStream and tostring(sampGetPlayerHealth(id)) or "-"
	local armor = playerInStream and tostring(sampGetPlayerArmor(id)) or "-"
	local model = playerInStream and tostring(getCharModel(ped)) or "-"
	local speed = playerInStream and tostring(math.floor(getCharSpeed(ped))) or "-"
	local distance = getDistanceToPlayer(id)
	local r, g, b = bitex.bextract(color, 16, 8), bitex.bextract(color, 8, 8), bitex.bextract(color, 0, 8)
	local imgui_RGBA = imgui.ImVec4(r / 255.0, g / 255.0, b / 255.0, 1)
	playerCount = playerCount + 1
	imgui.NewLine()
	imgui.SameLine(2)
	if imgui.Selectable(tostring(id), id == focusId, imgui.SelectableFlags.SpanAllColumns + imgui.SelectableFlags.AllowDoubleClick) then
		if imgui.IsMouseDoubleClicked(0) then
			sampSendClickPlayer(id, 0)
			lua_thread.create(function ()
				wait(150)
				toggleScoreboard(false)
			end)
		else
			focusId = focusId == id and -1 or id
		end
	end

	imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(4.0, 3.0))
	if id ~= getLocalPlayerId() and imgui.BeginPopupContextItem() then
		imgui.BeginChild("##pMenu", imgui.ImVec2(150, 138))
		pop = true
		imgui.TextColored(imgui_RGBA, nickname .. "[" .. id .. "]")
		local btnSize = imgui.ImVec2(-0.001, 0.0)
		imgui.Separator()
		if id ~= getLocalPlayerId() then
			bMarkPlayer.v = pMarker[id] and true or false
			if imgui.Checkbox(u8"Waypoint player", bMarkPlayer) then
				if pMarker[id] then
					if doesBlipExist(pMarker[id]) then
						removeBlip(pMarker[id])
					end
					mColor[pMarker[id]] = nil
					pMarker[id] = nil
					if notf then
						notf.addNotification("Waypoint player " .. nickname .. " deleted", 5)
					end
				elseif playerInStream then
					pMarker[id] = addBlipForChar(ped)
					local mCol = alpha255(color)
					changeBlipColour(pMarker[id], mCol)
					mColor[pMarker[id]] = color
					changeBlipDisplay(pMarker[id], 3)
					setBlipAlwaysDisplayOnZoomedRadar(pMarker[id], true)
					if notf then
						notf.addNotification("Waypoint player " .. nickname .. " was set", 5)
					end
				else
					pMarker[id] = -1
					if notf then
						notf.addNotification("Jucatorul " .. nickname .. " nu este in apropiere. Waypoint-ul va fi plasat cand jucatorul apare in zona de stream.", 5)
					end
				end
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'Trimite mesaj', btnSize) then
				imgui.CloseCurrentPopup()
				toggleScoreboard(false)
				sampSetChatInputText("/sms " .. id .. " ")
				sampSetChatInputEnabled(true)
			end
		end
		if imgui.Button(u8'Copiaza numele', btnSize) then
			setClipboardText(nickname)
			imgui.CloseCurrentPopup()
		end
		imgui.Text(u8"Grupul jucatorului:")
		imgui.PushItemWidth(-0.001)
		_, cSetGroup.v = getPlayerSGroup(nickname)
		if imgui.Combo("##cSetGroup", cSetGroup, {u8"Fara grup", u8"Prieten", u8"Admin", u8"Dusmani"}) then
			if cSetGroup.v == 0 then
				allset.groups.friend[tostring(nickname)] = nil
				allset.groups.admin[tostring(nickname)] = nil
				allset.groups.enemy[tostring(nickname)] = nil
			elseif cSetGroup.v == 1 then
				allset.groups.friend[tostring(nickname)] = true
				allset.groups.admin[tostring(nickname)] = nil
				allset.groups.enemy[tostring(nickname)] = nil
			elseif cSetGroup.v == 2 then
				allset.groups.friend[tostring(nickname)] = nil
				allset.groups.admin[tostring(nickname)] = true
				allset.groups.enemy[tostring(nickname)] = nil
			elseif cSetGroup.v == 3 then
				allset.groups.friend[tostring(nickname)] = nil
				allset.groups.admin[tostring(nickname)] = nil
				allset.groups.enemy[tostring(nickname)] = true
			end
			imgui.CloseCurrentPopup()
		end
		imgui.PopItemWidth()
		imgui.EndChild()
		imgui.EndPopup()
	else
		pop = false
	end
	imgui.PopStyleVar()

	-- Tooltip imbunatatit cu statisticile jucatorului
	if bShowPlayerStats.v and imgui.IsItemHovered() and not pop and id ~= getLocalPlayerId() then
		imgui.BeginTooltip();
		imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(4.0, 3.0))
		imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(4.0, 2.0))
		imgui.BeginChild("##PlayerInfo", imgui.ImVec2(170, (tonumber(sizesFont[allset.set.fontSize + 1]) + 2) * 8 + 10), true)

		-- Antet jucator cu culoare
		imgui.TextColored(imgui_RGBA, nickname)
		imgui.SameLine()
		imgui.TextDisabled("[" .. id .. "]")
		imgui.Separator()

			-- Bara de viata
		imgui.Text(u8"Viata: ")
		imgui.SameLine()
		if playerInStream then
			local hp = tonumber(health) or 0
			local hpColor = hp > 50 and imgui.ImVec4(0.2, 0.9, 0.2, 1) or (hp > 25 and imgui.ImVec4(0.9, 0.9, 0.2, 1) or imgui.ImVec4(0.9, 0.2, 0.2, 1))
			imgui.TextColored(hpColor, health)
		else
			imgui.TextDisabled("-")
		end

		-- Armura
		imgui.Text(u8"Armura: ")
		imgui.SameLine()
		if playerInStream and tonumber(armor) > 0 then
			imgui.TextColored(imgui.ImVec4(0.3, 0.6, 0.9, 1), armor)
		else
			imgui.TextDisabled(armor)
		end

		imgui.Text(u8"Skin: ")
		imgui.SameLine()
		imgui.Text(model)

		-- Indicator de grup
		if gId > 0 then
			imgui.Separator()
			local groupColor
			if gId == 1 then
				groupColor = imgui.ImVec4(0.2, 0.8, 0.2, 1)
			elseif gId == 2 then
				groupColor = imgui.ImVec4(0.9, 0.9, 0.2, 1)
			elseif gId == 3 then
				groupColor = imgui.ImVec4(0.9, 0.2, 0.2, 1)
			end
			imgui.TextColored(groupColor, u8(group))
		end

		imgui.EndChild()
		imgui.PopStyleVar(2)
		imgui.EndTooltip();
	end

	imgui.NextColumn()

	if cNType.v == 0 then
		imgui.TextColored(imgui_RGBA, nickname)
	else
		imgui.Text(nickname)
	end
	imgui.NextColumn()
	if allset.set.list > 0 then
		if gId == 0 then
			imgui.Text(u8("-"))
		else
			local color
			if gId == 1 then
				color = imgui.ImColor(10, 180, 10, 255):GetVec4()
			elseif gId == 2 then
				color = imgui.ImColor(255, 200, 10, 255):GetVec4()
			elseif gId == 3 then
				color = imgui.ImColor(220, 40, 40, 255):GetVec4()
			end
			imgui.TextColored(color, u8(group))
		end
		imgui.NextColumn()
	end
	if streamCheck.v then
		local afkColor = sampIsPlayerPaused(id) and imgui.ImVec4(0.9, 0.6, 0.2, 1) or imgui.ImVec4(0.7, 0.7, 0.7, 1)
		imgui.TextColored(afkColor, sampIsPlayerPaused(id) and u8"Da" or u8"Nu")
		imgui.NextColumn()
		imgui.Text(string.format("%0.1f", distance)); imgui.NextColumn()
	end
	if cNType.v == 1 then
		imgui.TextColored(imgui_RGBA, "0x" .. string.upper(string.format("%0.8s", bit.tohex(color)))); imgui.NextColumn()
	end
	imgui.Text(tostring(score)); imgui.NextColumn()

	-- Ping cu codificare de culoare
	local pingColor
	if ping < 80 then
		pingColor = imgui.ImVec4(0.2, 0.9, 0.2, 1)
	elseif ping < 150 then
		pingColor = imgui.ImVec4(0.9, 0.9, 0.2, 1)
	else
		pingColor = imgui.ImVec4(0.9, 0.2, 0.2, 1)
	end
	imgui.TextColored(pingColor, tostring(ping))
	imgui.NextColumn()

	if scrollToId and focusId > -1 and focusId == id then
		scrollToId = false
		imgui.SetScrollHere(0.43)
	end
end

function onScriptTerminate(script, quitGame)
	if script == thisScript() then
		for k, v in pairs(pMarker) do
			if doesBlipExist(v) then
				removeBlip(v)
			end
		end
		if not doesDirectoryExist("moonloader\\config") then
			createDirectory("moonloader\\config")
		end
		if not builtInThemes[allset.set.curTheme] then
			if notThems then
				inicfg.save(cfg, "..\\resource\\scoreboard\\main\\data.ini")
				notThems = false
			else
				inicfg.save(cfg, "..\\resource\\scoreboard\\" .. allset.set.curTheme .. "\\data.ini")
			end
		end
		inicfg.save(allset, "scoreboard_ro")
	end
end

function string.rlower(s)
	s = s:lower()
	local strlen = s:len()
	if strlen == 0 then return s end
	s = s:lower()
	local output = ''
	for i = 1, strlen do
		 local ch = s:byte(i)
		 if ch >= 192 and ch <= 223 then
			  output = output .. russian_characters[ch + 32]
		 elseif ch == 168 then
			  output = output .. russian_characters[184]
		 else
			  output = output .. string.char(ch)
		 end
	end
	return output
end
function string.rupper(s)
	s = s:upper()
	local strlen = s:len()
	if strlen == 0 then return s end
	s = s:upper()
	local output = ''
	for i = 1, strlen do
		 local ch = s:byte(i)
		 if ch >= 224 and ch <= 255 then
			  output = output .. russian_characters[ch - 32]
		 elseif ch == 184 then
			  output = output .. russian_characters[168]
		 else
			  output = output .. string.char(ch)
		 end
	end
	return output
end

function SE.onPlayerJoin(id, color, isNpc, nickname)
	if gameInit then
		addConLog(string.format("%s[%d] s-a conectat", nickname, id))
	end
end

function SE.onPlayerQuit(id, reason)
	if gameInit then
		addConLog(string.format("%s[%d] %s", sampGetPlayerNickname(id), id, quitReason[reason+1]))
	end
end

function SE.onRequestClassResponse()
	gameInit = true
end

function SE.onShowDialog()
	gameInit = true
end

function SE.onServerMessage()
	gameInit = true
end

function addConLog(string)
	logConnect[#logConnect+1] = string.format("[%s] %s", os.date("%H:%M:%S"), string)
end

function explode_color(color)
	local a = bit.band(bit.rshift(color, 24), 0xFF)
	local r = bit.band(bit.rshift(color, 16), 0xFF)
	local g = bit.band(bit.rshift(color, 8), 0xFF)
	local b = bit.band(color, 0xFF)
	return a, r, g, b
end

function join_color(a, r, g, b)
	local color = b
	color = bit.bor(color, bit.lshift(g, 8))
	color = bit.bor(color, bit.lshift(r, 16))
	color = bit.bor(color, bit.lshift(a, 24))
	return color
end

function convertARGBToRGBA(color)
	local color = tonumber(color)
	local a, r, g, b = explode_color(color)
	return join_color(r, g, b, a)
end

function convertRGBAToARGB(color)
	local color = tonumber(color)
	local r, g, b, a = explode_color(color)
	return join_color(a, r, g, b)
end

function alpha255(color)
	local color = tonumber(color)
	local a, r, g, b = explode_color(color)
	return join_color(r, g, b, 255)
end
