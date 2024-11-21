extends EnemyState

var bulletPath = preload("res://Scenes/Bullet.tscn")
@onready var gun = $"../../Gun"
@onready var aiming = $"../../Gun/Aiming"
var readyToAttack = true

const bulletSpeed = 250.0

func Physics_Update(delta):
	animate.play("Run")
	gun.look_at(player.position)
	# Note: This approach is kinda buggy. Refactor into something better later
	var playerDirection = player.global_position - enemy.global_position
	
	animate.flip_h = playerDirection.x < 0

	if(playerDirection.length() > 200):
		onNewState.emit(self, AvailableStates.Idle)
	else:
		# Follow Player
		enemy.velocity = playerDirection.normalized() * speed
		# Attack Player
		if(readyToAttack):
			ShootPlayer()

func ShootPlayer():
	# Start Cooldown and stop from attacking
	readyToAttack = false
	$AttackCooldown.start()
	
	# Get Bullet Scene and Add it
	var bullet = bulletPath.instantiate()
	get_tree().root.add_child(bullet)

	# Position the bullet at the player's shooting point (Marker2D).
	bullet.position = aiming.global_position
	
	# Set the bullet's velocity and rotation based on the direction to the mouse.
	var direction = (player.global_position - bullet.position).normalized()
	bullet.velocity = direction * bulletSpeed
	bullet.rotation = direction.angle()


func _on_attack_cooldown_timeout():
	# Enable Attacking
	readyToAttack = true
