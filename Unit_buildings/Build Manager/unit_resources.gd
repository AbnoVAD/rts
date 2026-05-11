extends Panel

#------------------------------------------
#Labels
#------------------------------------------
@onready var label_gold: Label = $"Gold Icon/Label Gold"
@onready var label_meat: Label = $"Meat Icon/Label Meat"
@onready var label_wood: Label = $"Wood Icon/Label Wood"


func _process(delta: float) -> void:
	update_labels()
	check_resources()
	if delta:
		pass

func update_labels():
	label_gold.text=" : "+str(Global.gold)
	label_meat.text=" : "+str(Global.meat)
	label_wood.text=" : "+str(Global.wood)

func check_resources():
	check_resource(
		label_gold,
		Global.gold,
		Global.max_gold
	)
	check_resource(
		label_meat,
		Global.meat,
		Global.max_meat
	)
	check_resource(
		label_wood,
		Global.wood,
		Global.max_wood
	)
func check_resource(label:Label,value:int,max_value:int):
	
#normal state color
	label.add_theme_color_override("font_color",Color.WHITE)
	label.add_theme_color_override("font_outline_color",Color.BLACK)

#for min resources
	if value<=0:
		label.add_theme_color_override("font_color",Color.RED)
		label.add_theme_color_override("font_outline_color",Color.BLACK)

#for max resources
	if value>=max_value:
		label.add_theme_color_override("font_color",Color.GREEN)
		label.add_theme_color_override("font_outline_color",Color.BLACK)

func flash_label_red(label:Label):
	var tween:=create_tween()
	
	tween.set_loops(3)
	
	tween.tween_property(
		label,
		"theme_override_colors/font_color",
		Color.RED,
		0.1
	)

	tween.tween_property(
		label,
		"theme_override_colors/font_color",
		Color.WHITE,
		0.1
	)

func _scale_bump(node)->void:
	var tween=create_tween()
	var original=node.scale
	
	tween.tween_property(node,"scale",original*3.5,0.08)
	tween.tween_property(node,"scale",original,0.12)
