
-- kanaFurniture - Release 2 - For tes3mp v0.7.0
-- REQUIRES: decorateHelp (https://github.com/Atkana/tes3mp-scripts/blob/master/decorateHelp.lua)
-- Purchase and place an assortment of furniture

-- NOTE FOR SCRIPTS: pname requires the name to be in all LOWERCASE

--[[ INSTALLATION:
1) Save this file as "kanaFurniture.lua" in server/scripts/custom
2) Add [ kanaFurniture = require("custom.kanaFurniture") ] to the top of customScripts.lua

]]

decorateHelp = require("custom.decorateHelp")
tableHelper = require("tableHelper")
eventHandler = require("eventHandler")

local config = {}
config.whitelist = true --false --If true, the player must be given permission to place items in the cell that they're in (set using this script's methods, or editing the world.json). Note that this only prevents placement, players can still move/remove items they've placed in the cell.
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

local furnitureAdminData = {
--Admin Items
{name = "", refId = "", price = 00},
{name = "#red ..ADMIN", refId = "#option", price = 00},
{name = "Balmora Signpost", refId = "balmora_signpost_custom_01", price = 0},
{name = "Public Bank", refId = "player_bank_storage_public", price = 0},
{name = "Clutter Warehouse Exterior", refId = "clutter_warehouse_ext_static", price = 0},
{name = "Clutter Warehouse Door", refId = "clutter_warehouse_ext_door", price = 0},
{name = "Clutter Warehouse Door Exit", refId = "clutter_warehouse_int_door_exit", price = 0},
{name = "Clutter Warehouse Doorjamb", refId = "clutter_warehouse_int_doorjamb", price = 0},
{name = "Int RoomT Corner", refId = "clutter_warehouse_int_roomt_corner_piece", price = 0},
{name = "Int RoomT Side", refId = "clutter_warehouse_int_roomt_side_piece", price = 0},
{name = "Int RoomT Door Side", refId = "clutter_warehouse_int_roomt_side_door_piece", price = 0},
{name = "Int Hlaalu Room T Side Door", refId = "in_hlaalu_roomt_sided", price = 0},
{name = "Int Hlaalu Wall", refId = "in_hlaalu_wall", price = 0},
{name = "Light Candle 1", refId = "light_de_candle_01", price = 0},
{name = "Light Candle 1", refId = "light_de_candle_01", price = 0},
{name = "Light Candle 2", refId = "light_de_candle_02", price = 0},
--{name = "Light Candle 3", refId = "light_de_candle_03", price = 0},
{name = "Light Candle 4", refId = "light_de_candle_04", price = 0},
{name = "Light Candle 7", refId = "light_de_candle_07", price = 0},
{name = "Light Candle 8", refId = "light_de_candle_08", price = 0},
{name = "Light Candle Wax Trio", refId = "light_com_candle_07", price = 0},
{name = "Light Lamp Candle (Green)", refId = "light_de_lamp_02_256", price = 0},
{name = "Light Lamp Candle (Red)", refId = "light_de_lamp_03_256", price = 0},
{name = "Wall Sconce 128", refId = "light_sconce00_128", price = 0},
{name = "Altar", refId = "furn_velothi_altar_01", price = 0},
{name = "Solstheim Bridge", refId = "ex_s_bridge", price = 0},
{name = "Vivec Arena (Huge)", refId = "in_v_arena_01", price = 0},
{name = "wooden door single 1", refId = "wooden_door_single_1", price = 0},
{name = "wooden door double 1", refId = "wooden_door_double_1", price = 0},
{name = "light brazier", refId = "light_velothi_brazier_177", price = 0},
{name = "street light", refId = "light_de_streetlight_01_223_S", price = 0},
{name = "street light post", refId = "furn_de_lightpost_01", price = 0},


{name = "Thirsk Doorway Interior", refId = "in_thirsk_doorway", price = 0},
{name = "Thirsk Downstairs Interior", refId = "in_thirsk_downstairs", price = 0},
{name = "Thirsk Upstairs Interior", refId = "in_thirsk_upstairs", price = 0},
-- Horkey
{name = "Ashlander Tent 04", refId = "ex_ashl_tent_04", price = 0},
-- Rals Requested Stuff start
{name = "ex_t_root_hook", refId = "ex_t_root_hook", price = 0},
{name = "ex_t_door_01", refId = "ex_t_door_01", price = 0},
{name = "ex_t_door_02", refId = "ex_t_door_02", price = 0},
{name = "ex_t_councilhall", refId = "ex_t_councilhall", price = 0},
{name = "ex_t_housestem_01", refId = "ex_t_housestem_01", price = 0},
{name = "ex_t_stair_spiral", refId = "ex_t_stair_spiral", price = 0},
{name = "light_de_streetlight_01", refId = "light_de_streetlight_01", price = 0},
{name = "act_crystal_01_pulse", refId = "act_crystal_01_pulse", price = 0},
{name = "in_velothilarge_connector_01", refId = "in_velothilarge_connector_01", price = 0},
{name = "in_om_trap", refId = "in_om_trap", price = 0},
{name = "in_py_rock_05", refId = "in_py_rock_05", price = 0},
{name = "in_pycave_21_1", refId = "in_pycave_21_1", price = 0},
{name = "in_pycave_21_1", refId = "in_impsmall_d_hidden_01", price = 0},
{name = "furn planter", refId = "furn_planter_mh_01", price = 0},
{name = "mournhold tree 1", refId = "act_flora_tree_mh_01", price = 0},
{name = "ex stronghold pylon01", refId = "ex_stronghold_pylon01", price = 0},
{name = "terrain bc scum 01", refId = "terrain_bc_scum_01", price = 0},
{name = "door load darkness00", refId = "door_load_darkness00", price = 0},
{name = "in lava blacksquare", refId = "in_lava_blacksquare", price = 0},
{name = "in lava 1024", refId = "in_lava_1024", price = 0},
-- Rals Requested Stuff end
{name = "", refId = "", price = 00},
{name = "", refId = "", price = 00},
{name = "#red ..XMAS EVENT", refId = "#option", price = 00},
{name = "Tree Small", refId = "flora_tree_bm_04", price = 0},
{name = "Tree Large", refId = "flora_tree_bm_05", price = 0},
{name = "Twinkle Effect", refId = "light_sotha_sparks", price = 0},
{name = "Twinkle Effect Large", refId = "light_sotha_sparks_hi", price = 0},
{name = "Tree Light Blue", refId = "light_ashl_lantern_01", price = 0},
{name = "Tree Light Orange", refId = "light_ashl_lantern_02", price = 0},
{name = "Tree Light Red", refId = "light_ashl_lantern_03", price = 0},
{name = "Tree Light Purple", refId = "light_ashl_lantern_04", price = 0},
{name = "Tree Light Yellow", refId = "light_ashl_lantern_05", price = 0},
{name = "Tree Light Teal", refId = "light_ashl_lantern_06", price = 0},
{name = "Tree Light Dark Blue", refId = "light_ashl_lantern_07", price = 0},
{name = "Tree Bedding", refId = "bm_ka_bedding", price = 0},
{name = "Tree Rock Small", refId = "terrain_rock_wg_14", price = 0},
{name = "Small Bag of Goodies", refId = "xmas_presents_01", price = 0},
{name = "Large Bag of Goodies", refId = "xmas_presents_02", price = 0},
{name = "Small Chest of Goodies", refId = "xmas_presents_03", price = 0},
{name = "Large Crate of Goodies", refId = "xmas_presents_04", price = 0},
{name = "Large Basket of Goodies", refId = "xmas_presents_05", price = 0},
{name = "Large Urn of Goodies", refId = "xmas_presents_06", price = 0},
{name = "Large Chest of Goodies", refId = "xmas_presents_07", price = 0},
{name = "Large Crate of Curiosities", refId = "xmas_presents_08", price = 0},

}

