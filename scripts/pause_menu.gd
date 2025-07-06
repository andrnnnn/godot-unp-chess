# di res://scripts/pause_menu.gd

extends CanvasLayer

signal resume_pressed
signal quit_to_menu_pressed

@onready var resume_button = $ColorRect/VBoxContainer/ButtonContainer/ResumeButton
@onready var quit_button = $ColorRect/VBoxContainer/ButtonContainer/QuitButton

func _ready():
	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_to_menu_pressed)
	hide()

func _on_resume_pressed():
	emit_signal("resume_pressed")

func _on_quit_to_menu_pressed():
	emit_signal("quit_to_menu_pressed")

func toggle(is_paused: bool):
	visible = is_paused
