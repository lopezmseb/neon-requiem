extends Consumable


@export var baseHealthHealed : float = 20.0

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		# Pass Upgrades 
		var userUpgrades = body.find_children("*", "HealthPackUpgrade", true, false)
		
		# Calculate Amount To Heal
		var amountToHeal = baseHealthHealed	
		for i in userUpgrades:
			var upgrade = i as HealthPackUpgrade
			
			amountToHeal = upgrade.Apply(amountToHeal)
			
		# Heal
		body.healthComponent.currentHealth = clampf(body.healthComponent.currentHealth + amountToHeal, 0, body.healthComponent.MAX_HEALTH)
		
		queue_free()
			
