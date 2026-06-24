extends Node2D

@onready var music: AudioStreamPlayer = $"sound fx/music"
@onready var click: AudioStreamPlayer = $"sound fx/click"
@onready var camera: Camera2D = $Camera2D
@onready var ui_root: Control = $UI/Root
@onready var menu_panel: Control = $"UI/Root/MenuPanel"
@onready var load_panel: Panel = $"UI/Root/LoadPanel"
@onready var settings_panel: Panel = $"UI/Root/SettingsPanel"
@onready var info_panel: Panel = $"UI/Root/InfoPanel"
@onready var save_state_label: Label = $"UI/Root/LoadPanel/LoadContentMargin/LoadContent/SaveState"
@onready var continue_button: Button = $"UI/Root/LoadPanel/LoadContentMargin/LoadContent/ContinueButton"
@onready var master_value_label: Label = $"UI/Root/SettingsPanel/SettingsContentMargin/SettingsContent/MasterRow/Value"
@onready var music_value_label: Label = $"UI/Root/SettingsPanel/SettingsContentMargin/SettingsContent/MusicRow/Value"
@onready var sfx_value_label: Label = $"UI/Root/SettingsPanel/SettingsContentMargin/SettingsContent/SfxRow/Value"
@onready var master_slider: HSlider = $"UI/Root/SettingsPanel/SettingsContentMargin/SettingsContent/MasterRow/Slider"
@onready var music_slider: HSlider = $"UI/Root/SettingsPanel/SettingsContentMargin/SettingsContent/MusicRow/Slider"
@onready var sfx_slider: HSlider = $"UI/Root/SettingsPanel/SettingsContentMargin/SettingsContent/SfxRow/Slider"
@onready var fullscreen_toggle: CheckButton = $"UI/Root/SettingsPanel/SettingsContentMargin/SettingsContent/FullscreenToggle"
@onready var vsync_toggle: CheckButton = $"UI/Root/SettingsPanel/SettingsContentMargin/SettingsContent/VsyncToggle"
@onready var controls_list: VBoxContainer = $"UI/Root/SettingsPanel/ControlsCard/ControlsContentMargin/ControlsContent/ControlsList"
@onready var settings_audio_tab: Button = $"UI/Root/SettingsPanel/SettingsShell/SettingsSidebarPanel/SettingsSidebarMargin/SettingsSidebarContent/SettingsAudioTab"
@onready var settings_display_tab: Button = $"UI/Root/SettingsPanel/SettingsShell/SettingsSidebarPanel/SettingsSidebarMargin/SettingsSidebarContent/SettingsDisplayTab"
@onready var settings_controls_tab: Button = $"UI/Root/SettingsPanel/SettingsShell/SettingsSidebarPanel/SettingsSidebarMargin/SettingsSidebarContent/SettingsControlsTab"
@onready var settings_back_arrow: Button = $"UI/Root/SettingsPanel/SettingsShell/SettingsDetailsPanel/SettingsDetailsMargin/SettingsDetailsContent/SettingsTopBar/SettingsBackArrow"
@onready var settings_page_title: Label = $"UI/Root/SettingsPanel/SettingsShell/SettingsDetailsPanel/SettingsDetailsMargin/SettingsDetailsContent/SettingsTopBar/SettingsPageTitle"
@onready var settings_page_subtitle: Label = $"UI/Root/SettingsPanel/SettingsShell/SettingsDetailsPanel/SettingsDetailsMargin/SettingsDetailsContent/SettingsPageSubtitle"
@onready var settings_audio_page: VBoxContainer = $"UI/Root/SettingsPanel/SettingsShell/SettingsDetailsPanel/SettingsDetailsMargin/SettingsDetailsContent/SettingsPageStack/SettingsAudioPage"
@onready var settings_display_page: VBoxContainer = $"UI/Root/SettingsPanel/SettingsShell/SettingsDetailsPanel/SettingsDetailsMargin/SettingsDetailsContent/SettingsPageStack/SettingsDisplayPage"
@onready var settings_controls_page: VBoxContainer = $"UI/Root/SettingsPanel/SettingsShell/SettingsDetailsPanel/SettingsDetailsMargin/SettingsDetailsContent/SettingsPageStack/SettingsControlsPage"
@onready var info_units_page: VBoxContainer = $"UI/Root/InfoPanel/InfoContentMargin/InfoContent/InfoScroll/InfoScrollContent/UnitsPage"
@onready var info_buildings_page: VBoxContainer = $"UI/Root/InfoPanel/InfoContentMargin/InfoContent/InfoScroll/InfoScrollContent/BuildingsPage"
@onready var info_enemies_page: VBoxContainer = $"UI/Root/InfoPanel/InfoContentMargin/InfoContent/InfoScroll/InfoScrollContent/EnemiesPage"
@onready var info_controls_page: VBoxContainer = $"UI/Root/InfoPanel/InfoContentMargin/InfoContent/InfoScroll/InfoScrollContent/ControlsPage"
@onready var info_units_tab: Button = $"UI/Root/InfoPanel/InfoContentMargin/InfoContent/InfoTabs/UnitsTab"
@onready var info_buildings_tab: Button = $"UI/Root/InfoPanel/InfoContentMargin/InfoContent/InfoTabs/BuildingsTab"
@onready var info_enemies_tab: Button = $"UI/Root/InfoPanel/InfoContentMargin/InfoContent/InfoTabs/EnemiesTab"
@onready var info_controls_tab: Button = $"UI/Root/InfoPanel/InfoContentMargin/InfoContent/InfoTabs/ControlsTab"
@onready var info_sidebar_units_tab: Button = $"UI/Root/InfoPanel/InfoShell/InfoSidebarPanel/InfoSidebarMargin/InfoSidebarContent/InfoUnitsTab"
@onready var info_sidebar_buildings_tab: Button = $"UI/Root/InfoPanel/InfoShell/InfoSidebarPanel/InfoSidebarMargin/InfoSidebarContent/InfoBuildingsTab"
@onready var info_sidebar_enemies_tab: Button = $"UI/Root/InfoPanel/InfoShell/InfoSidebarPanel/InfoSidebarMargin/InfoSidebarContent/InfoEnemiesTab"
@onready var info_sidebar_controls_tab: Button = $"UI/Root/InfoPanel/InfoShell/InfoSidebarPanel/InfoSidebarMargin/InfoSidebarContent/InfoControlsTab"
@onready var info_back_arrow: Button = $"UI/Root/InfoPanel/InfoShell/InfoDetailsPanel/InfoDetailsMargin/InfoDetailsContent/InfoTopBar/InfoBackArrow"
@onready var info_page_title: Label = $"UI/Root/InfoPanel/InfoShell/InfoDetailsPanel/InfoDetailsMargin/InfoDetailsContent/InfoTopBar/InfoPageTitle"
@onready var info_page_subtitle: Label = $"UI/Root/InfoPanel/InfoShell/InfoDetailsPanel/InfoDetailsMargin/InfoDetailsContent/InfoPageSubtitle"
@onready var info_scroll_content: VBoxContainer = $"UI/Root/InfoPanel/InfoShell/InfoDetailsPanel/InfoDetailsMargin/InfoDetailsContent/InfoScroll/InfoScrollContent"
@onready var info_units_page_new: VBoxContainer = $"UI/Root/InfoPanel/InfoShell/InfoDetailsPanel/InfoDetailsMargin/InfoDetailsContent/InfoScroll/InfoScrollContent/InfoUnitsPage"
@onready var info_buildings_page_new: VBoxContainer = $"UI/Root/InfoPanel/InfoShell/InfoDetailsPanel/InfoDetailsMargin/InfoDetailsContent/InfoScroll/InfoScrollContent/InfoBuildingsPage"
@onready var info_enemies_page_new: VBoxContainer = $"UI/Root/InfoPanel/InfoShell/InfoDetailsPanel/InfoDetailsMargin/InfoDetailsContent/InfoScroll/InfoScrollContent/InfoEnemiesPage"
@onready var info_controls_page_new: VBoxContainer = $"UI/Root/InfoPanel/InfoShell/InfoDetailsPanel/InfoDetailsMargin/InfoDetailsContent/InfoScroll/InfoScrollContent/InfoControlsPage"

