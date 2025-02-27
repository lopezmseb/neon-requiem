extends BossState

@onready var gun = $"../../Gun"
@onready var aiming = $"../../Gun/Aiming"
var bulletPath = preload("res://Scenes/Bullet.tscn")
var rng: RandomNumberGenerator
var readyToAttack = true
const bulletSpeed = 500.0

func Enter():
	rng = RandomNumberGenerator.new()
	animate.play("Attack")

func Physics_Update(delta: float):
	if(readyToAttack):
		Attack_All_Around()
		readyToAttack = false

func Attack_All_Around():
	var degrees = 360
	var bulletAmount = 12
	var degreeIncrease = degrees/bulletAmount
	
	for i in range(0, bulletAmount):
		var radian = deg_to_rad(degreeIncrease * i)
		var newPos = enemy.position + Vector2(cos(radian), sin(radian)) * 50
		gun.look_at(newPos)
		
		$AttackCooldown.start()
		var bullet = bulletPath.instantiate()
		get_tree().root.add_child(bullet)

		# Position the bullet at the player's shooting point (Marker2D).
		bullet.position = newPos
		bullet.source = "Enemy"
		bullet.set_collision_layer_value(2, false)
		bullet.set_collision_mask_value(2, false)
		
		print(bullet.get_collision_layer())
		print(bullet.get_collision_mask())
		
		# Set the bullet's velocity and rotation based on the direction to the mouse.\
		var direction = (newPos - enemy.position).normalized()
		bullet.velocity = direction * bulletSpeed
		bullet.rotation = direction.angle()
	



func _on_attack_cooldown_timeout():
	readyToAttack = true