local furnitureData = {

--Survival
{name = "", refId = "", price = 00},
{name = "#red ..SURVIVAL", refId = "#option", price = 00},
{name = "Bedroll", refId = "active_de_bedroll", price = 100},
{name = "Survival tent", refId = "ex_mh_bazaar_tent", price = 500},
{name = "Campfire", refId = "furn_de_firepit_01", price = 100},

--Containers
{name = "", refId = "", price = 00},
{name = "#red ..CONTAINERS", refId = "#option", price = 00},
{name = "Barrel 1", refId = "barrel_01", price = 50},
{name = "Barrel 2", refId = "barrel_02", price = 50},
{name = "Crate 1", refId = "crate_01_empty", price = 200},
{name = "Crate 2", refId = "crate_02_empty", price = 200},
{name = "Basket", refId = "com_basket_01", price = 50},
{name = "Sack (Dish)", refId = "com_sack_01", price = 50},
{name = "Sack (Sack)", refId = "com_sack_02", price = 50},
{name = "Sack (Crumples)", refId = "com_sack_03", price = 50},
{name = "Sack (Lightweight)", refId = "com_sack_00", price = 50},
{name = "Urn 1", refId = "urn_01", price = 100},
{name = "Urn 2", refId = "urn_02", price = 100},
{name = "Urn 3", refId = "urn_03", price = 100},
{name = "Urn 4", refId = "urn_04", price = 100},
{name = "Urn 5", refId = "urn_05", price = 100},
{name = "Urn, 6th House", refId = "urn_05", price = 1000},
{name = "Dwarven Barrel 1", refId = "dwrv_barrel00_empty", price = 150},
{name = "Dwarven Barrel 2", refId = "dwrv_barrel10_empty", price = 75},
{name = "Trough (6th House)", refId = "furn_6th_troth_01", price = 75},

--Chesty Containers
{name = "", refId = "#option", price = 00},
{name = "#red ..CHESTS", refId = "#option", price = 00},
{name = "Cheap Chest", refId = "com_chest_11_empty", price = 150},
{name = "Cheap Chest (Open)", refId = "com_chest_11_open", price = 150},
{name = "Small Chest (Metal)", refId = "chest_small_01", price = 50}, --*2 price because fancier material
{name = "Small Chest (Wood)", refId = "chest_small_02", price = 25},

--Unique
{name = "", refId = "#option", price = 00},
{name = "#red ..BANK", refId = "#option", price = 00},
{name = "Personal Safe", refId = "player_bank_storage_personal", price = 500000},
--{name = "Sales Chest", refId = "de_r_chest_01", price = 50000},

--Imperial Furniture Set
{name = "", refId = "#option", price = 00},
{name = "#red ..IMPERIAL", refId = "#option", price = 00},
{name = "Imperial Closet", refId = "com_closet_01", price = 300},
{name = "Imperial Cupboard", refId = "com_cupboard_01", price = 100},
{name = "Imperial Drawers", refId = "com_drawers_01", price = 300},
{name = "Imperial Hutch", refId = "com_hutch_01", price = 75},
{name = "Imperial Chest (Cheap)", refId = "com_chest_01", price = 150},
{name = "Imperial Chest (Expensive)", refId = "com_chest_02", price = 400}, --*2 price because fancier

--Dunmer Furniture Set
{name = "", refId = "#option", price = 00},
{name = "#red ..TEMPLE", refId = "#option", price = 00},
{name = "Dunmer Closet (Cheap)", refId = "de_p_closet_02", price = 300},
{name = "Dunmer Closet (Expensive)", refId = "de_r_closet_01", price = 600}, --*2 for quality
{name = "Dunmer Desk", refId = "de_p_desk_01", price = 75},
{name = "Dunmer Drawer (Cheap)", refId = "de_drawers_02", price = 300},
{name = "Dunmer Drawer (Expensive)", refId = "de_r_drawers_01", price = 600},
{name = "Dunmer Drawer Table (Large)", refId = "de_p_table_02", price = 25},
{name = "Dunmer Drawer Table (Small)", refId = "de_p_table_01", price = 25},
{name = "Dunmer chest (Cheap)", refId = "de_r_chest_01", price = 200},
{name = "Dunmer chest (Expensive)", refId = "de_p_chest_02", price = 400}, --*2 because fancy
{name = "Shrine of St. Aralor", refId = "furn_shrine_aralor_cure_01", price = 40000},
{name = "Shrine of St. Delyn", refId = "furn_shrine_delyn_cure_01", price = 40000},
{name = "Shrine of St. Felms", refId = "furn_shrine_felms_cure_01", price = 40000},
{name = "Shrine of St. Llothis", refId = "furn_shrine_llothis_cure_01", price = 40000},
{name = "Shrine of St. Meris", refId = "furn_shrine_meris_cure_01", price = 50000},
{name = "Shrine of St. Nerevar", refId = "furn_shrine_nerevar_cure_01", price = 50000},
{name = "Shrine of St. Olms", refId = "furn_shrine_olms_cure_01", price = 40000},
{name = "Shrine of St. Rilm", refId = "furn_shrine_rilm_cure_01", price = 40000},
{name = "Shrine of St. Roris", refId = "furn_shrine_roris_cure_01", price = 50000},
{name = "Shrine of St. Seryn", refId = "furn_shrine_seryn_cure_01", price = 40000},
{name = "Shrine of St. Veloth", refId = "furn_shrine_veloth_cure_01", price = 50000},
{name = "Shrine of the Tribunal", refId = "furn_shrine_tribunal_cure_01", price = 85000},
{name = "Shrine of Vivec's Fury", refId = "furn_shrine_vivec_cure_01", price = 65000},


--General Furniture
{name = "", refId = "#option", price = 00},
{name = "#red ..FURNITURE", refId = "#option", price = 00},
{name = "Stool (Gross)", refId = "furn_de_ex_stool_02", price = 50},
{name = "Stool (Prayer)", refId = "furn_velothi_prayer_stool_01", price = 50},
{name = "Stool (Bar Stool)", refId = "furn_com_rm_barstool", price = 100},
{name = "chair (Camp)", refId = "furn_com_pm_chair_02", price = 50},
{name = "chair (General 1)", refId = "furn_com_rm_chair_03", price = 100},
{name = "chair (General 2)", refId = "furn_de_p_chair_01", price = 100},
{name = "chair (General 3)", refId = "furn_de_p_chair_02", price = 100},
{name = "chair (Expensive)", refId = "furn_de_r_chair_03", price = 200},
{name = "chair (Padded)", refId = "furn_com_r_chair_01", price = 200},
{name = "chair (Chieftain)", refId = "furn_chieftains_chair", price = 200},
{name = "Cushion (Round)", refId = "furn_de_cushion_round_01", price = 600},
{name = "Banc, Long (Cheap)", refId = "furn_de_p_bench_03", price = 200},
{name = "Banc, Court (Cheap)", refId = "furn_de_p_bench_04", price = 200},
{name = "Bench, Long (Expensive)", refId = "furn_de_r_bench_01", price = 400},
{name = "Bench, Court (Expensive)", refId = "furn_de_r_bench_02", price = 400},
{name = "Bench (Gross)", refId = "furn_de_p_bench_03", price = 150},
{name = "Bench Commun 1", refId = "furn_com_p_bench_01", price = 200},
{name = "Bench Commun 2", refId = "furn_com_rm_bench_02", price = 200},
{name = "Table, Grand Oval (Expensive)", refId = "furn_de_r_table_03", price = 800},
{name = "Table, Grand Rectangular (Cheap)", refId = "furn_de_p_table_04", price = 400},
{name = "Table, Grand Rectangular (Expensive)", refId = "furn_de_r_table_07", price = 800},
{name = "Table, Small Round (Cheap) 1", refId = "furn_de_p_table_01", price = 400},
{name = "Table, Small Round (Cheap) 2", refId = "furn_de_p_table_06", price = 400},
{name = "Table, Small Round (Expensive)", refId = "furn_de_r_table_08", price = 800},
{name = "Table, Small Square (Cheap)", refId = "furn_de_p_table_05", price = 400},
{name = "Table, Small Square (Expensive)", refId = "furn_de_r_table_09", price = 800},
{name = "Table, Small Rond (Cheap)", refId = "furn_de_p_table_02", price = 400},
{name = "Table, Square (Gross)", refId = "furn_de_ex_table_02", price = 200},
{name = "Table, Rectangular (Gross)", refId = "furn_de_ex_table_03", price = 200},
{name = "Table, Colony", refId = "furn_com_table_colony", price = 400},
{name = "Table, Rectangular 1", refId = "furn_com_rm_table_04", price = 400},
{name = "Table, Rectangular 2", refId = "furn_com_r_table_01", price = 800},
{name = "Table, Small Rectangular", refId = "furn_com_rm_table_05", price = 400},
{name = "Table, Round", refId = "furn_com_rm_table_03", price = 400},
{name = "Table, Oval", refId = "furn_de_table10", price = 800},
{name = "Bar, Middle", refId = "furn_com_rm_bar_01", price = 200},
{name = "Bar, End 1", refId = "furn_com_rm_bar_04", price = 200},
{name = "Bar, End 2", refId = "furn_com_rm_bar_02", price = 200},
{name = "Bar, Corner", refId = "furn_com_rm_bar_03", price = 200},
{name = "Bar, Middle (Dunmer)", refId = "furn_de_bar_01", price = 200},
{name = "Bar, End 1 (Dunmer)", refId = "furn_de_bar_04", price = 200},
{name = "Bar, End 2 (Dunmer)", refId = "furn_de_bar_02", price = 200},
{name = "Bar, Corner (Dunmer)", refId = "furn_de_bar_03", price = 200},
{name = "Bar, Door", refId = "active_com_bar_door", price = 200},
{name = "Display Railing, Ancestral Tomb", refId = "in_r_s_int_rail_02", price = 2000},
{name = "Bookshelf, Supported (Cheap)", refId = "furn_com_rm_bookshelf_02", price = 500},
{name = "Bookshelf, Supported (Expensive)", refId = "furn_com_r_bookshelf_01", price = 1000},
{name = "Bookshelf, Standing (Cheap)", refId = "furn_de_p_bookshelf_01", price = 350},
{name = "Bookshelf, Standing (Expensive)", refId = "furn_de_r_bookshelf_02", price = 700},
{name = "Wall Shelf (Wooden)", refId = "furn_de_p_shelf_02", price = 400},

--Beds
{name = "", refId = "#option", price = 00},
{name = "#red ..BEDS", refId = "#option", price = 00},
--{name = "Bedroll", refId = "active_de_bedroll", price = 100},
{name = "Hammock", refId = "active_de_r_bed_02", price = 150},
{name = "Bunk Bed 1", refId = "active_com_bunk_01", price = 800},
{name = "Bunk Bed 2", refId = "active_com_bunk_02", price = 800},
{name = "Bunk Bed 3", refId = "active_de_p_bed_03", price = 800},
{name = "Bunk Bed 4", refId = "active_de_p_bed_09", price = 800},
{name = "Bed, Simple 1 (Dark, Red Patterned)", refId = "active_com_bed_02", price = 400},
{name = "Bed, Simple 2 (Light, Pale Red)", refId = "active_com_bed_03", price = 400},
{name = "Bed, Simple 3 (Dark, Pale Green)", refId = "active_com_bed_04", price = 400},
{name = "Bed, Simple 4 (Light, Grey)", refId = "active_com_bed_05", price = 400},
{name = "Bed, Simple 5 (Grey-Brown)", refId = "active_de_p_bed_04", price = 400},
{name = "Bed, Simple 6 (Pale Red)", refId = "active_de_p_bed_10", price = 400},
{name = "Bed, Simple 7 (Blue Patterned)", refId = "active_de_p_bed_11", price = 400},
{name = "Bed, Simple 8 (Blue Patterned)", refId = "active_de_p_bed_12", price = 400},
{name = "Bed, Simple 9 (Red Patterned)", refId = "active_de_p_bed_13", price = 400},
{name = "Bed, Simple 10 (Dunmer, Grey)", refId = "active_de_p_bed_14", price = 400},
{name = "Bed, Simple 11 (Blue Patterned)", refId = "active_de_pr_bed_07", price = 400},
{name = "Bed, Simple 12 (Blue Patterned)", refId = "active_de_pr_bed_21", price = 400},
{name = "Bed, Simple 13 (Red Patterned)", refId = "active_de_pr_bed_22", price = 400},
{name = "Bed, Simple 14 (Red Patterned)", refId = "active_de_pr_bed_23", price = 400},
{name = "Bed, Simple 15 (Grey-Brown)", refId = "active_de_pr_bed_24", price = 400},
{name = "Bed, Simple 16 (Pale Green)", refId = "active_de_pr_bed_24", price = 400},      
{name = "Bed, Simple Cot 1 (Blue Patterned)", refId = "active_de_r_bed_01", price = 400},
{name = "Bed, Simple Cot 2 (Blue Patterned)", refId = "active_de_r_bed_17", price = 400},
{name = "Bed, Simple Cot 3 (Red Patterned)", refId = "active_de_r_bed_18", price = 400},
{name = "Bed, Simple Cot 4 (Red Patterned)", refId = "active_de_r_bed_19", price = 400},
{name = "Bed, Double 1 (Pale Green)", refId = "active_de_p_bed_05", price = 800},
{name = "Bed, Double 2 (Red Patterned)", refId = "active_de_p_bed_15", price = 800},
{name = "Bed, Double 3 (Red Patterned)", refId = "active_de_p_bed_16", price = 800},
{name = "Bed, Double 4 (Pale Green)", refId = "active_de_pr_bed_27", price = 800},
{name = "Bed, Double 5 (Red Patterned)", refId = "active_de_pr_bed_26", price = 800},
{name = "Bed, Double 6 (Red Patterned)", refId = "active_de_pr_bed_08", price = 800},
{name = "Bed, Double 7 (Red Patterned)", refId = "active_de_r_bed_20", price = 800},
{name = "Bed, Double 8 (Red Patterned)", refId = "active_de_r_bed_06", price = 800},
{name = "Bed, Double 9 (Imperial Blue)", refId = "active_com_bed_06", price = 800},

--Rugs
{name = "", refId = "#option", price = 00},
{name = "#red ..RUGS", refId = "#option", price = 00},
{name = "Dunmer Rug 1", refId = "furn_de_rug_01", price = 200},
{name = "Dunmer Rug 2", refId = "furn_de_rug_02", price = 200},
{name = "Wolf Skin Rug", refId = "furn_colony_wolfrug01", price = 50},
{name = "Bear Skin Rug", refId = "furn_rug_bearskin", price = 100},
{name = "Grand Rug 1 (Red)", refId = "furn_de_rug_big_01", price = 200},
{name = "Grand Rug 2 (Red)", refId = "furn_de_rug_big_02", price = 200},
{name = "Grand Rug 3 (Green)", refId = "furn_de_rug_big_03", price = 200},
{name = "Grand Rug 4 (Blue)", refId = "furn_de_rug_big_08", price = 200},
{name = "Grand Rectangular Rug 1 (Red)", refId = "furn_de_rug_big_04", price = 200},
{name = "Grand Rectangular Rug 2 (Red)", refId = "furn_de_rug_big_05", price = 200},
{name = "Grand Rectangular Rug 3 (Green)", refId = "furn_de_rug_big_06", price = 200},
{name = "Grand Rectangular Rug 4 (Green)", refId = "furn_de_rug_big_07", price = 200},
{name = "Grand Rectangular Rug 5 (Blue)", refId = "furn_de_rug_big_09", price = 200},

--Fireplaces
{name = "", refId = "#option", price = 00},
{name = "#red ..FIREPLACES", refId = "#option", price = 00},
{name = "Campfire 1", refId = "furn_de_firepit", price = 100},
--{name = "Campfire 2", refId = "furn_de_firepit_01", price = 100},
{name = "Fireplace (Simple Oven)", refId = "furn_t_fireplace_01", price = 500},
{name = "Fireplace (Forge)", refId = "furn_de_forge_01", price = 500},
{name = "Fireplace (Nord)", refId = "in_nord_fireplace_01", price = 1500},
{name = "Fireplace", refId = "furn_fireplace10", price = 2000},
{name = "Fireplace (Grand Imperial)", refId = "in_imp_fireplace_grand", price = 5000},

--Lighting
{name = "", refId = "#option", price = 00},
{name = "#red ..LIGHTS", refId = "#option", price = 00},
{name = "Campfire (Lit)", refId = "light_pitfire00", price = 175},
{name = "Tiki Torch", refId = "light_tikitorch_512", price = 150},
{name = "Paper Lantern (Yellow)", refId = "light_de_lantern_03", price = 25},
{name = "Paper Lantern (Blue)", refId = "light_de_lantern_08", price = 25},
{name = "Ashland Lantern (Blue)", refId = "light_ashl_lantern_01", price = 125},
{name = "Ashland Lantern (Green)", refId = "light_ashl_lantern_05", price = 125},
{name = "Ashland Lantern (Indigo)", refId = "light_ashl_lantern_07", price = 125},
{name = "Ashland Lantern (Orange)", refId = "light_ashl_lantern_02", price = 125},
{name = "Ashland Lantern (Purple)", refId = "light_ashl_lantern_04", price = 125},
{name = "Ashland Lantern (Red)", refId = "light_ashl_lantern_03", price = 125},
{name = "Ashland Lantern (Teal)", refId = "light_ashl_lantern_06", price = 125},

{name = "Candle (Yellow)", refId = "light_com_candle_07", price = 25},
{name = "Candle (Blue)", refId = "light_com_candle_11", price = 25},
{name = "Candle (6th House)", refId = "light_6th_candle_01", price = 125},

{name = "Candle, 6th House (Black)", refId = "light_6th_candle_01", price = 125},
{name = "Candle, 6th House (Red)", refId = "light_6th_candle_05", price = 125},
{name = "Candle, 6th House (White)", refId = "light_6th_candle_03", price = 125},

{name = "Wall Sconce (Thee Candles)", refId = "light_com_sconce_02_128", price = 25},
{name = "Wall Sconce", refId = "light_com_sconce_01", price = 25},
{name = "Candlestick (Three Candles)", refId = "light_com_lamp_02_128", price = 50},
{name = "Chandelier, Simple (Four Candles)", refId = "light_com_chandelier_03", price = 50},
{name = "Wax Candles (Red)", refId = "light_com_candle_13_77", price = 150},
{name = "Brazier, Velothi", refId = "light_velothi_brazier_177", price = 3500},
{name = "Brazier, 6th House", refId = "light_6th_brazier_02", price = 4500},

--Special Containers
--{name = "", refId = "#option", price = 00},
--{name = "#red ..MANNEQUINS", refId = "#option", price = 00},
--{name = "Squelette 1", refId = "contain_corpse00", price = 122}, --120 for weight + 2 for the bonemeal :P
--{name = "Squelette 2", refId = "contain_corpse10", price = 122},
--{name = "Squelette 3", refId = "contain_corpse20", price = 122},
--{name = "mannequin", refId = "armor mannequin", price = 100},

--Misc
{name = "", refId = "#option", price = 00},
{name = "#red ..DECORATIONS", refId = "#option", price = 00},
{name = "Anvil", refId = "furn_anvil00", price = 200},
{name = "Kegstand", refId = "furn_com_kegstand", price = 200},
{name = "Cauldron", refId = "furn_com_cauldron_01", price = 100},
{name = "Ashpit", refId = "in_velothi_ashpit_01", price = 100},
{name = "Ash Pillar", refId = "furn_6th_ashpillar", price = 30000},
{name = "Ash Statue (Large)", refId = "furn_6th_ashstatue", price = 70000},
{name = "Shack Awning", refId = "ex_de_shack_awning_03", price = 100},
--{name = "Bazaar Tent", refId = "EX_MH_bazaar_tent", price = 500},
{name = "Ashlander Tent (Small)", refId = "ex_ashl_tent_04", price = 400},
{name = "Ashlander Tent (Large)", refId = "ex_ashl_tent_03", price = 2000},

{name = "Bear Head (Brown)", refId = "bm_bearhead_brown", price = 200},
{name = "Bear Head (Red)", refId = "bm_bearhead_red", price = 200},
{name = "Bear Head (White)", refId = "bm_bearhead_white", price = 200},
{name = "Wolf Head (White)", refId = "bm_wolfhead_white", price = 200},
{name = "Argonian Head (Scourge)", refId = "misc_argonianhead_01", price = 400},
{name = "Wallscreen", refId = "furn_de_r_wallscreen_02", price = 100},
{name = "Guarskin Screen", refId = "furn_de_screen_guar_01", price = 300},
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
{name = "Banner (Thief)", refId = "furn_c_t_theif_01", price = 100},
{name = "Banner (Tower)", refId = "furn_c_t_tower_01", price = 100},
{name = "Banner (Warrior)", refId = "furn_c_t_warrior_01", price = 100},
{name = "Banner (Wizard)", refId = "furn_c_t_wizard_01", price = 100},
{name = "Display Pedestal (Museum)", refId = "furn_museum_display_02", price = 20000},
{name = "Display Table (Museum)", refId = "furn_museum_display_01", price = 45000},
{name = "Dwemer Display Tray", refId = "furn_de_tray_01", price = 5000},

--Wood (wood wall = stairs , wall , door wall , windowed wall , ...)
{name = "", refId = "#option", price = 00},
{name = "#red ..CONSTRUCTION", refId = "#option", price = 00},
{name = "Wooden Wall", refId = "bm_colony_wall04", price = 1000},
{name = "Wooden Doorway wall", refId = "bm_colony_wall03", price = 1500},
{name = "Wooden Nord Doorframe (Green Finsh)", refId = "in_nord_doorf_01", price = 800},
{name = "Wooden Nord Doorframe (Brown Finish)", refId = "in_nord_doorf_02", price = 800},
{name = "Stone Wall", refId = "ex_imp_foundation_01", price = 2500},
{name = "Stone Wall (colony)", refId = "bm_colony_stonewall01", price = 2500},
{name = "Daedric Wall", refId = "ex_dae_wall_512_01", price = 3000},
{name = "Mournhold Door", refId = "in_mh_door_02_play", price = 500},
{name = "Plank", refId = "chargen_plank", price = 500},
{name = "Wooden Board", refId = "ex_common_plat_lrg", price = 500},
{name = "Small Wooden Board", refId = "ex_de_shack_plank_01", price = 250},
{name = "Wooden Structure", refId = "ex_common_trellis", price = 2000},
{name = "Stone Structure", refId = "ex_ruin_00", price = 5000},
{name = "Wooden Bridge", refId = "ex_de_scaffold_01a", price = 2000},
{name = "Wooden Post", refId = "ex_de_docks_piling_01", price = 500},
{name = "Large Wooden Ladder", refId = "ex_de_shack_steps", price = 1000},
{name = "Wooden Ladder", refId = "ex_de_shack_steps_01", price = 750},
{name = "Stone Block", refId = "ex_dwrv_block00", price = 100},
{name = "Stone Foundation", refId = "ex_v_foundation_01", price = 5000},
{name = "Wooden Fence", refId = "ex_s_fence_01", price = 100},
{name = "Wooden Hut", refId = "ex_s_foodhut", price = 10000},
{name = "Window", refId = "ex_s_window01", price = 500},
{name = "Altar, 6th House", refId = "furn_6th_ashaltar", price = 35000},
{name = "Platform, 6th House", refId = "furn_6th_platform", price = 500000},
{name = "Wooden Doorframe", refId = "in_c_doorframe_01", price = 250},
{name = "Wooden Doorjamb", refId = "in_s_doorjam", price = 250},
{name = "Wooden Round Doorjamb", refId = "in_s_doorjam_rounded", price = 250},
{name = "Plain Arched Doorjamb", refId = "in_c_djamb_plain_arched", price = 500},
{name = "Plain Square Doorjamb", refId = "in_c_djamb_plain_square", price = 500},
{name = "Expensive Arched Doorjamb", refId = "in_c_djamb_rich_arched", price = 900},
{name = "Hlaalu Arched Doorjamb", refId = "in_hlaalu_doorjamb", price = 800},
{name = "Redoran Doorjamb 1", refId = "in_r_s_doorjamb_01", price = 800},
{name = "Redoran Doorjamb 2", refId = "in_redoran_l_doorjamb_01", price = 800},
{name = "Redoran Doorjamb 3", refId = "in_r_l_doorjamb_02", price = 800},
{name = "Telvanni Doorjamb", refId = "in_t_s_djamb_plain", price = 800},
{name = "Telvanni Round Doorjamb", refId = "in_t_l_doorjamb_01", price = 800},
{name = "Imperial Arched Doorjamb", refId = "in_impsmall_doorjam_01", price = 800},
{name = "Stone Arched Doorjamb", refId = "in_c_djamb_stone_arched", price = 750},
{name = "Stone Square Doorjamb", refId = "in_c_djamb_stone_square", price = 750},
{name = "Stronghold Doorjamb", refId = "in_strong_doorjam00", price = 950},

-- {name = "", refId = "#option", price = 00},
-- {name = "#red ..GARDENING", refId = "#option", price = 00},
-- {name = "Wooden Wall", refId = "BM_colony_wall04", price = 1000},
-- {name = "Wooden Doorway wall", refId = "BM_colony_wall03", price = 1500},
-- {name = "Stone Wall", refId = "ex_imp_foundation_01", price = 2500},
-- {name = "Stone Wall (colony)", refId = "BM_colony_stonewall01", price = 2500},
-- {name = "Daedric Wall", refId = "ex_dae_wall_512_01", price = 3000},
-- {name = "Mournhold Door", refId = "in_mh_door_02_play", price = 500},
-- {name = "Plank", refId = "chargen_plank", price = 500},
-- {name = "Wooden Board", refId = "Ex_common_plat_LRG", price = 500},
-- {name = "Small Wooden Board", refId = "ex_de_shack_plank_01", price = 250},
-- {name = "Wooden Structure", refId = "ex_common_trellis", price = 2000},
-- {name = "Stone Structure", refId = "ex_ruin_00", price = 5000},
-- {name = "Wooden Bridge", refId = "Ex_de_scaffold_01a", price = 2000},
-- {name = "Wooden Post", refId = "Ex_De_Docks_Piling_01", price = 500},
-- {name = "Large Wooden Ladder", refId = "ex_de_shack_steps", price = 1000},
-- {name = "Wooden Ladder", refId = "Ex_De_Shack_Steps_01", price = 750},
-- {name = "Stone Block", refId = "ex_dwrv_block00", price = 100},
-- {name = "Stone Foundation", refId = "ex_v_foundation_01", price = 5000},
-- {name = "Wooden Fence", refId = "ex_S_fence_01", price = 100},
-- {name = "Wooden Hut", refId = "Ex_S_FoodHut", price = 10000},
-- {name = "Window", refId = "ex_S_window01", price = 500},
-- {name = "Altar, 6th House", refId = "furn_6th_ashaltar", price = 35000},
-- {name = "Platform, 6th House", refId = "furn_6th_platform", price = 500000},

--Personnage (garde , vendeur , ect , ...)
--{name = "", refId = "#option", price = 00},
--{name = "#red ..PERSONNAGES", refId = "#option", price = 00},
--{name = "Garde de l'empire", refId = "Elokiel Garde Empire", price = 5000},
--{name = "Garde du temple", refId = "Elokiel Garde du temple", price = 5000},
--{name = "Marchand de Elokiel", refId = "Elokiel Marchand", price = 2500},
--{name = "Danseuse de Elokiel", refId = "Elokiel dancer girl", price = 2500},

--Compagnons (rats , chien , ect , ...)
--{name = "", refId = "#option", price = 00},
--{name = "#red ..COMPAGNONS", refId = "#option", price = 00},
--{name = "Rat de compagnie", refId = "Rat_pack_rerlas", price = 500},
--{name = "Chien de compagnie", refId = "Chien_pack_rerlas", price = 1000},
--{name = "Guar de compagnie", refId = "Guar_pack_rerlas", price = 2500},
--{name = "Braillard de compagnie", refId = "Braillard_pack_rerlas", price = 2500},

--Companions (rats , chien , ect , ...)



{name = "", refId = "#option", price = 00},
{name = "#red ..HOUSE MERCHANTS", refId = "#option", price = 00},
{name = "Creeper", refId = "scamp_creeper", price = 800000},
{name = "Mudcrab", refId = "mudcrab_unique", price = 1000000},


--{name = "", refId = "#option", price = 00},
--{name = "#red ..HOUSECARLS", refId = "#option", price = 00},
--{name = "Runt", refId = "dremora_housecarl", price = 750000},

--{name = "Guar de compagnie", refId = "Guar_pack_rerlas", price = 2500},
--{name = "Braillard de compagnie", refId = "Braillard_pack_rerlas", price = 2500},

--[Dwarven Furniture Set
--{name = "Heavy Dwemer Chest", refId = "dwrv_chest00", price = 200}, --NOTE: Contains 2 random dwarven items
--{name = "Heavy Dwemer Chest", refId = "dwrv_chest00", price = 200},
--{name = "Dwemer Cabinet", refId = "dwrv_cabinet10", price = 200},
--{name = "Dwemer Desk", refId = "dwrv_desk00", price = 50},
--{name = "Dwemer Drawers", refId = "dwrv_desk00", price = 300}, --NOTE: Contains paper + one dwarven coin
--{name = "Dwemer Drawer Table", refId = "dwrv_table00", price = 50}, --NOTE: Contains dwarven coin
--{name = "Dwemer Chair", refId = "furn_dwrv_chair00", price = 000},
--{name = "Dwemer Shelf", refId = "furn_dwrv_bookshelf00", price = 000},

--in_dwe_slate00 to in_dwe_slate11
--furn_com_p_table_01
--furn_com_planter
--]]
}

