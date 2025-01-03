extends CharacterBody2D

@onready var bulletSprite  = $BulletSprite
@onready var colorComponent: ColorComponent = $ColorComponent

const SPEED = 150

func _ready():
	bulletSprite.modulate = COLORS.OUTLINE_CLRS[colorComponent.color]

func _physics_process(delta):
	# Move the bullet and check for collisions
	move_and_collide(velocity.normalized()* SPEED * delta)


func _on_area_2d_body_entered(body):
	# Get Health Component
	var health = body.find_child("HealthComponent")
	var body_color = body.find_child("ColorComponent")
	
	# If the object does not have a health component, then it must be a wall
	# therefore, delete projectile
	if(health == null || body_color == null):
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
		
	queue_free()
	


func _on_life_timeout():
	# Once Timer runs out, delete projectile.
	queue_free()
