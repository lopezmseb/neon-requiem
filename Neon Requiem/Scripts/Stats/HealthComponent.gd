extends Node
class_name HealthComponent

signal health_depleted(owner)
signal entity_damaged(attack:float)

const BASE_HEALTH = 100
@export var MAX_HEALTH : float = 100 : get = calcMaxHealth
@export var currentHealth: float = MAX_HEALTH
@onready var healthPackScene = preload("res://Scenes/HealthPack.tscn")
@onready var speedBoostScene = preload("res://Scenes/SpeedBoost.tscn")


func damage(attack: AttackComponent):
	# If health == 0 or lower, destroy the object.
	currentHealth -= attack.calculateDamage()
	print("Damage", attack.calculateDamage())
	entity_damaged.emit(attack.calculateDamage())
	if(currentHealth <= 0):
		
		var parent = get_parent()
		if(parent is Player):
			health_depleted.emit(parent)
			parent.position = Vector2(999999,999999)
			parent.visible = false
			currentHealth = MAX_HEALTH
		else:
			var chance_25 = randf_range(0.0, 1.0) < 0.9
			if chance_25:
				var pickupObject
				if randi() % 2:
					pickupObject = speedBoostScene.instantiate()
				else:
					pickupObject = healthPackScene.instantiate()
				pickupObject.position = parent.position
				parent.get_parent().get_parent().add_child(pickupObject)
			parent.queue_free()

		

func calcMaxHealth():
	# Here we will run all health upgrades when implemented
	var maxHealth = BASE_HEALTH
	for i in get_children():
		var upgrade = i as UpgradeStrategy
		
		maxHealth = i.Apply(maxHealth)
		
	
	return maxHealth
