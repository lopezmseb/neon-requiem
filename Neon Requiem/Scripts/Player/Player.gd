extends CharacterBody2D
class_name Player

const speed = 100
const dashSpeed: float = 50
const bulletSpeed = 500.0
var is_dash_ready: bool = true
var is_attack_ready: bool = true

@onready var animatedSprite = $AnimatedSprite2D
@onready var colorComponent = $ColorComponent


const bulletPath = preload("res://Scenes/bullet.tscn")

	
func _physics_process(delta):
	$Gun.look_at(get_global_mouse_position())
	
	var moveDirection = Input.get_vector("left","right","up","down");
	velocity = moveDirection * speed
		
	if(velocity):
		animatedSprite.play("Run")
		animatedSprite.flip_h = velocity.x <= 0
	else:
		animatedSprite.play("Idle")
	
	move_and_slide()
	
	if Input.is_action_just_pressed("dash") && is_dash_ready:
		dash()
		
	if Input.is_action_pressed("attack") && is_attack_ready:
		shoot()
		
	if Input.is_action_just_pressed("change_color"): 
		# TODO: Change Later
		colorComponent.color = COLORS.OFFENSIVE if colorComponent.color == COLORS.DEFENSIVE else COLORS.DEFENSIVE; 
		$AnimatedSprite2D.material.set("shader_parameter/line_color", COLORS.OUTLINE_CLRS[colorComponent.color])

func dash():
	is_dash_ready = false
	
	velocity = velocity * dashSpeed
	move_and_slide()
	
	$DashCooldown.start()

func _on_dash_cooldown_timeout():
	is_dash_ready = true

func shoot():
	is_attack_ready = false
	$AttackCooldown.start()
	var bullet = bulletPath.instantiate()
	bullet.source = get_instance_id()
	var bulletColor: ColorComponent = bullet.find_child("ColorComponent")
	
	if(bulletColor):
		bulletColor.color = colorComponent.color
		
	get_parent().add_child(bullet)
	
	# Position the bullet at the player's shooting point (Marker2D).
	bullet.position = $Gun/Aiming.global_position
	
	# Set the bullet's velocity and rotation based on the direction to the mouse.
	var direction = (get_global_mouse_position() - bullet.position).normalized()
	bullet.velocity = direction * bulletSpeed
	bullet.rotation = direction.angle()


func _on_attack_cooldown_timeout():
	is_attack_ready = true
