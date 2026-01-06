extends CharacterBody2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var jump_sound: AudioStreamPlayer2D = $jumpSound
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_bottom: RayCast2D = $RayCastBottom


const SPEED = 300.0
const JUMP_VELOCITY = -850.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
#		velocity.y = JUMP_VELOCITY
	#	jump_sound.play()

	
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, SPEED * direction, 30)

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	

	move_and_slide()
	
	
	
	var directionStringValue = "ui_down"
	if direction == 1:
		directionStringValue = "right"
	elif direction == -1:
		directionStringValue = "left"
		
	if (ray_cast_right.is_colliding() or ray_cast_left.is_colliding() ) and ! ray_cast_bottom.is_colliding() and Input.is_action_pressed(directionStringValue):
		if velocity.y > 0:
			velocity -= get_gravity() * delta * .7
			
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			direction = direction * -1.0
			velocity.x = (SPEED + 100) * direction
			jump_sound.play()
	
	if direction == 1.0:
		sprite_2d.flip_h = false
	elif direction == -1.0:
		sprite_2d.flip_h = true
		
	
		
	
