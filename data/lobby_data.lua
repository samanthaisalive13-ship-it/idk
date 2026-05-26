-- Combined Lobby Configuration Module
-- Contains optimized, math-only structures for ClassConfigs and Races

local lobby_data = {
    ClassConfigs = {},
    Races = {}
}

-- 1. CLASS SKILL TREES (ClassConfigs)
-- Keys correspond to skill nodes: M (Middle/General), L (Left/Defensive), R (Right/Offensive)
lobby_data.ClassConfigs = {
    ["Warrior"] = {
        max_points = { M1 = 5, M2 = 5, M3 = 5, L2 = 5, L3 = 5, R2 = 5, R3 = 5 },
        level_costs = {
            M1 = { 1, 1, 2, 3, 3 }, M2 = { 1, 1, 2, 3, 3 }, M3 = { 1, 1, 2, 3, 4 },
            L2 = { 1, 1, 2, 3, 4 }, L3 = { 1, 1, 2, 3, 4 },
            R2 = { 1, 1, 2, 3, 4 }, R3 = { 1, 1, 2, 3, 4 }
        },
        skills = {
            M1 = { name = "Stat Points", stat_points_per_pt = 1 },
            M2 = { name = "HP", hp_per_pt = 2 },
            M3 = { name = "Conquerer's Basics", str_mult_per_pt = 0.02, con_mult_per_pt = 0.02 },
            L2 = { name = "Unbreakable Guard", block_chance_per_pt = 0.01 },
            L3 = { name = "Demanding Presence", aggro_mult_per_pt = 0.03 },
            R2 = { name = "Iron Defenses", block_dr_per_pt = 0.01 },
            R3 = { name = "Everlasting", status_damage_reduction_per_pt = 0.03 }
        }
    },
    ["Mage"] = {
        max_points = { M1 = 5, M2 = 5, M3 = 5, L2 = 5, L3 = 5, R2 = 5, R3 = 5 },
        level_costs = {
            M1 = { 1, 1, 2, 3, 3 }, M2 = { 1, 1, 2, 3, 3 }, M3 = { 1, 1, 2, 3, 4 },
            L2 = { 1, 1, 2, 3, 4 }, L3 = { 1, 1, 2, 3, 4 },
            R2 = { 1, 1, 2, 3, 4 }, R3 = { 1, 1, 2, 3, 4 }
        },
        skills = {
            M1 = { name = "Stat Points", stat_points_per_pt = 1 },
            M2 = { name = "HP", hp_per_pt = 2 },
            M3 = { name = "Archmage Ascension", int_mult_per_pt = 0.02 },
            L2 = { name = "Strategic Mind", weakness_damage_mult_per_pt = 0.02 },
            L3 = { name = "Counterspell", force_damage_taken_mult_per_pt = -0.01, force_damage_deal_mult_per_pt = 0.01 },
            R2 = { name = "Reinforced Summoning", summon_hp_mult_per_pt = 0.03 },
            R3 = { name = "Proficient Conjuration", summon_damage_mult_per_pt = 0.02 }
        }
    },
    ["Rogue"] = {
        max_points = { M1 = 5, M2 = 5, M3 = 5, L2 = 5, L3 = 5, R2 = 5, R3 = 5 },
        level_costs = {
            M1 = { 1, 1, 2, 3, 3 }, M2 = { 1, 1, 2, 3, 3 }, M3 = { 1, 1, 2, 3, 4 },
            L2 = { 1, 1, 2, 3, 4 }, L3 = { 1, 1, 2, 3, 4 },
            R2 = { 1, 1, 2, 3, 4 }, R3 = { 1, 1, 2, 3, 4 }
        },
        skills = {
            M1 = { name = "Stat Points", stat_points_per_pt = 1 },
            M2 = { name = "HP", hp_per_pt = 2 },
            M3 = { name = "Jagged Edge", bleed_chance_per_pt = 0.04 },
            L2 = { name = "Trained Killer", crit_chance_per_pt = 0.01 },
            L3 = { name = "Nimble", dodge_chance_per_pt = 0.005 },
            R2 = { name = "Thievery", gold_mult_per_pt = 0.05 },
            R3 = { name = "Shadowy Figure", aggro_mult_per_pt = -0.03 }
        }
    },
    ["Priest"] = {
        max_points = { M1 = 5, M2 = 5, M3 = 5, L2 = 5, L3 = 5, R2 = 5, R3 = 5 },
        level_costs = {
            M1 = { 1, 1, 2, 3, 3 }, M2 = { 1, 1, 2, 3, 3 }, M3 = { 1, 1, 2, 3, 4 },
            L2 = { 1, 1, 2, 3, 4 }, L3 = { 1, 1, 2, 3, 4 },
            R2 = { 1, 1, 2, 3, 4 }, R3 = { 1, 1, 2, 3, 4 }
        },
        skills = {
            M1 = { name = "Stat Points", stat_points_per_pt = 1 },
            M2 = { name = "HP", hp_per_pt = 2 },
            M3 = { name = "Faith Rewarded", fth_mult_per_pt = 0.02 },
            L2 = { name = "Advanced Restoration", outgoing_healing_mult_per_pt = 0.02 },
            L3 = { name = "Blessings of Greater Faith", incoming_healing_mult_per_pt = 0.02 },
            R2 = { name = "Conquerer's Wrath", holy_damage_mult_per_pt = 0.02 },
            R3 = { name = "Gathering Darkness", dark_damage_mult_per_pt = 0.02 }
        }
    },
    ["Brawler"] = {
        max_points = { M1 = 5, M2 = 5, M3 = 1, L2 = 5, L3 = 5, R2 = 5, R3 = 5 },
        level_costs = {
            M1 = { 1, 1, 2, 3, 3 }, M2 = { 1, 1, 2, 3, 3 }, M3 = { 11 },
            L2 = { 1, 1, 2, 3, 4 }, L3 = { 1, 1, 2, 3, 4 },
            R2 = { 1, 1, 2, 3, 4 }, R3 = { 1, 1, 2, 3, 4 }
        },
        skills = {
            M1 = { name = "Stat Points", stat_points_per_pt = 1 },
            M2 = { name = "HP", hp_per_pt = 2 },
            M3 = { name = "Battle Prowess", turn_start_dr = 0.15, turn_start_dr_duration = 2 },
            L2 = { name = "Heavy Handed", crit_damage_mult_per_pt = 0.015 },
            L3 = { name = "Clear Mind", energy_gain_chance_per_pt = 0.01 },
            R2 = { name = "Precise Punches", physical_damage_mult_per_pt = 0.02 },
            R3 = { name = "Predation", lifesteal_per_pt = 0.008 }
        }
    },
    ["Ranger"] = {
        max_points = { M1 = 5, M2 = 5, M3 = 1, L2 = 5, L3 = 5, R2 = 5, R3 = 3 },
        level_costs = {
            M1 = { 1, 1, 2, 3, 3 }, M2 = { 1, 1, 2, 3, 3 }, M3 = { 11 },
            L2 = { 1, 1, 2, 3, 4 }, L3 = { 1, 1, 2, 3, 4 },
            R2 = { 1, 1, 2, 3, 4 }, R3 = { 2, 4, 5 }
        },
        skills = {
            M1 = { name = "Stat Points", stat_points_per_pt = 1 },
            M2 = { name = "HP", hp_per_pt = 2 },
            M3 = { name = "Colossus Slayer", giant_slayer_apply_mark_turns = 3 },
            L2 = { name = "Kinetic Mastery", force_damage_mult_per_pt = 0.02 },
            L3 = { name = "Fey Trickery", psychic_damage_mult_per_pt = 0.02 },
            R2 = { name = "Scavenger's Bounty", double_drop_chance_per_pt = 0.04 },
            R3 = { name = "Preemption", initiative_per_pt = 1 }
        }
    },
    ["Bard"] = {
        max_points = { M1 = 5, M2 = 5, M3 = 1, L2 = 5, L3 = 5, R2 = 5, R3 = 3 },
        level_costs = {
            M1 = { 1, 1, 2, 3, 3 }, M2 = { 1, 1, 2, 3, 3 }, M3 = { 11 },
            L2 = { 1, 1, 2, 3, 4 }, L3 = { 1, 1, 2, 3, 4 },
            R2 = { 1, 1, 2, 3, 4 }, R3 = { 2, 4, 5 }
        },
        skills = {
            M1 = { name = "Stat Points", stat_points_per_pt = 1 },
            M2 = { name = "HP", hp_per_pt = 2 },
            M3 = { name = "Master of Melodies", song_duration_bonus = 1, song_empower_override = 0.25 },
            L2 = { name = "Building Tempo", outgoing_shielding_mult_per_pt = 0.03 },
            L3 = { name = "Pleasantries", charmed_damage_debuff_per_pt = -0.03 },
            R2 = { name = "Devil's Tongue", psychic_damage_mult_per_pt = 0.02 },
            R3 = { name = "Manipulator", charmed_target_damage_mult_per_pt = 0.03 }
        }
    }
}

