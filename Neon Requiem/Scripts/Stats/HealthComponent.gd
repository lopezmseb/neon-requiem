extends Node
class_name HealthComponent

@export var MAX_HEALTH : float = 100
@onready var currentHealth: float = MAX_HEALTH

func damage(attack: AttackComponent):
	currentHealth -= attack.calculateDamage()
