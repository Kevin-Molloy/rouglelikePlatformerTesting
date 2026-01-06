extends PlayerState

func physics_update(delta: float) -> void:
	player.velocity.y += 2500.0 * delta

	player.move_and_slide()

	if not player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("jump"):
		finished.emit(JUMPING)
	elif Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		finished.emit(RUNNING)

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.x = 0.0
