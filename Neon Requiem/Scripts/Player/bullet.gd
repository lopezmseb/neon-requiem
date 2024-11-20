extends CharacterBody2D

const SPEED = 300


func _physics_process(delta):
	# Move the bullet and check for collisions
	move_and_collide(velocity.normalized()* SPEED * delta)


func _on_area_2d_body_entered(body):
	# Get Health Component
	var health = body.find_child("HealthComponent")
	
	# If the object does not have a health component, then it must be a wall
	# therefore, delete projectile
	if(health == null):
		queue_free()
		return
		
	# Get Attack Component
	var attack = find_child("AttackComponent")
	
	#If projectile has attack component, then damage object
	if(attack == null):
		return
	
	# Deal damage to enemy
	health.damage(attack)
		
	queue_free()
	


func _on_life_timeout():
	# Once Timer runs out, delete projectile.
	queue_free()
