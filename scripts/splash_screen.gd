extends Control

#-----------------------------------------------------------------------------
# PENGATURAN YANG BISA DIUBAH DARI INSPECTOR
#-----------------------------------------------------------------------------

## Durasi transisi fade-in dan fade-out (dalam detik).
@export var transition_duration: float = 0.75

## Durasi logo ditampilkan setelah fade-in selesai (dalam detik).
@export var hold_duration: float = 2.5 
# Total durasi per logo = (2 * transition_duration) + hold_duration
# Contoh: (2 * 0.75) + 2.5 = 1.5 + 2.5 = 4.0 detik. Sesuai permintaan.

## Path ke scene menu utama Anda.
@export var main_menu_scene: String = "res://scenes/main_menu.tscn"

#-----------------------------------------------------------------------------
# REFERENSI NODE
#-----------------------------------------------------------------------------

@onready var logo_unp: Control = $Screen1_Logos/LogoUNP
@onready var logo_fakultas: Control = $Screen1_Logos/LogoFakultas
@onready var logo_prodi: Control = $Screen1_Logos/LogoProdi
@onready var screen2_kelompok: Control = $Screen2_Kelompok
@onready var screen3_judul: Control = $Screen3_Judul

var can_press_any_key: bool = false

#-----------------------------------------------------------------------------
# FUNGSI BAWAAN GODOT
#-----------------------------------------------------------------------------

func _ready() -> void:
	set_window()
	start_splash_sequence()

func _unhandled_input(event: InputEvent) -> void:
	if can_press_any_key and event.is_pressed():
		set_process_unhandled_input(false)
		get_tree().change_scene_to_file(main_menu_scene)

#-----------------------------------------------------------------------------
# FUNGSI KUSTOM
#-----------------------------------------------------------------------------

func set_window() -> void:
	var screen_size = DisplayServer.screen_get_size()
	var lowest_dimension = screen_size[screen_size.min_axis_index()]
	get_window().size = Vector2i.ONE * lowest_dimension * 0.75
	DisplayServer.window_set_position(
		DisplayServer.screen_get_position() +
		(DisplayServer.screen_get_size() - DisplayServer.window_get_size()) / 2
	)

## Menjalankan seluruh urutan splash screen dengan efek transisi.
func start_splash_sequence() -> void:
	# Pastikan semua disembunyikan di awal
	logo_unp.hide()
	logo_fakultas.hide()
	logo_prodi.hide()
	screen2_kelompok.hide()
	screen3_judul.hide()
	
	# Mainkan transisi untuk setiap elemen secara berurutan
	await play_fade_transition(logo_unp)
	await play_fade_transition(logo_fakultas)
	await play_fade_transition(logo_prodi)
	await play_fade_transition(screen2_kelompok)
	
	# Untuk layar judul, kita hanya butuh fade-in dan berhenti.
	screen3_judul.modulate.a = 0.0 # Mulai dari transparan
	screen3_judul.show()
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(screen3_judul, "modulate:a", 1.0, transition_duration)
	await tween.finished
	
	can_press_any_key = true

## Fungsi helper untuk memainkan transisi fade-in, hold, dan fade-out pada sebuah node.
func play_fade_transition(target_node: Control) -> void:
	# --- FADE IN ---
	# Atur node agar transparan lalu tampilkan
	target_node.modulate.a = 0.0
	target_node.show()
	
	# Buat tween untuk menganimasikan properti 'modulate:a' (alpha/transparansi)
	var tween_in = create_tween().set_trans(Tween.TRANS_SINE) # set_trans untuk efek lebih halus
	tween_in.tween_property(target_node, "modulate:a", 1.0, transition_duration)
	await tween_in.finished # Tunggu sampai fade-in selesai

	# --- HOLD ---
	# Tunggu selama durasi yang ditentukan
	await get_tree().create_timer(hold_duration).timeout

	# --- FADE OUT ---
	# Buat tween baru untuk fade-out
	var tween_out = create_tween().set_trans(Tween.TRANS_SINE)
	tween_out.tween_property(target_node, "modulate:a", 0.0, transition_duration)
	await tween_out.finished # Tunggu sampai fade-out selesai
	
	target_node.hide() # Sembunyikan node setelah transisi selesai
