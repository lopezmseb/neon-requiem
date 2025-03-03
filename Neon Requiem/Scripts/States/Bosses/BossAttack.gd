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
	var attackToChoose = rng.randi_range(0,3)
	if(readyToAttack):
		match attackToChoose:
			0:				
				Attack_All_Around()
			1: 				
				AAA_Burst()
			2:
				Spread_Attack()
				$SpreadWaitTime.start()
				await $SpreadWaitTime.timeout
				Spread_Attack(45)
			3: 
				Track_Closest_Player()

func Track_Closest_Player():
	readyToAttack = false	
	var players = get_tree().root.find_children("*", "Player", true, false)
	
	if(players.size() > 0):
		var randomPlayer = rng.randi_range(0, players.size() - 1)
		var playerToTrack = players[randomPlayer] as Player
		var bulletAmount = 100
		
		for i in range(0, 20):
			var bullet = bulletPath.instantiate()
			add_child(bullet)

			# Position the bullet at the player's shooting point (Marker2D).
			bullet.position = enemy.global_position + (playerToTrack.global_position - enemy.global_position).normalized() * 50
			bullet.source = "Enemy"
			bullet.set_collision_layer_value(2, false)
			bullet.set_collision_mask_value(2, false)
			
			# Set the bullet's velocity and rotation based on the direction to the mouse.\
			var direction = (playerToTrack.global_position - enemy.position).normalized()
			bullet.velocity = direction * bulletSpeed
			bullet.rotation = direction.angle()
			$TrackTimer.start()
			await $TrackTimer.timeout
		$AttackCooldown.start()
		
func Attack_All_Around(offset:float = 0.0):
	readyToAttack = false
	
	var degrees = 360
	var bulletAmount = 12
	var degreeIncrease = degrees/bulletAmount
	
	for i in range(0, bulletAmount):
		var radian = deg_to_rad((degreeIncrease * i) + offset)
		var newPos = enemy.position + Vector2(cos(radian), sin(radian)) * 50
		gun.look_at(newPos)
		
		var bullet = bulletPath.instantiate()
		add_child(bullet)

		# Position the bullet at the player's shooting point (Marker2D).
		bullet.position = newPos
		bullet.source = "Enemy"
		bullet.set_collision_layer_value(2, false)
		bullet.set_collision_mask_value(2, false)
		
		# Set the bullet's velocity and rotation based on the direction to the mouse.\
		var direction = (newPos - enemy.position).normalized()
		bullet.velocity = direction * bulletSpeed
		bullet.rotation = direction.angle()
	
	$AttackCooldown.start()
	
func AAA_Burst():
	for i in range(0,3):
		$BurstTimer.start()
		Attack_All_Around(0 if i%2 == 1 else 15)
		await $BurstTimer.timeout
		
func Spread_Attack(baseDegree: float = 0):
	readyToAttack = false
	var offset = 90
	var waveAmount = 5
	var maxBullet = 5
	var maxSpread = 45
	for i in range(0, waveAmount):
		var bulletAmount = maxBullet - i
		var deviation = maxSpread/bulletAmount
		for x in range(0,4):
			for j in range(0, bulletAmount):
				var degreesToChange = (baseDegree + offset * x) + deviation * j
				
				var radian = deg_to_rad(degreesToChange) 
				var newPos = enemy.position + Vector2(cos(radian), sin(radian)) * 50
				gun.look_at(newPos)
				
				var bullet = bulletPath.instantiate()
				add_child(bullet)

				# Position the bullet at the player's shooting point (Marker2D).
				bullet.position = newPos
				bullet.source = "Enemy"
				bullet.set_collision_layer_value(2, false)
				bullet.set_collision_mask_value(2, false)
				
				# Set the bullet's velocity and rotation based on the direction to the mouse.\
				var direction = (newPos - enemy.position).normalized()
				bullet.velocity = direction * bulletSpeed
				bullet.rotation = direction.angle()
		$WaveWaitTime.start()
		await $WaveWaitTime.timeout
	
	$AttackCooldown.start()	

func _on_attack_cooldown_timeout():
	readyToAttack = true
	
