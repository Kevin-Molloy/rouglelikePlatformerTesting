extends CharacterBody2D

@onready var camera:  Camera2D = $Camera
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_bottom: RayCast2D = $RayCastBottom
@onready var jump_sound: AudioStreamPlayer2D = $jumpSound
@onready var tilemap: TileMapLayer = null
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var ray_cast_up: RayCast2D = $RayCastUp
@onready var hurt_box: Area2D = $HurtBox

const SPEED:  float = 220.0
const MAX_CAPE_SPEED: float = 100.0
const DASHBOOST:  float = 500.0
const DASH_DURATION: float = 0.2
const DASH_COOLDOWN: float = 0.5
const JUMP_VELOCITY: float = -600.0
const DOUBLE_JUMP_VELOCITY: float = -450
const JUMP_CUT_MULTIPLIER: float = 0.5
const COYOTE_TIME: float = 0.15  
const JUMP_BUFFER_TIME: float = 0.01
const MAX_GP_SPEED:  float = 800 
const GP_STALL: float = 0.2
const SLIDE_GRAVITY_MULTIPLIER: float = 0.3
const MAX_SLIDE_SPEED: float = 100.0
const WALL_JUMP_HORIZONTAL_BOOST: float = 20.0 
const WALL_JUMP_INPUT_LOCK_TIME: float = 0.05  
	
#Unlocks
var hasUnlockedDash = false
var hasUnlockedDoubleJump = false
var hasUnlockedWallJump = false
var hasUnlockedCape = false
var hasUnlockedGroundPound = false
var hasUnlockedSpringJump = false

# Ability availability
var canDash = false
var canDoubleJump = false
var canWallJump = false
var canCape = false
var canGroundPound = false
var canSpringJump = false

var health = 4
var spawn_point: Vector2 = Vector2.ZERO
var dash_cooldown_timer:  float = 0.0

func _ready() -> void:
	tilemap = get_parent().get_node("TileMapLayer")
	
	if not tilemap:  
		printerr("TileMap not found!")
		return
	
	print("✓ TileMap found successfully!")
	
	spawn_point = global_position
	print("World spawn:", spawn_point)

	if hurt_box:  
		print("HurtBox found")
	else:
		printerr("HurtBox not found!")

func _physics_process(delta: float) -> void:
	# Update dash cooldown
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0.0:
			canDash = true
			dash_cooldown_timer = 0.0
	
	if is_on_floor():
		check_ground_tile_type()
	
	var direction := Input. get_axis("left", "right")
	move_and_slide()
	
	_check_hurt_box_hazards()
	
	if direction == 1.0:
		sprite_2d. flip_h = false
	elif direction == -1.0:
		sprite_2d.flip_h = true

func _check_hurt_box_hazards() -> void:
	if not hurt_box:
		return
	
	var overlapping_bodies = hurt_box.get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body is TileMapLayer or body is TileMap:
			var check_position = hurt_box.global_position
			var tile_data = get_tile_data_at_position(check_position)
			
			if tile_data and tile_data.get_custom_data("HAZARD"):
				print("💥 HurtBox touching hazard at:", check_position)
				damagePlayer()
				respawnPlayer()
				return  
				
func respawnPlayer() -> void:
	global_position = spawn_point
	velocity = Vector2.ZERO
		
func damagePlayer(num: int = 1) -> void:
	health -= num
	print(health)

func isSlidable(directionAsString) -> bool:
	var on_wall:  bool = (ray_cast_right.is_colliding() or ray_cast_left.is_colliding()) and not ray_cast_bottom.is_colliding()
	var holding_wall: bool = Input.is_action_pressed(directionAsString) and canWallJump and hasUnlockedWallJump and ! ray_cast_up.is_colliding()

	if ! on_wall or !holding_wall:
		return false
		
	var direction := Input.get_axis("left", "right")
	var collDirection:  RayCast2D
	
	if direction > 0: 
		collDirection = ray_cast_right
	elif direction < 0: 
		collDirection = ray_cast_left
	else:  
		if sprite_2d.flip_h:  
			collDirection = ray_cast_left
		else:  
			collDirection = ray_cast_right
	
	if collDirection and collDirection.is_colliding():
		var collision_point = collDirection.get_collision_point()
		var tile_data = get_tile_data_at_position(collision_point)
		
		if tile_data: 
			var custom_data = tile_data.get_custom_data("SLIDABLE")
			if custom_data != null:  
				return custom_data
	
	return false
	
