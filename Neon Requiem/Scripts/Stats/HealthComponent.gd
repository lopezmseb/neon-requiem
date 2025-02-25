extends Node
class_name HealthComponent

signal health_depleted(owner)

@export var MAX_HEALTH : float = 100 : get = calcMaxHealth
@onready var currentHealth: float = MAX_HEALTH

func damage(attack: AttackComponent):
	# If health == 0 or lower, destroy the object.
	currentHealth -= attack.calculateDamage()
	print("Damage", attack.calculateDamage())
	
	if(currentHealth <= 0):
		var parent = get_parent()
		health_depleted.emit(parent)
		parent.position = Vector2(999999,999999)
		parent.visible = false


		

func _on_health_depleted(owner):
	# Handle the signal, using the `owner` object (which is the parent).
	print("Health depleted for: ", owner.name)

func calcMaxHealth():
	# Here we will run all health upgrades when implemented
	var maxHealth = MAX_HEALTH
	for i in get_children():
		var upgrade = i as UpgradeStrategy
		
		maxHealth = i.Apply(maxHealth)
		
	
	return maxHealth
