class_name PlayerState extends State


const IDLE = "Idle"
const RUNNING = "Running"
const JUMPING = "Jumping"
const FALLING = "Falling"

#Abilities, will increment ability counter
const SLIDING = "Sliding"
const WALLJUMPING = "WallJumping"			#Mantis Claw, both in 1 collectible
const DASHING = "Dashing"
const DOUBLEJUMPING = "DoubleJumping"
const CAPE = "Cape"							#Slow Decent
const GROUNDPOUNDING = "GroundPounding"		#Springs, to go through certain platforms

#const SPRINGJUMP = "SpringJump"				#High Jump NOT A STATE


const GRAPPLING = "Grappling"				#Hookshot, on the fence abt this one
const CLIMBING = "Climbing"					#Grates, Vines
const HOVERING = "Hovering"					#Jump and hold, or repress a canclelled jump, hoverpack from spelunky, tbd
#crystal dash

#Interactions with Enviorment, may not increment ability counter, seems more explorational 
const POWERGLOVE = "PowerGlove"				#Power Glove Zelda
const FLIPPERS = "Flippers"					#Unsure how to implement swimming to parkour but
const ICESKATES = "IceSkates"				#Cancels ice physics LASTS 4 ROOMS
const AVIATORHELM = "AviatorHelm"			#Cancels Wind		 LASTS 4 ROOMS
const HEATSUIT = "HeatSuit"					#Take 1 damage from lava/fire based hazards	LASTS 4 ROOMS	ALSO 4 health total, potential health increases

#NEXT, Health/Damage System + Hazards

#Bouncy Platforms, Slippery Platforms, Donut Blocks, Hazards, Wind, Fog
#stats, weakened versions of jump, wall jump, dash, double jump, wall jump
#healing
#challenge rooms, speed completion

#challenge rooms for other rewards

var player: CharacterBody2D


func _ready() -> void:
	await owner.ready
	player = owner as CharacterBody2D
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")
