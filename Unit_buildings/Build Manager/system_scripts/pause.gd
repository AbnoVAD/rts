extends Panel

@export_group("Text")
@export var title_text: String = "Paused"
@export var subtitle_text: String = "Battle is on hold. Reorganize your forces, save if needed, then jump back in."
@export var action_text: String = "Resume"
@export var save_text: String = "Save Game"
@export var menu_text: String = "Main Menu"
@export var hint_text: String = "Press P to pause and resume, or use Save Game to keep your progress."

@onready var title_label: Label = get_node_or_null("pause_/PauseUI/Center/Pause Card/ContentMargin/Content/paused") as Label
@onready var subtitle_label: Label = get_node_or_null("pause_/PauseUI/Center/Pause Card/ContentMargin/Content/info") as Label
@onready var action_btn: Button = $"pause_/PauseUI/Center/Pause Card/ContentMargin/Content/ResumeButton"
@onready var save_btn: Button = $"pause_/PauseUI/Center/Pause Card/ContentMargin/Content/SaveButton"
@onready var menu_btn: Button = $"pause_/PauseUI/Center/Pause Card/ContentMargin/Content/MenuButton"
@onready var hint_label: Label = get_node_or_null("pause_/PauseUI/Center/Pause Card/ContentMargin/Content/Hint") as Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if action_btn:
		action_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	if save_btn:
		save_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	if menu_btn:
		menu_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	if action_btn and not action_btn.pressed.is_connected(_on_resume_btn_pressed):
		action_btn.pressed.connect(_on_resume_btn_pressed)
	if save_btn and not save_btn.pressed.is_connected(_on_save_btn_pressed):
		save_btn.pressed.connect(_on_save_btn_pressed)
	if menu_btn and not menu_btn.pressed.is_connected(_on_menu_btn_pressed):
		menu_btn.pressed.connect(_on_menu_btn_pressed)
	_apply_text()
	hide()


func _apply_text() -> void:
	if title_label:
		title_label.text = title_text
	if subtitle_label:
		subtitle_label.text = subtitle_text
	if hint_label:
		hint_label.text = hint_text
	if action_btn:
		action_btn.text = action_text
	if save_btn:
		save_btn.text = save_text
	if menu_btn:
		menu_btn.text = menu_text


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not get_tree().paused:
		get_tree().paused = true
		show()
	elif event.is_action_pressed("resume") and get_tree().paused:
		get_tree().paused = false
		hide()


func _on_resume_btn_pressed() -> void:
	if get_tree().paused:
		get_tree().paused = false
		hide()

func _on_save_btn_pressed() -> void:
	Global.save_game()
	if hint_label:
		hint_label.text = "Game saved. Press P to resume."

func _on_menu_btn_pressed() -> void:
	if get_tree().paused:
		get_tree().paused = false
	Global.save_game()
	Global.reset_game()
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://Menus/Main menu.tscn")
