extends Panel

@onready var selector: Sprite2D = $Selector
#Buttons nodes
@onready var buttons=[
	$BuildHouse1Button,
	$BuildHouse2Button,
	$BuildHouse3Button,
	$BuildTowerButton,
	$BuildBarrackButton,
	$BuildMonasteryButton,
	$BuildArcheryButton
]

#Marker nodes
@onready var markers=[
	$BuildHouse1Button/Marker2D, 
	$BuildHouse2Button/Marker2D, 
	$BuildHouse3Button/Marker2D, 
	$BuildTowerButton/Marker2D, 
	$BuildBarrackButton/Marker2D, 
	$BuildMonasteryButton/Marker2D, 
	$BuildArcheryButton/Marker2D
]

#Icons nodes
@onready var icons=[
	$BuildHouse1Button/animation, 
	$BuildHouse2Button/animation, 
	$BuildHouse3Button/animation, 
	$BuildTowerButton/animation, 
	$BuildBarrackButton/animation, 
	$BuildMonasteryButton/animation, 
	$BuildArcheryButton/animation
]

#Cost of production
var cost=[
	{"gold":20,"wood":30},
	{"gold":25,"wood":35},
	{"gold":30,"wood":40},
	{"gold":40,"wood":60},
	{"gold":35,"wood":500},
	{"gold":45,"wood":70},
	{"gold":50,"wood":80},
]

signal build_requested(building_name:String)

func _ready() -> void:
	for i in buttons.size():
		buttons[i].pressed.connect(_on_any_button_pressed.bind(i))

func _on_any_button_pressed(index:int) -> void:
	var icon=icons[index]

	if Global.gold>0 or Global.wood>0:
		if Global.gold>0 or Global.wood>0:
			var building=buttons[index].name
			Global.pawn_tool=building
			emit_signal("build_requested",building)
			
			_flash_green(icon)
		elif Global.gold<=0 or Global.wood<=0:
			_flash_red(icon)

#-------------------------------------------------
#Tweens/effects
#-------------------------------------------------
func _scale_bump(node) -> void:
	var tween=create_tween()
	var original=node.scale
	
	tween.tween_property(node,"scale",original*3.15,0.08)
	tween.tween_property(node,"scale",original,0.12)

func _flash_green(node) -> void:
	var tween=create_tween()
	var original=node.modulate
	
	tween.tween_property(node,"scale",Color.GREEN,0.15)
	tween.tween_property(node,"scale",original,0.15)
	
	await tween.finished

func _flash_red(node) -> void:
	var tween=create_tween()
	var original=node.modulate
	
	tween.tween_property(node,"scale",Color.RED,0.15)
	tween.tween_property(node,"scale",original,0.15)
	
	await tween.finished
