extends PlayerState

@onready var jump_sound: AudioStreamPlayer2D =  $"../../doubleJumpSound"

var SPEED 
var JUMP_VELOCITY
var DOUBLE_JUMP_VELOCITY 
var JUMP_CUT_MULTIPLIER 

func enter(previous_state_path: String, data := {}) -> void:
	#print("Double Jumping")
	SPEED = player.SPEED
	JUMP_VELOCITY = player.JUMP_VELOCITY
	DOUBLE_JUMP_VELOCITY = player.DOUBLE_JUMP_VELOCITY
	JUMP_CUT_MULTIPLIER = player.JUMP_CUT_MULTIPLIER
	player.velocity.y = DOUBLE_JUMP_VELOCITY
	jump_sound.play()

func physics_update(delta: float) -> void:
	if player.canSpringJump and player.hasUnlockedSpringJump:
		player.velocity.y += 2500.0 * delta -15
	else:
		player.velocity.y += 2500.0 * delta

	

	var direction := Input.get_axis("left", "right")
	if direction:
		player.velocity.x = move_toward(player.velocity. x, SPEED * direction, 30)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, SPEED)
	
	player.move_and_slide()
	
	if Input.is_action_just_pressed("dash") and player.canDash :
		finished.emit(DASHING)
		return
	

	if Input.is_action_just_released("jump") and player.velocity.y < 0:
		player.velocity.y *= JUMP_CUT_MULTIPLIER  
		finished.emit(FALLING)
	elif player.velocity. y >= 0.0:
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("down") and player.canGroundPound and player.hasUnlockedGroundPound:
		finished.emit(GROUNDPOUNDING)
