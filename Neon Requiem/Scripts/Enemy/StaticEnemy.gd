extends CharacterBody2D

@onready var color_component : ColorComponent = $ColorComponent
@onready var animated_sprite_2d := $AnimatedSprite2D
signal onDamage(allowAnimation: bool)

func _physics_process(delta):
	if(animated_sprite_2d):
		var shaderMaterial = ShaderMaterial.new()
				
		if($ColorComponent.color == COLORS.OFFENSIVE):
			shaderMaterial.shader = COLORS.OFFENSIVE_SHADER
			shaderMaterial.set_shader_parameter("colourBlindMode", int(GlobalVariables.colourBlind))
		else:
			shaderMaterial.shader = COLORS.DEFENSIVE_SHADER
			shaderMaterial.set_shader_parameter("colourBlindMode", int(GlobalVariables.colourBlind))
		
		animated_sprite_2d.material = shaderMaterial
		
	move_and_slide()

# Display damage numbers
func _on_health_component_entity_damaged(attack: float):
	onDamage.emit(false) 
	
	var number = Label.new()
	var startingPosition: Control = $HealthBar
	number.position = startingPosition.position  - Vector2(-5,15)
	number.text = str(UIHelpers.formatFloat(attack))
	number.z_index = 50
	number.label_settings = LabelSettings.new()
	
	var color = "#FFF"
	
	number.label_settings.font = load("res://Assets/Theme/Better VCR 9.0.1.ttf")
	number.label_settings.font_color = color
	number.label_settings.font_size = 10
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 5
	

	add_child(number)
	
	await get_tree().create_timer(0.10).timeout
	number.pivot_offset = Vector2(number.size/2)
	
	var tween = create_tween()

	tween.tween_property(number, "position:y", number.position.y - 10, 0.15).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(number, "position:y", number.position.y, 0.15).set_ease(Tween.EASE_IN).set_delay(0.15)
	tween.tween_property(number, "scale", Vector2.ZERO, 0.15).set_ease(Tween.EASE_IN).set_delay(0.2)
	
	await tween.finished
	
	onDamage.emit(true)
	number.queue_free()

	
		
