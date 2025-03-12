extends Consumable
class_name SpeedBoost
@onready var timer: Timer = $Timer
var originalSpeed = 100
var speedComponent : SpeedComponent
var curPlayer : Player
var used = false

func _on_body_entered(body: Node2D) -> void:
	if body is Player and not used and not body.isBoosted:
		used = true
		body.isBoosted = true
		print("Speed")
		curPlayer = body
		speedComponent = curPlayer.get_node("SpeedComponent")
		originalSpeed = speedComponent.startingSpeed
		speedComponent.startingSpeed = originalSpeed + 50
		timer.start()
		visible = false	


func _on_timer_timeout() -> void:
	speedComponent = curPlayer.get_node("SpeedComponent")
	speedComponent.startingSpeed = originalSpeed
	curPlayer.isBoosted = false
	queue_free()
