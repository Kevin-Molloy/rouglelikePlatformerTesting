extends PlayerState

@onready var jump_sound: AudioStreamPlayer2D = owner.get_node("jumpSound")

var SPEED
var MAX_CAPE_SPEED


func enter(previous_state_path: String, data := {}) -> void:
	#print("Cape-ing")
	SPEED = player.SPEED
	MAX_CAPE_SPEED = player.MAX_CAPE_SPEED
	
	player.velocity.y = MAX_CAPE_SPEED

	
func physics_update(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	if direction:
		player.velocity.x = move_toward(player.velocity. x, SPEED * direction, 30)
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, SPEED)

	var directionAsString := "right" if direction > 0 else "left"

	player.move_and_slide()
	
	if player.is_on_floor():
		if is_equal_approx(direction, 0.0):
			finished.emit(IDLE)
		else:
			finished. emit(RUNNING)
	elif player.isSlidable(directionAsString):
		finished.emit(SLIDING)
	elif Input.is_action_just_pressed("dash") and player.canDash and player.hasUnlockedDash:
		finished.emit(DASHING)
	elif Input.is_action_just_released("jump"):
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("down") and player.canGroundPound and player.hasUnlockedGroundPound:
		finished.emit(GROUNDPOUNDING)
