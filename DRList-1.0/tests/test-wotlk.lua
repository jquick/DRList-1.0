-- Running tests from command line: (Make sure you run from root/main folder)
-- > lua DRList-1.0/tests/test-wotlk.lua
--
-- Running tests ingame:
-- /drlist

if loadfile then
    assert(loadfile("DRList-1.0/tests/engine.lua"))()
end

local Tests = SimpleTesting:New("DRList-1.0", "WOTLK")
if not Tests:IsInGame() then
    strmatch = string.match
    GetLocale = function() return "enUS" end
    GetSpellInfo = function() return "" end

    WOW_PROJECT_MAINLINE = 1
    WOW_PROJECT_CLASSIC = 2
    WOW_PROJECT_BURNING_CRUSADE_CLASSIC = 5
    WOW_PROJECT_WRATH_CLASSIC = 11
    WOW_PROJECT_ID = 11

    assert(loadfile("DRList-1.0/libs/LibStub/LibStub.lua"))()
    assert(loadfile("DRList-1.0/DRList-1.0.lua"))()
    assert(loadfile("DRList-1.0/Spells.lua"))()
end

local DRList = LibStub("DRList-1.0")

function Tests:BeforeEach()
    DRList.gameExpansion = "wotlk"
end

Tests:It("Loads lib", function()
    assert(LibStub("DRList-1.0"))
    assert(type(LibStub("DRList-1.0").spellList) == "table")
    assert(LibStub("DRList-1.0").gameExpansion == "wotlk")
end)

Tests:It("GetsSpellList", function()
    assert(next(DRList.spellList))
    assert(DRList:GetSpells()[132169] == nil)
    assert(DRList:GetSpells()[44572] == "stun")
    assert(DRList:GetSpells()[339] == "root")
    assert(DRList:GetSpells()[51514] == "incapacitate")
    assert(DRList:GetSpells()[47476] == "silence")
    assert(DRList:GetSpells()[6789] == "horror")
end)

Tests:It("GetsResetTimes", function()
    assert(DRList:GetResetTime() == 19)
    assert(DRList:GetResetTime("stun") == 19)
    assert(DRList:GetResetTime("horror") == 19)
    assert(DRList:GetResetTime(123) == 19)
    assert(DRList:GetResetTime(true) == 19)
    assert(DRList:GetResetTime({}) == 19)
    assert(DRList:GetResetTime("npc") == 23)
end)

Tests:It("GetsCategoryNames", function()
    assert(type(DRList.categoryNames[DRList.gameExpansion].stun) == "string")
    assert(type(DRList:GetCategories().root) == "string")
    assert(type(DRList:GetCategories().opener_stun) == "string")
    assert(DRList:GetCategories().chastise == nil)
end)

Tests:It("GetsCategoryNamesPvE", function()
    assert(type(DRList:GetPvECategories().stun) == "string")
    assert(type(DRList:GetPvECategories().opener_stun) == "string")
    --assert(type(DRList:GetPvECategories().cyclone) == "string")
    --assert(DRList:GetPvECategories().taunt == nil)
    assert(DRList:GetPvECategories().horror == nil)
    assert(DRList:GetPvECategories().disorient == nil)
    assert(DRList:GetPvECategories().kidney_shot == nil)
    assert(DRList:GetPvECategories().chastise == nil)
end)

Tests:It("GetsCategoryFromSpell", function()
    assert(DRList:GetCategoryBySpellID(853) == "stun")
    assert(DRList:GetCategoryBySpellID(339) == "root")
    assert(DRList:GetCategoryBySpellID(1776) == "incapacitate")
    assert(DRList:GetCategoryBySpellID(2094) == "fear")

    assert(DRList:GetCategoryBySpellID(123) == nil)
    assert(DRList:GetCategoryBySpellID("123") == nil)
    assert(DRList:GetCategoryBySpellID(true) == nil)
    assert(DRList:GetCategoryBySpellID({}) == nil)
    assert(DRList:GetCategoryBySpellID() == nil)
end)

