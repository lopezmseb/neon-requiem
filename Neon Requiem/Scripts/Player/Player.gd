extends CharacterBody2D
class_name Player

const speed = 100
const dashSpeed: float = 50
const dashAttackSpeed: float = 25
const bulletSpeed = 500.0
var is_dash_ready: bool = true
var is_shoot_ready: bool = true
var is_melee_ready: bool = true
var is_ability1_ready: bool = true
var is_ability2_ready: bool = true

const bulletPath = preload("res://Scenes/Bullet.tscn")
const swordPath = preload("res://Scenes/Sword.tscn")

@onready var animatedSprite = $AnimatedSprite2D
@onready var colorComponent = $ColorComponent

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _input(event):
	return

	
func _physics_process(delta):
	# Move Mouse if Using Controller
	if(InputEventJoypadMotion):
		var joystickAimingVector = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
		# TODO: Will need to figure out how to clamp this or rework entirely
		var mouse_pos = get_viewport().get_mouse_position() + joystickAimingVector  * 800 * delta
		Input.warp_mouse(mouse_pos)
		
	# Move Gun Reticle on Mouse Direction
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
		
	if Input.is_action_pressed("Ability 1") && is_ability1_ready:
		shotgun()
		
	if Input.is_action_pressed("Ability 2") && is_ability2_ready:
		dashAttack()

		
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
	is_shoot_ready = false
	$ShootCooldown.start()
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
	
func shotgun():
	is_ability1_ready = false
	$Ability1Cooldown.start()
	
	var bullet_count = 5
	var spread_angle = 30
	var shotgun_rotation = rotation_degrees

	for i in range(bullet_count): 
		var bullet = bulletPath.instantiate()
		var bulletColor = bullet.find_child("ColorComponent")
		
		if(bulletColor):
			bulletColor.color = colorComponent.color
			
		bullet.source = get_instance_id()
		
		get_parent().add_child(bullet)
		
		bullet.position = $Gun/Aiming.global_position
		
		var base_direction = (get_global_mouse_position() - bullet.position).normalized()
		
		var spread_offset = -spread_angle + (spread_angle * 2) * randf()

		var angle = base_direction.angle() + deg_to_rad(spread_offset)
		var spread_direction = Vector2(cos(angle), sin(angle))

		bullet.velocity = spread_direction * bulletSpeed
		bullet.rotation = angle

func dashAttack():
	is_ability2_ready = false
	$Ability2Cooldown.start()

	# Get the player's current position.
	var position = global_position

	# Calculate the direction to the mouse position.
	var direction = (get_global_mouse_position() - position).normalized()

	# Set the velocity for the dash.
	velocity = direction * dashAttackSpeed * speed

	# Move the player in the calculated direction.
	move_and_slide()
	melee()
	
func melee():
	is_melee_ready = false
	$MeleeCooldown.start()
	var sword = swordPath.instantiate()
	get_parent().add_child(sword)
	
	# Position the bullet at the player's shooting point (Marker2D).
	sword.position = $Gun/Aiming.global_position
	
	# Set the bullet's velocity and rotation based on the direction to the mouse.
	var direction = (get_global_mouse_position() - sword.position).normalized()
#	sword.velocity = direction
	sword.rotation = direction.angle()

func _on_shoot_cooldown_timeout():
	is_shoot_ready = true


func _on_melee_cooldown_timeout():
	is_melee_ready = true


func _on_ability_1_cooldown_timeout():
	is_ability1_ready = true;


func _on_ability_2_cooldown_timeout():
	is_ability2_ready = true;
