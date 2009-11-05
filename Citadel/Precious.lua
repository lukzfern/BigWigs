if not QueryQuestsCompleted then return end
--------------------------------------------------------------------------------
-- Module declaration
--

local mod = BigWigs:NewBoss("Precious", "Icecrown Citadel")
if not mod then return end
mod:RegisterEnableMob(37212)
mod.toggleOptions = {"zombies", 71123, {71127, "FLASHSHAKE"}, "bosskill"}
 --71123: Decimate
 --71127: Mortal wound
 --71159: Zombies

--------------------------------------------------------------------------------
-- Locals
--

local summoned = nil

--------------------------------------------------------------------------------
-- Localization
--

local L = LibStub("AceLocale-3.0"):NewLocale("Big Wigs: Precious", "enUS", true)
if L then
	L.zombies = GetSpellInfo(71159)
	L.zombies_desc = "Summons 11 Plague Zombies to assist the caster."
	L.zombies_message = "Zombies summoned!"
	L.zombies_cd = "~Next Zombies" -- 20sek cd (11 Zombies)
	
	L.wound_message = "%2$dx Mortal Wound on %1$s"
	
	L.decimate_cd = "~Next Decimate" -- 33 sec cd
end
L = LibStub("AceLocale-3.0"):GetLocale("Big Wigs: Precious")
mod.locale = L

--------------------------------------------------------------------------------
-- Initialization
--

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Wound", 71127)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Wound", 71127)
	self:Log("SPELL_SUMMON", "Zombies", 71159)
	self:Log("SPELL_CAST_SUCCESS", "Decimate", 71123)

	self:Death("Win", 37212)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
end

function mod:OnEngage()
	--self:Bar(71159, spellName, 45, 71159)
end

--------------------------------------------------------------------------------
-- Event handlers
--

function mod:Wound(player, spellId, _, _, spellName)
	local _, _, icon, stack = UnitDebuff(player, spellName)
	if stack and stack > 1 then
		self:TargetMessage(71127, L["wound_message"], player, "Urgent", icon, "Info", stack)
	end
end

function mod:Decimate(_, spellId, _, _, spellName)
	self:Message(71123, spellName, "Attention", spellId)
	self:Bar(71123, L["decimate_cd"], 33, spellId)
end

do
	local function resetZombies() summoned = nil end
	function mod:Zombies() 
		if summoned then return end
		summoned = true
		self:Message("zombies", L["zombies_message"], "Important", 71159)
		self:Bar("zombies", L["zombies_cd"], 20, 71159)
		self:ScheduleTimer(resetZombies, 3)
	end
end