local furniturePatreonData = {
{name = "", refId = "#option", price = 00},
{name = "#red ..*PATREON FURNITURE*", refId = "#option", price = 00},

{name = "", refId = "#option", price = 00},
{name = "#red ..DANCERS", refId = "#option", price = 00},
{name = "Breton Dancer", refId = "breton dancer girl", price = 50000},

{name = "", refId = "#option", price = 00},
{name = "#red ..STATUES", refId = "#option", price = 00},
{name = "Azura Statue", refId = "azura", price = 45000},
{name = "Werewolf Ice Statue", refId = "act_werewolf_statue", price = 45000},

{name = "", refId = "#option", price = 00},
{name = "#red ..TABLES", refId = "#option", price = 00},
{name = "Colony Stonetable 1", refId = "furn_colony_stonetable01", price = 18000},
{name = "Colony Stonetable 2", refId = "furn_colony_stonetable02", price = 18000},

{name = "", refId = "#option", price = 00},
{name = "#red ..SOUND", refId = "#option", price = 00},
{name = "Bell 1", refId = "active_6th_bell_01", price = 15000},
{name = "Bell 2", refId = "active_6th_bell_02", price = 15000},
{name = "Bell 3", refId = "active_6th_bell_03", price = 15000},
{name = "Bell 4", refId = "active_6th_bell_04", price = 15000},
{name = "Bell 5", refId = "active_6th_bell_05", price = 15000},
{name = "Bell 6", refId = "active_6th_bell_06", price = 15000},

{name = "", refId = "#option", price = 00},
{name = "#red ..SMOKE", refId = "#option", price = 00},
{name = "Chimney Smoke", refId = "active_chimney_smoke02", price = 12000},
{name = "Akhul Steam", refId = "akhul_steam", price = 18000},

{name = "", refId = "#option", price = 00},
{name = "#red ..OTHER", refId = "#option", price = 00},
{name = "Akula Door A", refId = "akula door a", price = 8000},
{name = "Akula Door B", refId = "akula door b", price = 8000},
{name = "Forcefield", refId = "active_mh_forcefield", price = 14000},
{name = "Coat of Arms Red", refId = "furn_com_coatofarms_01", price = 12000},
{name = "Coat of Arms Blue", refId = "furn_com_coatofarms_02", price = 12000},
{name = "Practice Dummy", refId = "furn_practice_dummy", price = 19500},

{name = "", refId = "#option", price = 00},
{name = "#red ..DISPLAY", refId = "#option", price = 00},
{name = "Weaponrack", refId = "furn_uni_weaponrack_01", price = 4000},
{name = "Spearholder", refId = "furn_uni_spearholder_01", price = 6000},
{name = "Dagoth Scaffold", refId = "in_dagoth_scaffold00", price = 8000},
{name = "Clockwork Door", refId = "in_sotha_pre_door", price = 60000},
{name = "Ice Lamp", refId = "bm_ka_lamp", price = 25000},
{name = "Ice Chandelier", refId = "bm_ka_chandelier", price = 42000},
{name = "Ice Chair", refId = "bm_ka_chair", price = 30000},
{name = "Ice Throne", refId = "bm_ka_throne", price = 60000},

{name = "", refId = "#option", price = 00},
{name = "#red ..CONSTRUCTION", refId = "#option", price = 00},
{name = "Lavacave Doorway", refId = "in_lavacave_doorway00", price = 1200},
{name = "Mournhold Doorjamb 1", refId = "in_mh_doorjamb_01", price = 1800},
{name = "Mournhold Doorjamb 2", refId = "in_mh_doorjamb_02", price = 1800},
{name = "Sotha Doorjamb", refId = "in_sotha_doorjam00", price = 2600},
{name = "Thirsk Doorway", refId = "in_thirsk_doorway", price = 3200},

}
-- {name = "name", refId = "ref_id", price = 50},
------------


