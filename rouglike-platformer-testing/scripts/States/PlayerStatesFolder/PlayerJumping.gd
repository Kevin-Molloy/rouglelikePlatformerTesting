extends PlayerState

@onready var jump_sound:  AudioStreamPlayer2D = owner. get_node("jumpSound")

var SPEED 
var JUMP_VELOCITY
var JUMP_CUT_MULTIPLIER
var COYOTE_TIME
var JUMP_BUFFER_TIME

var coyote_timer: float = 0.0

func enter(previous_state_path: String, data := {}) -> void:
	
	SPEED = player.SPEED
	JUMP_VELOCITY = player.JUMP_VELOCITY
	JUMP_CUT_MULTIPLIER = player.JUMP_CUT_MULTIPLIER
	COYOTE_TIME = player.COYOTE_TIME
	JUMP_BUFFER_TIME = player.JUMP_BUFFER_TIME
	
	player.velocity.y = JUMP_VELOCITY  
	
	coyote_timer = COYOTE_TIME
	
	jump_sound.play()

func physics_update(delta:  float) -> void:
	if player.canSpringJump and player.hasUnlockedSpringJump: 
		player.velocity.y += 2500.0 * delta - 15
		jump_sound = $"../../springJumpSound"
	else:
		player.velocity.y += 2500.0 * delta
	
	var direction := Input.get_axis("left", "right")
	if direction:
		player.velocity. x = move_toward(player. velocity.x, SPEED * direction, 30)
	else:
		player.velocity.x = move_toward(player.velocity. x, 0.0, SPEED)
	
	player.move_and_slide()
	
	coyote_timer -= delta
	
	if Input.is_action_just_pressed("dash") and player.canDash and player.hasUnlockedDash:
		finished.emit(DASHING)
		return
	if Input.is_action_just_pressed("down") and player.canGroundPound and player.hasUnlockedGroundPound:
		finished.emit(GROUNDPOUNDING)
		return
	if Input.is_action_just_released("jump") and player.velocity.y < 0:
		player.velocity.y *= JUMP_CUT_MULTIPLIER  
		finished.emit(FALLING)
	elif player.velocity.y >= 0.0:
		finished.emit(FALLING)
