-- kanaFurniture - Release 3 - For tes3mp v0.7-alpha
-- REQUIRES: decorateHelp (https://github.com/Atkana/tes3mp-scripts/blob/master/0.7/decorateHelp.lua)
-- Purchase and place an assortment of furniture

-- NOTE FOR SCRIPTS: pname requires the name to be in all LOWERCASE

--[[ INSTALLATION:
1) Save this file as "kanaFurniture.lua" in server/scripts/custom
2) Add [ kanaFurniture = require("custom.kanaFurniture") ] to the top of customScripts.lua

]]

local config = {}
config.whitelist = false --If true, the player must be given permission to place items in the cell that they're in (set using this script's methods, or editing the world.json). Note that this only prevents placement, players can still move/remove items they've placed in the cell.
config.sellbackModifier = 0.75 -- The base cost that an item is multiplied by when selling the items back (0.75 is 75%)

--GUI Ids used for the script's GUIs. Shouldn't have to be edited.
config.MainGUI = 31363
config.BuyGUI = 31364
config.InventoryGUI = 31365
config.ViewGUI = 31366
config.InventoryOptionsGUI = 31367
config.ViewOptionsGUI = 31368

------------
--Indexed table of all available furniture. refIds should be in all lowercase
--Best resource I could find online was this: http://tamriel-rebuilt.org/content/resource-guide-models-morrowind (note, items that begin with TR are part of Tamriel Rebuilt, not basic Morrowind, and it certainly doesn't list all the furniture items)

