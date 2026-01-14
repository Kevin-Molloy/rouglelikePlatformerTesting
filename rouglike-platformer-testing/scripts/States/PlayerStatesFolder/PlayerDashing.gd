extends PlayerState

@onready var jump_sound: AudioStreamPlayer2D = owner.get_node("jumpSound")

var DASHBOOST
var SPEED 
var DASH_DURATION
var DASH_COOLDOWN

var dash_direction: float = 0.0
var dash_timer: float = 0.0

func enter(previous_state_path: String, data := {}) -> void:
	#print("Dashing - Cooldown started")
	DASHBOOST = player.DASHBOOST
	SPEED = player.SPEED
	DASH_DURATION = player.DASH_DURATION
	DASH_COOLDOWN = player.DASH_COOLDOWN
	
	# Set cooldown IMMEDIATELY
	player.canDash = false
	player.dash_cooldown_timer = DASH_COOLDOWN
	
	player.velocity.y = 0
	# Get dash direction
	dash_direction = Input.get_axis("left", "right")
	
	if dash_direction == 0.0:
		dash_direction = 1.0 if not player.get_node("Sprite2D").flip_h else -1.0
	
	# Apply dash boost (keep vertical momentum)
	player.velocity.x = DASHBOOST * dash_direction
	
	dash_timer = DASH_DURATION
	jump_sound.play()

func physics_update(delta:  float) -> void:
	dash_timer -= delta
	
	
	if dash_timer > 0:
		player.velocity.x = move_toward(player.velocity.x, DASHBOOST * dash_direction, 50)
	else:
		var current_direction := Input.get_axis("left", "right")
		if current_direction != 0:
			player.velocity.x = move_toward(player.velocity.x, SPEED * current_direction, 30)
		else:
			player.velocity.x = move_toward(player.velocity.x, 0.0, SPEED)
	
		
	
	player.move_and_slide()
	
	var current_direction := Input. get_axis("left", "right")
	var directionAsString := "right" if current_direction > 0 else "left"
	if  Input.is_action_just_pressed("jump"):
		
		if player.hasUnlockedDoubleJump and player.canDoubleJump and !player.is_on_floor():
			player.canDoubleJump = false
			finished.emit(DOUBLEJUMPING)
		else:
			finished.emit(JUMPING)
	elif dash_timer <= 0:
		if not player.is_on_floor():
			if  player.isSlidable(directionAsString):
				finished.emit(SLIDING)
			else:
				finished.emit(FALLING)
		elif is_equal_approx(current_direction, 0.0):
			finished.emit(IDLE)
		else:
			finished.emit(RUNNING)
