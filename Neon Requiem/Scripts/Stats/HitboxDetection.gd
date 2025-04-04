extends Area2D
class_name HitboxCollision

@onready var healthComponent: HealthComponent

func _on_body_entered(body):
	# Get Attack Component
	var attack = body.find_child("AttackComponent")
	
	#If projectile has attack component, then damage object
	if(attack != null):
		healthComponent.damage(attack)
		return