local furnitureData = {
--Containers (Lowest quality container = 1 price per weight)
{name = "Barrel 1", refId = "barrel_01", price = 50},
{name = "Barrel 2", refId = "barrel_02", price = 50},
{name = "Crate 1", refId = "crate_01_empty", price = 200},
{name = "Crate 2", refId = "crate_02_empty", price = 200},
{name = "Basket", refId = "com_basket_01", price = 50},
{name = "Sack (Flat)", refId = "com_sack_01", price = 50},
{name = "Sack (Bag)", refId = "com_sack_02", price = 50},
{name = "Sack (Crumpled)", refId = "com_sack_03", price = 50},
{name = "Sack (Light)", refId = "com_sack_00", price = 50},
{name = "Urn 1", refId = "urn_01", price = 100},
{name = "Urn 2", refId = "urn_02", price = 100},
{name = "Urn 3", refId = "urn_03", price = 100},
{name = "Urn 4", refId = "urn_04", price = 100},
{name = "Urn 5", refId = "urn_05", price = 100},
{name = "Steel Keg", refId = "dwrv_barrel00_empty", price = 150},
{name = "Steel Quarter Keg", refId = "dwrv_barrel10_empty", price = 75},
--Chesty Containers
{name = "Cheap Chest", refId = "com_chest_11_empty", price = 150},
{name = "Cheap Chest (Open)", refId = "com_chest_11_open", price = 150},
{name = "Small Chest (Metal)", refId = "chest_small_01", price = 50}, --*2 price because fancier material
{name = "Small Chest (Wood)", refId = "chest_small_02", price = 25},

--Imperial Furniture Set
{name = "Imperial Closet", refId = "com_closet_01", price = 300},
{name = "Imperial Cupboard", refId = "com_cupboard_01", price = 100},
{name = "Imperial Drawers", refId = "com_drawers_01", price = 300},
{name = "Imperial Hutch", refId = "com_hutch_01", price = 75},
{name = "Imperial Chest (Cheap)", refId = "com_chest_01", price = 150},
{name = "Imperial Chest (Fine)", refId = "com_chest_02", price = 400}, --*2 price because fancier

--Dunmer Furniture Set
{name = "Dunmer Closet (Cheap)", refId = "de_p_closet_02", price = 300},
{name = "Dunmer Closet (Fine)", refId = "de_r_closet_01", price = 600}, --*2 for quality
{name = "Dunmer Desk", refId = "de_p_desk_01", price = 75},
{name = "Dunmer Drawers (Cheap)", refId = "de_drawers_02", price = 300},
{name = "Dunmer Drawers (Fine)", refId = "de_r_drawers_01", price = 600},
{name = "Dunmer Drawer Table (Large)", refId = "de_p_table_02", price = 25},
{name = "Dunmer Drawer Table (Small)", refId = "de_p_table_01", price = 25},
{name = "Dunmer Chest (Cheap)", refId = "de_r_chest_01", price = 200},
{name = "Dunmer Chest (Fine)", refId = "de_p_chest_02", price = 400}, --*2 because fancy

--General Furniture
{name = "Stool (Crude)", refId = "furn_de_ex_stool_02", price = 50},
{name = "Stool (Prayer)", refId = "furn_velothi_prayer_stool_01", price = 50},
{name = "Stool (Bar Stool)", refId = "furn_com_rm_barstool", price = 100},
{name = "Chair (Camp)", refId = "furn_com_pm_chair_02", price = 50},
{name = "Chair (General 1)", refId = "furn_com_rm_chair_03", price = 100},
{name = "Chair (General 2)", refId = "furn_de_p_chair_01", price = 100},
{name = "Chair (General 3)", refId = "furn_de_p_chair_02", price = 100},
{name = "Chair (Fine)", refId = "furn_de_r_chair_03", price = 200},
{name = "Chair (Padded)", refId = "furn_com_r_chair_01", price = 200},
{name = "Chair (Chieftain)", refId = "furn_chieftains_chair", price = 200},
{name = "Bench, Long (Cheap)", refId = "furn_de_p_bench_03", price = 200},
{name = "Bench, Short (Cheap)", refId = "furn_de_p_bench_04", price = 200},
{name = "Bench, Long (Fine)", refId = "furn_de_r_bench_01", price = 400},
{name = "Bench, Short (Fine)", refId = "furn_de_r_bench_02", price = 400},
{name = "Bench (Crude)", refId = "furn_de_p_bench_03", price = 150},
{name = "Common Bench 1", refId = "furn_com_p_bench_01", price = 200},
{name = "Common Bench 2", refId = "furn_com_rm_bench_02", price = 200},

{name = "Table, Big Oval (Fine)", refId = "furn_de_r_table_03", price = 800},
{name = "Table, Big Rectangle (Cheap)", refId = "furn_de_p_table_04", price = 400},
{name = "Table, Big Rectangle (Fine)", refId = "furn_de_r_table_07", price = 800},
{name = "Table, Low Round (Cheap) 1", refId = "furn_de_p_table_01", price = 400},
{name = "Table, Low Round (Cheap) 2", refId = "furn_de_p_table_06", price = 400},
{name = "Table, Low Round (Fine)", refId = "furn_de_r_table_08", price = 800},
{name = "Table, Small Square (Cheap)", refId = "furn_de_p_table_05", price = 400},
{name = "Table, Small Square (Fine)", refId = "furn_de_r_table_09", price = 800},
{name = "Table, Small Round (Cheap)", refId = "furn_de_p_table_02", price = 400},
{name = "Table, Square (Crude)", refId = "furn_de_ex_table_02", price = 200},
{name = "Table, Rectangle (Crude)", refId = "furn_de_ex_table_03", price = 200},

{name = "Table, Colony", refId = "furn_com_table_colony", price = 400},
{name = "Table, Rectangle 1", refId = "furn_com_rm_table_04", price = 400},
{name = "Table, Rectangle 2", refId = "furn_com_r_table_01", price = 800},
{name = "Table, Small Rectangle", refId = "furn_com_rm_table_05", price = 400},
{name = "Table, Round", refId = "furn_com_rm_table_03", price = 400},
{name = "Table, Oval", refId = "furn_de_table10", price = 800},

{name = "Bar Counter, Middle", refId = "furn_com_rm_bar_01", price = 200},
{name = "Bar Counter, End Cap 1", refId = "furn_com_rm_bar_04", price = 200},
{name = "Bar Counter, End Cap 2", refId = "furn_com_rm_bar_02", price = 200},
{name = "Bar Counter, Corner", refId = "furn_com_rm_bar_03", price = 200},

{name = "Bar Counter, Middle (Dunmer)", refId = "furn_de_bar_01", price = 200},
{name = "Bar Counter, End Cap 1 (Dunmer)", refId = "furn_de_bar_04", price = 200},
{name = "Bar Counter, End Cap 2 (Dunmer)", refId = "furn_de_bar_02", price = 200},
{name = "Bar Counter, Corner (Dunmer)", refId = "furn_de_bar_03", price = 200},

{name = "Bookshelf, Backed (Cheap)", refId = "furn_com_rm_bookshelf_02", price = 500},
{name = "Bookshelf, Backed (Fine)", refId = "furn_com_r_bookshelf_01", price = 1000},
{name = "Bookshelf, Standing (Cheap)", refId = "furn_de_p_bookshelf_01", price = 350},
{name = "Bookshelf, Standing (Fine)", refId = "furn_de_r_bookshelf_02", price = 700},

--Beds
{name = "Bedroll", refId = "active_de_bedroll", price = 100},
{name = "Standing Hammock", refId = "active_de_r_bed_02", price = 150},
{name = "Bunk Bed 1", refId = "active_com_bunk_01", price = 800},
{name = "Bunk Bed 2", refId = "active_com_bunk_02", price = 800},
{name = "Bunk Bed 3", refId = "active_de_p_bed_03", price = 800},
{name = "Bunk Bed 4", refId = "active_de_p_bed_09", price = 800},
{name = "Bed, Single 1 (Imperial, Dark, Red Patterned)", refId = "active_com_bed_02", price = 400},
{name = "Bed, Single 2 (Imperial, Light, Pale Red)", refId = "active_com_bed_03", price = 400},
{name = "Bed, Single 3 (Imperial, Dark, Pale Green)", refId = "active_com_bed_04", price = 400},
{name = "Bed, Single 4 (Imperial, Light, Grey)", refId = "active_com_bed_05", price = 400},
{name = "Bed, Single 5 (Dunmer, Grey-Brown)", refId = "active_de_p_bed_04", price = 400},
{name = "Bed, Single 6 (Dunmer, Pale Red)", refId = "active_de_p_bed_10", price = 400},
{name = "Bed, Single 7 (Dunmer, Blue Patterned)", refId = "active_de_p_bed_11", price = 400},
{name = "Bed, Single 8 (Dunmer, Blue Patterned)", refId = "active_de_p_bed_12", price = 400},
{name = "Bed, Single 9 (Dunmer, Red Patterned)", refId = "active_de_p_bed_13", price = 400},
{name = "Bed, Single 10 (Dunmer, Grey)", refId = "active_de_p_bed_14", price = 400},
{name = "Bed, Single 11 (Headboard, Blue Patterned)", refId = "active_de_pr_bed_07", price = 400},
{name = "Bed, Single 12 (Headboard, Blue Patterned)", refId = "active_de_pr_bed_21", price = 400},
{name = "Bed, Single 13 (Headboard, Red Patterned)", refId = "active_de_pr_bed_22", price = 400},
{name = "Bed, Single 14 (Headboard, Red Patterned)", refId = "active_de_pr_bed_23", price = 400},
{name = "Bed, Single 15 (Headboard, Grey-Brown)", refId = "active_de_pr_bed_24", price = 400},
{name = "Bed, Single 16 (Headboard, Pale Green)", refId = "active_de_pr_bed_24", price = 400},

{name = "Bed, Single Cot 1 (Dunmer, Blue Patterned)", refId = "active_de_r_bed_01", price = 400},
{name = "Bed, Single Cot 2 (Dunmer, Blue Patterned)", refId = "active_de_r_bed_17", price = 400},
{name = "Bed, Single Cot 3 (Dunmer, Red Patterned)", refId = "active_de_r_bed_18", price = 400},
{name = "Bed, Single Cot 4 (Dunmer, Red Patterned)", refId = "active_de_r_bed_19", price = 400},

{name = "Bed, Double 1 (Dunmer, Pale Green)", refId = "active_de_p_bed_05", price = 800},
{name = "Bed, Double 2 (Dunmer, Red Patterned)", refId = "active_de_p_bed_15", price = 800},
{name = "Bed, Double 3 (Dunmer, Red Patterned)", refId = "active_de_p_bed_16", price = 800},
{name = "Bed, Double 4 (Headboard, Pale Green)", refId = "active_de_pr_bed_27", price = 800},
{name = "Bed, Double 5 (Headboard, Red Patterned)", refId = "active_de_pr_bed_26", price = 800},
{name = "Bed, Double 6 (Headboard, Red Patterned)", refId = "active_de_pr_bed_08", price = 800},
{name = "Bed, Double 7 (Cot, Red Patterned)", refId = "active_de_r_bed_20", price = 800},
{name = "Bed, Double 8 (Cot, Red Patterned)", refId = "active_de_r_bed_06", price = 800},
{name = "Bed, Double 9 (Imperial, Four Poster, Blue)", refId = "active_com_bed_06", price = 800},

--Rugs
{name = "Dunmer Rug 1", refId = "furn_de_rug_01", price = 200},
{name = "Dunmer Rug 2", refId = "furn_de_rug_02", price = 200},
{name = "Wolf Rug", refId = "furn_colony_wolfrug01", price = 50},
{name = "Bearskin Rug", refId = "furn_rug_bearskin", price = 100},
{name = "Rug, Big Round 1 (Red)", refId = "furn_de_rug_big_01", price = 200},
{name = "Rug, Big Round 2 (Red)", refId = "furn_de_rug_big_02", price = 200},
{name = "Rug, Big Round 3 (Green)", refId = "furn_de_rug_big_03", price = 200},
{name = "Rug, Big Round 4 (Blue)", refId = "furn_de_rug_big_08", price = 200},
{name = "Rug, Big Rectangle 1 (Red)", refId = "furn_de_rug_big_04", price = 200},
{name = "Rug, Big Rectangle 2 (Red)", refId = "furn_de_rug_big_05", price = 200},
{name = "Rug, Big Rectangle 3 (Green)", refId = "furn_de_rug_big_06", price = 200},
{name = "Rug, Big Rectangle 4 (Green)", refId = "furn_de_rug_big_07", price = 200},
{name = "Rug, Big Rectangle 5 (Blue)", refId = "furn_de_rug_big_09", price = 200},

--Fireplaces
{name = "Firepit", refId = "furn_de_firepit", price = 100},
{name = "Firepit 2", refId = "furn_de_firepit_01", price = 100},
{name = "Fireplace (Simple Oven)", refId = "furn_t_fireplace_01", price = 500},
{name = "Fireplace (Forge)", refId = "furn_de_forge_01", price = 500},
{name = "Fireplace (Nord)", refId = "in_nord_fireplace_01", price = 1500},
{name = "Fireplace", refId = "furn_fireplace10", price = 2000},
{name = "Fireplace (Grand Imperial)", refId = "in_imp_fireplace_grand", price = 5000},

--Lighting
{name = "Yellow Paper Lantern", refId = "light_de_lantern_03", price = 25},
{name = "Blue Paper Lantern", refId = "light_de_lantern_08", price = 25},
{name = "Yellow Candles", refId = "light_com_candle_07", price = 25},
{name = "Blue Candles", refId = "light_com_candle_11", price = 25},
{name = "Blue Candles", refId = "light_com_candle_11", price = 25},
{name = "Wall Sconce (Three Candles)", refId = "light_com_sconce_02_128", price = 25},
{name = "Wall Sconce (Single Candle)", refId = "light_com_sconce_01", price = 25},
{name = "Standing Candleholder (Three Candles)", refId = "light_com_lamp_02_128", price = 50},
{name = "Chandelier, Simple (Four Candles)", refId = "light_com_chandelier_03", price = 50},

--Special Containers
{name = "Skeleton 1", refId = "contain_corpse00", price = 122}, --120 for weight + 2 for the bonemeal :P
{name = "Skeleton 2", refId = "contain_corpse10", price = 122},
{name = "Skeleton 3", refId = "contain_corpse20", price = 122},

--Misc
{name = "Anvil", refId = "furn_anvil00", price = 200},
{name = "Keg On Stand", refId = "furn_com_kegstand", price = 200},
{name = "Cauldron, Standing", refId = "furn_com_cauldron_01", price = 100},
{name = "Ashpit", refId = "in_velothi_ashpit_01", price = 100},
{name = "Shack Awning", refId = "ex_de_shack_awning_03", price = 100},
{name = "Mounted Bear Head (Brown)", refId = "bm_bearhead_brown", price = 200},
{name = "Mounted Wolf Head (White)", refId = "bm_wolfhead_white", price = 200},
{name = "Paper Wallscreen", refId = "furn_de_r_wallscreen_02", price = 100},

{name = "Banner (Imperial, Tapestry 2 - Tree)", refId = "furn_com_tapestry_02", price = 100},
{name = "Banner (Imperial, Tapestry 3)", refId = "furn_com_tapestry_03", price = 100},
{name = "Banner (Imperial, Tapestry 4 - Empire)", refId = "furn_com_tapestry_04", price = 100},
{name = "Banner (Imperial, Tapestry 5)", refId = "furn_com_tapestry_05", price = 100},

{name = "Banner (Dunmer, Tapestry 2)", refId = "furn_de_tapestry_02", price = 100},
{name = "Banner (Dunmer, Tapestry 5)", refId = "furn_de_tapestry_05", price = 100},
{name = "Banner (Dunmer, Tapestry 6)", refId = "furn_de_tapestry_06", price = 100},
{name = "Banner (Dunmer, Tapestry 7)", refId = "furn_de_tapestry_07", price = 100},

{name = "Banner (Temple 1)", refId = "furn_banner_temple_01_indoors", price = 100},
{name = "Banner (Temple 2)", refId = "furn_banner_temple_02_indoors", price = 100},
{name = "Banner (Temple 3)", refId = "furn_banner_temple_03_indoors", price = 100},

{name = "Banner (Akatosh)", refId = "furn_c_t_akatosh_01", price = 100},
{name = "Banner (Arkay)", refId = "furn_c_t_arkay_01", price = 100},
{name = "Banner (Dibella)", refId = "furn_c_t_dibella_01", price = 100},
{name = "Banner (Juilianos)", refId = "furn_c_t_julianos_01", price = 100},
{name = "Banner (Kynareth)", refId = "furn_c_t_kynareth_01", price = 100},
{name = "Banner (Mara)", refId = "furn_c_t_mara_01", price = 100},
{name = "Banner (Stendarr)", refId = "furn_c_t_stendarr_01", price = 100},
{name = "Banner (Zenithar)", refId = "furn_c_t_zenithar_01", price = 100},

{name = "Banner (Apprentice)", refId = "furn_c_t_apprentice_01", price = 100},
{name = "Banner (Golem)", refId = "furn_c_t_golem_01", price = 100},
{name = "Banner (Lady)", refId = "furn_c_t_lady_01", price = 100},
{name = "Banner (Lord)", refId = "furn_c_t_lord_01", price = 100},
{name = "Banner (Lover)", refId = "furn_c_t_lover_01", price = 100},
{name = "Banner (Ritual)", refId = "furn_c_t_ritual_01", price = 100},
{name = "Banner (Shadow)", refId = "furn_c_t_shadow_01", price = 100},
{name = "Banner (Steed)", refId = "furn_c_t_steed_01", price = 100},
{name = "Banner (Thief)", refId = "furn_c_t_thief_01", price = 100},
{name = "Banner (Tower)", refId = "furn_c_t_tower_01", price = 100},
{name = "Banner (Warrior)", refId = "furn_c_t_warrior_01", price = 100},
{name = "Banner (Wizard)", refId = "furn_c_t_wizard_01", price = 100},

--[[
--Dwarven Furniture Set
{name = "Heavy Dwemer Chest", refId = "dwrv_chest00", price = 200}, --NOTE: Contains 2 random dwarven items
{name = "Heavy Dwemer Chest", refId = "dwrv_chest00", price = 200},
{name = "Dwemer Cabinet", refId = "dwrv_cabinet10", price = 200},
{name = "Dwemer Desk", refId = "dwrv_desk00", price = 50},
{name = "Dwemer Drawers", refId = "dwrv_desk00", price = 300}, --NOTE: Contains paper + one dwarven coin
{name = "Dwemer Drawer Table", refId = "dwrv_table00", price = 50}, --NOTE: Contains dwarven coin
{name = "Dwemer Chair", refId = "furn_dwrv_chair00", price = 000},
{name = "Dwemer Shelf", refId = "furn_dwrv_bookshelf00", price = 000},

--in_dwe_slate00 to in_dwe_slate11
--furn_com_p_table_01
--furn_com_planter
]]
}
-- {name = "name", refId = "ref_id", price = 50},

