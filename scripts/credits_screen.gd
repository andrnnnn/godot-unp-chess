extends Control

@onready var back_button = $MarginContainer/VBoxContainer/BackButton
@onready var credits_music = $CreditsMusic

func _ready():
	back_button.pressed.connect(_on_back_button_pressed)
	credits_music.play()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
