extends Node2D

@onready var music: AudioStreamPlayer = $"sound fx/music"
@onready var click: AudioStreamPlayer = $"sound fx/click"
@onready var camera: Camera2D = $Camera2D
@onready var ui_root: Control = $UI/Root

const LEVEL_SCENE := preload("res://Levels/level.tscn")
const BASE_UI_SIZE := Vector2(1920, 1080)
const MENU_CAMERA_POSITION := Vector2(1144, 320)
const MENU_CAMERA_ZOOM := Vector2.ONE
const TITLE_FONT := preload("res://assets/Text Font/ringbearer/RINGM___.TTF")

func _ready() -> void:
	music.play()
	camera.enabled = true
	camera.position = MENU_CAMERA_POSITION
	camera.zoom = MENU_CAMERA_ZOOM
	camera.make_current()
	_setup_menu_polish()
	_fit_ui_to_viewport()
	get_viewport().size_changed.connect(_fit_ui_to_viewport)

func _exit_tree() -> void:
	var viewport := get_viewport()
	if viewport and viewport.size_changed.is_connected(_fit_ui_to_viewport):
		viewport.size_changed.disconnect(_fit_ui_to_viewport)
	music.stop()

func _on_start_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_packed(LEVEL_SCENE)

func _on_quit_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()

func _fit_ui_to_viewport() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var scale_factor: float = min(viewport_size.x / BASE_UI_SIZE.x, viewport_size.y / BASE_UI_SIZE.y)
	var scaled_size: Vector2 = BASE_UI_SIZE * scale_factor
	ui_root.set_anchors_preset(Control.PRESET_TOP_LEFT)
	ui_root.size = BASE_UI_SIZE
	ui_root.scale = Vector2.ONE * scale_factor
	ui_root.position = (viewport_size - scaled_size) * 0.5

func _setup_menu_polish() -> void:
	if ui_root.has_node("BackdropShade"):
		return

	var backdrop := ColorRect.new()
	backdrop.name = "BackdropShade"
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.color = Color(0.03, 0.02, 0.01, 0.22)
	backdrop.z_index = -20
	ui_root.add_child(backdrop)

	var title := Label.new()
	title.name = "GameTitle"
	title.text = "DIZERTATIE RTS"
	title.add_theme_font_override("font", TITLE_FONT)
	title.add_theme_font_size_override("font_size", 54)
	title.add_theme_color_override("font_color", Color(0.98, 0.93, 0.82, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	title.add_theme_constant_override("outline_size", 8)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 22.0
	title.offset_bottom = 90.0
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.z_index = 8
	ui_root.add_child(title)

	var subtitle := Label.new()
	subtitle.name = "GameSubtitle"
	subtitle.text = "Build, defend, and push back the waves."
	subtitle.add_theme_font_override("font", TITLE_FONT)
	subtitle.add_theme_font_size_override("font_size", 20)
	subtitle.add_theme_color_override("font_color", Color(1, 1, 1, 0.78))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle.set_anchors_preset(Control.PRESET_TOP_WIDE)
	subtitle.offset_top = 84.0
	subtitle.offset_bottom = 122.0
	subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	subtitle.z_index = 8
	ui_root.add_child(subtitle)
