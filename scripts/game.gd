extends Node2D

const TILE_SIZE := Global.TILE_SIZE
enum State {RUNNING, ENDED, PROMOTING}

@onready var start_sound = $StartSound
@onready var time_out_sound = $TimeOutSound
@onready var move_sound = $MoveSound
@onready var checkmate_sound = $CheckmateSound
@onready var check_notification = $CanvasLayer/CheckNotification
@onready var pause_menu = $PauseMenu
@onready var game_over_screen = $GameOverScreen

# Referensi untuk node-node timer
@onready var white_timer_display = $CanvasLayer/WhiteTimerDisplay
@onready var black_timer_display = $CanvasLayer/BlackTimerDisplay
@onready var white_timer_label = $CanvasLayer/WhiteTimerDisplay/WhiteTimerLabel
@onready var black_timer_label = $CanvasLayer/BlackTimerDisplay/BlackTimerLabel
@onready var white_timer = $WhiteTimer
@onready var black_timer = $BlackTimer

var board: Array
var selected_piece: Piece
var moves: Dictionary = {}
var round_num: int = 1
var turn := "white"
var state: State = State.RUNNING

var use_timer: bool = false
var white_time_left: int
var black_time_left: int

var is_board_flipped: bool = false
var white_timer_initial_pos: Vector2
var black_timer_initial_pos: Vector2


func _ready():
	start_sound.play()
	var values = Create.create_board(Create.DEFAULT_BOARD)
	board = values["board"]
	values["node"].name = "Pieces"
	add_child(values["node"])
	
	game_over_screen.play_again_pressed.connect(_on_play_again)
	game_over_screen.quit_pressed.connect(_on_quit_game)
	game_over_screen.hide()
	
	pause_menu.resume_pressed.connect(_on_resume_game)
	pause_menu.quit_to_menu_pressed.connect(_on_quit_to_main_menu)

	white_timer_initial_pos = white_timer_display.position
	black_timer_initial_pos = black_timer_display.position

	# Inisialisasi Timer
	if Global.player_time > 0:
		use_timer = true
		white_time_left = Global.player_time
		black_time_left = Global.player_time
		
		white_timer.timeout.connect(_on_white_timer_timeout)
		black_timer.timeout.connect(_on_black_timer_timeout)

		update_timer_label(white_timer_label, white_time_left)
		update_timer_label(black_timer_label, black_time_left)
		
	else:
		use_timer = false
		white_timer_display.hide()
		black_timer_display.hide()


func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if state == State.RUNNING:
			get_tree().paused = not get_tree().paused
			pause_menu.toggle(get_tree().paused)

	if get_tree().paused or state != State.RUNNING:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var pos := get_tile_pos()
		if moves.has(pos):
			make_move(pos)
		else:
			show_moves(pos)
		$Board.queue_redraw()
		
	if Input.is_action_just_pressed("ui_accept"):
		flip_board()


func flip_board():
	rotate(PI)
	for child in $Pieces.get_children():
		child.flip_v = not child.flip_v
		child.flip_h = child.flip_v
	var movement = Vector2.ONE * TILE_SIZE * 8
	position += -movement if position else movement

	is_board_flipped = not is_board_flipped

	if is_board_flipped:
		# Jika papan dibalik, tukar posisi timer
		white_timer_display.position = black_timer_initial_pos
		black_timer_display.position = white_timer_initial_pos
	else:
		# Jika dikembalikan, pakai posisi awal
		white_timer_display.position = white_timer_initial_pos
		black_timer_display.position = black_timer_initial_pos


func make_move(pos: Vector2i):
	move_sound.play()
	
	if use_timer:
		var current_timer = white_timer if turn == "white" else black_timer
		current_timer.stop()
	
	var move = moves[pos]
	moves.clear()
	
	move_piece(pos, selected_piece)
	round_num += 1

	if move.type == Moves.CAPTURE:
		var timer = get_tree().create_timer(Piece.MOVE_TIME)
		timer.timeout.connect(move.take_piece.queue_free)
	elif move.type == Moves.CASTLE and not is_in_check():
		var rook: Piece
		var x := pos.x
		if move.side == "long": rook = board[pos.y][0]; x += 1
		else: rook = board[pos.y][7]; x -= 1
		move_piece(Vector2i(x, pos.y), rook)
	
	if move.has("promote"):
		state = State.PROMOTING
		await selected_piece.promote_menu(pos)
		state = State.RUNNING

	turn = "black" if turn == "white" else "white"
	selected_piece = null
	
	if use_timer and state == State.RUNNING:
		# Logika ini sekarang akan memulai timer hitam setelah langkah pertama putih
		var next_timer = white_timer if turn == "white" else black_timer
		next_timer.start(1)

	if no_legal_moves():
		state = State.ENDED
		if use_timer:
			white_timer.stop()
			black_timer.stop()
		if not is_in_check():
			game_over_screen.set_result_text("Stalemate!")
		else:
			checkmate_sound.play()
			game_over_screen.set_result_text(turn.capitalize() + " is Checkmated!")
		game_over_screen.show()
	elif is_in_check():
		show_check_notification()

