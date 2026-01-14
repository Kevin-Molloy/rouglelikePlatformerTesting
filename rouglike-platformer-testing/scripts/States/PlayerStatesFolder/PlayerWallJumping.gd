extends PlayerState
@onready var jump_sound: AudioStreamPlayer2D = $"../../wallJumpSound"


var SPEED
var JUMP_VELOCITY
var WALL_JUMP_HORIZONTAL_BOOST
var WALL_JUMP_INPUT_LOCK_TIME

var wall_jump_direction: float = 0.0
var input_lock_timer: float = 0.0

func enter(previous_state_path: String, data := {}) -> void:
	SPEED = player.SPEED
	JUMP_VELOCITY = player.JUMP_VELOCITY
	WALL_JUMP_HORIZONTAL_BOOST = player.WALL_JUMP_HORIZONTAL_BOOST
	WALL_JUMP_INPUT_LOCK_TIME = player.WALL_JUMP_INPUT_LOCK_TIME
	
	var wall_on_right = player.ray_cast_right. is_colliding()
	var wall_on_left = player. ray_cast_left.is_colliding()
	
	if wall_on_right: 
		wall_jump_direction = -1.0
	elif wall_on_left:
		wall_jump_direction = 1.0
	else:
		var input_direction := Input.get_axis("left", "right")
		wall_jump_direction = -sign(input_direction) if input_direction != 0 else 1.0
	
	player.velocity.y = JUMP_VELOCITY
	player.velocity.x = wall_jump_direction * (SPEED + WALL_JUMP_HORIZONTAL_BOOST)
	
	input_lock_timer = WALL_JUMP_INPUT_LOCK_TIME
	
	jump_sound.play()
	print("Wall jump direction: ", wall_jump_direction)

func physics_update(delta: float) -> void:
	player.velocity.y += 2500.0 * delta
	
	if input_lock_timer > 0:
		input_lock_timer -= delta
	
	var direction := Input.get_axis("left", "right")
	if input_lock_timer <= 0 and direction != 0:
		player.velocity.x = move_toward(player. velocity.x, SPEED * direction, 30)
	
	player.move_and_slide()
	
	if Input.is_action_just_pressed("dash") and player.canDash and player.hasUnlockedDash:
		finished.emit(DASHING)
	elif player.velocity.y >= 0:
		finished.emit(FALLING)
	elif player.canDoubleJump and player.hasUnlockedDoubleJump and Input.is_action_just_pressed("jump"):
		player.canDoubleJump = false
		finished.emit(DOUBLEJUMPING)
