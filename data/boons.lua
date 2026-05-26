-- Compandium of Passive Perks (Boons)
-- Stripped of cosmetic resources for optimal algorithm lookup

local boons = {}

boons.Data = {
    ["Critical Overdrive"] = {
        slots = 3,
        cost = 100,
        mutually_exclusive = { "Natural 20" },
        requirements = { "Dink!" },
        effects = {
            crit_chance_turn_1 = 1.0,
            crit_damage_flat = 0.25,
            total_damage_mult = 0.85,
            high_crit_bonus = 0.40,
            high_crit_threshold = 0.60
        }
    },
    ["Selfless Heart"] = {
        slots = 2,
        cost = 50,
        requirements = { "It's a Miracle" },
        effects = {
            outgoing_healing_mult = 1.20,
            incoming_healing_mult = 0.90,
            damage_mult = 0.90
        }
    },
    ["Thick Hide"] = {
        slots = 1,
        cost = 20,
        requirements = { "Gigantomachy" },
        effects = {
            physical_damage_mult = 0.90
        }
    },
    ["Elven Skin"] = {
        slots = 1,
        cost = 20,
        requirements = { "Bixies..." },
        effects = {
            force_damage_mult = 0.85
        }
    },
    ["Vampiric Bloodline"] = {
        slots = 2,
        cost = 100,
        requirements = { "Go Ahead, Be Negative!", "Familial Bond" },
        effects = {
            lifesteal = 0.05,
            incoming_healing_mult = 1.10,
            fire_damage_mult = 1.25,
            holy_damage_mult = 1.25
        }
    },
    ["Mage Birthsign"] = {
        slots = 3,
        cost = 100,
        requirements = { "The Magic... It's Gathering" },
        effects = {
            int_multiplier = 1.10,
            damage_taken_mult = 1.10,
            grant_random_scroll = true
        }
    },
    ["Nobility"] = {
        slots = 1,
        cost = 10,
        requirements = { "Luh Gobbus" },
        effects = {
            gold_gain_mult = 1.25,
            max_hp_mult = 0.90
        }
    },
    ["Trained"] = {
        slots = 1,
        cost = 10,
        requirements = { "Starting Out" },
        effects = {
            stat_points_bonus = 3
        }
    },
    ["Ourpled"] = {
        slots = 1,
        cost = 10,
        requirements = { "Ourple" },
        effects = {
            necrotic_damage_mult = 0.95,
            poison_damage_mult = 0.95,
            force_damage_mult = 0.95
        }
    },
    ["Well Prepared"] = {
        slots = 1,
        cost = 20,
        requirements = { "P-Potion Seller..." },
        effects = {
            start_items = {
                ["Minor Healing Potion"] = 2,
                ["Minor Energy Potion"] = 1,
                ["Apple"] = 3,
                ["Carp"] = 2
            }
        }
    },
    ["Force of Will"] = {
        slots = 1,
        cost = 30,
        requirements = { "Stay Dead" },
        effects = {
            revive_threshold_hp = 5,
            revives_per_encounter = 1
        }
    },
    ["The Pinnacle"] = {
        slots = 3,
        cost = 100,
        requirements = { "Purification" },
        effects = {
            damage_taken_mult = 1.50,
            stat_point_per_combat = 1
        }
    },
    ["Silvered Arms"] = {
        slots = 2,
        cost = 50,
        requirements = { "Will you prove worthy?" },
        effects = {
            convert_physical_to_force = true,
            physical_int_scaling = 0.005
        }
    },
    ["Summoner Supreme"] = {
        slots = 2,
        cost = 50,
        requirements = { "Arise" },
        effects = {
            summon_hp_mult = 1.25,
            summon_damage_mult = 1.10
        }
    },
    ["Energy Conserver"] = {
        slots = 2,
        cost = 50,
        requirements = { "Come, Test Your Convictions" },
        effects = {
            extra_energy_chance = 0.15
        }
    },
    ["Fortitude"] = {
        slots = 2,
        cost = 50,
        requirements = { "Bloodbath" },
        effects = {
            status_damage_mult = 0.70
        }
    },
    ["The Chosen One"] = {
        slots = 4,
        cost = 250,
        requirements = { "The Chosen" },
        effects = {
            force_sword_pull = true,
            flat_str_bonus = 5,
            skill_check_stat_mult = 1.20,
            sword_event_weight_mult = 2.0
        }
    },
    ["Natural 20"] = {
        slots = 3,
        cost = 50,
        mutually_exclusive = { "Critical Overdrive" },
        requirements = { "My Lucky Day" },
        effects = {
            set_crit_chance = 0.05,
            base_crit_damage = 2.0,
            crit_chance_to_damage_ratio = 1.5,
            undodgeable_crits = true,
            skill_check_any_pass_chance = 0.05
        }
    },
    ["Alert"] = {
        slots = 1,
        cost = 20,
        requirements = { "Quick Feet" },
        effects = {
            initiative_bonus = 3,
            turn_1_block_bonus = 0.05,
            turn_1_dodge_bonus = 0.05,
            turn_2_block_bonus = 0.05,
            turn_2_dodge_bonus = 0.05
        }
    },
    ["Divine Retribution"] = {
        slots = 3,
        cost = 100,
        requirements = { "For The Emperor!" },
        effects = {
            healing_effectiveness = 0.5,
            fth_multiplier = 1.10,
            dark_damage_mult = 0.75,
            holy_damage_mult = 1.10,
            damage_taken_mult = 1.10
        }
    },
    ["Opportunist"] = {
        slots = 2,
        cost = 50,
        requirements = { "The Beast, Full Moon, Alpha" },
        effects = {
            uninjured_target_damage_mult = 1.25,
            injured_target_damage_mult = 0.90
        }
    },
    ["Overtime"] = {
        slots = 3,
        cost = 100,
        requirements = { "Taking Your Sweet Time" },
        effects = {
            start_damage_mult = 0.70,
            damage_gain_per_turn = 0.10,
            turn_threshold = 3,
            post_threshold_damage_mult = 1.20,
            post_threshold_energy_bonus = 1
        }
    },
    ["Flow State"] = {
        slots = 3,
        cost = 100,
        requirements = { "True Man's World" },
        effects = {
            crit_damage_per_dodge = 0.006,
            dodge_per_dodge = 0.002,
            max_stacks = 50,
            dodge_cap_override = 0.85,
            dodge_cap_threshold = 40,
            damage_taken_mult = 1.15,
            max_stacks_per_encounter = 3
        }
    },
    ["Potential: Bunny"] = {
        slots = 5,
        cost = 300,
        requirements = { "For My Lord" },
        effects = {
            damage_mult = 0.25,
            spawn_companion = "Bunny?"
        }
    },
    ["Bulk Up"] = {
        slots = 1,
        cost = 20,
        requirements = { "Beefy" },
        effects = {
            hp_bonus = 10,
            initiative_bonus = -3
        }
    },
    ["Destined"] = {
        slots = 2,
        cost = 50,
        requirements = { "This Village Needs a Hero!" },
        effects = {
            damage_mult = 1.20,
            randomize_stats = true
        }
    },
    ["Perserverance"] = {
        slots = 2,
        cost = 30,
        requirements = { "A Golden Vow" },
        effects = {
            low_hp_threshold = 0.50,
            damage_reduction_low_hp = 0.10
        }
    },
    ["Daredevil Impulse"] = {
        slots = 3,
        cost = 100,
        requirements = { "You're Mine!" },
        effects = {
            impulse_per_action = 2,
            max_impulse_stacks = 10,
            damage_per_impulse = 0.025,
            lifesteal_at_stacks = 8,
            lifesteal_value = 0.10,
            damage_mult = 0.90,
            damage_taken_mult = 1.15
        }
    },
    ["Honed Mind"] = {
        slots = 2,
        cost = 30,
        requirements = { "My Ordinary Life" },
        effects = {
            focus_duration_bonus = 1,
            damage_mult = 1.15,
            damage_taken_mult = 1.25
        }
    },
    ["Death's Dance"] = {
        slots = 2,
        cost = 50,
        requirements = { "Dragonslayer" },
        effects = {
            defer_damage_percent = 0.30,
            defer_non_lethal = true
        }
    },
    ["Cleansing"] = {
        slots = 2,
        cost = 50,
        requirements = { "Tree Hugging" },
        effects = {
            dots_cleansed_on_heal = 2,
            healing_effectiveness = 0.75
        }
    },
    ["Weak Points"] = {
        slots = 1,
        cost = 20,
        requirements = { "The Dark Brotherhood" },
        effects = {
            flat_crit_damage_bonus = 0.08
        }
    },
    ["Keen Eye"] = {
        slots = 1,
        cost = 20,
        requirements = { "The Good, The Bad, and The Drifter" },
        effects = {
            flat_crit_chance_bonus = 0.04
        }
    },
    ["Well Rested"] = {
        slots = 1,
        cost = 20,
        requirements = { "Long Rest" },
        effects = {
            post_combat_heal = 5
        }
    },
    ["Wild Ride"] = {
        slots = 2,
        cost = 50,
        requirements = { "I Want Off!" },
        effects = {
            damage_min_mult = 0.80,
            damage_max_mult = 1.25,
            damage_taken_min_mult = 0.85,
            damage_taken_max_mult = 1.10
        }
    },
    ["Inconspicuous"] = {
        slots = 1,
        cost = 10,
        requirements = { "Nothing To See Here" },
        effects = {
            aggro_mult = 0.75
        }
    },
    ["Conspicuous"] = {
        slots = 1,
        cost = 10,
        requirements = { "Overly Chalant" },
        effects = {
            aggro_mult = 1.25
        }
    },
    ["Jack of All Trades"] = {
        slots = 2,
        cost = 200,
        requirements = { "Ultraviolence" },
        effects = {
            disable_subclasses = true,
            disable_skill_tree = true,
            grant_all_base_weapons = true,
            grant_all_base_classes = true
        }
    },
    ["Potential: Pebble"] = {
        slots = 3,
        cost = 200,
        requirements = { "Better Pebble Wins" },
        effects = {
            damage_mult = 0.50,
            spawn_companion = "Pebble?"
        }
    },
    ["Matrix Anomaly"] = {
        slots = 4,
        cost = 100,
        requirements = { "Neo" },
        effects = {
            escape_matrix = true,
            grant_shades = "Analytic Shades"
        }
    },
    ["Epicure"] = {
        slots = 2,
        cost = 50,
        requirements = { "Gourmet" },
        effects = {
            first_eat_heal_mult = 1.30,
            first_eat_cleanse = 2,
            stat_per_unique_foods = { unique_count = 3, stat_point = 1 },
            repeat_eat_heal_mult = 0.70
        }
    },
    ["Looting"] = {
        slots = 1,
        cost = 20,
        requirements = { "Path Correction" },
        effects = {
            double_drop_chance = 0.10
        }
    },
    ["Versatile"] = {
        slots = 2,
        cost = 50,
        requirements = { "Western Glory" },
        effects = {
            single_target_focus = { buff_next_aoe = 0.20, debuff_next_single = -0.30 },
            aoe_focus = { buff_next_single = 0.20, debuff_next_aoe = -0.30 }
        }
    },
    ["True Strike"] = {
        slots = 1,
        cost = 25,
        requirements = { "Slick Moves" },
        effects = {
            first_turn_unmissable = true,
            first_turn_undodgeable = true
        }
    },
    ["Voidtouched"] = {
        slots = 2,
        cost = 50,
        requirements = { "Such Fascinating Evolution" },
        effects = {
            voidblaze_chance_on_hit = 0.16,
            ability_damage_taken_mult = 1.06,
            dark_void_damage_taken_mult = 0.76
        }
    },
    ["Thornmail"] = {
        slots = 2,
        cost = 30,
        requirements = { "Prickly Thorns" },
        effects = {
            reflect_percent = 0.40,
            damage_type = "Physical",
            applies_lifesteal = false
        }
    },
    ["Coagulating Ichor"] = {
        slots = 2,
        cost = 50,
        requirements = { "Bloodmoon Rising" },
        effects = {
            start_ichor_stacks = 2,
            dark_damage_taken_mult = 0.90
        }
    },
    ["Blood Arts"] = {
        slots = 2,
        cost = 50,
        requirements = { "Bloodmoon Eclipsing" },
        effects = {
            damage_mult_per_bleed_turn = 1.02,
            damage_taken_mult_per_bleed_turn = 0.985,
            max_bleed_turns = 10,
            bleed_damage_taken_mult = 0.60,
            healing_effectiveness_mult = 0.70
        }
    },
    ["Shock Absorption"] = {
        slots = 2,
        cost = 50,
        requirements = { "Brute Force" },
        effects = {
            block_guard_buff_stack = 0.02,
            max_stacks = 20,
            reset_on_combat_start = true
        }
    },
    ["Irrepresssable Drive"] = {
        slots = 2,
        cost = 50,
        requirements = { "Going Nowhere" },
        effects = {
            dodge_debuff_effectiveness_mult = 0.60
        }
    },
    ["Enervation"] = {
        slots = 2,
        cost = 50,
        requirements = { "Ultimate Serum" },
        effects = {
            damage_mult_per_dot = 1.05,
            max_dot_multiplier = 1.40,
            debuff_damage_taken_mult = 1.15
        }
    },
    ["Small Game Hunter"] = {
        slots = 1,
        cost = 25,
        requirements = { "Small Game" },
        effects = {
            small_enemy_damage_mult = 1.15
        }
    },
    ["Steam Engine"] = {
        slots = 2,
        cost = 50,
        requirements = { "Steampunk Slammer" },
        effects = {
            apply_steam_on_fire_hit = true,
            steam_penalty_mult = 0.70
        }
    },
    ["Steam Conversion"] = {
        slots = 2,
        cost = 30,
        requirements = { "Steampunk Slammer" },
        effects = {
            start_steam_stacks = 3,
            steam_gain_on_fire_taken = true,
            fire_damage_mult_per_steam = 1.02,
            fire_damage_taken_mult_per_steam = 0.98,
            steam_penalty_mult = 0.70
        }
    },
    ["Critical Healing"] = {
        slots = 3,
        cost = 100,
        requirements = { "Support Carry" },
        effects = {
            healing_crit_multiplier = 0.65
        }
    },
    ["Toxicator"] = {
        slots = 2,
        cost = 50,
        requirements = { "Experiment: Failed" },
        effects = {
            poison_chance_on_poison_hit = 0.35,
            toxin_x_chance_on_toxin_poison_apply = 0.35
        }
    },
    ["Plagueburst"] = {
        slots = 2,
        cost = 50,
        requirements = { "Experiment: Failed" },
        effects = {
            toxic_burst_scale_factor = 2.0,
            poison_explosion_type = "Poison"
        }
    },
    ["Resonant Soul"] = {
        slots = 1,
        cost = 20,
        requirements = { "Legendary Lore" },
        effects = {
            positive_song_effectiveness_mult = 1.15,
            negative_song_effectiveness_mult = 0.85
        }
    },
    ["Mental Deterioration"] = {
        slots = 1,
        cost = 20,
        requirements = { "Weaver of Echoes" },
        effects = {
            fear_charm_target_damage_mult = 1.10,
            feared_charmed_incoming_damage_mult = 1.10
        }
    },
    ["Incandescence"] = {
        slots = 1,
        cost = 30,
        requirements = { "Imperium Meminit" },
        effects = {
            convert_fire_to_holy = true,
            convert_burn_to_holy_fire = true,
            dark_damage_taken_mult = 1.15
        }
    },
    ["Underdog"] = {
        slots = 1,
        cost = 30,
        requirements = { "For The People" },
        effects = {
            higher_hp_damage_mult = 0.90,
            lower_hp_damage_mult = 1.10,
            low_hp_threshold = 0.50,
            low_hp_damage_mult = 1.15
        }
    },
    ["Blood Sacrifice"] = {
        slots = 2,
        cost = 50,
        requirements = { "Thwart Evil" },
        effects = {
            self_damage_percent = 0.20,
            ally_heal_percent = 0.15,
            apply_psyched_turns = 2,
            apply_ruptured_turns = 2
        }
    },
    ["Dark Sight"] = {
        slots = 1,
        cost = 20,
        requirements = { "Cave Cleaner" },
        effects = {
            blind_immunity = true,
            miss_effectiveness_mult = 0.70,
            holy_damage_taken_mult = 1.10
        }
    },
    ["Fearmonger"] = {
        slots = 2,
        cost = 50,
        requirements = { "True Strength" },
        effects = {
            apply_fear_on_kill = true
        }
    },
    ["Adrenaline Surge"] = {
        slots = 2,
        cost = 50,
        requirements = { "Never Back Down Never What?" },
        effects = {
            thresholds = {
                [0.60] = { crit_dmg = 0.05, dodge = 0.02, energy_gain = 0.03 },
                [0.40] = { crit_dmg = 0.10, dodge = 0.04, energy_gain = 0.06 },
                [0.20] = { crit_dmg = 0.15, dodge = 0.06, energy_gain = 0.10 }
            },
            overall_damage_taken_mult = 1.10
        }
    },
    ["Energy Cascade"] = {
        slots = 2,
        cost = 50,
        requirements = { "FEEL THE POWER!" },
        effects = {
            high_energy_threshold = 4,
            apply_overload_turns = 1
        }
    },
    ["Coming At You Live"] = {
        slots = 0,
        cost = 300,
        requirements = { "It Was Truly, An Average Campaign" },
        effects = {
            spout_one_liners = true
        }
    },
    ["Will of Thiacdemo"] = {
        slots = 0,
        cost = 500,
        requirements = { "Session 0" },
        effects = {
            unlock_jumpscare_all = true
        }
    }
}

return boons
