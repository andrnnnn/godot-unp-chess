extends Control

# Deklarasikan variabel kosong terlebih dahulu
var screen1: Control
var screen2: Control
var screen3: Control

# Fungsi _ready akan berjalan otomatis saat scene dimulai
func _ready() -> void:
	# PANGGIL FUNGSI UNTUK MENGATUR UKURAN JENDELA DI SINI
	set_window()

	# Cari dan tetapkan referensi node di dalam _ready()
	screen1 = $Screen1_UNP
	screen2 = $Screen2_Kelompok
	screen3 = $Screen3_Judul
	
	# Panggil fungsi untuk memulai urutan splash screen
	start_splash_sequence()

# FUNGSI BARU DARI MAIN_MENU.GD
func set_window():
	var screen_size = DisplayServer.screen_get_size()

	var lowest_dimension = screen_size[screen_size.min_axis_index()]
	get_window().size = Vector2i.ONE * lowest_dimension * 0.75

	DisplayServer.window_set_position(
		DisplayServer.screen_get_position() +
		(DisplayServer.screen_get_size() - DisplayServer.window_get_size())/2
	)

# Kita gunakan async agar bisa memakai 'await' untuk menjeda
func start_splash_sequence() -> void:
	# --- Bagian 1: Logo Universitas (4 detik) ---
	# Tunggu selama 4 detik
	await get_tree().create_timer(4.0).timeout
	
	# Sembunyikan layar 1, tampilkan layar 2
	screen1.visible = false
	screen2.visible = true
	
	# --- Bagian 2: Logo Kelompok (4 detik) ---
	# Tunggu lagi selama 4 detik
	await get_tree().create_timer(4.0).timeout
	
	# Sembunyikan layar 2, tampilkan layar 3
	screen2.visible = false
	screen3.visible = true
	
	# Urutan otomatis selesai, sekarang menunggu input pemain

# Fungsi ini akan menangani input dari pemain
func _unhandled_input(event: InputEvent) -> void:
	# Cek apakah layar 3 sedang aktif DAN ada input (keyboard/mouse) yang ditekan
	if screen3.visible and event.is_pressed():
		# Jika ya, nonaktifkan proses input agar tidak terpanggil berkali-kali
		set_process_unhandled_input(false)
		# Pindah ke scene menu utama
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