Methods = {}
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
		--eventHandler.LoadCell(cell)
		-- Lear edit, replaced above line with below
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

-- -- local function getFurnitureData(refId)
	-- -- local location = tableHelper.getIndexByNestedKeyValue(furnitureData, "refId", refId)
	-- -- if location then
		-- -- return furnitureData[location], location
	-- -- else
		-- -- return false
	-- -- end
-- -- end

-- -- Atkana had me replace above with below for additional admin table

-- local function getFurnitureData(refId)
    -- local location = tableHelper.getIndexByNestedKeyValue(furnitureData, "refId", refId)
    -- if location then
        -- return furnitureData[location], location
    -- else
        -- --Could be on the admin table
        -- location = tableHelper.getIndexByNestedKeyValue(furnitureAdminData, "refId", refId)
        -- if location then
            -- return furnitureAdminData[location], location
        -- else
            -- --Furniture doesn't exist
            -- return false
        -- end
    -- end
-- end
local function getFurnitureData(refId)
    local location = tableHelper.getIndexByNestedKeyValue(furnitureData, "refId", refId)
    if location then
        return furnitureData[location], location
    else
        --Could be on the patreon table
        location = tableHelper.getIndexByNestedKeyValue(furniturePatreonData, "refId", refId)
        if location then
            return furniturePatreonData[location], location
        else
			 --Could be on the admin table
			location = tableHelper.getIndexByNestedKeyValue(furnitureAdminData, "refId", refId)
			if location then
				return furnitureAdminData[location], location
			else
				--Furniture doesn't exist
				return false
			end
        end
    end