# --- FUNGSI-FUNGSI TIMER ---

func update_timer_label(label: Label, time_in_seconds: int):
	var minutes = time_in_seconds / 60
	var seconds = time_in_seconds % 60
	label.text = "%02d:%02d" % [minutes, seconds]

func _on_white_timer_timeout():
	white_time_left -= 1
	update_timer_label(white_timer_label, white_time_left)
	if white_time_left <= 0:
		end_game_on_timeout("White")
	else:
		white_timer.start(1)

func _on_black_timer_timeout():
	black_time_left -= 1
	update_timer_label(black_timer_label, black_time_left)
	if black_time_left <= 0:
		end_game_on_timeout("Black")
	else:
		black_timer.start(1)

func end_game_on_timeout(player_who_lost: String):
	state = State.ENDED
	white_timer.stop()
	black_timer.stop()
	time_out_sound.play()
	game_over_screen.set_result_text(player_who_lost.capitalize() + " ran out of time!")
	game_over_screen.show()

# --- FUNGSI-FUNGSI LAINNYA ---

func get_tile_pos() -> Vector2i:
	var mouse_pos = get_local_mouse_position()
	var pos = (mouse_pos / TILE_SIZE).floor()
	return pos.clamp(Vector2i.ZERO, Vector2i(7, 7))

func get_legal_moves(piece: Piece) -> Dictionary:
	var piece_moves = piece.get_moves(board)
	var original_pos := piece.pos
	for move in piece_moves.keys():
		var take_piece: Piece = null
		if piece_moves[move].type == Moves.CAPTURE:
			take_piece = piece_moves[move].take_piece
			board[take_piece.pos.y][take_piece.pos.x] = null
		board[piece.pos.y][piece.pos.x] = null
		board[move.y][move.x] = piece
		piece.pos = move
		if is_in_check(): piece_moves.erase(move)
		piece.pos = original_pos
		board[move.y][move.x] = null
		board[piece.pos.y][piece.pos.x] = piece
		if take_piece:
			board[take_piece.pos.y][take_piece.pos.x] = take_piece
	return piece_moves

func no_legal_moves() -> bool:
	for row in board:
		for piece in row:
			if !piece or piece.team != turn:
				continue
			if get_legal_moves(piece).size():
				return false
	return true

func is_in_check() -> bool:
	for row in board:
		for piece in row:
			if !piece or piece.team == turn:
				continue
			var piece_moves: Dictionary = piece.get_moves(board)
			for move in piece_moves.values():
				if move.type != Moves.CAPTURE: continue
				if move.take_piece.piece_id == Piece.KING: return true
	return false

func show_moves(pos: Vector2i):
	if !board[pos.y][pos.x]: return
	var piece: Piece = board[pos.y][pos.x]
	if piece.team != turn: return
	if selected_piece == piece:
		moves.clear()
		selected_piece = null
		return
	moves = get_legal_moves(piece)
	selected_piece = piece

func show_check_notification():
	check_notification.modulate.a = 1.0
	check_notification.visible = true
	var tween = create_tween()
	tween.tween_property(check_notification, "modulate:a", 0.0, 0.5).set_delay(1.0)

func move_piece(pos: Vector2i, piece: Piece):
	board[piece.pos.y][piece.pos.x] = null
	board[pos.y][pos.x] = piece
	piece.last_move_round = round_num
	piece.pos = pos
	piece.move_animation(pos)

func _on_play_again():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_game():
	get_tree().quit()

func _on_resume_game():
	get_tree().paused = false
	pause_menu.toggle(false)

func _on_quit_to_main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