------------
decorateHelp = require("custom.decorateHelp")
tableHelper = require("tableHelper")

local Methods = {}
--Forward declarations:
local showMainGUI, showBuyGUI, showInventoryGUI, showViewGUI, showInventoryOptionsGUI, showViewOptionsGUI
------------
local playerBuyOptions = {} --Used to store the lists of items each player is offered so we know what they're trying to buy
local playerInventoryOptions = {} --
local playerInventoryChoice = {}
local playerViewOptions = {} -- [pname = [index = [refIndex = x, refId = y] ]
local playerViewChoice = {}

-- ===========
--  DATA ACCESS
-- ===========

local function getFurnitureInventoryTable()
	return WorldInstance.data.customVariables.kanaFurniture.inventories
end

local function getPermissionsTable()
	return WorldInstance.data.customVariables.kanaFurniture.permissions
end

local function getPlacedTable()
	return WorldInstance.data.customVariables.kanaFurniture.placed
end

local function addPlaced(refIndex, cell, pname, refId, save)
	local placed = getPlacedTable()
	
	if not placed[cell] then
		placed[cell] = {}
	end
	
	placed[cell][refIndex] = {owner = pname, refId = refId}
	
	if save then
		WorldInstance:Save()
	end
end

local function removePlaced(refIndex, cell, save)
	local placed = getPlacedTable()
	
	placed[cell][refIndex] = nil
	
	if save then
		WorldInstance:Save()
	end
end

local function getPlaced(cell)
	local placed = getPlacedTable()
	
	if placed[cell] then
		return placed[cell]
	else
		return false
	end
end

local function addFurnitureItem(pname, refId, count, save)
	local fInventories = getFurnitureInventoryTable()
	
	if fInventories[pname] == nil then
		fInventories[pname] = {}
	end
	
	fInventories[pname][refId] = (fInventories[pname][refId] or 0) + (count or 1)
	
	--Remove the entry if the count is 0 or less (so we can use this function to remove items, too!)
	if fInventories[pname][refId] <= 0 then
		fInventories[pname][refId] = nil
	end
	
	if save then
		WorldInstance:Save()
	end
end

Methods.OnServerPostInit = function()
	--Create the script's required data if it doesn't exits
	if WorldInstance.data.customVariables.kanaFurniture == nil then
		WorldInstance.data.customVariables.kanaFurniture = {}
		WorldInstance.data.customVariables.kanaFurniture.placed = {}
		WorldInstance.data.customVariables.kanaFurniture.permissions = {}
		WorldInstance.data.customVariables.kanaFurniture.inventories = {}
		WorldInstance:Save()
	end
	
	--Slight Hack for updating pnames to their new values. In release 1, the script stored player names as their login names, in release 2 it stores them as their all lowercase names.
	local placed = getPlacedTable()
	for cell, v in pairs(placed) do
		for refIndex, v in pairs(placed[cell]) do
			placed[cell][refIndex].owner = string.lower(placed[cell][refIndex].owner)
		end
	end
	local permissions = getPermissionsTable()
		
	for cell, v in pairs(permissions) do
		local newNames = {}
		
		for pname, v in pairs(permissions[cell]) do
			table.insert(newNames, string.lower(pname))
		end
		
		permissions[cell] = {}
		for k, newName in pairs(newNames) do
			permissions[cell][newName] = true
		end
	end
	
	local inventories = getFurnitureInventoryTable()
	local newInventories = {}
	for pname, invData in pairs(inventories) do
		newInventories[string.lower(pname)] = invData
	end
	
	WorldInstance.data.customVariables.kanaFurniture.inventories = newInventories
	
	WorldInstance:Save()
end

-------------------------

local function getSellValue(baseValue)
	return math.max(0, math.floor(baseValue * config.sellbackModifier))
end

local function getName(pid)
	--return Players[pid].data.login.name
	--Release 2 change: Now uses all lowercase name for storage
	return string.lower(Players[pid].accountName)
end

local function getObject(refIndex, cell)
	if refIndex == nil then
		return false
	end
	
	if not LoadedCells[cell] then
		--TODO: Should ideally be temporary
		logicHandler.LoadCell(cell)
	end

	if LoadedCells[cell]:ContainsObject(refIndex)  then 
		return LoadedCells[cell].data.objectData[refIndex]
	else
		return false
	end	
end

--Returns the amount of gold in a player's inventory
local function getPlayerGold(pid)
	local goldLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, "gold_001", -1)
	
	if goldLoc then
		return Players[pid].data.inventory[goldLoc].count
	else
		return 0
	end
