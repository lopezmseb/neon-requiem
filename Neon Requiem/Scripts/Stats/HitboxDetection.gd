extends Area2D

@onready var healthComponent: HealthComponent

func _on_body_entered(body):
	# Get Health Component
	
	# Get Attack Component
	var attack = body.find_child("AttackComponent")
	
	#If projectile has attack component, then damage object
	if(attack != null):
		healthComponent.damage(attack)
		
		return
		
	#body.get_tree().queue_free()
	
	
