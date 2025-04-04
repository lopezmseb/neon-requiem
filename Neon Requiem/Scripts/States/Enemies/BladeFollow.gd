extends EnemyState

var swordPath = preload("res://Scenes/Sword.tscn")
var canPlayAnimation = true
@onready var gun = $"../../Gun"
@onready var aiming = $"../../Gun/Aiming"

var readyToAttack = true
var isEnemyAlive = true

const bulletSpeed = 250.0
var rng = RandomNumberGenerator.new()

func Physics_Update(delta):
	if(animate.animation_finished && canPlayAnimation):
		animate.play("Run")
	gun.look_at(player.global_position)
	# Note: This approach is kinda buggy. Refactor into something better later
	if(player):
		var playerDirection = player.global_position - enemy.global_position
		var distance_to_player = playerDirection.length()
		animate.flip_h = playerDirection.x < 0

		if(distance_to_player > 200):
			onNewState.emit(self, AvailableStates.Idle)
		elif distance_to_player <= 25:
			enemy.velocity = -playerDirection.normalized() * (speed * 0.2)
		else :
			# Follow Player
			enemy.velocity = playerDirection.normalized() * speed
			# Attack Player
			if(readyToAttack && isEnemyAlive):
				SwingAtPlayer()
		

func SwingAtPlayer():
	# Start Cooldown and stop from attacking
	readyToAttack = false
	$AttackCooldown.start()
	
	# Instantiate the sword and set it as a child of the player
	var sword = swordPath.instantiate()
	var area2D : Area2D =sword.get_node("Area2D")
	area2D.set_collision_mask_value(2, false)
	area2D.set_collision_mask_value(1, true)
	
	await get_tree().process_frame
	# Apply upgrades to the sword
	var swordUpgrades : Array[Node] = $"../../AttackComponent".get_children()
	sword.upgrades = swordUpgrades
	enemy.add_child(sword)
	# Position the sword based on the player's position and movement
	sword.position = enemy.to_local($"../../Gun/Aiming".global_position)
	# Calculate the direction to the shooting position (mouse)
	var swordDirection = (player.global_position - enemy.position).normalized()
	print(swordDirection)
	if swordDirection.x <= 0:
		sword.get_node("Sprite2D").flip_v = true
	sword.rotation = swordDirection.angle()
	sword.position = enemy.to_local($"../../Gun/Aiming".global_position)
	

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


func _on_health_component_health_depleted(owner):
	isEnemyAlive = false
	#await get_tree().create_timer(1).timeout
	for i in get_children():
		var timer = i as Timer
		timer.stop()
	onNewState.emit(self, AvailableStates.Death)
	
func _on_base_enemy_on_damage(allowAnimation: bool):
	canPlayAnimation = allowAnimation
	if(not isEnemyAlive):
		return
	
	animate.stop()
	animate.play("Hurt")
