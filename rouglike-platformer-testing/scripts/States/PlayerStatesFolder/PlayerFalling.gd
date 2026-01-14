extends PlayerState

var SPEED
var COYOTE_TIME
var JUMP_BUFFER_TIME

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

func enter(previous_state_path: String, data := {}) -> void:
	
	SPEED = player.SPEED
	COYOTE_TIME = player.COYOTE_TIME
	JUMP_BUFFER_TIME = player.JUMP_BUFFER_TIME
	
	if previous_state_path in ["PlayerRunning", "PlayerIdle"]:
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = 0.0
	
	if player.dash_cooldown_timer == 0:
		player.canDash = true

func physics_update(delta:  float) -> void:
	player.velocity.y += 2500.0 * delta
	
	var direction := Input.get_axis("left", "right")
	if direction:
		player. velocity. x = move_toward(player. velocity.x, SPEED * direction, 30)
	else:
		player.velocity.x = move_toward(player.velocity. x, 0.0, SPEED)
	
	player.move_and_slide()
	
	if coyote_timer > 0:
		coyote_timer -= delta
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	
	var directionAsString := "right" if direction > 0 else "left"
	var platCheck = player.check_direction_tile_type() == "PLATFORM"
	
	var jump_attempt = Input. is_action_just_pressed("jump") or jump_buffer_timer > 0
	
	if player.is_on_floor():
		if jump_attempt: 
			jump_buffer_timer = 0.0
			finished.emit(JUMPING)
		elif is_equal_approx(direction, 0.0):
			finished.emit(IDLE)
		else:
			finished.emit(RUNNING)
	elif player.isSlidable(directionAsString):
		if platCheck:
			finished.emit(FALLING)
		else:
			finished.emit(SLIDING)
	elif jump_attempt and coyote_timer > 0:
		coyote_timer = 0.0  
		jump_buffer_timer = 0.0
		finished.emit(JUMPING)
	elif player.canDoubleJump and player.hasUnlockedDoubleJump and Input.is_action_just_pressed("jump"):
		player.canDoubleJump = false
		finished.emit(DOUBLEJUMPING)
	elif (Input.is_action_just_pressed("jump") or Input.is_action_pressed("jump")) and player.canCape and player.hasUnlockedCape:
		finished. emit(CAPE)
	elif Input.is_action_just_pressed("dash") and player.canDash and player.hasUnlockedDash:
		finished.emit(DASHING)
	elif Input.is_action_just_pressed("down") and player.canGroundPound and player.hasUnlockedGroundPound:
		finished.emit(GROUNDPOUNDING)