Tests:It("GetsLocalizations", function()
    assert(next(DRList.categoryNames))
    assert(DRList:GetCategoryLocalization("abc") == nil)
    assert(DRList:GetCategoryLocalization(123) == nil)
    assert(DRList:GetCategoryLocalization(true) == nil)
    assert(DRList:GetCategoryLocalization({}) == nil)
    assert(DRList:GetCategoryLocalization() == nil)

    assert(DRList:GetCategoryLocalization("kidney_shot") == nil)
    assert(DRList:GetCategoryLocalization("chastise") == nil)

    local low = string.lower
    assert(low(DRList.categoryNames[DRList.gameExpansion]["stun"]) == low(DRList.L.STUNS))
    assert(low(DRList:GetCategoryLocalization("root")) == low(DRList.L.ROOTS))
    assert(low(DRList:GetCategoryLocalization("random_root")) == low(DRList.L.RANDOM_ROOTS))
    assert(low(DRList:GetCategoryLocalization("horror")) == low(DRList.L.HORROR))
    assert(low(DRList:GetCategoryLocalization("cyclone")) == low(DRList.L.CYCLONE))
end)

Tests:It("ChecksCategoriesPvE", function()
    assert(next(DRList.categoriesPvE))
    assert(DRList:IsPvECategory("stun") == true)
    assert(DRList:IsPvECategory("opener_stun") == true)
    --assert(DRList:IsPvECategory("taunt") == false)
    assert(DRList:IsPvECategory("disorient") == false)
    assert(DRList:IsPvECategory("horror") == false)

    assert(DRList:IsPvECategory() == false)
    assert(DRList:IsPvECategory({}) == false)
    assert(DRList:IsPvECategory("") == false)
    assert(DRList:IsPvECategory(853) == false)
    assert(DRList:IsPvECategory(true) == false)
end)

Tests:It("GetsNextDR", function()
    assert(DRList:GetNextDR(1, "stun") == 0.50)
    assert(DRList:GetNextDR(2, "stun") == 0.25)
    assert(DRList:GetNextDR(3, "stun") == 0)
    assert(DRList:GetNextDR(10, "stun") == 0)

    assert(DRList:GetNextDR(1, "abc") == 0)
    assert(DRList:GetNextDR(1, 123) == 0)
    assert(DRList:GetNextDR(1, true) == 0)
    assert(DRList:GetNextDR("1", "stun") == 0)
    assert(DRList:GetNextDR(true, "stun") == 0)
    assert(DRList:GetNextDR({}, "stun") == 0)
    assert(DRList:GetNextDR(true) == 0)
    assert(DRList:GetNextDR() == 0)
    assert(DRList:GetNextDR(-1, {}) == 0)
    assert(DRList:GetNextDR(1, "random_stun") == 0.50)
    assert(DRList:GetNextDR(1, "cyclone") == 0.50)
    assert(DRList:GetNextDR(2, "horror") == 0.25)
    assert(DRList:GetNextDR(2, "opener_stun") == 0.25)

    assert(DRList:GetNextDR(1, "disorient") == 0)
    assert(DRList:GetNextDR(2, "disorient") == 0)
    assert(DRList:GetNextDR(2, "kidney_shot") == 0)

    assert(DRList:GetNextDR(0, "knockback") == 0)
    assert(DRList:GetNextDR(1, "knockback") == 0)

    --assert(DRList:GetNextDR(1, "taunt") ==  0)
end)

Tests:It("IterateSpellsByCategory", function()
    local ran = false
    for spellID, category in DRList:IterateSpellsByCategory("root") do
        assert(type(spellID) == "number")
        assert(category == "root")
        ran = true
    end
    assert(ran)
    ran = false

    for category, localizedCategory in pairs(DRList:GetPvECategories()) do
        for spellID, cat in DRList:IterateSpellsByCategory(category) do -- luacheck: ignore
            assert(type(spellID) == "number")
            assert(category == cat)
            ran = true
            break
        end
    end
    assert(ran)
end)

-- This test is only ran ingame
Tests:It("Verifies spell list", function()
    local success = true
    local err = ""

    for spellID, category in pairs(DRList.spellList) do
        if type(spellID) ~= "number" or not GetSpellInfo(spellID) then
            success = false
            err = err .. "|cFFFF0000Invalid spell:|r " .. spellID .. "\n"
        end

        if type(category) ~= "string" or not DRList.categoryNames[DRList.gameExpansion][category] then
            success = false
            err = err .. "|cFFFF0000Invalid category:|r " .. category .. "\n"
        end
    end

    if not success then
        return error(err)
    end

    return success
end, true)

if Tests:IsInGame() then
    if WOW_PROJECT_WRATH_CLASSIC and WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then
        SLASH_DRLIST1 = "/drlist"
        SlashCmdList["DRLIST"] = function()
            Tests:RunAll()
        end
    end
else
    Tests:RunAll()
end
