extends RigidBody2D

const NUMBER_OF_PIECES = 6

func _ready():
	randomize()

	if randi() % 2:
		$Sprite.texture = preload("res://assets/black.png")
	
	$Sprite.frame = randi() % NUMBER_OF_PIECES
	
	var torque_direction = [1, -1][randi() % 2]
	var torque = randf_range(1, 2) * 100
	
	apply_torque(torque * torque_direction)

func delete_if_not_visible():
	# DIUBAH: Bidak akan dihapus jika posisinya sudah melewati bagian bawah layar (1080px)
	if position.y > 1100:
		queue_free()