end

local function addGold(pid, amount)
	--TODO: Add functionality to add gold to offline player's inventories, too
	local goldLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, "gold_001", -1)
	
	if goldLoc then
		Players[pid].data.inventory[goldLoc].count = Players[pid].data.inventory[goldLoc].count + amount
	else
		table.insert(Players[pid].data.inventory, {refId = "gold_001", count = amount, charge = -1})
	end
	
	Players[pid]:Save()
	Players[pid]:LoadInventory()
	Players[pid]:LoadEquipment()
end

local function getFurnitureData(refId)
	local location = tableHelper.getIndexByNestedKeyValue(furnitureData, "refId", refId)
	if location then
		return furnitureData[location], location
	else
		return false
	end
end

local function hasPlacePermission(pname, cell)
	local perms = getPermissionsTable()
	
	if not config.whitelist then
		return true
	end
	
	if perms[cell] then
		if perms[cell]["all"] or perms[cell][pname] then
			return true
		else
			return false
		end
	else
		--There's not even any data for that cell
		return false
	end
end

local function getPlayerFurnitureInventory(pid)
	local invlist = getFurnitureInventoryTable()
	local pname = getName(pid)
	
	if invlist[pname] == nil then
		invlist[pname] = {}
		WorldInstance:Save()
	end
	
	return invlist[pname]
