extends EnemyState

var bulletPath = preload("res://Scenes/Bullet.tscn")
@onready var gun = $"../../Gun"
@onready var aiming = $"../../Gun/Aiming"

const bulletSpeed = 500.0

func Physics_Update(delta):
	gun.look_at(player.position)
	
	$AttackCooldown.start()
	var bullet = bulletPath.instantiate()
	get_tree().root.add_child(bullet)

	# Position the bullet at the player's shooting point (Marker2D).
	bullet.position = aiming.global_position

	# Set the bullet's velocity and rotation based on the direction to the mouse.\
	var direction = (player.global_position - bullet.position).normalized()
	bullet.velocity = direction * bulletSpeed
	bullet.rotation = direction.angle()