var settings_master_slider_new: HSlider
var settings_music_slider_new: HSlider
var settings_sfx_slider_new: HSlider
var settings_master_value_label_new: Label
var settings_music_value_label_new: Label
var settings_sfx_value_label_new: Label
var settings_fullscreen_toggle_new: CheckButton
var settings_vsync_toggle_new: CheckButton

const LEVEL_SCENE := preload("res://Levels/level.tscn")
const BASE_UI_SIZE := Vector2(1920, 1080)
const MENU_CAMERA_POSITION := Vector2(1144, 320)
const MENU_CAMERA_ZOOM := Vector2.ONE
const TITLE_FONT := preload("res://assets/Text Font/ringbearer/RINGM___.TTF")

const ARCHER_ICON := preload("res://assets/Tiny Swords (Free Pack)/Units/Blue Units/Archer/Archer_Idle.png")
const KNIGHT_ICON := preload("res://assets/Tiny Swords (Free Pack)/Units/Blue Units/Warrior/Warrior_Idle.png")
const PAWN_ICON := preload("res://assets/Tiny Swords (Free Pack)/Units/Blue Units/Pawn/Pawn_Idle.png")
const MONK_ICON := preload("res://assets/Tiny Swords (Free Pack)/Units/Blue Units/Monk/Idle.png")
const CASTLE_ICON := preload("res://assets/Tiny Swords (Free Pack)/Buildings/Blue Buildings/Castle.png")
const TOWER_ICON := preload("res://assets/Tiny Swords (Free Pack)/Buildings/Blue Buildings/Tower.png")
const BARRACKS_ICON := preload("res://assets/Tiny Swords (Free Pack)/Buildings/Blue Buildings/Barracks.png")
const MONASTERY_ICON := preload("res://assets/Tiny Swords (Free Pack)/Buildings/Blue Buildings/Monastery.png")
const GOBLIN_TORCH_ICON := preload("res://assets/Tiny Swords old/Tiny Swords (Update 010)/Factions/Goblins/Troops/Torch/Yellow/Torch_Yellow.png")
const GOBLIN_BARREL_ICON := preload("res://assets/Tiny Swords old/Tiny Swords (Update 010)/Factions/Goblins/Troops/Barrel/Yellow/Barrel_Yellow.png")
const GOBLIN_TNT_ICON := preload("res://assets/Tiny Swords old/Tiny Swords (Update 010)/Factions/Goblins/Troops/TNT/Yellow/TNT_Yellow.png")
const GOBLIN_HOUSE_ICON := preload("res://assets/Tiny Swords old/Tiny Swords (Update 010)/Factions/Goblins/Buildings/Wood_House/Goblin_House.png")
const WIZARD_ICON := preload("res://assets/EVil Wizard 2/Sprites/Idle.png")