end

local function getSortedPlayerFurnitureInventory(pid)
	local inv = getPlayerFurnitureInventory(pid)
	local sorted = {}
	
	for refId, amount in pairs(inv) do
		local name = getFurnitureData(refId).name
		table.insert(sorted, {name = name, count = amount, refId = refId})
	end
	
	return sorted
end

local function placeFurniture(refId, loc, cell)
	local useTempLoad = false
	
	local location = {
		posX = loc.x, posY = loc.y, posZ = loc.z,
		rotX = 0, rotY = 0, rotZ = 0
	}
	
	if not LoadedCells[cell] then
		logicHandler.LoadCell(cell)
		useTempLoad = true
	end

	local uniqueIndex = logicHandler.CreateObjectAtLocation(cell, location, refId, "place")
	
	if useTempLoad then
		logicHandler.UnloadCell(cell)
	end
	
	return uniqueIndex
end

local function removeFurniture(refIndex, cell)
	--If for some reason the cell isn't loaded, load it. Causes a bit of spam in the server log, but that can't really be helped.
	local useTempLoad = false
	
	if LoadedCells[cell] == nil then
		logicHandler.LoadCell(cell)
		useTempLoad = true
	end
	
	if LoadedCells[cell]:ContainsObject(refIndex) and not tableHelper.containsValue(LoadedCells[cell].data.packets.delete, refIndex) then --Shouldn't ever have a delete packet, but it's worth checking anyway
		--Delete the object for all the players currently online
		logicHandler.DeleteObjectForEveryone(cell, refIndex)
		
		LoadedCells[cell]:DeleteObjectData(refIndex)
		LoadedCells[cell]:Save()
		--Removing the object from the placed list will be done elsewhere
	end
	
	if useTempLoad then
		logicHandler.UnloadCell(cell)
	end
