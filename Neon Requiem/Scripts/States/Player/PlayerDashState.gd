extends PlayerState

var dashVelocity: Vector2
const dashSpeed: float = 10

@export var dashTimer : Timer

func Enter():
	dashVelocity = player.velocity
	dashTimer.start()

func Physics_Update(delta):
	if(dashTimer.is_stopped()):
		onNewState.emit(self, AvailableStates.Movement)
	
	player.velocity = dashVelocity * dashSpeed
	player.move_and_slide()
