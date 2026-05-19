extends Node2D

@onready var music: AudioStreamPlayer = $"sound fx/music"
@onready var click: AudioStreamPlayer = $"sound fx/click"

var level=preload("res://Levels/level.tscn")

func _ready() -> void:
	music.play()

func _exit_tree() -> void:
	music.stop()

func _on_start_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_packed(level)

func _on_quit_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