end
--


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
		--local name = getFurnitureData(refId).name
		-- Lear edit - replace above with below to resolve a boolean crash?
		local name = getFurnitureData(refId:lower()).name:lower()
		table.insert(sorted, {name = name, count = amount, refId = refId})
	end
	
	return sorted
end

local function placeFurniture(refId, loc, cell)
	local mpNum = WorldInstance:GetCurrentMpNum() + 1
	local location = {
		posX = loc.x, posY = loc.y, posZ = loc.z,
		rotX = 0, rotY = 0, rotZ = 0
	}
	local refIndex =  0 .. "-" .. mpNum
	
	WorldInstance:SetCurrentMpNum(mpNum)
	tes3mp.SetCurrentMpNum(mpNum)
	
	if not LoadedCells[cell] then
		--TODO: Should ideally be temporary
		--eventHandler.LoadCell(cell)
		--replaced above with below thanks to atkana
		logicHandler.LoadCell(cell)
	end

	LoadedCells[cell]:InitializeObjectData(refIndex, refId)
	LoadedCells[cell].data.objectData[refIndex].location = location
	table.insert(LoadedCells[cell].data.packets.place, refIndex)
 
	for onlinePid, player in pairs(Players) do
		if player:IsLoggedIn() then
			tes3mp.InitializeEvent(onlinePid)
			tes3mp.SetEventCell(cell)
			tes3mp.SetObjectRefId(refId)
			tes3mp.SetObjectRefNumIndex(0)
			tes3mp.SetObjectMpNum(mpNum)
			tes3mp.SetObjectPosition(location.posX, location.posY, location.posZ)
			tes3mp.SetObjectRotation(location.rotX, location.rotY, location.rotZ)
			tes3mp.AddWorldObject()
			tes3mp.SendObjectPlace()
		end
	end
	
	LoadedCells[cell]:Save()
	
	return refIndex
