# Nama file: main_menu.gd

extends Control

const FallingPiece := preload("res://scenes/falling_piece.tscn")

var piece_scale: int

@onready var menu_music = $MenuMusic
# 1. Tambahkan referensi ke node pop-up yang sudah di-instance di scene
@onready var time_selection_popup = $TimeSelectionPopup


func _ready():
	set_window()
	randomize_background()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	menu_music.play()
	
	# 2. Hubungkan sinyal dari pop-up ke fungsi di skrip ini
	time_selection_popup.time_selected.connect(_on_time_selected)


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		_on_play_pressed()
	elif event.is_action_pressed("change_bg"):
		randomize_background()
	elif event.is_action_pressed("ui_cancel"):
		_on_exit_pressed()

# --- FUNGSI-FUNGSI YANG TIDAK BERUBAH ---

func set_window():
	var screen_size = DisplayServer.screen_get_size()
	var lowest_dimension = screen_size[screen_size.min_axis_index()]
	get_window().size = Vector2i.ONE * lowest_dimension * 0.75
	DisplayServer.window_set_position(
		DisplayServer.screen_get_position() +
		(DisplayServer.screen_get_size() - DisplayServer.window_get_size())/2
	)

func randomize_background():
	randomize()
	$Background/Ground.collision_layer = randi() % 2 + 1
	piece_scale = randi() % 2 + 1
	$Background/AddPieceTimer.wait_time = 0.25 if piece_scale == 2 else 0.1

func add_falling_piece():
	var spawn_width = 1080
	get_tree().call_group("falling_pieces", "delete_if_not_visible")
	var piece := FallingPiece.instantiate()
	piece.add_to_group("falling_pieces")
	piece.get_node("CollisionShape").shape.radius *= piece_scale
	piece.get_node("Sprite").scale *= piece_scale
	piece.position.x = randi_range(0, spawn_width)
	piece.position.y = -2 * Global.TILE_SIZE * piece_scale
	$Background.add_child(piece)

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/credits_screen.tscn")

func _on_exit_pressed():
	get_tree().quit()

# --- FUNGSI-FUNGSI YANG DIUBAH / BARU ---

# 3. Fungsi ini sekarang menampilkan pop-up, bukan langsung main
func _on_play_pressed():
	time_selection_popup.show_popup()


# 4. Fungsi baru ini akan berjalan setelah pemain memilih waktu dan menekan "Start" di pop-up
func _on_time_selected(total_seconds: int):
	# Simpan waktu yang dipilih ke skrip Global agar bisa diakses dari mana saja
	Global.player_time = total_seconds
	
	# Setelah waktu disimpan, baru pindah ke scene permainan
	get_tree().change_scene_to_file("res://scenes/game.tscn")
