extends EnemyState

var bulletPath = preload("res://Scenes/Bullet.tscn")
@onready var gun = $"../../Gun"
@onready var aiming = $"../../Gun/Aiming"
var readyToAttack = true

const bulletSpeed = 250.0
var rng = RandomNumberGenerator.new()

func Physics_Update(delta):
	animate.play("Run")
	gun.look_at(player.position)
	# Note: This approach is kinda buggy. Refactor into something better later
	var playerDirection = player.global_position - enemy.global_position
	
	animate.flip_h = playerDirection.x < 0
	
	if(rng.randi_range(0,100) == 100):
		# TODO: Fix All Enemies Switching Colors
		switchColor()

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
	var bulletColor : ColorComponent = bullet.find_child("ColorComponent")
	var colorComponent: ColorComponent = get_owner().find_child("ColorComponent")
	
	if(bulletColor == null || colorComponent == null):
		return
	
	bulletColor.color = colorComponent.color
	bullet.source = get_instance_id()
	get_tree().root.add_child(bullet)

	# Position the bullet at the player's shooting point (Marker2D).
	bullet.position = aiming.global_position
	
	# Set the bullet's velocity and rotation based on the direction to the mouse.
	var direction = (player.global_position - bullet.position).normalized()
	bullet.velocity = direction * bulletSpeed
	bullet.rotation = direction.angle()

func switchColor():
	var colorComponent: ColorComponent = $"../../ColorComponent"
	var sprite : AnimatedSprite2D =  $"../../AnimatedSprite2D"
	# Check sprite and component exist, end if not
	if(sprite == null || colorComponent == null):
		return
		
	# Swap Colors
	colorComponent.color = COLORS.MATCHUPS[colorComponent.color]
	sprite.material.set("shader_parameter/line_color", COLORS.OUTLINE_CLRS[colorComponent.color])



func _on_attack_cooldown_timeout():
	# Enable Attacking
	readyToAttack = true
