extends AnimatedSprite2D

var image_black=preload("res://assets/Tiny Swords (Free Pack)/Buildings/Black Buildings/House1.png")
var image_blue=preload("res://assets/Tiny Swords (Free Pack)/Buildings/Blue Buildings/House1.png")
var image_red=preload("res://assets/Tiny Swords (Free Pack)/Buildings/Red Buildings/House1.png")
var image_purple=preload("res://assets/Tiny Swords (Free Pack)/Buildings/Purple Buildings/House1.png")
var image_yellow=preload("res://assets/Tiny Swords (Free Pack)/Buildings/Yellow Buildings/House1.png")

func _ready() -> void:
	Global.load_colour()
	match Global.choosed_colour:
		"black":
			sprite_frames.clear("idle")
			sprite_frames.add_frame("idle",image_black)
		"blue":
			sprite_frames.clear("idle")
			sprite_frames.add_frame("idle",image_blue)
		"red":
			sprite_frames.clear("idle")
			sprite_frames.add_frame("idle",image_red)
		"purple":
			sprite_frames.clear("idle")
			sprite_frames.add_frame("idle",image_purple)
		"yellow":
			sprite_frames.clear("idle")
			sprite_frames.add_frame("idle",image_yellow)