func get_tile_data_at_position(world_pos: Vector2) -> TileData:
	if not tilemap:
		return null
	
	var local_pos = tilemap.to_local(world_pos)
	var tile_pos = tilemap.local_to_map(local_pos)
	
	return tilemap.get_cell_tile_data(tile_pos)

func check_ground_tile_type():
	if not is_on_floor():
		return null
	
	ray_cast_bottom.force_raycast_update()
	print("🔍 Checking ground tile (on floor)")
	print("  RayCast enabled:", ray_cast_bottom.enabled)
	print("  RayCast target:", ray_cast_bottom.target_position)
	print("  RayCast collision mask:", ray_cast_bottom. collision_mask)
	
	if ray_cast_bottom.is_colliding():
		print("✓ RayCastBottom is colliding")
		var collider = ray_cast_bottom. get_collider()
		print("  Collider:", collider)
		print("  Collider type:", collider. get_class() if collider else "null")
		
		var collision_point = ray_cast_bottom.get_collision_point()
		var tile_data = get_tile_data_at_position(collision_point)
		
		if tile_data:
			print("✓ Got tile data")
			
			var tile_set = tilemap.tile_set
			if tile_set and tile_set.get_custom_data_layer_by_name("RESPAWNPOINT") != -1:
				var is_respawn = tile_data.get_custom_data("RESPAWNPOINT")
				print("🚩 Checking RESPAWNPOINT:", is_respawn)
				
				if is_respawn: 
					_set_spawn_point(collision_point)
			
			var custom_data = tile_data.get_custom_data("TYPE")
			if custom_data != null and custom_data != "":
				return custom_data
		else:
			print("❌ No tile data at collision point:", collision_point)
	else:
		print("❌ RayCastBottom NOT colliding")
		print("  Distance to check collision:", ray_cast_bottom.target_position.length())
	
	return null

func _set_spawn_point(tile_world_pos: Vector2) -> void:
	if not tilemap:
		return
	
	var local_pos = tilemap.to_local(tile_world_pos)
	var tile_pos = tilemap.local_to_map(local_pos)
	
	var tile_center = tilemap. map_to_local(tile_pos)
	var tile_center_world = tilemap.to_global(tile_center)
	
	if spawn_point != tile_center_world:  
		spawn_point = tile_center_world
		print("🚩 Spawn point updated:", spawn_point)
	
func check_direction_tile_type():
	if ray_cast_left.is_colliding():
		var collision_point = ray_cast_left.get_collision_point()
		var tile_data = get_tile_data_at_position(collision_point)
		
		if tile_data: 
			var custom_data = tile_data.get_custom_data("TYPE")
			if custom_data != null and custom_data != "":  
				return custom_data
	elif ray_cast_right.is_colliding():
		var collision_point = ray_cast_right. get_collision_point()
		var tile_data = get_tile_data_at_position(collision_point)
		
		if tile_data:
			var custom_data = tile_data.get_custom_data("TYPE")
			if custom_data != null and custom_data != "": 
				return custom_data
	return null

func updateAbility(ability: String):
	var variable_name = "hasUnlocked" + ability
	set(variable_name, true)
	set("can" + ability, true)
	print("Unlocked:", ability)
	
func cameraSetup(top, left, bottom, right):
	camera.limit_top = top
	camera. limit_left = left
	camera.limit_bottom = bottom
	camera.limit_right = right