-- 2. RACE PASSIVES & MODIFIERS (Races)
lobby_data.Races = {
    ["Human"] = {
        scale = 1.0,
        passives = {
            adept = { stat_point_step = 2, stat_bonus = 1 },
            specialization = { highest_stat_mult = 1.05 }
        }
    },
    ["Robloxian"] = {
        scale = 1.0,
        requirements = { "Surpassing Stupidity" },
        passives = {
            builders_club = { weapon_type_restriction = "Hammer", damage_mult = 1.0595 },
            tix = { gold_gain_mult = 1.10 },
            toolbox = { unlock_drink_skills = true }
        }
    },
    ["Elf"] = {
        scale = 1.0,
        requirements = { "Gigantomachy" },
        passives = {
            magical_origin = { force_damage_taken = 0.90, psychic_damage_taken = 0.90, physical_damage_taken = 1.10, charm_immune = true },
            mana_convergence = { double_energy_chance = 0.05, base_energy_mult = 1.10, energy_to_crit_conversion_ratio = 0.30 }
        }
    },
    ["Dwarf"] = {
        scale = 0.8,
        requirements = { "Steampunk Slammer" },
        passives = {
            dwarven_resilience = { max_hp_mult = 1.10, status_resistance = 0.10 },
            masterwork = { craft_stat_growth_per_level = 0.0075 }
        }
    },
    ["Goblin"] = {
        scale = 0.7,
        requirements = {},
        passives = {
            green_greed = { gold_gain_mult = 1.35 }
        }
    },
    ["Kobold"] = {
        scale = 0.75,
        requirements = { "A Small Favor" },
        passives = {
            epidermal_scales = { incoming_crit_damage_mult = 0.75 },
            fire_resistance = { fire_damage_taken = 0.70 },
            birthright = { fire_damage_lifesteal = 0.10 }
        }
    },
    ["Drakon"] = {
        scale = 1.0,
        requirements = { "A Small Favora" },
        passives = {
            epidermal_scales = { incoming_crit_damage_mult = 0.75 },
            trueblood_ignition = { replacement_ability = "Trueblood Ignition" },
            birthright = { fire_damage_lifesteal = 0.10, fire_damage_taken = 0.75 }
        }
    },
    ["Wulven"] = {
        scale = 1.0,
        requirements = {},
        passives = {
            pack_tactics = { base_offensive_step = 0.05, base_defensive_step = 0.03, wulven_synergy_boost = 0.10 },
            follow_up = { damage_mult_per_prior_attack = 1.03 }
        }
    },
    ["Nyvari"] = {
        scale = 1.0,
        requirements = {},
        passives = {
            catlike_form = { max_hp_mult = 0.85, base_dodge_bonus = 0.05 },
            flow_reversal = { max_stacks = 5, damage_multiplier_per_stack = 0.10 }
        }
    },
    ["Gamirn"] = {
        scale = 0.95,
        requirements = {},
        passives = {
            communal_offering = { lifesteal_from_outgoing_healing = 0.10 },
            protector_of_the_briar = { vs_void_damage_mult = 1.10 },
            guardian_blessing = { grant_skill = "Guardian Spirit's Blessing" }
        }
    },
    ["Dark Elf"] = {
        scale = 1.0,
        requirements = {},
        passives = {
            murder_prowess = { on_first_kill_energy_gain = 1, on_first_kill_rallied_turns = 3 },
            cull_the_weak = { vs_poisoned_damage_mult = 1.10 },
            chosen_of_the_queen = { base_poison_chance = 0.25, fth_poison_scaling_factor = 0.0025 }
        }
    },
    ["Withered"] = {
        scale = 1.0,
        requirements = { "Cycle of Death" },
        passives = {
            life_in_death = { fire_taken = 1.20, holy_taken = 1.30, necrotic_taken = 0.70, poison_taken = 0.80 },
            regenerator = { missing_hp_regen_per_turn = 0.10 },
            pact_of_the_husk = { convert_lifesteal_to_dark = true }
        }
    },
    ["Oscarios"] = {
        scale = 0.95,
        requirements = {},
        passives = {
            living_legend = { can_scribe_abilities = true },
            knight_of_the_scroll = { energy_spent_shield_factor = 0.05 }
        }
    },
    ["Noctria"] = {
        scale = 1.0,
        requirements = {},
        passives = {
            seekers_vision = { bypass_accuracy_checks = true },
            sight_beyond_sight = { focus_grant_true_damage = 0.15 },
            wise_guard = { block_chance_int_effectiveness = 0.35, block_dr_int_effectiveness = 0.35, max_hp_mult = 0.90 }
        }
    },
    ["Myconid"] = {
        scale = 0.9,
        requirements = {},
        passives = {
            parasitic_explosion = { trigger_active_spores = true, reflect_spores_on_hit_turns = 2 },
            spreading_spores = { apply_random_spores_on_heal = true },
            fungal_body = { poison_taken = 0.70, necrotic_taken = 0.70, physical_taken = 1.20, fire_taken = 1.30 }
        }
    },
    ["Glitchborn"] = {
        scale = 1.0,
        requirements = { "0x000000EF" },
        passives = {
            desync = { hp_threshold = 0.25, dodge_bonus = 0.50, damage_reduction = 0.50, outgoing_damage_mult = 0.50, duration = 2 },
            buffer_overflow = { trigger_chance = 0.404, damage_fraction = 0.404, apply_random_statuses_count = 2 },
            glitching = { focus_apply_random_positives_count = 2 }
        }
    },
    ["Bluarian"] = {
        scale = 1.2,
        requirements = {},
        passives = {
            phantasmagoria = { apply_fear_on_first_hit = true },
            fading_image = { aggro_mult = 0.75, afterimage_dark_fraction = 0.15 },
            fear_factor = { vs_feared_dark_extra_max_hp_damage = 0.05 }
        }
    }
}

return lobby_data
