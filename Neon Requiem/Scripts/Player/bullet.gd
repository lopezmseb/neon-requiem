extends CharacterBody2D

const SPEED = 300.0


func _physics_process(delta):
	# Move the bullet and check for collisions
	var collision = move_and_collide(velocity.normalized() * SPEED * delta)
	
	# If a collision occurs, remove the bullet
	if collision:
		queue_free()  # Remove the bullet from the scene