const INFO_UNITS := [
	{"title":"Archer","body":"Ranged defender and field attacker. Strong from a safe position and especially effective when placed on buildings.", "icon": ARCHER_ICON},
	{"title":"Knight","body":"Frontline melee unit. Best for pushing enemies back, holding ground, and soaking damage while others work.", "icon": KNIGHT_ICON},
	{"title":"Pawn","body":"Worker unit used for gathering, hauling, and supporting your economy. Keep them alive to keep your kingdom growing.", "icon": PAWN_ICON},
	{"title":"Monk","body":"Support unit that heals allies and keeps your army in fighting shape during long battles.", "icon": MONK_ICON}
]

const INFO_BUILDINGS := [
	{"title":"Castle","body":"Your main base and one of your most important structures. It anchors your economy and helps defend the kingdom.", "icon": CASTLE_ICON},
	{"title":"Tower","body":"Static defense structure that places an archer on top. Good for covering lanes and protecting approaches.", "icon": TOWER_ICON},
	{"title":"Barracks","body":"Military building that produces knights. Place it where your frontline needs reinforcements most.", "icon": BARRACKS_ICON},
	{"title":"Monastery","body":"Support building that produces monks. Great for sustaining armies and recovering after attacks.", "icon": MONASTERY_ICON}
]

