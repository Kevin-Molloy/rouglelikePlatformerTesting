extends PlayerState

@onready var jump_sound: AudioStreamPlayer2D = owner.get_node("jumpSound")

var SPEED
var MAX_GP_SPEED 
var GP_STALL

var gp_timer: float = 0.0



func enter(previous_state_path: String, data := {}) -> void:
	#print("GroundPounding")
	SPEED = player.SPEED
	MAX_GP_SPEED = player.MAX_GP_SPEED
	GP_STALL = player.GP_STALL
	
	
	player.velocity.y = 0
	gp_timer = GP_STALL
	
func physics_update(delta: float) -> void:
	
	gp_timer -= delta
	var direction := Input.get_axis("left", "right")

	
	if gp_timer > 0:
		player.velocity.y = move_toward(player.velocity.y, MAX_GP_SPEED, 100)
		if direction:
			player.velocity.x = move_toward(player.velocity.x, SPEED * direction, 30)
		else:
			player.velocity.x = move_toward(player.velocity.x, 0.0, SPEED)

	player.move_and_slide()
	
	if player.is_on_floor():
		if is_equal_approx(direction, 0.0):
			finished.emit(IDLE)
		else:
			finished. emit(RUNNING)
	elif Input.is_action_just_pressed("up"):
		finished.emit(FALLING)
	elif player.canDoubleJump and player.hasUnlockedDoubleJump and Input.is_action_just_pressed("jump"):
		player.canDoubleJump = false
		finished.emit(DOUBLEJUMPING)
