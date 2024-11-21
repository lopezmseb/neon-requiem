extends Node
class_name HealthComponent

@export var MAX_HEALTH : float = 100 : get = calcMaxHealth
@onready var currentHealth: float = MAX_HEALTH

func damage(attack: AttackComponent):
	currentHealth -= attack.calculateDamage()
	
	# If health == 0 or lower, destroy the object.
	if(currentHealth <= 0):
		get_parent().queue_free()

func calcMaxHealth():
	# Here we will run all health upgrades when implemented
	return MAX_HEALTH
