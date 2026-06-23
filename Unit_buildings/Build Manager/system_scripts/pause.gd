extends Panel

@export_group("Text")
@export var title_text: String = "Paused"
@export var subtitle_text: String = "Battle is on hold. Reorganize your forces, then jump back in."
@export var action_text: String = "Resume"
@export var hint_text: String = "Press P or click Resume"

@onready var title_label: Label = $"pause_/PauseUI/Center/Pause Card/ContentMargin/Content/Title"
@onready var subtitle_label: Label = $"pause_/PauseUI/Center/Pause Card/ContentMargin/Content/Subtitle"
@onready var action_btn: Button = $"pause_/PauseUI/Center/Pause Card/ContentMargin/Content/ResumeButton"
@onready var hint_label: Label = $"pause_/PauseUI/Center/Pause Card/ContentMargin/Content/Hint"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if action_btn and not action_btn.pressed.is_connected(_on_resume_btn_pressed):
		action_btn.pressed.connect(_on_resume_btn_pressed)
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
