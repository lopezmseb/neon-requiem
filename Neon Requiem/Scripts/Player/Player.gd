extends CharacterBody2D
class_name Player

const speed = 100
const dashSpeed: float = 50
const bulletSpeed = 500.0
var is_dash_ready: bool = true
var is_shoot_ready: bool = true
var is_melee_ready: bool = true


const bulletPath = preload("res://Scenes/Bullet.tscn")
const swordPath = preload("res://Scenes/Sword.tscn")

@onready var animatedSprite = $AnimatedSprite2D
	
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
		
	if Input.is_action_pressed("shoot") && is_shoot_ready:
		shoot()
	
	if Input.is_action_pressed("melee") && is_melee_ready:
		melee()

func dash():
	is_dash_ready = false
	$DashCooldown.start()
	velocity = velocity * dashSpeed
	move_and_slide()

func _on_dash_cooldown_timeout():
	is_dash_ready = true

func shoot():
	is_shoot_ready = false
	$ShootCooldown.start()
	var bullet = bulletPath.instantiate()
	get_parent().add_child(bullet)
	
	# Position the bullet at the player's shooting point (Marker2D).
	bullet.position = $Gun/Aiming.global_position
	
	# Set the bullet's velocity and rotation based on the direction to the mouse.
	var direction = (get_global_mouse_position() - bullet.position).normalized()
	bullet.velocity = direction * bulletSpeed
	bullet.rotation = direction.angle()
	
func melee():
	is_melee_ready = false
	$MeleeCooldown.start()
	var sword = swordPath.instantiate()
	get_parent().add_child(sword)
	
	# Position the bullet at the player's shooting point (Marker2D).
	sword.position = $Gun/Aiming.global_position
	
	# Set the bullet's velocity and rotation based on the direction to the mouse.
	var direction = (get_global_mouse_position() - sword.position).normalized()
	#sword.velocity = direction
	sword.rotation = direction.angle()

func _on_shoot_cooldown_timeout():
	is_shoot_ready = true


func _on_melee_cooldown_timeout():
	is_melee_ready = true
