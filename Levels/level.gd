extends Node2D

#-------------------------------
#LEVEL : 1
#-------------------------------
const LEVEL_ID:=1

var level_completed:bool=false
@onready var timer_label: Label = $"UI/ui/Panel/Timer Label"

#-------------------------------
#Music system
#-------------------------------
@onready var music: AudioStreamPlayer = $"Music and Fx/music"
@onready var click: AudioStreamPlayer = $"Music and Fx/click"
@onready var waves_sea_fx: AudioStreamPlayer = $"Music and Fx/waves sea_fx"
@onready var fight_theme_music: AudioStreamPlayer = $"Music and Fx/fight theme music"

#-------------------------------
#Game over system
#-------------------------------
@onready var game_ovr: Panel = $"UI/ui/Panel/Game Over"
@onready var retry: Label = $"UI/ui/Panel/Game Over/Retry"
@onready var next_level: Button = $"UI/ui/Panel/Player/Unit resources/Next level"
@onready var info_label: Label = $"UI/ui/Panel/Info label"

func _ready() -> void:
	Global.wave_ended.connect(_on_wave_ended)
	next_level.hide()
	Global.init_level_state()
	Global.set_current_level(LEVEL_ID)
	Global.Goblin_house=0
	get_tree().paused=false
	Global.game_over=false
	music.play()
	waves_sea_fx.play()

var last_wave_state:=false
func _process(delta: float) -> void:
	if Global.wave_active!=last_wave_state:
		last_wave_state=Global.wave_active
		if Global.wave_active:
			music.stop()
			fight_theme_music.play()
		else:
			music.play()
			fight_theme_music.stop()

	if level_completed:
		return
	if Global.current_wave>=Global.max_waves:
		info_label.text="Destroy All Goblin Houses To Complete The Level "
		timer_label.text="All Waves Completed"

#Timer UI
	var remaining:float=Global.wave_interval-Global.wave_timer
	var minutes:int=int(remaining/60)
	var seconds:int=int(remaining)%60
	timer_label.text="%02d:%02d"%[minutes,seconds]

#Game over
	if Global.game_over:
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
		fight_theme_music.volume_db=-80
	else:
		music.volume_db=-5
		fight_theme_music.volume_db=-5

var scene=preload("res://Menus/Main menu.tscn")

func _on_quit_button_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_packed(scene)

func _on_setting_button_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_packed(scene)

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
	Global.save_game()
	timer_label.text="Task Completed"
	info_label.text="Congratulations.You can press 'Next' to advance or collect more resources for next level. "
	next_level.show()
	
#Create a system which allow the player to collect extra resources only for 2 minutes
	await get_tree().create_timer(0.5).timeout
	go_to_next_level()

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
