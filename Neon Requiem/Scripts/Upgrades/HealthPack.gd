extends Node2D
class_name HealthPack

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.healthComponent.currentHealth != body.healthComponent.MAX_HEALTH:
			if body.healthComponent.currentHealth + 20 < body.healthComponent.MAX_HEALTH:
				body.healthComponent.currentHealth = body.healthComponent.currentHealth + 20
				queue_free()
			else: 
				body.healthComponent.currentHealth = body.healthComponent.MAX_HEALTH
				queue_free()
			
