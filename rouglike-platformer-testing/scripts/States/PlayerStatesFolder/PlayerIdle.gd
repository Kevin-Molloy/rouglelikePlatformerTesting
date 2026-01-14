extends PlayerState

var JUMP_BUFFER_TIME 

var jump_buffer_timer: float = 0.0

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.x = 0.0
	JUMP_BUFFER_TIME = player.JUMP_BUFFER_TIME
	
	if player. dash_cooldown_timer == 0:
		player.canDash = true
	player.canDoubleJump = true

func physics_update(delta: float) -> void:
	player.velocity.y += 2500.0 * delta
	player.move_and_slide()
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	var jump_attempt = Input.is_action_just_pressed("jump") or jump_buffer_timer > 0
	
	if not player.is_on_floor() and !(player.ray_cast_right.is_colliding() or player.ray_cast_left. is_colliding()):
		finished.emit(FALLING)
	elif Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		finished.emit(RUNNING)
	elif Input.is_action_pressed("down"):
		var tile_type = player.check_ground_tile_type()
		if tile_type == "PLATFORM" and Input.is_action_just_pressed("jump"):
			player.position.y += 20
			finished.emit(FALLING)
	elif jump_attempt and player.is_on_floor():
		jump_buffer_timer = 0.0  
		finished.emit(JUMPING)
	elif Input.is_action_just_pressed("dash") and player.canDash and player.hasUnlockedDash:
		finished.emit(DASHING)