end

local function getAvailableFurnitureStock(pid)
	--In the future this can be used to customise what items are available for a particular player, like making certain items only available for things like their race, class, level, their factions, or the quests they've completed. For now, however, everything in furnitureData is available :P
	
	local options = {}
	
	for i = 1, #furnitureData do
		table.insert(options, furnitureData[i])
	end
	
	return options
end

--If the player has placed items in the cell, returns an indexed table containing all the refIndexes of furniture that they have placed.
local function getPlayerPlacedInCell(pname, cell)
	local cellPlaced = getPlaced(cell)
	
	if not cellPlaced then
		-- Nobody has placed items in this cell
		return false
	end
	
	local list = {}
	for refIndex, data in pairs(cellPlaced) do
		if data.owner == pname then
			table.insert(list, refIndex)
		end
	end
	
	if #list > 0 then
		return list
	else
		--The player hasn't placed any items in this cell
		return false
	end
end

local function addFurnitureData(data)
	--Check the furniture doesn't already have an entry, if it does, overwrite it
	--TODO: Should probably check that the data is valid
	local fdata, loc = getFurnitureData(data.refId)
	
	if fdata then
		furnitureData[loc] = data
	else
		table.insert(furnitureData, data)
	end
end

Methods.AddFurnitureData = function(data)
	addFurnitureData(data)
end
--NOTE: Both AddPermission and RemovePermission use pname, rather than pid
Methods.AddPermission = function(pname, cell)
	local perms = getPermissionsTable()
	
	if not perms[cell] then
		perms[cell] = {}
	end
	
	perms[cell][pname] = true
	WorldInstance:Save()
end

Methods.RemovePermission = function(pname, cell)
	local perms = getPermissionsTable()
	
	if not perms[cell] then
		return
	end
	
	perms[cell][pname] = nil
	
	WorldInstance:Save()
end

Methods.RemoveAllPermissions = function(cell)
	local perms = getPermissionsTable()
	
	perms[cell] = nil
	WorldInstance:Save()
end

Methods.RemoveAllPlayerFurnitureInCell = function(pname, cell, returnToOwner)
	local placed = getPlacedTable()
	local cInfo = placed[cell] or {}
	
	for refIndex, info in pairs(cInfo) do
		if info.owner == pname then
			if returnToOwner then
				addFurnitureItem(info.owner, info.refId, 1, false)
			end
			removeFurniture(refIndex, cell)
			removePlaced(refIndex, cell, false)
		end
	end
	WorldInstance:Save()
end

Methods.RemoveAllFurnitureInCell = function(cell, returnToOwner)
	local placed = getPlacedTable()
	local cInfo = placed[cell] or {}
	
	for refIndex, info in pairs(cInfo) do
		if returnToOwner then
			addFurnitureItem(info.owner, info.refId, 1, false)
		end
		removeFurniture(refIndex, cell)
		removePlaced(refIndex, cell, false)
	end
	WorldInstance:Save()
end

--Change the ownership of the specified furniture object (via refIndex) to another character's (playerToName). If playerCurrentName is false, the owner will be changed to the new one regardless of who owned it first.
Methods.TransferOwnership = function(refIndex, cell, playerCurrentName, playerToName, save)
	local placed = getPlacedTable()
	
	if placed[cell] and placed[cell][refIndex] and (placed[cell][refIndex].owner == playerCurrentName or not playerCurrentName) then
		placed[cell][refIndex].owner = playerToName
	end
	
	if save then
		WorldInstance:Save()
	end
	
	--Unset the current player's selected item, just in case they had that furniture as their selected item
	if playerCurrentName and logicHandler.IsPlayerNameLoggedIn(playerCurrentName) then
		decorateHelp.SetSelectedObject(logicHandler.GetPlayerByName(playerCurrentName).pid, "")
	end
end

--Same as TransferOwnership, but for all items in a given cell
Methods.TransferAllOwnership = function(cell, playerCurrentName, playerToName, save)
	local placed = getPlacedTable()
	
	if not placed[cell] then
		return false
	end
	
	for refIndex, info in pairs(placed[cell]) do
		if not playerCurrentName or info.owner == playerCurrentName then
			placed[cell][refIndex].owner = playerToName
		end
	end
	
	if save then
		WorldInstance:Save()
	end
	
	--Unset the current player's selected item, just in case they had any of the furniture as their selected item
	if playerCurrentName and logicHandler.IsPlayerNameLoggedIn(playerCurrentName) then
		decorateHelp.SetSelectedObject(logicHandler.GetPlayerByName(playerCurrentName).pid, "")
	end
