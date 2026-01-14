extends PlayerState

@onready var jump_sound: AudioStreamPlayer2D = owner.get_node("jumpSound")

var SPEED
var JUMP_VELOCITY
var SLIDE_GRAVITY_MULTIPLIER
var MAX_SLIDE_SPEED
var COYOTE_TIME

var coyote_timer: float = 0.0
var wall_side: String = "" 

func enter(previous_state_path: String, data := {}) -> void:
	SPEED = player.SPEED
	JUMP_VELOCITY = player.JUMP_VELOCITY
	SLIDE_GRAVITY_MULTIPLIER = player.SLIDE_GRAVITY_MULTIPLIER
	MAX_SLIDE_SPEED = player.MAX_SLIDE_SPEED
	COYOTE_TIME = player.COYOTE_TIME

	if player.dash_cooldown_timer == 0:
		player.canDash = true
	player.canDoubleJump = true
	
	if player.ray_cast_right. is_colliding():
		wall_side = "right"
	elif player.ray_cast_left. is_colliding():
		wall_side = "left"
	
	coyote_timer = COYOTE_TIME 

func physics_update(delta: float) -> void:
	if player.velocity.y > 0:
		player. velocity.y += 2500.0 * delta * SLIDE_GRAVITY_MULTIPLIER
		player.velocity.y = min(player.velocity.y, MAX_SLIDE_SPEED)
	else:
		player.velocity. y += 2500.0 * delta
	
	player. move_and_slide()
	
	var direction := Input.get_axis("left", "right")
	var directionAsString := "right" if direction > 0 else "left"
	
	var on_wall:  bool = (player.ray_cast_right.is_colliding() or player.ray_cast_left.is_colliding()) and not player.ray_cast_bottom. is_colliding()
	var pressing_toward_wall: bool = Input.is_action_pressed(wall_side)  # ← Check the wall side, not input direction
	var pressing_away_from_wall: bool = (wall_side == "right" and direction < 0) or (wall_side == "left" and direction > 0)
	
	if not pressing_toward_wall or pressing_away_from_wall: 
		coyote_timer -= delta
	else:
		coyote_timer = COYOTE_TIME 
	if Input.is_action_just_pressed("jump"):
		finished.emit(WALLJUMPING)
	elif player.is_on_floor():
		if is_equal_approx(direction, 0.0):
			finished.emit(IDLE)
		else:
			finished.emit(RUNNING)
	elif not on_wall or coyote_timer <= 0.0:
		finished.emit(FALLING)
