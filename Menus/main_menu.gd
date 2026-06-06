extends Node2D

@onready var music: AudioStreamPlayer = $"sound fx/music"
@onready var click: AudioStreamPlayer = $"sound fx/click"
@onready var camera: Camera2D = $Camera2D
@onready var ui_root: Control = $UI/Root

var level = preload("res://Levels/level.tscn")
const BASE_UI_SIZE := Vector2(1920, 1080)

func _ready() -> void:
	music.play()
	camera.make_current()
	_fit_ui_to_viewport()
	var viewport := get_viewport()
	if not viewport.size_changed.is_connected(_fit_ui_to_viewport):
		viewport.size_changed.connect(_fit_ui_to_viewport)

func _exit_tree() -> void:
	var viewport := get_viewport()
	if viewport.size_changed.is_connected(_fit_ui_to_viewport):
		viewport.size_changed.disconnect(_fit_ui_to_viewport)
	music.stop()

func _on_start_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_packed(level)

func _on_quit_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()

func _fit_ui_to_viewport() -> void:
	var viewport_size := get_viewport_rect().size
	var scale_factor := min(viewport_size.x / BASE_UI_SIZE.x, viewport_size.y / BASE_UI_SIZE.y)
	var scaled_size := BASE_UI_SIZE * scale_factor
	ui_root.scale = Vector2.ONE * scale_factor
	ui_root.position = (viewport_size - scaled_size) * 0.5