const INFO_ENEMIES := [
	{"title":"Goblin Torch","body":"Basic enemy pressure unit. Cheap, aggressive, and useful for early wave harassment.", "icon": GOBLIN_TORCH_ICON},
	{"title":"Goblin Barrel","body":"Heavier goblin unit that hits harder and helps break through your defenses.", "icon": GOBLIN_BARREL_ICON},
	{"title":"Goblin TNT","body":"Explosive enemy unit. Dangerous around clusters of buildings and packed defenders.", "icon": GOBLIN_TNT_ICON},
	{"title":"Goblin House","body":"Enemy structure that contributes to goblin forces. Destroy it to reduce the enemy threat.", "icon": GOBLIN_HOUSE_ICON},
	{"title":"Wizard Boss","body":"Late-game enemy boss with stronger pressure. Treat it like a priority target when it appears.", "icon": WIZARD_ICON}
]

const INFO_CONTROLS := [
	{"action":"move_up","label":"Move Up"},
	{"action":"move_down","label":"Move Down"},
	{"action":"move_left","label":"Move Left"},
	{"action":"move_right","label":"Move Right"},
	{"action":"use","label":"Use / Action"},
	{"action":"pause","label":"Pause"},
	{"action":"resume","label":"Resume"},
	{"action":"tool_hammer","label":"Tool 1"},
	{"action":"tool_knife","label":"Tool 2"},
	{"action":"tool_axe","label":"Tool 3"},
	{"action":"tool_pickaxe","label":"Tool 4"},
	{"action":"tool_hand","label":"Tool 5"}
]

func _ready() -> void:
	music.play()
	camera.enabled = true
	camera.position = MENU_CAMERA_POSITION
	camera.zoom = MENU_CAMERA_ZOOM
	camera.make_current()
	_fit_ui_to_viewport()
	Global.apply_settings(self)
	_build_settings_pages()
	_build_info_pages()
	_refresh_load_state_label()
	_sync_settings_ui()
	_show_main_menu()
	get_viewport().size_changed.connect(_fit_ui_to_viewport)

func _exit_tree() -> void:
	var viewport := get_viewport()
	if viewport and viewport.size_changed.is_connected(_fit_ui_to_viewport):
		viewport.size_changed.disconnect(_fit_ui_to_viewport)
	music.stop()

func _on_start_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.2).timeout
	Global.reset_game()
	get_tree().change_scene_to_packed(LEVEL_SCENE)

func _on_load_pressed() -> void:
	click.play()
	_refresh_load_state_label()
	load_panel.show()
	menu_panel.hide()
	settings_panel.hide()
	info_panel.hide()

func _on_continue_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.2).timeout
	if Global.load_game():
		return
	_refresh_load_state_label()

func _on_new_game_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.2).timeout
	Global.reset_game()
	get_tree().change_scene_to_packed(LEVEL_SCENE)

func _on_back_from_load_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.1).timeout
	_show_main_menu()

func _on_info_pressed() -> void:
	click.play()
	_show_info_page("units")
	info_panel.show()
	menu_panel.hide()
	load_panel.hide()
	settings_panel.hide()

func _on_info_units_pressed() -> void:
	_show_info_page("units")

func _on_info_buildings_pressed() -> void:
	_show_info_page("buildings")

func _on_info_enemies_pressed() -> void:
	_show_info_page("enemies")

func _on_info_controls_pressed() -> void:
	_show_info_page("controls")

func _on_back_from_info_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.1).timeout
	_show_main_menu()

func _on_settings_audio_tab_pressed() -> void:
	_show_settings_page("audio")

func _on_settings_display_tab_pressed() -> void:
	_show_settings_page("display")

func _on_settings_controls_tab_pressed() -> void:
	_show_settings_page("controls")

func _on_setting_pressed() -> void:
	click.play()
	_sync_settings_ui()
	_show_settings_page("audio")
	settings_panel.show()
	menu_panel.hide()
	load_panel.hide()
	info_panel.hide()

