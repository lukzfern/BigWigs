﻿----------------------------------
--      Module Declaration      --
----------------------------------

local boss = BB["Koralon the Flame Watcher"]
local mod = BigWigs:New(boss, "$Revision$")
if not mod then return end
mod.zonename = BZ["Vault of Archavon"]
mod.otherMenu = "Northrend"
mod.enabletrigger = boss
mod.guid = 33993
mod.toggleoptions = {"fists", "cinder", "berserk", "bosskill"}

------------------------------
--      Are you local?      --
------------------------------

local db = nil
local started = nil
local UnitGUID = _G.UnitGUID
local GetNumRaidMembers = _G.GetNumRaidMembers
local fmt = _G.string.format
local guid = nil

----------------------------
--      Localization      --
----------------------------

local L = AceLibrary("AceLocale-2.2"):new("BigWigs"..boss)

L:RegisterTranslations("enUS", function() return {
	cmd = "Koralon",

	fists = "Meteor Fists",
	fists_desc = "Warn when Koralon casts Meteor Fists.",
	fists_message = "Meteor Fists Active!",

	cinder = "cinder",
	cinder_desc = "Warn when Emalon casts Flaming Cinder.",
	cinder_message = "Flaming Cinder!",
} end )

------------------------------
--      Initialization      --
------------------------------

function mod:OnEnable()
	self:AddCombatListener("SPELL_AURA_APPLIED", "Fists", 66725, 66808)
	self:AddCombatListener("SPELL_CAST_SUCCESS", "Cinder", 67332, 66684)
	self:AddCombatListener("UNIT_DIED", "BossDeath")

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("BigWigs_RecvSync")

	started = nil
	guid = nil
	db = self.db.profile
end

------------------------------
--      Event Handlers      --
------------------------------

function mod:Fists(_, spellID)
	if db.fists then
		self:IfMessage(L["fists_message"], "Attention", spellID)
		self:Bar(L["fists"], 15, spellID)
	end
end

function mod:Cinder(_, spellID)
	if db.cinder then
		self:IfMessage(L["cinder_message"], "Attention", spellID)
		self:Bar(L["cinder_bar"], 20, spellID)
	end
end

function mod:BigWigs_RecvSync(sync, rest, nick)
	if self:ValidateEngageSync(sync, rest) and not started then
		started = true
		if self:IsEventRegistered("PLAYER_REGEN_DISABLED") then
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		end
		if db.berserk then
			self:Enrage(360, true)
		end
	end
end

