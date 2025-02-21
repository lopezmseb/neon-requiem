extends CharacterBody2D


const SPEED = 150

@onready var audio_stream_player = $AudioStreamPlayer

func _ready():
		audio_stream_player.pitch_scale = randf_range(0.5, 1.5)
		audio_stream_player.play()
		
		
func _physics_process(delta):
	move_and_collide(velocity.normalized()* SPEED * delta)


func _on_area_2d_body_entered(body):
	# Get Health Component
	
	var health = body.find_child("HealthComponent")
	
	# If the object does not have a health component, then it must be a wall
	# therefore, delete projectile
	if(health == null):
		await audio_stream_player.finished
		queue_free()
		return
		
	# Get Attack Component
	var attack = find_child("AttackComponent")
	
	#If projectile has attack component, then damage object
	if(attack == null):
		return
	
	# Deal damage to enemy
	health.damage(attack)
	
	# Enable HealthBar
	var healthBar = body.find_child("HealthBar")
		
	if(healthBar is HealthBar):
		healthBar.show()
		
	await audio_stream_player.finished
	queue_free()


func _on_sprite_2d_animation_finished():
	queue_free()
