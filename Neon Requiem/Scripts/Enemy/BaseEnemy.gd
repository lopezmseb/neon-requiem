extends CharacterBody2D

func _physics_process(delta):
	move_and_slide()

func _on_health_component_entity_damaged(attack: float):
	print("Enemy Hurt", attack)
	var number = Label.new()
	var startingPosition: Node2D = $DamageNumberStartinPosition
	number.position = startingPosition.position
	number.text = str(attack)
	number.z_index = 9999
	number.label_settings = LabelSettings.new()
	
	var color = "#FFF"
	
	number.label_settings.font_color = color
	number.label_settings.font_size = 5
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 1
	
	add_child(number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size/2)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(number, "position:y", number.position.y - 100, 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(number, "position:y", number.position.y, 0.25).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(number, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	print("done")
	number.queue_free()
		
	
		