end

--New Release 2 Methods:
Methods.GetSellBackPrice = function(value)
	return getSellValue(value)
end

Methods.GetFurnitureDataByRefId = function(refId)
	return getFurnitureData(refId)
end

Methods.GetPlacedInCell = function(cell)
	return getPlaced(cell)
end


-- ====
--  GUI
-- ====

-- VIEW (OPTIONS)
showViewOptionsGUI = function(pid, loc)
	local message = ""
	local choice = playerViewOptions[getName(pid)][loc]
	local fdata = getFurnitureData(choice.refId)
	
	message = message .. "Item Name: " .. fdata.name .. " (RefIndex: " .. choice.refIndex .. "). Price: " .. fdata.price .. " (Sell price: " .. getSellValue(fdata.price) .. ")"
	
	playerViewChoice[getName(pid)] = choice
	tes3mp.CustomMessageBox(pid, config.ViewOptionsGUI, message, "Select;Put Away;Sell;Close")
end

local function onViewOptionSelect(pid)
	local pname = getName(pid)
	local choice = playerViewChoice[pname]
	local cell = tes3mp.GetCell(pid)
	
	if getObject(choice.refIndex, cell) then
		decorateHelp.SetSelectedObject(pid, choice.refIndex)
		tes3mp.MessageBox(pid, -1, "Object selected, use /dh to move.")
	else
		tes3mp.MessageBox(pid, -1, "The object seems to have been removed.")
	end
end

local function onViewOptionPutAway(pid)
	local pname = getName(pid)
	local choice = playerViewChoice[pname]
	local cell = tes3mp.GetCell(pid)
	
	if getObject(choice.refIndex, cell) then
		removeFurniture(choice.refIndex, cell)
		removePlaced(choice.refIndex, cell, true)
		
		addFurnitureItem(pname, choice.refId, 1, true)
		tes3mp.MessageBox(pid, -1, getFurnitureData(choice.refId).name .. " has been added to your furniture inventory.")
	else
		tes3mp.MessageBox(pid, -1, "The object seems to have been removed.")
	end
end

local function onViewOptionSell(pid)
	local pname = getName(pid)
	local choice = playerViewChoice[pname]
	local cell = tes3mp.GetCell(pid)
	
	if getObject(choice.refIndex, cell) then
		local saleGold = getSellValue(getFurnitureData(choice.refId).price)
		
		--Add gold to inventory
		addGold(pid, saleGold)
		
		--Remove the item from the cell
		removeFurniture(choice.refIndex, cell)
		removePlaced(choice.refIndex, cell, true)
		
		--Inform the player
		tes3mp.MessageBox(pid, -1, saleGold .. " Gold has been added to your inventory and the furniture has been removed from the cell.")
	else
		tes3mp.MessageBox(pid, -1, "The object seems to have been removed.")
	end
end

