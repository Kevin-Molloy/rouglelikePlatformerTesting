extends PlayerState
@export var SPEED = 300.0
#func enter(previous_state_path: String, data := {}) -> void:
	#player.animation_player.play("run")

func physics_update(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	if direction:
		player.velocity.x = move_toward(player.velocity.x, SPEED * direction, 30)

	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
	

	player.move_and_slide()

	if not player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("jump"):
		finished.emit(JUMPING)
	elif is_equal_approx(direction, 0.0):
		finished.emit(IDLE)
