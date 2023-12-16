extends Node

var base_cfg = {
	"num_players": 4,
	"map_size": Vector2(9,7),
	
	"solo_player_point_multiplier": 1.275,
	
	"special_cells": ["rotator", "shooter"],
	"special_items": [],
	
	"cells_rotate_with_player": true,
	
	"allow_cell_sharing_for_players": false,
	"beds_need_correct_rotation": true,
	"players_can_stand_on_beds": false,
	"line_up_trampolines_with_beds": false,
	"auto_rotate_bears": false,
	"disable_rotation_input": false,
	
	"teleport_needs_timer": false,
	"can_rewind_timers": true,
	
	"big_bear_requires_player_hug": true,
	
	"only_place_row_shifters": false,
	
	"solo_split_field": "none",
	
	"moving": {
		"use_max_steps": true,
		"rotation_counts_as_step": true,
		"forbid_diagonal_if_backpack": true,
		"items_shoot_from_hands": false,
		"bears_wrap_field": true,
	},
	
	"bear_spawning": {
		"interval": 10,
		"randomness": 0.5,
		"min": 4,
		"max": 6,
		"use_beds": true,
		"keep_to_same_area": false,
		"use_point_gui": false,
	},
	
	"item_spawning": {
		"interval": 10,
		"randomness": 0.5,
		"min": 2,
		"max": 8
	},
	
	"objective": {
		"duration": 5*60,
		"bear_point_value_multiplier": 4.0,
	},
	
	"shifting": {
		"prevent_when_others_present": false,
		"keep_dividers_fixed": true
	}
}

var cfg = {}

var items = {
	"player": {
		
	},
	
	"tinybear": {
		"num_steps": 4,
		"frame": 0,
		"rotation_matters": true,
		"interact_cells": ["bear", "bamboo", "bed", "hole", "conveyorbelt"],
		"destroy_on_wrap": true,
		"points": {
			"delivery": 10,
			"removal": -6
		}
	},
	
	"tinycactus": {
		"num_steps": 5,
		"frame": 1,
		"rotation_matters": true,
		"interact_cells": ["hole", "conveyorbelt"],
		"points": {
			"delivery": 0,
			"removal": 5,
			"player_backpack": -1
		}
	},
	
	"tinypillow": {
		"num_steps": 5,
		"frame": 2,
		"stops_flying_objects": true,
		"interact_cells": ["conveyorbelt"],
		"needs_max_steps": true,
		"points": {
			"delivery": 0,
			"removal": -1, 
			"player_backpack": 1
		}
	},
	
	"tinyheart": {
		"needs_max_steps": true,
		"frame": 3,
		"interact_cells": ["bear", "conveyorbelt"],
		"num_steps": 4,
		"points": {
			"delivery": 0,
			"removal": -4,
			"cell_addition": 1
		}
	},
	
	"tinygift": {
		"needs_max_steps": true,
		"frame": 4,
		"destroy_on_wrap": true,
		"interact_cells": ["conveyorbelt"],
		"num_steps": 6,
		"points": {
			"delivery": 0,
			"removal": -8,
			"all_players_touched": 13
		}
	}
}

var cells = {
	"": {
		"frame": 0,
		"num_per_player": 0.0
	},
	
	"trampoline": {
		"frame": 1,
		"needs_time_counter": true,
		"can_be_rewound": true,
		"timing": {
			"interval": 3,
			"steps": 4
		},
		"fixed_num": 6,
		"auto_drop": true,
		"gui_also_shows_rotation": true,
	},
	
	"bear": {
		"frame": 2,
		#"forbidden_objects": ["player"],
		"rotation_matters": true,
		"disallow_entry_with_content": true,
		"allowed_content": ["tinyheart"],
		"num_per_player": 0.0
	},
	
	"score": {
		"frame": 3,
		"num_per_player": 0.0
	},
	
	"shifter": {
		"frame": 4,
		"forbid_visual_rotation": true,
		"fixed_num": 6,
	},
	
	"divider": {
		"frame": 5,
		"forbidden_objects": ["player"],
		"num_per_player": 0.0,
		"can_never_hold_anything": true
	},
	
	"bamboo": {
		"frame": 6,
		"content_offset": Vector2(-110,0),
		"rotation_always_correct": true,
		"fixed_num": 8
	},
	
	"bed": {
		"frame": 7,
		"content_offset": Vector2(-100, 0),
		"rotation_always_correct": true,
		"num_per_player": 0.0
	},
	
	"rotator": {
		"frame": 8,
		"fixed_num": 6,
	},
	
	"shooter": {
		"frame": 9,
		"fixed_num": 6,
		"auto_drop": true,
	},
	
	"hole": {
		"frame": 10,
		"fixed_num": 2,
		"rotation_always_correct": true
	},
	
	"stepchanger": {
		"frame": 11,
		"fixed_num": 3,
		"forbid_visual_rotation": true,
		"four_directional_cell": true
	},
	
	"campaign": {
		"frame": 12,
		"num_per_player": 0.0,
		"forbid_visual_rotation": true
	},
	
	"bedmover": {
		"frame": 13,
		"num_per_player": 0.5,
		"forbid_visual_rotation": true
	},
	
	"teleport": {
		"frame": 14,
		"num_per_player": 1.0,
		"needs_label": true,
		"auto_drop": true,
		"can_be_rewound": true,
		"timing": {
			"interval": 2,
			"steps": 4
		},
	},
	
	"alarm": {
		"frame": 15,
		"fixed_num": 2.0,
		"needs_time_counter": true,
		"forbid_visual_rotation": true,
		"can_be_rewound": true,
		"timing": {
			"interval": 2,
			"steps": 4
		}
	},
	
	"autoshifter": {
		"frame": 16,
		"fixed_num": 4,
	},
	
	"store": {
		"frame": 17,
		"fixed_num": 4,
		"forbid_visual_rotation": true,
		"four_directional_cell": true
	},
	
	"giftwrapper": {
		"frame": 18,
		"num_per_player": 0.5,
		"forbid_visual_rotation": true
	},
	
	"conveyorbelt": {
		"frame": 19,
		"fixed_num": 10,
		"auto_drop": true,
		"needs_time_counter": true,
		"rotation_always_correct": true,
		"timing": {
			"interval": 0.4,
			"steps": 3,
		},
		"gui_also_shows_rotation": true,
	},
	
	"decoration_grass": {
		"frame": 20,
		"num_per_player": -1,
	},
	
	"decoration_water": {
		"frame": 21,
		"num_per_player": -1
	},
	
	"decoration_forest": {
		"frame": 22,
		"num_per_player": -1
	}
}
