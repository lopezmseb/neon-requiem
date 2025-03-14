extends CharacterBody2D
class_name Bullet

@onready var bulletSprite  = $BulletSprite
@onready var colorComponent: ColorComponent = $ColorComponent
@onready var audio_stream_player = $AudioStreamPlayer

var source = null
var upgrades: Array[Node] = []

const SPEED = 150

func initialize(source_type = null, upgradeList: Array[Node] = []):
	source = source_type
	upgrades = upgradeList
	
	if($AttackComponent.get_child_count() == 0):
		for i in upgradeList:
			$AttackComponent.add_child(i)
		

func _ready():
	bulletSprite.modulate = COLORS.OUTLINE_CLRS[colorComponent.color]
	audio_stream_player.pitch_scale = randf_range(0.9, 2)
	audio_stream_player.play()
	if(upgrades.size() > 0):
		for i in upgrades:
			$AttackComponent.add_child(i.duplicate())

func _physics_process(delta):
	# Move the bullet and check for collisions
	move_and_collide(velocity.normalized()* SPEED * delta)


func _on_area_2d_body_entered(body):
	# Check if collided with shooter
	if(source == "Player" and body is Player):
		return
	
	# Get Health Component
	var health = body.find_child("HealthComponent")
	var body_color = body.find_child("ColorComponent")
	
	# If the object does not have a health component, then it must be a wall
	# therefore, delete projectile
	if(health == null):
		visible = false
		await audio_stream_player.finished
		queue_free()
		return
		
	# Get Attack Component
	var attack : AttackComponent = find_child("AttackComponent")
	var own_color : ColorComponent = find_child("ColorComponent")
	
	#If projectile has attack component, then damage object
	if(attack == null || own_color == null):
		return

	# Projectile Color Multiplier
	if(COLORS.MATCHUPS[own_color.color] == body_color.color):
		attack.updateMult(COLORS.SAME_MULTIPLIER)
	else:
		attack.updateMult(COLORS.OPPOSITE_MULTIPLIER)
	
	# Deal damage to enemy
	health.damage(attack)
	
	# Enable HealthBar
	var healthBar = body.find_child("HealthBar")
		
	if(healthBar is HealthBar):
		healthBar.show()
	visible = false
	await audio_stream_player.finished
	queue_free()
	


func _on_life_timeout():
	# Once Timer runs out, delete projectile.
	await audio_stream_player.finished
	queue_free()
