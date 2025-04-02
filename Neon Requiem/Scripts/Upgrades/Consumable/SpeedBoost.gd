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
		curPlayer = body
		speedComponent = curPlayer.get_node("SpeedComponent")
		originalSpeed = speedComponent.baseSpeed
		speedComponent.baseSpeed = originalSpeed + 50
		timer.start()
		visible = false
		$CollisionShape2D.disabled = true
		$PowerUp.play()


func _on_timer_timeout() -> void:
	speedComponent = curPlayer.get_node("SpeedComponent")
	speedComponent.baseSpeed = originalSpeed
	curPlayer.isBoosted = false
	queue_free()
