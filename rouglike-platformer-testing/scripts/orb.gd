extends Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D

signal collected(ability_name:  String)

func _ready() -> void:
	var ability = self.get_meta("Type")
	body_entered. connect(_on_body_entered)
	var spritePath = 'res://assets/images/collectibles/'+ ability +'.png'
	var texture = load(spritePath)
	sprite_2d.texture = texture
	
	# Validation
	if not has_meta("Type"):
		printerr("Orb '", name, "' has no 'Type' metadata!")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player": 
		if self.has_meta("Type"):
			var player_sprite = body.get_node("Sprite2D")
			
			if player_sprite:
				# Get orb color
				var orb_image = sprite_2d.texture. get_image()
				var center_pos = Vector2i(orb_image.get_width() / 2, orb_image.get_height() / 2)
				var orb_color = orb_image.get_pixelv(center_pos)
				
				# Blend with white to make it lighter/more transparent-looking
				var flash_color = orb_color.lerp(Color.WHITE, 0.3)  # ← 0.5 = 50% blend with white

				# Flash player
				player_sprite.modulate = flash_color
				await get_tree().create_timer(0.3).timeout
				player_sprite.modulate = Color.WHITE
			
			var ability = self.get_meta("Type")
			print(name, " collected!  Granting: ", ability)
			collected.emit(ability)
			queue_free()
		else:	
			printerr(name, " missing Type metadata!")
