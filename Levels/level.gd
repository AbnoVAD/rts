extends Node2D

#-------------------------------
#LEVEL : 1
#-------------------------------
const LEVEL_ID:=1
const TITLE_FONT := preload("res://assets/Text Font/ringbearer/RINGM___.TTF")
const MAIN_MENU_SCENE_PATH := "res://Menus/Main menu.tscn"

var level_completed:bool=false
@onready var timer_label: Label = $"UI/ui/Panel/Timer Label"
@onready var ui_panel: Control = $"UI/ui/Panel"
@onready var winter_tilemap: TileMapLayer = $Tiles/wintertile

var objective_label: Label
@onready var victory_panel: Panel = $"UI/ui/Panel/Victory"
@onready var victory_title_label: Label = $"UI/ui/Panel/Victory/Victory_/VictoryUI/Center/Victory Card/ContentMargin/Content/Title"
@onready var victory_subtitle_label: Label = $"UI/ui/Panel/Victory/Victory_/VictoryUI/Center/Victory Card/ContentMargin/Content/Subtitle"
@onready var victory_replay_button: Button = $"UI/ui/Panel/Victory/Victory_/VictoryUI/Center/Victory Card/ContentMargin/Content/ReplayButton"
@onready var victory_menu_button: Button = $"UI/ui/Panel/Victory/Victory_/VictoryUI/Center/Victory Card/ContentMargin/Content/MenuButton"
@onready var victory_hint_label: Label = $"UI/ui/Panel/Victory/Victory_/VictoryUI/Center/Victory Card/ContentMargin/Content/Hint"

#-------------------------------
#Music system
#-------------------------------
@onready var music: AudioStreamPlayer = $"Music and Fx/music"
@onready var click: AudioStreamPlayer = $"Music and Fx/click"


const TORCH_HOUSE_SCENE: PackedScene = preload("res://Unit goblin buildings/Torch/goblin_house_torch.tscn")
const BARREL_HOUSE_SCENE: PackedScene = preload("res://Unit goblin buildings/Barrel/goblin_house_barrel.tscn")
const TNT_HOUSE_SCENE: PackedScene = preload("res://Unit goblin buildings/Tnt/goblin_house_tnt.tscn")
const UNDEAD_HOUSE_SCENE: PackedScene = preload("res://Unit goblin buildings/Boss/undead_house.tscn")

const MAX_HOUSES_PER_WAVE: int = 2
const MAX_NAV_DISTANCE_FROM_TILE: float = 5.0

#-------------------------------
#Game over system
#-------------------------------
@onready var game_ovr: Panel = $"UI/ui/Panel/Game Over"
@onready var retry: Label = $"UI/ui/Panel/Game Over/Retry"
@onready var next_level: Button = $"UI/ui/Panel/Player/Unit resources/Next level"
@onready var info_label: Label = $"UI/ui/Panel/Info label"

var game_over_handled: bool = false
var victory_handled: bool = false

func _ready() -> void:
	_setup_hud_polish()
	Global.apply_settings(self)
	Global.wave_started_signal.connect(_on_wave_started)
	Global.wave_ended.connect(_on_wave_ended)
	next_level.hide()
	if not Global.apply_loaded_game_state():
		Global.init_level_state()
	Global.set_current_level(LEVEL_ID)
	Global.Goblin_house=0
	game_over_handled = false
	victory_handled = false
	get_tree().paused=false
	Global.game_over=false
	if victory_panel:
		victory_panel.hide()
	Global.restore_loaded_entities(self)
	music.play()

func _on_wave_started(wave_number:int) -> void:
	_spawn_enemy_houses_for_wave(wave_number)

var last_wave_state:=false
func _process(_delta: float) -> void:
	if Global.wave_active!=last_wave_state:
		last_wave_state=Global.wave_active


	if level_completed:
		_update_objective_text()
		return
	if _should_trigger_victory():
		complete_level()
		return
	if Global.current_wave>=Global.max_waves:
		info_label.text=""
		timer_label.text="All waves completed"
		_update_objective_text()
		return

#Timer UI
	var remaining:float=Global.get_wave_countdown()
	var minutes:int=int(remaining/60)
	var seconds:int=int(remaining)%60
	timer_label.text="%02d:%02d"%[minutes,seconds]
	_update_objective_text()