func _on_back_from_settings_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.1).timeout
	_show_main_menu()

func _on_master_slider_value_changed(value: float) -> void:
	Global.set_master_volume(value)
	_update_settings_labels()

func _on_music_slider_value_changed(value: float) -> void:
	Global.set_music_volume(value)
	_update_settings_labels()

func _on_sfx_slider_value_changed(value: float) -> void:
	Global.set_sfx_volume(value)
	_update_settings_labels()

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	Global.set_fullscreen(toggled_on)

func _on_vsync_toggled(toggled_on: bool) -> void:
	Global.set_vsync(toggled_on)

func _on_reset_settings_pressed() -> void:
	click.play()
	Global.set_master_volume(100.0)
	Global.set_music_volume(100.0)
	Global.set_sfx_volume(100.0)
	Global.set_fullscreen(false)
	Global.set_vsync(true)
	_sync_settings_ui()

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

func _show_main_menu() -> void:
	menu_panel.show()
	load_panel.hide()
	settings_panel.hide()
	info_panel.hide()

func _refresh_load_state_label() -> void:
	if save_state_label == null:
		return
	if Global.has_saved_game():
		save_state_label.text = "Save found. You can continue your last session."
		continue_button.disabled = false
	else:
		save_state_label.text = "No save found. Start a new campaign."
		continue_button.disabled = true

func _sync_settings_ui() -> void:
	if settings_master_slider_new:
		settings_master_slider_new.value = Global.master_volume
	elif master_slider:
		master_slider.value = Global.master_volume
	if settings_music_slider_new:
		settings_music_slider_new.value = Global.music_volume
	elif music_slider:
		music_slider.value = Global.music_volume
	if settings_sfx_slider_new:
		settings_sfx_slider_new.value = Global.sfx_volume
	elif sfx_slider:
		sfx_slider.value = Global.sfx_volume
	if settings_fullscreen_toggle_new:
		settings_fullscreen_toggle_new.button_pressed = Global.fullscreen_enabled
	elif fullscreen_toggle:
		fullscreen_toggle.button_pressed = Global.fullscreen_enabled
	if settings_vsync_toggle_new:
		settings_vsync_toggle_new.button_pressed = Global.vsync_enabled
	elif vsync_toggle:
		vsync_toggle.button_pressed = Global.vsync_enabled
	_update_settings_labels()

func _update_settings_labels() -> void:
	if settings_master_value_label_new:
		settings_master_value_label_new.text = "%d%%" % int(round(Global.master_volume))
	elif master_value_label:
		master_value_label.text = "%d%%" % int(round(Global.master_volume))
	if settings_music_value_label_new:
		settings_music_value_label_new.text = "%d%%" % int(round(Global.music_volume))
	elif music_value_label:
		music_value_label.text = "%d%%" % int(round(Global.music_volume))
	if settings_sfx_value_label_new:
		settings_sfx_value_label_new.text = "%d%%" % int(round(Global.sfx_volume))
	elif sfx_value_label:
		sfx_value_label.text = "%d%%" % int(round(Global.sfx_volume))

func _build_settings_pages() -> void:
	_build_audio_settings_page()
	_build_display_settings_page()
	_build_controls_list()
	_show_settings_page("audio")

func _build_audio_settings_page() -> void:
	if settings_audio_page == null:
		return
	_clear_container(settings_audio_page)
	settings_master_slider_new = null
	settings_music_slider_new = null
	settings_sfx_slider_new = null
	settings_master_value_label_new = null
	settings_music_value_label_new = null
	settings_sfx_value_label_new = null
	settings_audio_page.add_child(_make_section_header("Audio"))
	settings_audio_page.add_child(_make_slider_card("Master Volume", Global.master_volume, "_on_master_slider_value_changed", "master"))
	settings_audio_page.add_child(_make_slider_card("Music Volume", Global.music_volume, "_on_music_slider_value_changed", "music"))
	settings_audio_page.add_child(_make_slider_card("SFX Volume", Global.sfx_volume, "_on_sfx_slider_value_changed", "sfx"))

