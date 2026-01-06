
extends PlayerState

@onready var jump_sound: AudioStreamPlayer2D = $jumpSound

@export var SPEED = 300.0
@export var JUMP_VELOCITY = 850.0

	player.velocity.y = JUMP_VELOCITY

jump_sound.play()

	
move_and_slide()
