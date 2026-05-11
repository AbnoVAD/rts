extends Panel

@onready var pause: Label = $pause
@onready var resume: Label = $resume
@onready var resume_btn: Button = $"resume/resume btn"

func _ready() -> void:
	hide()
	process_mode=Node.PROCESS_MODE_ALWAYS

func _input(event:InputEvent)->void:
	if event.is_action_pressed("pause") and !get_tree().paused:
		get_tree().paused=true
		show()

#Manual resume from keyboard
	elif event.is_action_pressed("resume") and get_tree().paused:
		get_tree().paused=false
		hide()

func _on_resume_btn_pressed() -> void:
	if get_tree().paused:
		get_tree().paused=false
		hide()