#Game over
	if Global.game_over and not game_over_handled:
		game_over_handled = true
		await get_tree().create_timer(0.5).timeout
		game_ovr.show()
		get_tree().paused=true
		Global.save_game()

#-------------------------------
#Buttons and signals
#-------------------------------
func _on_info_button_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.5).timeout
	pass
var vol:bool=false
func _on_mute_button_pressed() -> void:
	click.play()
	vol=!vol
	if vol==true:
		music.volume_db=-80
	else:
		music.volume_db=-5

func _on_quit_button_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)

func _on_setting_button_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)

#retry after game over
func _on_retry_btn_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().paused=false
	Global.reset_game()
	get_tree().reload_current_scene()

func complete_level():
	if level_completed:
		return
	level_completed=true
	victory_handled=true
	Global.save_game()
	timer_label.text="Victory"
	info_label.text="The last enemy has fallen. Your kingdom stands victorious."
	if victory_panel:
		victory_panel.show()
	get_tree().paused=true

func go_to_next_level():
	Global.save_game()
	pass
	#get_tree().change_scene_to_file() #lvl2 path in the brackets

func _on_next_level_pressed() -> void:
	Global.save_game()
	click.play()
	await get_tree().create_timer(0.5).timeout
	go_to_next_level()

func _on_wave_ended(wave_number:int):
	if wave_number==Global.max_waves:
		timer_label.text="All waves completed"

func _spawn_enemy_houses_for_wave(wave_number:int) -> void:
	if winter_tilemap == null:
		return

	if wave_number>=Global.max_waves:
		_spawn_house_on_winter_tile(UNDEAD_HOUSE_SCENE)
		return

	var house_pool:Array[PackedScene]=_get_goblin_house_pool(wave_number)
	if house_pool.is_empty():
		return

	var active_house_slots:int=MAX_HOUSES_PER_WAVE-Global.active_goblin_houses
	if active_house_slots<=0:
		return

	var available_cells:Array[Vector2i]=winter_tilemap.get_used_cells().duplicate()
	if available_cells.is_empty():
		return
	var valid_cells:Array[Vector2i]=[]
	for cell in available_cells:
		if _is_valid_goblin_house_spawn_cell(cell):
			valid_cells.append(cell)
	available_cells=valid_cells
	if available_cells.is_empty():
		return

	var desired_house_count:int=clamp(1+int(floor(float(wave_number - 1) / 4.0)),1,MAX_HOUSES_PER_WAVE)
	var house_count:int=min(desired_house_count,active_house_slots)
	for i in range(house_count):
		if available_cells.is_empty():
			break
		var house_scene:PackedScene=house_pool[randi()%house_pool.size()]
		_spawn_house_on_winter_tile(house_scene,available_cells)
		await get_tree().create_timer(0.4).timeout

func _get_goblin_house_pool(wave_number:int) -> Array[PackedScene]:
	match wave_number:
		1:
			return [TORCH_HOUSE_SCENE, BARREL_HOUSE_SCENE]
		2:
			return [TORCH_HOUSE_SCENE, BARREL_HOUSE_SCENE, TNT_HOUSE_SCENE]
		_:
			return [TORCH_HOUSE_SCENE, BARREL_HOUSE_SCENE, TNT_HOUSE_SCENE]

func _spawn_house_on_winter_tile(house_scene:PackedScene, available_cells:Array[Vector2i]=[]) -> void:
	if house_scene==null or winter_tilemap==null:
		return

	var cells:Array[Vector2i]=available_cells.duplicate() if not available_cells.is_empty() else winter_tilemap.get_used_cells()
	if cells.is_empty():
		return

	cells.shuffle()
	for spawn_cell in cells:
		if not _is_valid_goblin_house_spawn_cell(spawn_cell):
			if not available_cells.is_empty():
				available_cells.erase(spawn_cell)
			continue

		var spawn_position:=_winter_cell_to_world(spawn_cell)
		var nav_position: Variant = _get_snapped_goblin_spawn_position(spawn_position)
		if nav_position == null:
			if not available_cells.is_empty():
				available_cells.erase(spawn_cell)
			continue

		if not available_cells.is_empty():
			available_cells.erase(spawn_cell)

		var house:=house_scene.instantiate() as Node2D
		house.global_position=nav_position
		add_child(house)
		return

