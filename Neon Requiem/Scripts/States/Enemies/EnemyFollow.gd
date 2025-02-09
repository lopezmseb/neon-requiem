extends EnemyState

var bulletPath = preload("res://Scenes/Bullet.tscn")
@onready var gun = $"../../Gun"
@onready var aiming = $"../../Gun/Aiming"

var readyToAttack = true

const bulletSpeed = 250.0
var rng = RandomNumberGenerator.new()

func Physics_Update(delta):
	animate.play("Run")
	gun.look_at(player.global_position)
	# Note: This approach is kinda buggy. Refactor into something better later
	if(player):
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
	bullet.source = "Enemy"
	var parent = get_tree().get_nodes_in_group("Viewports")

	if(parent.size() > 0):
		parent[0].add_child(bullet)

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


func _on_area_2d_body_entered(body: Node2D):
	if body is Player:
		player = body
		# This gets the distance from the body and the distance from the tracked player. It will start tracking whoever
		# is nearer. Feels Better with it off? Might be work tweaking and seeing how it feels with more people later.
		# Keeping in case we want it back
		#else:
		#	var distanceFromBody = abs(enemy.global_position - body.global_position)
		#	var distanceFromPlayer = abs(enemy.global_position - player.global_position)
		#	
		#	if(distanceFromBody < distanceFromPlayer):
		#		player = body
