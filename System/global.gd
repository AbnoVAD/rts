extends Node
#-------------------------------------
# Level variable
#-------------------------------------

var level=1
var current_level_id: int=2
var Goblin_house =0
var active_goblin_houses:int=0
var active_goblin_units:int=0
var active_goblin_bosses:int=0

#-------------------------------------
# Resources
#-------------------------------------
var pawn_tool:String="hand"
var choosed_colour:String="black"
const SAVE_COLOR: String ="user://levels.save"
const SETTINGS_FILE: String = "user://settings.cfg"

#variables
var gold:int=50
var wood:int=50
var meat:int=50

var master_volume:float=100.0
var music_volume:float=100.0
var sfx_volume:float=100.0
var fullscreen_enabled:bool=false
var vsync_enabled:bool=true

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

var pending_save_data:Dictionary={}
var has_pending_save_data:bool=false
var loaded_save_entities:Array=[]
var restoring_save_game:bool=false

const SAVEABLE_ENTITY_GROUP:StringName = &"saveable_entity"

#-------------------------------------
#Ready func
#-------------------------------------
func _ready() -> void:
	randomize()
	Global.Goblin_house=0
	load_colour()
	load_settings()
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

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_FILE) == OK:
		master_volume = float(config.get_value("audio", "master_volume", master_volume))
		music_volume = float(config.get_value("audio", "music_volume", music_volume))
		sfx_volume = float(config.get_value("audio", "sfx_volume", sfx_volume))
		fullscreen_enabled = bool(config.get_value("video", "fullscreen", fullscreen_enabled))
		vsync_enabled = bool(config.get_value("video", "vsync", vsync_enabled))
	apply_settings()

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("video", "fullscreen", fullscreen_enabled)
	config.set_value("video", "vsync", vsync_enabled)
	config.save(SETTINGS_FILE)

func _slider_to_db(value: float) -> float:
	return lerp(-30.0, 0.0, clamp(value, 0.0, 100.0) / 100.0)

func _is_music_player_name(name: String) -> bool:
	var lowered := name.to_lower()
	return lowered.find("music") != -1 or lowered.find("theme") != -1 or lowered.find("waves") != -1

func _apply_audio_recursive(node: Node) -> void:
	for child in node.get_children():
		if child is AudioStreamPlayer:
			var player := child as AudioStreamPlayer
			if not player.has_meta("base_volume_db"):
				player.set_meta("base_volume_db", player.volume_db)
			var base_volume_db := float(player.get_meta("base_volume_db", player.volume_db))
			var gain_db := _slider_to_db(music_volume if _is_music_player_name(player.name) else sfx_volume)
			player.volume_db = base_volume_db + gain_db
		_apply_audio_recursive(child)

func apply_settings(scene_root:Node = null) -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	if master_bus >= 0:
		AudioServer.set_bus_volume_db(master_bus, _slider_to_db(master_volume))

	if scene_root == null:
		scene_root = get_tree().current_scene
	if scene_root != null:
		_apply_audio_recursive(scene_root)

	if fullscreen_enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	var vsync_mode := DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(vsync_mode)

func set_master_volume(value: float) -> void:
	master_volume = clamp(value, 0.0, 100.0)
	save_settings()
	apply_settings()

func set_music_volume(value: float) -> void:
	music_volume = clamp(value, 0.0, 100.0)
	save_settings()
	apply_settings()

func set_sfx_volume(value: float) -> void:
	sfx_volume = clamp(value, 0.0, 100.0)
	save_settings()
	apply_settings()

func set_fullscreen(enabled: bool) -> void:
	fullscreen_enabled = enabled
	save_settings()
	apply_settings()

func set_vsync(enabled: bool) -> void:
	vsync_enabled = enabled
	save_settings()
	apply_settings()

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
	active_goblin_bosses=0
	
	game_over=false
	has_pending_save_data=false
	pending_save_data.clear()
	loaded_save_entities.clear()
	restoring_save_game=false

#-------------------------------------
#Game Saving System
#-------------------------------------
const SAVE_FILE:String="user://save_game.json"