func _build_display_settings_page() -> void:
	if settings_display_page == null:
		return
	_clear_container(settings_display_page)
	settings_display_page.add_child(_make_section_header("Display"))
	settings_display_page.add_child(_make_toggle_card("Fullscreen", "Run the game in fullscreen mode.", Global.fullscreen_enabled, "_on_fullscreen_toggled", "fullscreen"))
	settings_display_page.add_child(_make_toggle_card("VSync", "Keep rendering synchronized with the monitor.", Global.vsync_enabled, "_on_vsync_toggled", "vsync"))
	var reset_card := _make_simple_card("Reset", "Restore all settings to their default values.")
	var button := Button.new()
	button.custom_minimum_size = Vector2(240, 46)
	button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	button.add_theme_font_override("font", TITLE_FONT)
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_stylebox_override("normal", _make_menu_button_style(Color(0.38, 0.42, 0.51, 1.0), Color(0.68, 0.74, 0.84, 0.55), 8))
	button.add_theme_stylebox_override("pressed", _make_menu_button_style(Color(0.28, 0.32, 0.40, 1.0), Color(0.68, 0.74, 0.84, 0.75), 8))
	button.add_theme_stylebox_override("hover", _make_menu_button_style(Color(0.42, 0.46, 0.56, 1.0), Color(0.82, 0.88, 0.96, 0.75), 8))
	button.add_theme_stylebox_override("hover_pressed", _make_menu_button_style(Color(0.28, 0.32, 0.40, 1.0), Color(0.82, 0.88, 0.96, 0.85), 8))
	button.add_theme_stylebox_override("focus", _make_menu_button_style(Color(0.42, 0.46, 0.56, 1.0), Color(0.82, 0.88, 0.96, 0.75), 8))
	button.text = "Reset Defaults"
	button.flat = true
	button.pressed.connect(Callable(self, "_on_reset_settings_pressed"))
	reset_card.get_node("Margin/Content").add_child(button)
	settings_display_page.add_child(reset_card)

func _build_controls_list() -> void:
	if settings_controls_page == null:
		return
	_clear_container(settings_controls_page)
	settings_controls_page.add_child(_make_section_header("Controls"))
	var card := _make_simple_card("Keyboard", "Your current key layout.")
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 6)
	card.get_node("Margin/Content").add_child(list)
	for entry in INFO_CONTROLS:
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 12)

		var label := Label.new()
		label.text = String(entry.get("label", "Control"))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_override("font", TITLE_FONT)
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color(1, 0.95, 0.86, 1))
		label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		label.add_theme_constant_override("outline_size", 2)

		var value := Label.new()
		value.text = _describe_action_key(String(entry.get("action", "")))
		value.custom_minimum_size = Vector2(130, 0)
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value.add_theme_font_override("font", TITLE_FONT)
		value.add_theme_font_size_override("font_size", 16)
		value.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
		value.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		value.add_theme_constant_override("outline_size", 2)

		row.add_child(label)
		row.add_child(value)
		list.add_child(row)
	settings_controls_page.add_child(card)

func _build_info_pages() -> void:
	_build_info_page(info_units_page_new, INFO_UNITS)
	_build_info_page(info_buildings_page_new, INFO_BUILDINGS)
	_build_info_page(info_enemies_page_new, INFO_ENEMIES)
	_build_info_controls_page()
	_show_info_page("units")

func _build_info_page(page: VBoxContainer, entries: Array) -> void:
	if page == null:
		return
	_clear_container(page)
	for entry in entries:
		page.add_child(_make_info_card(String(entry.get("title", "Entry")), String(entry.get("body", "")), entry.get("icon")))

func _build_info_controls_page() -> void:
	if info_controls_page_new == null:
		return
	_clear_container(info_controls_page_new)
	info_controls_page_new.add_child(_make_info_card("Controls", "Use the sidebar tabs to switch between roster pages.", null))
	info_controls_page_new.add_child(_make_info_card("Tip", "The back arrow returns you to the main menu at any time.", null))

func _make_section_header(title_text: String) -> Control:
	var label := Label.new()
	label.text = title_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", TITLE_FONT)
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color(1, 0.96, 0.84, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 4)
	return label