end

local function removeFurniture(refIndex, cell)
	--If for some reason the cell isn't loaded, load it. Causes a bit of spam in the server log, but that can't really be helped.
	--TODO: Ideally this should only be a temporary load
	if LoadedCells[cell] == nil then
		--eventHandler.LoadCell(cell)
		-- Lear edit replaced above line with below
		logicHandler.LoadCell(cell)
	end
	
	if LoadedCells[cell]:ContainsObject(refIndex) and not tableHelper.containsValue(LoadedCells[cell].data.packets.delete, refIndex) then --Shouldn't ever have a delete packet, but it's worth checking anyway
		--Delete the object for all the players currently online
		local splitIndex = refIndex:split("-")
		
		for onlinePid, player in pairs(Players) do
			if player:IsLoggedIn() then
				tes3mp.InitializeEvent(onlinePid)
				tes3mp.SetEventCell(cell)
				tes3mp.SetObjectRefNumIndex(splitIndex[1])
				tes3mp.SetObjectMpNum(splitIndex[2])
				tes3mp.AddWorldObject()
				tes3mp.SendObjectDelete()
			end
		end
		
		LoadedCells[cell]:DeleteObjectData(refIndex)
		LoadedCells[cell]:Save()
		--Removing the object from the placed list will be done elsewhere
	end