func save_game():
	var entities:Array=[]
	var saveable_nodes:=get_tree().get_nodes_in_group(SAVEABLE_ENTITY_GROUP)
	for node in saveable_nodes:
		if not is_instance_valid(node):
			continue
		if not (node is Node2D):
			continue
		if node.scene_file_path.is_empty():
			continue
		var parent:=node.get_parent()
		if parent==null:
			continue
		var entry:=_serialize_saveable_entity(node as Node2D)
		if entry.is_empty():
			continue
		entities.append(entry)

	var save_data:={
		"level_id":current_level_id,
		"gold":gold,
		"meat":meat,
		"wood":wood,
		"current_wave":current_wave,
		"wave_timer":wave_timer,
		"initial_wave_delay":initial_wave_delay,
		"wave_interval":wave_interval,
		"max_waves":max_waves,
		"wave_active":wave_active,
		"wave_started":wave_started,
		"wave_start":wave_start,
		"active_spawners":active_spawners,
		"active_goblin_houses":active_goblin_houses,
		"active_goblin_units":active_goblin_units,
		"active_goblin_bosses":active_goblin_bosses,
		"boss_spawned":boss_spawned,
		"entities":entities
	}

	var file:=FileAccess.open(SAVE_FILE,FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()
	return true

func load_game():
	if not FileAccess.file_exists(SAVE_FILE):
		return false
	var file:=FileAccess.open(SAVE_FILE,FileAccess.READ)
	if file==null:
		push_error("failed to open save file")
		return false
	var text:String=file.get_as_text()
	file.close()
	
	var parsed:Variant=JSON.parse_string(text)
	if typeof(parsed)!=TYPE_DICTIONARY:
		push_error("save file is corrupted")
		return false
	
	pending_save_data=parsed
	has_pending_save_data=true
	restoring_save_game=true

	var data_level_id:int=int(pending_save_data.get("level_id",current_level_id))
	if not LEVEL_SCENES.has(data_level_id):
		push_error("invalid level id in save :%s"%data_level_id)
		has_pending_save_data=false
		pending_save_data.clear()
		restoring_save_game=false
		return false
	current_level_id=data_level_id
	get_tree().call_deferred("change_scene_to_file",LEVEL_SCENES[current_level_id])
	return true

func has_saved_game() -> bool:
	return FileAccess.file_exists(SAVE_FILE)

func apply_loaded_game_state() -> bool:
	if not has_pending_save_data:
		return false
	_apply_save_data(pending_save_data)
	has_pending_save_data=false
	loaded_save_entities = pending_save_data.get("entities", []).duplicate(true)
	pending_save_data.clear()
	return true

func restore_loaded_entities(scene_root:Node) -> void:
	if scene_root == null:
		return
	if loaded_save_entities.is_empty():
		restoring_save_game=false
		return

	var loaded_by_id:Dictionary={}
	var remaining:Array = loaded_save_entities.duplicate(true)
	var guard:int = max(remaining.size() * 8, 32)

	while not remaining.is_empty() and guard > 0:
		guard -= 1
		var progressed := false
		for i in range(remaining.size() - 1, -1, -1):
			var data:Dictionary = remaining[i]
			var parent := _resolve_saved_parent(scene_root, data, loaded_by_id)
			if parent == null:
				continue
			var node := _instantiate_saved_entity(scene_root, data, parent)
			if node == null:
				continue
			var save_id := String(data.get("save_id", ""))
			if save_id != "":
				loaded_by_id[save_id] = node
			remaining.remove_at(i)
			progressed = true
		if not progressed:
			break

	await get_tree().process_frame

	for node in scene_root.get_tree().get_nodes_in_group(SAVEABLE_ENTITY_GROUP):
		if is_instance_valid(node) and node.has_method("post_restore_saveable"):
			node.call("post_restore_saveable")

	loaded_save_entities.clear()
	restoring_save_game=false

func _apply_save_data(data:Dictionary) -> void:
	current_level_id=int(data.get("level_id",current_level_id))
	gold=int(data.get("gold",gold))
	meat=int(data.get("meat",meat))
	wood=int(data.get("wood",wood))
	current_wave=int(data.get("current_wave",current_wave))
	wave_timer=float(data.get("wave_timer",wave_timer))
	initial_wave_delay=float(data.get("initial_wave_delay",initial_wave_delay))
	wave_interval=float(data.get("wave_interval",wave_interval))
	max_waves=int(data.get("max_waves",max_waves))
	wave_active=bool(data.get("wave_active",wave_active))
	wave_started=bool(data.get("wave_started",wave_started))
	wave_start=bool(data.get("wave_start",wave_start))
	active_spawners=int(data.get("active_spawners",active_spawners))
	active_goblin_houses=int(data.get("active_goblin_houses",active_goblin_houses))
	active_goblin_units=int(data.get("active_goblin_units",active_goblin_units))
	active_goblin_bosses=int(data.get("active_goblin_bosses",active_goblin_bosses))
	boss_spawned=bool(data.get("boss_spawned",boss_spawned))

	clamp_resources()
	game_over=false
	resources_changed.emit()

func _ensure_save_id(node:Node) -> String:
	if node == null:
		return ""
	var save_id := String(node.get_meta("save_id", ""))
	if save_id == "":
		save_id = str(Time.get_ticks_usec()) + "_" + str(randi())
		node.set_meta("save_id", save_id)
	return save_id

func _serialize_saveable_entity(node:Node2D) -> Dictionary:
	if node == null or not is_instance_valid(node):
		return {}

	var parent := node.get_parent()
	if parent == null:
		return {}

	var entry:Dictionary = {
		"save_id": _ensure_save_id(node),
		"save_source_id": String(node.get_meta("save_source_id", "")),
		"save_source_path": String(node.get_meta("save_source_path", "")),
		"scene_path": node.scene_file_path,
		"name": node.name,
		"parent_save_id": "",
		"parent_path": ".",
		"local_position": [node.position.x, node.position.y],
		"global_position": [node.global_position.x, node.global_position.y],
		"rotation": node.rotation,
		"scale": [node.scale.x, node.scale.y],
		"z_index": node.z_index,
		"visible": node.visible,
		"groups": [],
		"extra": {}
	}

	if parent.is_in_group(SAVEABLE_ENTITY_GROUP):
		entry["parent_save_id"] = _ensure_save_id(parent)
	else:
		entry["parent_path"] = _relative_scene_path(parent)

	var extra:Variant = {}
	if node.has_method("get_save_data"):
		extra = node.call("get_save_data")
	if typeof(extra) == TYPE_DICTIONARY:
		entry["extra"] = extra

	return entry

func _relative_scene_path(node:Node) -> String:
	if node == null:
		return "."
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return String(node.get_path())
	if node == current_scene:
		return "."
	var node_path := String(node.get_path())
	var root_path := String(current_scene.get_path())
	if node_path.begins_with(root_path + "/"):
		return node_path.trim_prefix(root_path + "/")
	return node_path

func _resolve_saved_parent(scene_root:Node, data:Dictionary, loaded_by_id:Dictionary) -> Node:
	var parent_save_id := String(data.get("parent_save_id", ""))
	if parent_save_id != "" and loaded_by_id.has(parent_save_id):
		return loaded_by_id[parent_save_id] as Node

	var parent_path := String(data.get("parent_path", "."))
	if parent_path == "." or parent_path.is_empty():
		return scene_root
	if scene_root.has_node(parent_path):
		return scene_root.get_node(parent_path)
	return null

func _instantiate_saved_entity(scene_root:Node, data:Dictionary, parent:Node) -> Node2D:
	var scene_path := String(data.get("scene_path", ""))
	if scene_path == "":
		return null
	var packed := load(scene_path)
	if not (packed is PackedScene):
		return null
	var node := (packed as PackedScene).instantiate()
	if not (node is Node2D):
		node.queue_free()
		return null

	var entity := node as Node2D
	parent.add_child(entity)
	if data.has("name"):
		entity.name = String(data.get("name", entity.name))
	var pos: Array = data.get("global_position", [])
	var local_pos: Array = data.get("local_position", [])
	if local_pos is Array and local_pos.size() >= 2:
		entity.position = Vector2(float(local_pos[0]), float(local_pos[1]))
	elif parent is Node2D and pos is Array and pos.size() >= 2:
		entity.position = (parent as Node2D).to_local(Vector2(float(pos[0]), float(pos[1])))
	elif pos is Array and pos.size() >= 2:
		entity.global_position = Vector2(float(pos[0]), float(pos[1]))
	if data.has("rotation"):
		entity.rotation = float(data.get("rotation", entity.rotation))
	var scl: Array = data.get("scale", [])
	if scl is Array and scl.size() >= 2:
		entity.scale = Vector2(float(scl[0]), float(scl[1]))
	if data.has("z_index"):
		entity.z_index = int(data.get("z_index", entity.z_index))
	if data.has("visible"):
		entity.visible = bool(data.get("visible", entity.visible))
	var save_id := String(data.get("save_id", ""))
	if save_id != "":
		entity.set_meta("save_id", save_id)
	entity.add_to_group(SAVEABLE_ENTITY_GROUP)
	var source_id := String(data.get("save_source_id", ""))
	if source_id != "":
		entity.set_meta("save_source_id", source_id)
	var source_path := String(data.get("save_source_path", ""))
	if source_path != "":
		entity.set_meta("save_source_path", source_path)
	var extra: Dictionary = data.get("extra", {}) as Dictionary
	if typeof(extra) == TYPE_DICTIONARY and entity.has_method("apply_save_data"):
		entity.call("apply_save_data", extra)
	return entity

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
	active_goblin_bosses=0
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

func register_goblin_house(_ignore_limit:bool=false) -> bool:
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

func register_goblin_boss() -> void:
	active_goblin_bosses+=1

func unregister_goblin_boss() -> void:
	if active_goblin_bosses<=0:
		active_goblin_bosses=0
		return
	active_goblin_bosses-=1

func has_remaining_enemy_forces() -> bool:
	return active_goblin_houses>0 or active_goblin_units>0 or active_goblin_bosses>0 or active_spawners>0
