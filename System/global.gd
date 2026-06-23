extends Node
#-------------------------------------
# Level variable
#-------------------------------------

var level=1
var current_level_id: int=2
var Goblin_house =0
var active_goblin_houses:int=0
var active_goblin_units:int=0

#-------------------------------------
# Resources
#-------------------------------------
var pawn_tool:String="hand"
var choosed_colour:String="black"
const SAVE_COLOR: String ="user://levels.save"

#variables
var gold:int=50
var wood:int=50
var meat:int=50

var max_gold:int=1000
var max_wood:int=1000
var max_meat:int=1000

#implementing levels paths
const LEVEL_SCENES:={
	1: "res://Levels/level.tscn",
	2: "res://Levels/level.tscn",
}

#-------------------------------------
# Global goblin wave system
#-------------------------------------
var wave_timer:float=0.0
var initial_wave_delay:float=30.0
var wave_interval:float=10.0  #Time between waves
var current_wave:int=0
var max_waves:int=5 #Max number of waves
var boss_spawned:bool=false

var wave_active:bool=false
var wave_started:bool=false
var wave_start:bool=false #music trigger

var active_spawners:int=0

signal wave_started_signal(wave_number:int)
signal wave_ended(wave_number:int)

#game over logic
var game_over:bool=false
signal resources_changed

#-------------------------------------
#Ready func
#-------------------------------------
func _ready() -> void:
	randomize()
	Global.Goblin_house=0
	load_colour()
	clamp_resources()
	#game_over=false

#-------------------------------------
# Save/Load Colour
#-------------------------------------
func save_colour():
	var file:FileAccess=FileAccess.open(SAVE_COLOR,FileAccess.WRITE)
	file.store_string(choosed_colour)
	file.close()
	pass
func load_colour():
	#var file:FileAccess=FileAccess.open(SAVE_COLOR,FileAccess.WRITE)
	#chossed_colour=file.get_as_text()
	#file.close()
	pass

#-------------------------------------
#Resources clamping - indica numarul maxim de capacitate obtinut din noduri de resurse
#-------------------------------------
func clamp_resources():
	gold=clamp(gold,0,max_gold)
	wood=clamp(wood,0,max_wood)
	meat=clamp(meat,0,max_meat)

func add_gold(amount:int):
	gold=min(gold+amount,max_gold)
	resources_changed.emit()
func add_wood(amount:int):
	wood=min(wood+amount,max_wood)
	resources_changed.emit()
func add_meat(amount:int):
	meat=min(meat+amount,max_meat)
	resources_changed.emit()

func consume_gold(amount:int):
	if gold<amount:
		return false
	gold-=amount
	resources_changed.emit()
	return true
func consume_wood(amount:int):
	if wood<amount:
		return false
	wood-=amount
	resources_changed.emit()
	return true
func consume_meat(amount:int):
	if meat<amount:
		return false
	meat-=amount
	resources_changed.emit()
	return true

func can_spawn()->bool:
	return meat>0

#-------------------------------------
#Process
#-------------------------------------
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if wave_active:
		return
	if current_wave>=max_waves:
		return
	wave_timer+=delta
	if wave_timer>=get_current_wave_delay():
		wave_timer=0.0
		start_wave()
#-------------------------------------
#wave control
#-------------------------------------
func start_wave():
	current_wave+=1
	wave_timer=0.0
	wave_active=true
	wave_started=true
	wave_start=true
	active_spawners=0
	
	emit_signal("wave_started_signal",current_wave)

func register_spawner():
	active_spawners+=1

func unregister_spawner():
	if active_spawners<=0:
		active_spawners=0
		return
	active_spawners-=1
	if active_spawners<=0:
		end_wave()

func end_wave():
	wave_active=false
	wave_started=false
	wave_start=false

	emit_signal("wave_ended",current_wave)

#-------------------------------------
#Reset Game
#-------------------------------------
func reset_game():
	wave_timer=0.0
	current_wave=0
	wave_active=false
	wave_started=false
	wave_start=false
	active_spawners=0
	boss_spawned=false
	active_goblin_houses=0
	active_goblin_units=0
	
	game_over=false

#-------------------------------------
#Game Saving System
#-------------------------------------
const SAVE_FILE:String="user://save_game.json"

func save_game():
	var save_data:={
		"level_id":current_level_id,
		"gold":gold,
		"meat":meat,
		"wood":wood
	}

	var file:=FileAccess.open(SAVE_FILE,FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_FILE):
		return
	var file:=FileAccess.open(SAVE_FILE,FileAccess.READ)
	if file==null:
		push_error("failed to open save file")
		return
	var text:String=file.get_as_text()
	file.close()
	
	var parsed:Variant=JSON.parse_string(text)
	if typeof(parsed)!=TYPE_DICTIONARY:
		push_error("save file is corrupted")
		return
	
	var data:Dictionary=parsed

#Load the saved vars
	current_level_id=int(data["level_id"])
	gold=int(data["gold"])
	meat=int(data["meat"])
	wood=int(data["wood"])

	clamp_resources()
	resources_changed.emit()
	if not LEVEL_SCENES.has(current_level_id):
		push_error("invalid level id in save :%s"%current_level_id)
		return
	get_tree().change_scene_to_file(LEVEL_SCENES[current_level_id])

func set_current_level(level_id:int):
	current_level_id=level_id

func init_level_state():
	wave_timer=0.0
	current_wave=0
	wave_active=false
	wave_started=false
	wave_start=false
	active_spawners=0
	boss_spawned=false

	Goblin_house=0
	active_goblin_houses=0
	active_goblin_units=0
	game_over=false
	resources_changed.emit()

func get_current_wave_delay() -> float:
	if current_wave<=0:
		return initial_wave_delay
	return wave_interval

func get_wave_countdown() -> float:
	return max(0.0,get_current_wave_delay()-wave_timer)

func try_spawn_final_boss() -> bool:
	if boss_spawned:
		return false
	if current_wave<max_waves:
		return false
	boss_spawned=true
	return true

func register_goblin_house() -> bool:
	if active_goblin_houses>=3:
		return false
	active_goblin_houses+=1
	return true

func unregister_goblin_house() -> void:
	if active_goblin_houses<=0:
		active_goblin_houses=0
		return
	active_goblin_houses-=1

func register_goblin_unit() -> bool:
	if active_goblin_units>=12:
		return false
	active_goblin_units+=1
	return true

func unregister_goblin_unit() -> void:
	if active_goblin_units<=0:
		active_goblin_units=0
		return
	active_goblin_units-=1