end


-- local function getAvailableFurnitureStock(pid)
	-- --In the future this can be used to customise what items are available for a particular player, like making certain items only available for things like their race, class, level, their factions, or the quests they've completed. For now, however, everything in furnitureData is available :P
	
	-- local options = {}
	
	-- for i = 1, #furnitureData do
		-- table.insert(options, furnitureData[i])
	-- end
	
	-- return options
-- end

-- Lear edit begin - replace above with below.
-- local function getAvailableFurnitureStock(pid)
	-- --In the future this can be used to customise what items are available for a particular player, like making certain items only available for things like their race, class, level, their factions, or the quests they've completed. For now, however, everything in furnitureData is available :P
	
	-- local options = {}
	
		-- if Players[pid].data.settings.staffRank >= 2 then
			-- for i = 1, #furnitureAdminData do
				-- table.insert(options, furnitureAdminData[i])
			-- end
		-- end
		
		-- if Players[pid].data.customVariables.patreonActive ~= nil and Players[pid].data.customVariables.patreonActive > 0 then
			-- for i = 1, #furniturePatreonData do
				-- table.insert(options, furniturePatreonData[i])
				
				
				
				
			-- end
		-- end
		
		-- for i = 1, #furnitureData do
			-- table.insert(options, furnitureData[i])
		-- end
	
	-- return options
-- end

local function getAvailableFurnitureStock(pid)
	--In the future this can be used to customise what items are available for a particular player, like making certain items only available for things like their race, class, level, their factions, or the quests they've completed. For now, however, everything in furnitureData is available :P
	
	local options = {}
	
		if Players[pid].data.settings.staffRank >= 2 then
			for i = 1, #furnitureAdminData do
				table.insert(options, furnitureAdminData[i])
			end
		end
		
		for i = 1, #furnitureData do
				table.insert(options, furnitureData[i])
		end
		
		if Players[pid].data.customVariables.patreonActive ~= nil and Players[pid].data.customVariables.patreonActive >= 5 then
			for i = 1, #furniturePatreonData do
				table.insert(options, furniturePatreonData[i])
			end
		end
		
	return options
end


-- Lear edit end. See above comment.



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
	if playerCurrentName and eventHandler.IsPlayerNameLoggedIn(playerCurrentName) then
		decorateHelp.SetSelectedObject(eventHandler.GetPlayerByName(playerCurrentName).pid, "")
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
	if playerCurrentName and eventHandler.IsPlayerNameLoggedIn(playerCurrentName) then
		decorateHelp.SetSelectedObject(eventHandler.GetPlayerByName(playerCurrentName).pid, "")
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
	--local fdata = getFurnitureData(choice.refId)
	-- Lear edit start
	if choice == nil then return end
	if choice.refId == nil then return end
	-- Lear edit end
	local fdata = getFurnitureData(choice.refId:lower())
	
	message = message .. "Item Name: " .. fdata.name .. " (RefIndex: " .. choice.refIndex .. "). Price: " .. fdata.price .. " (Sell price: " .. getSellValue(fdata.price) .. ")"
	
	playerViewChoice[getName(pid)] = choice
	tes3mp.CustomMessageBox(pid, config.ViewOptionsGUI, message, "Select;Retrieve;Sell;Close")
end

local function onViewOptionSelect(pid)
	local pname = getName(pid)
	local choice = playerViewChoice[pname]
	local cell = tes3mp.GetCell(pid)
	
	if getObject(choice.refIndex, cell) then
		decorateHelp.SetSelectedObject(pid, choice.refIndex:lower())
		tes3mp.MessageBox(pid, -1, "Selected object, use Decorate to move.")
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
		
		addFurnitureItem(pname, choice.refId:lower(), 1, true)
		tes3mp.MessageBox(pid, -1, getFurnitureData(choice.refId:lower()).name .. " has been added to your furniture inventory.")
	else
		tes3mp.MessageBox(pid, -1, "The object seems to have been removed.")
	end
end

