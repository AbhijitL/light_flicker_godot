# Based on Valve source code
# https://www.reddit.com/r/gaming/comments/nyxzme/valve_reuses_the_source_code_for_flickering/h1n8c8h/
# https://github.com/ValveSoftware/source-sdk-2013/blob/0d8dceea4310fde5706b3ce1c70609d72a38efdf/mp/src/game/server/world.cpp#L535-L565
# https://80.lv/articles/valve-reused-the-code-for-flickering-lights-in-alyx-22-years-later/
# a in light_energy = 0 where z is maximum.

extends OmniLight

# From source-sdk source code.
enum STYLES {
	NORMAL
	FLICKER
	SLOW_STRONG_PULSE
	CANDLE
	FAST_STROBE
	GENTLE_PULSE
	FLICKER_2
	CANDLE_2
	CANDLE_3
	SLOW_STROBE
	FLUORESCENT_FLICKER
	SLOW_PULSE_NOT_FADE_TO_BLACK
	UNDERWATER_LIGHT_MUTATION
	CUSTOM
};

const STYLE_STRINGS = [
	"m",
	"mmnmmommommnonmmonqnmmo",
	"abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba",
	"mmmmmaaaaammmmmaaaaaabcdefgabcdefg",
	"mamamamamama",
	"jklmnopqrstuvwxyzyxwvutsrqponmlkj",
	"nmonqnmomnmomomno",
	"mmmaaaabcdefgmmmmaaaammmaamm",
	"mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa",
	"aaaaaaaazzzzzzzz",
	"mmamammmmammamamaaamammma",
	"abcdefghijklmnopqrrqponmlkjihgfedcba",
	"mmnnmmnnnmmnn"
];


export(STYLES) var default_light_style = STYLES.FLICKER;

var flicker_string : String;
export var custom_flicker_string : String = "IFCUSTOM";
export var max_energy : float = 3;# max light_energy
export var step_time = 500;# In ms
export var is_loop : bool = false;
export var run_at_start : bool = true;

var _cache : Array;
var _current_step : int;

const STEP : float = 3.84615384615;
const ALPHABET : String = "abcdefghijklmnopqrstuvwxyz";

var choose : String;

func _ready():
	if max_energy == 0:
		max_energy = light_energy;
	enum_to_string(default_light_style);
	flicker_string = choose;
	conver_alphabets_to_light_energy_scale();
	if run_at_start:
		start_flicker();

func enum_to_string(num:int):
	if STYLES.size()-1 == num:
		choose = custom_flicker_string;
	else:
		choose = STYLE_STRINGS[num];

func flicker():
	while true:
		if visible:
			light_energy = _cache[_current_step];
			_current_step +=1;
			if _current_step == _cache.size():
				if is_loop != true:
					_current_step = 0;
				else:
					return;
		yield(get_tree().create_timer(step_time/1000), "timeout")
		emit_signal("completed");

func conver_alphabets_to_light_energy_scale():
	_cache = [];
	for i in flicker_string.to_lower():
		_cache.append(STEP*ALPHABET.find(i)*max_energy/100);
	

func start_flicker():
	yield(flicker(),"completed");
	
