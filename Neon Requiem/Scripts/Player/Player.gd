extends CharacterBody2D
class_name Player

# -1 == Mouse and Keyboard
# >= 0 => Controller
@export var playerController : int = -1
@export var playerName : String = ""
@export var isBoosted : bool = false
const speed: float = 100
const dashSpeed: float = 500

var dash_duration: float = 0.2  # Dash lasts for 0.2 seconds
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

const bulletSpeed: float = 500.0

var movementDirection : Vector2
var shootingDirection : Vector2

var is_dash_ready: bool = true
var is_dashing: bool = false
var is_shoot_ready: bool = true
var is_melee_ready: bool = true
var is_ability1_ready: bool = true
var is_ability2_ready: bool = true
var input_enabled: bool = true

const bulletPath = preload("res://Scenes/Bullet.tscn")
const swordPath = preload("res://Scenes/Sword.tscn")

@onready var animatedSprite = $AnimatedSprite2D
@onready var colorComponent = $ColorComponent
@onready var dashSFX = $Dash
@onready var healthComponent = $HealthComponent

func _ready():
	var game_loop = get_tree().get_first_node_in_group("game_loop")
	if game_loop:
		healthComponent.health_depleted.connect(Callable(game_loop, "_on_player_death"))
	#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func disable_input():
	set_process_input(false)

func enable_input():
	set_process_input(true)

func _input(event):
	if input_enabled:
		if(event.device != playerController):
			return
		if(event is InputEventJoypadMotion):
			movementDirection = Vector2(Input.get_joy_axis(playerController, JOY_AXIS_LEFT_X), Input.get_joy_axis(playerController, JOY_AXIS_LEFT_Y))
			# TODO: Figure out how to deadzone sticks properly
			if(abs(movementDirection.x) < 0.1 and abs(movementDirection.y) < 0.1):
				movementDirection = Vector2.ZERO
			
			var tempDir = Vector2(Input.get_joy_axis(playerController, JOY_AXIS_RIGHT_X), Input.get_joy_axis(playerController, JOY_AXIS_RIGHT_Y))

			if(abs(tempDir.x) > 0.1 || abs(tempDir.y) > 0.1):
				shootingDirection = position + tempDir.normalized() * 4000
			
			var rightTrigger = Input.get_joy_axis(playerController, JOY_AXIS_TRIGGER_RIGHT);
			
			if(rightTrigger > 0.5 && is_shoot_ready):
				shoot()
			
			var leftTrigger = Input.get_joy_axis(playerController, JOY_AXIS_TRIGGER_LEFT);
			
			if(leftTrigger > 0.5 && is_ability2_ready):
				dashAttack()

		if(event is InputEventJoypadButton):
			if(event.button_index == JOY_BUTTON_A && is_dash_ready):
				dash()
			if(event.button_index == JOY_BUTTON_RIGHT_SHOULDER && is_ability1_ready):
				shotgun()
			if(event.button_index == JOY_BUTTON_LEFT_SHOULDER && is_melee_ready):
				melee()
			if(event.button_index == JOY_BUTTON_Y && event.is_pressed()):
				changeColor()

func handleKBInput(delta):
	# Move Gun Reticle on Mouse Direction
	if input_enabled:
		movementDirection = Input.get_vector("left","right","up","down");
		shootingDirection = get_global_mouse_position()
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
			changeColor()

	
func _physics_process(delta):
	var upgrades = find_children("*", "UpgradeStrategy", true, false)
	
	for i in upgrades:
		var upgrade = i as UpgradeStrategy
		
	if(playerController == -1):
		handleKBInput(delta)
		
	$Gun.look_at(shootingDirection)	
	if is_dashing:
		velocity = dash_direction * dashSpeed
		dash_timer -= delta
		
		# Reset velocity after dash
		if dash_timer <= 0:
			is_dashing = false
			
			velocity = Vector2.ZERO  
	elif is_dashing:
		velocity = dash_direction * dashSpeed
		dash_timer -= delta
		
		# Reset velocity after dash
		if dash_timer <= 0:
			is_dashing = false
			velocity = Vector2.ZERO  
	else:
		velocity = movementDirection * $SpeedComponent.calculateSpeed()
		
	if(velocity):
		animatedSprite.play("Run-" + playerName)
		animatedSprite.flip_h = velocity.x <= 0
	else:
		animatedSprite.play("Idle-" + playerName)
	
	move_and_slide()
	
