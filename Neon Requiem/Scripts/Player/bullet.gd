extends CharacterBody2D

@onready var bulletSprite  = $BulletSprite
@onready var colorComponent: ColorComponent = $ColorComponent
var source = null

const SPEED = 150

func _init(source_type = null):
	source = source_type

func _ready():
	bulletSprite.modulate = COLORS.OUTLINE_CLRS[colorComponent.color]

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
	
	# If the object collided with has no ColorComponent, stop the function
	if(body_color == null):
		return
	
	# If the object does not have a health component, then it must be a wall
	# therefore, delete projectile
	if(health == null):
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
