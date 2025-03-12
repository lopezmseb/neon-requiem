extends Consumable

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.healthComponent.currentHealth = clampf(body.healthComponent.currentHealth + 10, 0, body.healthComponent.MAX_HEALTH)
		queue_free()
			