-- VIEW (MAIN)
showViewGUI = function(pid)
	local pname = getName(pid)
	local cell = tes3mp.GetCell(pid)
	local options = getPlayerPlacedInCell(pname, cell)
	
	local list = "* CLOSE *\n"
	local newOptions = {}
	
	if options and #options > 0 then
		for i = 1, #options do
			--Make sure the object still exists, and get its data
			local object = getObject(options[i], cell)
			
			if object then
				local furnData = getFurnitureData(object.refId)
				
				list = list .. furnData.name .. " (at " .. math.floor(object.location.posX + 0.5) .. ", "  ..  math.floor(object.location.posY + 0.5) .. ", " .. math.floor(object.location.posZ + 0.5) .. ")"
				if not(i == #options) then
					list = list .. "\n"
				end
				
				table.insert(newOptions, {refIndex = options[i], refId = object.refId})
			end
		end
	end
	
	playerViewOptions[pname] = newOptions
	tes3mp.ListBox(pid, config.ViewGUI, "Select a piece of furniture you've placed in this cell. Note: The contents of containers will be lost if removed.", list)
	--getPlayerPlacedInCell(pname, cell)
end

local function onViewChoice(pid, loc)
	showViewOptionsGUI(pid, loc)
end

-- INVENTORY (OPTIONS)
showInventoryOptionsGUI = function(pid, loc)
	local message = ""
	local choice = playerInventoryOptions[getName(pid)][loc]
	local fdata = getFurnitureData(choice.refId)
	
	message = message .. "Item Name: " .. choice.name .. ". Price: " .. fdata.price .. " (Sell price: " .. getSellValue(fdata.price) .. ")"
	
	playerInventoryChoice[getName(pid)] = choice
	tes3mp.CustomMessageBox(pid, config.InventoryOptionsGUI, message, "Place;Sell;Close")
end

local function onInventoryOptionPlace(pid)
	local pname = getName(pid)
	local curCell = tes3mp.GetCell(pid)
	local choice = playerInventoryChoice[pname]
	
	--First check the player is allowed to place items where they are currently
	if config.whitelist and not hasPlacePermission(pname, curCell) then
		--Player isn't allowed
		tes3mp.MessageBox(pid, -1, "You don't have permission to place furniture here.")
		return false
	end
	
	--Remove 1 instance of the item from the player's inventory
	addFurnitureItem(pname, choice.refId, -1, true)
	
	--Place the furniture in the world
	local pPos = {x = tes3mp.GetPosX(pid), y = tes3mp.GetPosY(pid), z = tes3mp.GetPosZ(pid)}
	local furnRefIndex = placeFurniture(choice.refId, pPos, curCell)
	
	--Update the database of all placed furniture
	addPlaced(furnRefIndex, curCell, pname, choice.refId, true)
	--Set the placed item as the player's active object for decorateHelp to use
	decorateHelp.SetSelectedObject(pid, furnRefIndex)
end

local function onInventoryOptionSell(pid)
	local pname = getName(pid)
	local choice = playerInventoryChoice[pname]
	
	local saleGold = getSellValue(getFurnitureData(choice.refId).price)
	
	--Add gold to inventory
	addGold(pid, saleGold)
	
	--Remove 1 instance of the item from the player's inventory
	addFurnitureItem(pname, choice.refId, -1, true)
	
	--Inform the player
	tes3mp.MessageBox(pid, -1, saleGold .. " Gold has been added to your inventory.")
end

-- INVENTORY (MAIN)
showInventoryGUI = function(pid)
	local options = getSortedPlayerFurnitureInventory(pid)
	local list = "* CLOSE *\n"
	
	for i = 1, #options do
		list = list .. options[i].name .. " (" .. options[i].count .. ")"
		if not(i == #options) then
			list = list .. "\n"
		end
	end
	
	playerInventoryOptions[getName(pid)] = options
	tes3mp.ListBox(pid, config.InventoryGUI, "Select the piece of furniture from your inventory that you wish to do something with", list)
end

local function onInventoryChoice(pid, loc)
	showInventoryOptionsGUI(pid, loc)
end

-- BUY (MAIN)
showBuyGUI = function(pid)
	local options = getAvailableFurnitureStock(pid)
	local list = "* CLOSE *\n"
	
	for i = 1, #options do
		list = list .. options[i].name .. " (" .. options[i].price .. " Gold)"
		if not(i == #options) then
			list = list .. "\n"
		end
	end
	
	playerBuyOptions[getName(pid)] = options
	tes3mp.ListBox(pid, config.BuyGUI, "Select an item you wish to buy", list)
end

local function onBuyChoice(pid, loc)
	local pgold = getPlayerGold(pid)
	local choice = playerBuyOptions[getName(pid)][loc]
	
	if pgold < choice.price then
		tes3mp.MessageBox(pid, -1, "You can't afford to buy a " .. choice.name .. ".")
		return false
	end
	
	addGold(pid, -choice.price)
	addFurnitureItem(getName(pid), choice.refId, 1, true)
	
	tes3mp.MessageBox(pid, -1, "A " .. choice.name .. " has been added to your furniture inventory.")
	return true
end

-- MAIN
showMainGUI = function(pid)
	local message = "Welcome to the furniture menu. Use 'Buy' to purchase furniture for your furniture inventory, 'Inventory' to view the furniture items you own, 'View' to display a list of all the furniture that you own in the cell you're currently in.\n\nNote: The current version of tes3mp doesn't really like when lots of items are added to a cell, so try to restrain yourself from complete home renovations."
	tes3mp.CustomMessageBox(pid, config.MainGUI, message, "Buy;Inventory;View;Close")
end

local function onMainBuy(pid)
	showBuyGUI(pid)
end

local function onMainInventory(pid)
	showInventoryGUI(pid)
end

local function onMainView(pid)
	showViewGUI(pid)
end

-- GENERAL
Methods.OnGUIAction = function(pid, idGui, data)
	
	if idGui == config.MainGUI then -- Main
		if tonumber(data) == 0 then --Buy
			onMainBuy(pid)
			return true
		elseif tonumber(data) == 1 then -- Inventory
			onMainInventory(pid)
			return true
		elseif tonumber(data) == 2 then -- View
			onMainView(pid)
			return true
		elseif tonumber(data) == 3 then -- Close
			--Do nothing
			return true
		end
	elseif idGui == config.BuyGUI then -- Buy
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then --Close/Nothing Selected
			--Do nothing
			return true
		else
			onBuyChoice(pid, tonumber(data))
			return true
		end
	elseif idGui == config.InventoryGUI then --Inventory main
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then --Close/Nothing Selected
			--Do nothing
			return true
		else
			onInventoryChoice(pid, tonumber(data))
			return true
		end
	elseif idGui == config.InventoryOptionsGUI then --Inventory options
		if tonumber(data) == 0 then --Place
			onInventoryOptionPlace(pid)
			return true
		elseif tonumber(data) == 1 then --Sell
			onInventoryOptionSell(pid)
			return true
		else --Close
			--Do nothing
			return true
		end
	elseif idGui == config.ViewGUI then --View
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then --Close/Nothing Selected
			--Do nothing
			return true
		else
			onViewChoice(pid, tonumber(data))
			return true
		end
	elseif idGui == config.ViewOptionsGUI then -- View Options
		if tonumber(data) == 0 then --Select
			onViewOptionSelect(pid)
			return true
		elseif tonumber(data) == 1 then --Put away
			onViewOptionPutAway(pid)
		elseif tonumber(data) == 2 then --Sell
			onViewOptionSell(pid)
		else --Close
			--Do nothing
			return true
		end
	end
end

Methods.OnCommand = function(pid)
	showMainGUI(pid)
end

customCommandHooks.registerCommand("furniture", Methods.OnCommand)
customCommandHooks.registerCommand("furn", Methods.OnCommand)

customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	if kanaFurniture.OnGUIAction(pid, idGui, data) then
		return
	end
end)

customEventHooks.registerHandler("OnServerPostInit", function(eventStatus)
	kanaFurniture.OnServerPostInit()
end)

return Methods