func _make_simple_card(title_text: String, body_text: String) -> Panel:
	var card := Panel.new()
	card.custom_minimum_size = Vector2(0, 118)
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.26, 0.29, 0.37, 0.96)
	card_style.border_color = Color(0.66, 0.72, 0.82, 0.65)
	card_style.border_width_left = 2
	card_style.border_width_top = 2
	card_style.border_width_right = 2
	card_style.border_width_bottom = 2
	card_style.corner_radius_top_left = 8
	card_style.corner_radius_top_right = 8
	card_style.corner_radius_bottom_left = 8
	card_style.corner_radius_bottom_right = 8
	card.add_theme_stylebox_override("panel", card_style)
	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	card.add_child(margin)
	var content := VBoxContainer.new()
	content.name = "Content"
	content.add_theme_constant_override("separation", 6)
	margin.add_child(content)
	var title := Label.new()
	title.text = title_text.to_upper()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", TITLE_FONT)
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1, 0.98, 0.88, 1))
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	title.add_theme_constant_override("outline_size", 3)
	content.add_child(title)
	var body := Label.new()
	body.text = body_text
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_theme_font_override("font", TITLE_FONT)
	body.add_theme_font_size_override("font_size", 16)
	body.add_theme_color_override("font_color", Color(1, 1, 1, 0.88))
	body.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	body.add_theme_constant_override("outline_size", 2)
	body.visible = not body_text.is_empty()
	content.add_child(body)
	return card

func _make_slider_card(title_text: String, current_value: float, callback_name: String, kind: String) -> Panel:
	var card := _make_simple_card(title_text, "")
	card.custom_minimum_size = Vector2(0, 118)
	var content := card.get_node("Margin/Content") as VBoxContainer
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 12)
	content.add_child(row)

	var label := Label.new()
	label.text = title_text
	label.custom_minimum_size = Vector2(210, 0)
	label.add_theme_font_override("font", TITLE_FONT)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(1, 0.95, 0.87, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 3)

	var slider := HSlider.new()
	slider.custom_minimum_size = Vector2(320, 20)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.max_value = 100.0
	slider.step = 1.0
	slider.value = current_value

	var value_label := Label.new()
	value_label.custom_minimum_size = Vector2(72, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_font_override("font", TITLE_FONT)
	value_label.add_theme_font_size_override("font_size", 18)
	value_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.86))
	value_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	value_label.add_theme_constant_override("outline_size", 2)
	value_label.text = "%d%%" % int(round(current_value))

	slider.value_changed.connect(Callable(self, callback_name))
	row.add_child(label)
	row.add_child(slider)
	row.add_child(value_label)

	match kind:
		"master":
			settings_master_slider_new = slider
			settings_master_value_label_new = value_label
		"music":
			settings_music_slider_new = slider
			settings_music_value_label_new = value_label
		"sfx":
			settings_sfx_slider_new = slider
			settings_sfx_value_label_new = value_label
	return card

func _make_toggle_card(title_text: String, body_text: String, initial_state: bool, callback_name: String, kind: String) -> Panel:
	var card := _make_simple_card(title_text, body_text)
	var content := card.get_node("Margin/Content") as VBoxContainer
	var toggle_row := HBoxContainer.new()
	toggle_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(toggle_row)

	var toggle := CheckButton.new()
	toggle.text = title_text
	toggle.button_pressed = initial_state
	toggle.toggle_mode = true
	toggle.add_theme_color_override("font_color", Color(1, 0.95, 0.87, 1))
	toggle.add_theme_font_override("font", TITLE_FONT)
	toggle.add_theme_font_size_override("font_size", 22)
	toggle.toggled.connect(Callable(self, callback_name))
	toggle_row.add_child(toggle)

	match kind:
		"fullscreen":
			settings_fullscreen_toggle_new = toggle
		"vsync":
			settings_vsync_toggle_new = toggle
	return card