local function onViewOptionSell(pid)
	local pname = getName(pid)
	local choice = playerViewChoice[pname]
	local cell = tes3mp.GetCell(pid)
	
	if getObject(choice.refIndex, cell) then
		local saleGold = getSellValue(getFurnitureData(choice.refId:lower()).price)
		
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
				--local furnData = getFurnitureData(object.refId)
				local furnData = getFurnitureData(object.refId:lower())
				
				list = list .. furnData.name .. " (at " .. math.floor(object.location.posX + 0.5) .. ", "  ..  math.floor(object.location.posY + 0.5) .. ", " .. math.floor(object.location.posZ + 0.5) .. ")"
				if not(i == #options) then
					list = list .. "\n"
				end
				
				table.insert(newOptions, {refIndex = options[i], refId = object.refId})
			end
		end
	end
	
	playerViewOptions[pname] = newOptions
	tes3mp.ListBox(pid, config.ViewGUI, "Select a piece of furniture that you placed in this cell. Note: The contents of containers will be lost if removed.", list)
	--getPlayerPlacedInCell(pname, cell)
end

local function onViewChoice(pid, loc)
	showViewOptionsGUI(pid, loc)
end

-- INVENTORY (OPTIONS)
showInventoryOptionsGUI = function(pid, loc)
	local message = ""
	
	
	--local choice = playerInventoryOptions[getName(pid)][loc]
	-- Lear edit start - replaced above with below
	local choice = nil
	
	if playerInventoryOptions[getName(pid)][loc] ~= nil then 
		choice = playerInventoryOptions[getName(pid)][loc]
	end
	
	if choice == nil then return end
	-- Lear edit end.
	
	
	local fdata = getFurnitureData(choice.refId:lower())
	
	--Lear edit start - attempt to fix a nil error check
	if choice ~= nil then
	message = message .. "Item Name: " .. choice.name .. ". Price: " .. fdata.price .. " (Sell price: " .. getSellValue(fdata.price) .. ")"
	
	playerInventoryChoice[getName(pid)] = choice
	tes3mp.CustomMessageBox(pid, config.InventoryOptionsGUI, message, "Place;Sell;Close")
	end
	-- Lear edit end - Replaced below with above.
	
	-- message = message .. "Item Name: " .. choice.name .. ". Price: " .. fdata.price .. " (Sell price: " .. getSellValue(fdata.price) .. ")"
	
	-- playerInventoryChoice[getName(pid)] = choice
	-- tes3mp.CustomMessageBox(pid, config.InventoryOptionsGUI, message, "Place;Sell;Close")
end

local function onInventoryOptionPlace(pid)
	local pname = getName(pid)
	local curCell = tes3mp.GetCell(pid)
	local choice = playerInventoryChoice[pname]
	--
	--local fdata = getFurnitureData(choice.refId)
	
	--First check the player is allowed to place items where they are currently
	
	-- if config.whitelist and not hasPlacePermission(pname, curCell) then
		-- --Player isn't allowed
		-- tes3mp.MessageBox(pid, -1, "You do not have permission to place furniture here.")
		-- return false
	-- end
	-- Lear Edit - I'm pretty sure I can check to see if its a bedroll here, and place it.
	-- Lear Edit - So I'm replacing the above lines with the below.

--	--if choice.refId == "active_de_bedroll" then
	
	-- elseif choice.refId == "EX_MH_bazaar_tent" then

	-- elseif choice.refId == "furn_de_firepit_01" then
	--elseif	
	-- and not choice.refId == "active_de_bedroll"
	--if Players[pid].data.settings.staffRank == 0 then
	
	if Players[pid].data.settings.staffRank >= 2 then
	
	
	-- Lear edit within edit begin - Not sure if below works
	--elseif curCell == "Cavern of the Incarnate" then
	--	tes3mp.MessageBox(pid, -1, "You do not have permission to place furniture here.")
	--	return false
	
	-- Lear edit within edit end - Not sure if above works
	
	else 
	
	
	
	if choice.refId == "active_de_bedroll" then	
		if tes3mp.GetCell(pid) == "-3, -2" or tes3mp.GetCell(pid) == "-3, -3" or tes3mp.GetCell(pid) == "-2, -2" or tes3mp.GetCell(pid) == "-4, -2" then
			tes3mp.MessageBox(pid, -1, "You cannot place a bedroll near Balmora.")
			return false
		elseif tes3mp.GetCell(pid) == "Character Stuff Wonderland" then
			tes3mp.MessageBox(pid, -1, "You cannot place furniture here.")
			return false
		end
	-- elseif choice.refId == "EX_MH_bazaar_tent" then
		-- if not tes3mp.IsInExterior(pid) then
			-- tes3mp.MessageBox(pid, -1, "You do not have permission to place furniture here.")
			-- return false
		-- elseif tes3mp.GetCell(pid) == "Character Stuff Wonderland" then
			-- tes3mp.MessageBox(pid, -1, "You cannot place furniture here.")
			-- return false
		-- end
	elseif choice.refId == "furn_de_firepit_01" then
		if not tes3mp.IsInExterior(pid) then
			tes3mp.MessageBox(pid, -1, "You do not have permission to place furniture here.")
			return false
		elseif tes3mp.GetCell(pid) == "Character Stuff Wonderland" then
			tes3mp.MessageBox(pid, -1, "You cannot place furniture here.")
			return false
		end
	elseif config.whitelist and not hasPlacePermission(pname, curCell) then
		--Player isn't allowed
		tes3mp.MessageBox(pid, -1, "You do not have permission to place furniture here.")
		return false
	end
	
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
	
	kanaFurniture.OnCommand(pid)
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
	
	kanaFurniture.OnCommand(pid)
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
	tes3mp.ListBox(pid, config.InventoryGUI, "Select the piece of furniture from your inventory that you wish to do something with.", list)
end

local function onInventoryChoice(pid, loc)
	showInventoryOptionsGUI(pid, loc)
end

-- BUY (MAIN)
showBuyGUI = function(pid)
	local options = getAvailableFurnitureStock(pid)
	local list = "* CLOSE *\n"
	
	for i = 1, #options do
		if (options[i].price == 00) then
			list = list .. options[i].name
		end
		if (options[i].price > 00) then
			list = list .. options[i].name .. " (" .. options[i].price .. ") "
		end		
		if not(i == #options) then
			list = list .. "\n"
		end
	end
	
	playerBuyOptions[getName(pid)] = options
	-- -- Lear edit start
	-- tes3mp.ListBox(pid, config.BuyGUI, color.Khaki .. "Select an item you wish to purchase" .. color.Default, list)
	
	tes3mp.ListBox(pid, config.BuyGUI, color.Khaki .. "Select an item you wish to purchase.\n" .. "You have " .. getPlayerGold(pid) .. " gold." .. color.Default, list)
	-- -- Lear edit end
end

local function onBuyChoice(pid, loc)
	local pgold = getPlayerGold(pid)
	local choice = playerBuyOptions[getName(pid)][loc]
	
	if choice == nil or choice.price == nil then return end
	
	if pgold < choice.price then
		tes3mp.MessageBox(pid, -1, "You can not afford to buy " .. choice.name .. ".")
		return false
	end
	
	--if choice.price == 00 then
	if choice.refId == "#option" then
		tes3mp.MessageBox(pid, -1, "You cannot purchase that.")
		return false
	end
	
	addGold(pid, -choice.price)
	addFurnitureItem(getName(pid), choice.refId, 1, true)
	
	logicHandler.RunConsoleCommandOnPlayer(pid, "PlaySound \"Item Gold Up\"")
	tes3mp.MessageBox(pid, -1, "" .. choice.name .. " has been added to your furniture inventory.")
	--return true
	-- Lear edit start - replaced above with below.
	return true
	-- Lear edit end - see above note.
end

-- MAIN
showMainGUI = function(pid)
	local message = color.Orange .. "Jiubs Mobile Emporium\n" .. 
	color.Khaki .. "\nUse '".. 
	color.Yellow.. "Buy".. 
	color.Khaki .. "' to purchase furniture.\nUse '".. 
	color.Yellow .. "Inventory".. 
	color.Khaki .. "' to view the furniture items you own.\nUse '".. 
	color.Yellow .. "Nearby Objects".. 
	color.Khaki .. "' to display a list of all the furniture you have in the cell you're currently in. \nUse '" .. 
	color.Yellow .. "Decorate".. 
	color.Khaki .. "' to display and move them." .. 
	color.Default
	tes3mp.CustomMessageBox(pid, config.MainGUI, message, "Buy;Inventory;Nearby Objects;Decorate;Exit")
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
		elseif tonumber(data) == 3 then -- Decorate
			decorateHelp.OnCommand(pid)
			return true
		elseif tonumber(data) == 4 then -- Close
			--Do nothing
			return true
		end
	elseif idGui == config.BuyGUI then -- Buy
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then --Close/Nothing Selected
			--Do nothing
			-- added below
			kanaFurniture.OnCommand(pid)
			-- added above
			return true
		else
			onBuyChoice(pid, tonumber(data))
			-- -- Lear edit start
			--kanaFurniture.OnCommand(pid)
			onMainBuy(pid)
			-- -- Lear edit end
			return true
		end
	elseif idGui == config.InventoryGUI then --Inventory main
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then --Close/Nothing Selected
			--Do nothing
			-- added below
			kanaFurniture.OnCommand(pid)
			-- added above
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
			-- added below
			kanaFurniture.OnCommand(pid)
			-- added above
			return true
		end
	elseif idGui == config.ViewGUI then --View
		if tonumber(data) == 0 or tonumber(data) == 18446744073709551615 then --Close/Nothing Selected
			--Do nothing
			-- added below
			kanaFurniture.OnCommand(pid)
			-- added above
			return true
		else
			onViewChoice(pid, tonumber(data))
			return true
		end
	elseif idGui == config.ViewOptionsGUI then -- View Options
		if tonumber(data) == 0 then --Select
			onViewOptionSelect(pid)
			
			--kanaFurniture.OnCommand(pid)
			decorateHelp.OnCommand(pid)
			-- return true
		elseif tonumber(data) == 1 then --Put away
			onViewOptionPutAway(pid)
			kanaFurniture.OnCommand(pid)
		elseif tonumber(data) == 2 then --Sell
			onViewOptionSell(pid)
			
			kanaFurniture.OnCommand(pid)
		else --Close
			--Do nothing
			-- added below
			kanaFurniture.OnCommand(pid)
			-- added above
			return true
		end
	end
end

Methods.OnCommand = function(pid)
	showMainGUI(pid)
end

--Jakob
customCommandHooks.registerCommand("furniture", function(pid, cmd) showMainGUI(pid) end)
customCommandHooks.registerCommand("furn", function(pid, cmd) showMainGUI(pid) end)

customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	kanaFurniture.OnGUIAction(pid, idGui, data)
end)

customEventHooks.registerHandler("OnServerPostInit", function(eventStatus)
	kanaFurniture.OnServerPostInit()
end)

return Methods
