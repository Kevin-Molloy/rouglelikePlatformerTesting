extends Node2D

var player: CharacterBody2D = null 
var level_path: String = "res://scenes/Levels/level"



var current_level: Node = null

func _ready() -> void:
	load_level()

func load_level(num = "0") -> void:

	if current_level: 
		current_level.queue_free()
		current_level = null
	
	var level_scene = load(level_path + num + ".tscn")
	if not level_scene:
		printerr("Failed to load level: ", level_path)
		return
	
	current_level = level_scene.instantiate()
	add_child(current_level)
	
	print("Level loaded:  ", level_path)
	
	await get_tree().process_frame
	_setup_level()

func _setup_level() -> void:
	var player = current_level.find_child("Player", true, false)
	if player:
		print("Player found")
	else:
		printerr("Player not found in level!")
	if not current_level:
		printerr("No level loaded!")
		return
	var borderTop = current_level.get_meta("borderTop")
	var borderLeft = current_level.get_meta("borderLeft")
	var borderBottom = current_level.get_meta("borderBottom")
	var borderRight = current_level.get_meta("borderRight")
	

	
	if borderLeft == null or borderRight == null or borderTop == null or borderBottom == null:
		print("Missing Camera Border Metadata")
	else:
		player.cameraSetup(borderTop,borderLeft,borderBottom,borderRight)
	
	
	
	var orbs = current_level.find_child("Orbs", true, false)
	
	if orbs:
		print("Found ", orbs.get_child_count(), " orbs")
		for orb in orbs.get_children():
			if not orb.collected. is_connected(_update_abilities):
				orb.collected.connect(_update_abilities)
				print("Connected orb:  ", orb.name)
	else:
		print("No Orbs in level")
	
	

func _update_abilities(ability_name: String):
	print("Updating ability: ", ability_name)
	
	if not current_level:
		printerr("No level loaded!")
		return
	
	var player = current_level.find_child("Player", true, false)
	if player:
		player.updateAbility(ability_name)
		print("Ability updated:", ability_name)
	else:
		printerr("Player not found!")