func _winter_cell_to_world(cell:Vector2i) -> Vector2:
	var local_pos:Vector2=winter_tilemap.map_to_local(cell)
	return winter_tilemap.to_global(local_pos)

func _get_snapped_goblin_spawn_position(world_position:Vector2) -> Variant:
	var world:=get_world_2d()
	if world==null:
		return world_position

	var nav_map:RID=world.navigation_map
	if not nav_map.is_valid():
		return world_position

	var closest_point:=NavigationServer2D.map_get_closest_point(nav_map,world_position)
	if world_position.distance_to(closest_point)>MAX_NAV_DISTANCE_FROM_TILE:
		return null
	return closest_point

func _is_valid_goblin_house_spawn_cell(cell:Vector2i) -> bool:
	if winter_tilemap==null:
		return false
	var world_position:=_winter_cell_to_world(cell)
	return _get_snapped_goblin_spawn_position(world_position) != null

func _setup_hud_polish() -> void:
	if ui_panel.has_node("TopStatusBar"):
		objective_label = ui_panel.get_node("TopStatusBar/ObjectiveLabel") as Label
	else:
		var top_bar := Panel.new()
		top_bar.name = "TopStatusBar"
		top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
		top_bar.offset_top = 0.0
		top_bar.offset_bottom = 76.0
		top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		top_bar.z_index = -10

		var bar_style := StyleBoxFlat.new()
		bar_style.bg_color = Color(0.06, 0.05, 0.04, 0.8)
		bar_style.border_color = Color(0.84, 0.68, 0.38, 0.25)
		bar_style.border_width_bottom = 2
		bar_style.corner_radius_top_left = 8
		bar_style.corner_radius_top_right = 8
		bar_style.corner_radius_bottom_left = 8
		bar_style.corner_radius_bottom_right = 8
		top_bar.add_theme_stylebox_override("panel", bar_style)
		ui_panel.add_child(top_bar)

		var objective := Label.new()
		objective_label = objective
		objective.name = "ObjectiveLabel"
		objective.text = "Prepare the kingdom"
		objective.add_theme_font_override("font", TITLE_FONT)
		objective.add_theme_font_size_override("font_size", 18)
		objective.add_theme_color_override("font_color", Color(0.98, 0.93, 0.82, 1.0))
		objective.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		objective.add_theme_constant_override("outline_size", 4)
		objective.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		objective.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		objective.set_anchors_preset(Control.PRESET_TOP_WIDE)
		objective.offset_top = 12.0
		objective.offset_bottom = 42.0
		objective.mouse_filter = Control.MOUSE_FILTER_IGNORE
		objective.z_index = -5
		top_bar.add_child(objective)

		var hint := Label.new()
		hint.name = "ControlHintLabel"
		hint.text = "P: Pause   R: Resume"
		hint.add_theme_font_override("font", TITLE_FONT)
		hint.add_theme_font_size_override("font_size", 14)
		hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.72))
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hint.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		hint.offset_left = -260.0
		hint.offset_top = 12.0
		hint.offset_right = -16.0
		hint.offset_bottom = 34.0
		hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hint.z_index = -5
		top_bar.add_child(hint)

	timer_label.add_theme_font_override("font", TITLE_FONT)
	timer_label.add_theme_font_size_override("font_size", 24)
	timer_label.add_theme_color_override("font_color", Color(0.98, 0.95, 0.86, 1.0))
	timer_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	timer_label.add_theme_constant_override("outline_size", 4)
	timer_label.z_index = 5

func _update_objective_text() -> void:
	if objective_label == null:
		return

	if level_completed:
		objective_label.text = "Task complete. Hold the line or return to the menu."
	elif Global.current_wave >= Global.max_waves:
		objective_label.text = "Final objective: destroy every goblin unit and building."
	elif Global.wave_active:
		objective_label.text = "Wave %d is under way. Protect your kingdom." % Global.current_wave
	else:
		objective_label.text = "Prepare defenses for wave %d." % (Global.current_wave + 1)

func _should_trigger_victory() -> bool:
	if victory_handled:
		return false
	if Global.current_wave < Global.max_waves:
		return false
	return not Global.has_remaining_enemy_forces()

func _on_victory_replay_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().paused = false
	Global.reset_game()
	get_tree().reload_current_scene()

func _on_victory_menu_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().paused = false
	Global.save_game()
	Global.reset_game()
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