func changeColor():
	colorComponent.color = COLORS.OFFENSIVE if colorComponent.color == COLORS.DEFENSIVE else COLORS.DEFENSIVE; 
	var shaderMaterial = ShaderMaterial.new()
	var shader = COLORS.OFFENSIVE_SHADER if colorComponent.color == COLORS.OFFENSIVE else COLORS.DEFENSIVE_SHADER
	shaderMaterial.shader = shader
	shaderMaterial.set_shader_parameter("colourBlindMode", int(GlobalVariables.colourBlind))
	$AnimatedSprite2D.material = shaderMaterial

func dash():
	$DashCooldown.start()
	if is_dash_ready and not is_dashing:
		dashSFX.play()
		is_dashing = true
		is_dash_ready = false
		dash_timer = dash_duration
		dash_direction = movementDirection.normalized()  

func _on_dash_cooldown_timeout():
	is_dash_ready = true

func shoot():
	is_shoot_ready = false
	$ShootCooldown.start()
	var bullet= bulletPath.instantiate()
	var bulletUpgrades : Array[Node] = $BulletUpgrades.get_children()
	bullet.upgrades = bulletUpgrades
	bullet.source = "Player"
	var bulletColor: ColorComponent = bullet.find_child("ColorComponent")
	
	if(bulletColor):
		bulletColor.color = colorComponent.color
		
	get_parent().add_child(bullet)
	
	# Position the bullet at the player's shooting point (Marker2D).
	bullet.position = $Gun/Aiming.global_position
	
	# Set the bullet's velocity and rotation based on the direction to the mouse.
	var direction = (shootingDirection - bullet.position).normalized()
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
			
		bullet.source = "Player"
		
		get_parent().add_child(bullet)
		
		bullet.position = $Gun/Aiming.global_position
		
		var base_direction = (shootingDirection - bullet.position).normalized()
		
		var spread_offset = -spread_angle + (spread_angle * 2) * randf()

		var angle = base_direction.angle() + deg_to_rad(spread_offset)
		var spread_direction = Vector2(cos(angle), sin(angle))

		bullet.velocity = spread_direction * bulletSpeed
		bullet.rotation = angle

func dashAttack():
	
	$Ability2Cooldown.start()

	# Get the player's current position.
	var position = global_position   

	# Calculate the direction to the mouse position.
	var direction = (shootingDirection - position).normalized()

	# Set the velocity for the dash.
	if is_ability2_ready and not is_dashing:
		dashSFX.play()
		is_ability2_ready = false
		is_dashing = true
		dash_timer = .1
		dash_direction = direction.normalized()
		melee()

	move_and_slide()
	
func melee():
	is_melee_ready = false
	$MeleeCooldown.start()

	# Instantiate the sword and set it as a child of the player
	var sword = swordPath.instantiate()
	
	await get_tree().process_frame
	# Apply upgrades to the sword
	var swordUpgrades : Array[Node] = $SwordUpgrades.get_children()
	sword.upgrades = swordUpgrades
	add_child(sword)
	# Position the sword based on the player's position and movement
	sword.position = to_local($Gun/Aiming.global_position)
	# Calculate the direction to the shooting position (mouse)
	var direction = (shootingDirection - position).normalized()

	if direction.x <= 0:
		sword.get_node("Sprite2D").flip_v = true
		sword.rotation = direction.angle()
		sword.position = to_local($Gun/Aiming.global_position)
	else:
		sword.rotation = direction.angle()
		sword.position = to_local($Gun/Aiming.global_position)
	 
func _on_shoot_cooldown_timeout():
	is_shoot_ready = true


func _on_melee_cooldown_timeout():
	is_melee_ready = true


func _on_ability_1_cooldown_timeout():
	is_ability1_ready = true;


func _on_ability_2_cooldown_timeout():
	is_ability2_ready = true;
