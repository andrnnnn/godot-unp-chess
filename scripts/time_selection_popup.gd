extends CanvasLayer

signal time_selected(total_seconds: int)

# Path node untuk semua tombol pilihan
@onready var bullet_button = $PanelContainer/VBoxContainer/ButtonContainer/BulletButton
@onready var blitz_button = $PanelContainer/VBoxContainer/ButtonContainer/BlitzButton
@onready var rapid_button = $PanelContainer/VBoxContainer/ButtonContainer/RapidButton
@onready var classical_button = $PanelContainer/VBoxContainer/ButtonContainer/ClassicalButton
@onready var no_time_button = $PanelContainer/VBoxContainer/ButtonContainer/NoTimeButton
@onready var back_button = $PanelContainer/VBoxContainer/BackButton

const TIME_OPTIONS = {
	"bullet": 60,      # 1 menit
	"blitz": 180,      # 3 menit
	"rapid": 600,      # 10 menit
	"classical": 1800  # 30 menit
}

func _ready():
	# Sembunyikan pop-up ini secara default
	hide()
	
	# Hubungkan semua tombol ke fungsinya masing-masing
	bullet_button.pressed.connect(_on_time_button_pressed.bind("bullet"))
	blitz_button.pressed.connect(_on_time_button_pressed.bind("blitz"))
	rapid_button.pressed.connect(_on_time_button_pressed.bind("rapid"))
	classical_button.pressed.connect(_on_time_button_pressed.bind("classical"))
	no_time_button.pressed.connect(_on_no_time_button_pressed)
	# Hubungkan sinyal pressed dari tombol kembali ke fungsinya
	back_button.pressed.connect(_on_back_button_pressed)

# Fungsi untuk menampilkan pop-up dari luar (misal: main_menu.gd)
func show_popup():
	show()

# Fungsi ini dipanggil untuk SEMUA tombol mode waktu (kecuali "Tanpa Waktu")
func _on_time_button_pressed(mode: String):
	# Ambil nilai waktu dari dictionary
	var total_seconds = TIME_OPTIONS[mode]
	
	# Kirim sinyal dan sembunyikan pop-up
	emit_signal("time_selected", total_seconds)
	hide()

# Fungsi khusus untuk tombol "Tanpa Waktu"
func _on_no_time_button_pressed():
	# Kirim sinyal dengan nilai 0 untuk menandakan tidak ada timer
	emit_signal("time_selected", 0)
	hide()

# Fungsi baru khusus untuk tombol "Kembali"
func _on_back_button_pressed():
	# Cukup sembunyikan popup tanpa melakukan apa-apa
	hide()
