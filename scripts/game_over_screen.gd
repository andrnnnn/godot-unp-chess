extends CanvasLayer

# Sinyal yang akan dikirim ke scene game utama
signal play_again_pressed
signal quit_pressed

# Referensi ke node-node di dalam scene ini
@onready var result_message_label = $ColorRect/VBoxContainer/ResultMessage
@onready var play_again_button = $ColorRect/VBoxContainer/HBoxContainer/PlayAgainButton
@onready var quit_button = $ColorRect/VBoxContainer/HBoxContainer/QuitButton

func _ready():
	# Hubungkan sinyal 'pressed' dari setiap tombol ke fungsi di skrip ini
	play_again_button.pressed.connect(_on_play_again_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

# Fungsi publik yang bisa dipanggil dari luar (oleh game.gd) untuk mengubah teks
func set_result_text(text: String):
	result_message_label.text = text

# Saat tombol 'Play Again' ditekan, skrip ini akan memancarkan sinyalnya sendiri
func _on_play_again_button_pressed():
	emit_signal("play_again_pressed")

# Saat tombol 'Quit' ditekan, skrip ini akan memancarkan sinyalnya sendiri
func _on_quit_button_pressed():
	emit_signal("quit_pressed")