func _make_menu_button_style(bg_color: Color, border_color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style

func _make_info_card(title_text: String, body_text: String, icon_texture: Texture2D = null) -> Control:
	var card := Panel.new()
	card.custom_minimum_size = Vector2(0, 150)
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.26, 0.29, 0.37, 0.96)
	card_style.border_color = Color(0.66, 0.72, 0.82, 0.65)
	card_style.border_width_left = 2
	card_style.border_width_top = 2
	card_style.border_width_right = 2
	card_style.border_width_bottom = 2
	card_style.corner_radius_top_left = 10
	card_style.corner_radius_top_right = 10
	card_style.corner_radius_bottom_left = 10
	card_style.corner_radius_bottom_right = 10
	card.add_theme_stylebox_override("panel", card_style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	card.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	margin.add_child(row)

	if icon_texture != null:
		var icon := TextureRect.new()
		icon.texture = icon_texture
		icon.custom_minimum_size = Vector2(92, 92)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	row.add_child(content)

	var title := Label.new()
	title.text = title_text.to_upper()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_font_override("font", TITLE_FONT)
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1, 0.98, 0.88, 1))
	title.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	title.add_theme_constant_override("outline_size", 3)
	content.add_child(title)

	var body := Label.new()
	body.text = body_text
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_font_override("font", TITLE_FONT)
	body.add_theme_font_size_override("font_size", 18)
	body.add_theme_color_override("font_color", Color(1, 1, 1, 0.88))
	body.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	body.add_theme_constant_override("outline_size", 2)
	content.add_child(body)

	return card

func _clear_container(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()

func _show_settings_page(page_name: String) -> void:
	if settings_audio_page:
		settings_audio_page.visible = page_name == "audio"
	if settings_display_page:
		settings_display_page.visible = page_name == "display"
	if settings_controls_page:
		settings_controls_page.visible = page_name == "controls"
	if settings_audio_tab:
		settings_audio_tab.button_pressed = page_name == "audio"
	if settings_display_tab:
		settings_display_tab.button_pressed = page_name == "display"
	if settings_controls_tab:
		settings_controls_tab.button_pressed = page_name == "controls"
	if settings_page_title:
		settings_page_title.text = page_name.capitalize()
	if settings_page_subtitle:
		match page_name:
			"audio":
				settings_page_subtitle.text = "Tune audio before entering battle."
			"display":
				settings_page_subtitle.text = "Adjust how the game is rendered."
			"controls":
				settings_page_subtitle.text = "Review the current key layout."

func _show_info_page(page_name: String) -> void:
	if info_units_page_new:
		info_units_page_new.visible = page_name == "units"
	if info_buildings_page_new:
		info_buildings_page_new.visible = page_name == "buildings"
	if info_enemies_page_new:
		info_enemies_page_new.visible = page_name == "enemies"
	if info_controls_page_new:
		info_controls_page_new.visible = page_name == "controls"
	if info_sidebar_units_tab:
		info_sidebar_units_tab.button_pressed = page_name == "units"
	if info_sidebar_buildings_tab:
		info_sidebar_buildings_tab.button_pressed = page_name == "buildings"
	if info_sidebar_enemies_tab:
		info_sidebar_enemies_tab.button_pressed = page_name == "enemies"
	if info_sidebar_controls_tab:
		info_sidebar_controls_tab.button_pressed = page_name == "controls"
	if info_page_title:
		info_page_title.text = "INFORMATIONS"
	if info_page_subtitle:
		match page_name:
			"units":
				info_page_subtitle.text = "Learn how your own units behave in the field."
			"buildings":
				info_page_subtitle.text = "See what each structure does for your kingdom."
			"enemies":
				info_page_subtitle.text = "Know the goblin forces before they reach your walls."
			"controls":
				info_page_subtitle.text = "Quick reference for movement, tools, and actions."

func _describe_action_key(action_name: String) -> String:
	if action_name.is_empty():
		return "-"
	var events := InputMap.action_get_events(action_name)
	for event in events:
		if event is InputEventKey:
			return (event as InputEventKey).as_text_keycode()
		if event is InputEventMouseButton:
			var mouse_event := event as InputEventMouseButton
			return "Mouse %d" % mouse_event.button_index
	return "-"
