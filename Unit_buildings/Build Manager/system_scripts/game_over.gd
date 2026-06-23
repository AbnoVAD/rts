extends Panel

@export_group("Text")
@export var title_text: String = "Game Over"
@export var subtitle_text: String = "Your kingdom has fallen. Learn the pattern, rebuild faster, and try again."
@export var action_text: String = "Retry"
@export var hint_text: String = "Press R or click Retry"

@onready var title_label: Label = $"Gameover_/GameOverUI/Center/Game Over Card/ContentMargin/Content/Title"
@onready var subtitle_label: Label = $"Gameover_/GameOverUI/Center/Game Over Card/ContentMargin/Content/Subtitle"
@onready var action_btn: Button = $"Gameover_/GameOverUI/Center/Game Over Card/ContentMargin/Content/RetryButton"
@onready var hint_label: Label = $"Gameover_/GameOverUI/Center/Game Over Card/ContentMargin/Content/Hint"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if action_btn and not action_btn.pressed.is_connected(_on_retry_btn_pressed):
		action_btn.pressed.connect(_on_retry_btn_pressed)
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


func _on_retry_btn_pressed() -> void:
	if get_tree().paused:
		get_tree().paused = false
		Global.reset_game()
		get_tree().reload_current_scene()
