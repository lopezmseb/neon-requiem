extends BossState

@onready var gun = $"../../Gun"
@onready var aiming = $"../../Gun/Aiming"
var bulletPath = preload("res://Scenes/Bullet.tscn")
var rng: RandomNumberGenerator
var readyToAttack = true
const bulletSpeed = 500.0

func Enter():
	rng = RandomNumberGenerator.new()
	animate.play("Idle")

func Physics_Update(delta: float):
	var attackToChoose = rng.randi_range(0,1)
	if(readyToAttack):
		Spread_Attack()
#		match attackToChoose:
#			0:				
#				Attack_All_Around()
#			1: 				
#				AAA_Burst()

func Attack_All_Around(offset:float = 0.0):
	var degrees = 360
	var bulletAmount = 12
	var degreeIncrease = degrees/bulletAmount
	
	for i in range(0, bulletAmount):
		var radian = deg_to_rad((degreeIncrease * i) + offset)
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
		
		# Set the bullet's velocity and rotation based on the direction to the mouse.\
		var direction = (newPos - enemy.position).normalized()
		bullet.velocity = direction * bulletSpeed
		bullet.rotation = direction.angle()
	
	readyToAttack = false
	
func AAA_Burst():
	for i in range(0,3):
		$BurstTimer.start()
		Attack_All_Around(0 if i%2 == 1 else 15)
		await $BurstTimer.timeout
		
func Spread_Attack():
	var degrees = 360
	var bulletAmount = 12
	var degreeIncrease = degrees/bulletAmount
	var offset = 0
	
	for i in range(0, bulletAmount):
		var radian = deg_to_rad((45 + 90 * i) + offset)
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
		
		# Set the bullet's velocity and rotation based on the direction to the mouse.\
		var direction = (newPos - enemy.position).normalized()
		bullet.velocity = direction * bulletSpeed
		bullet.rotation = direction.angle()
	
	readyToAttack = false
	
		


func _on_attack_cooldown_timeout():
	readyToAttack = true
	
