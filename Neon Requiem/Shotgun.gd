extends CharacterBody2D

@onready var bullet_scene = preload("res://Scenes/Bullet.tscn")
	
func shoot_bullets():
	var bullet_count = 5
	var spread_angle = 30
	var shotgun_rotation = rotation_degrees

	for i in range(bullet_count):
		var bullet = bullet_scene.instance()
		get_parent().add_child(bullet)

		var angle_offset = spread_angle * (i - (bullet_count - 1) / 2.0) / (bullet_count - 1)
		var radians = (shotgun_rotation + angle_offset) * PI / 180
		var direction = Vector2(cos(radians), sin(radians))

		bullet.position = global_position
		bullet.rotation_degrees = shotgun_rotation + angle_offset
		bullet.set_velocity(direction * 500)
