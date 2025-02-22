extends EnemyState

@export var maxWanderingTime = 3
@export var minWanderingTime = 1

var direction: Vector2
var wanderingTime: float


func RandomizeWander():
	direction = Vector2(randf_range(-1, 1), randf_range(-1,1)).normalized()
	wanderingTime = randf_range(minWanderingTime, maxWanderingTime)
	
func Enter():
	RandomizeWander()
	
func Update(delta):
	if(wanderingTime > 0):
		animate.play("Run")
		wanderingTime -= delta
	else:
		RandomizeWander()
		
func Physics_Update(delta):
	if enemy:
		enemy.velocity = direction * speed
		animate.flip_h = enemy.velocity.x < 0


func _on_area_2d_body_entered(body):
	if body is Player:
		onNewState.emit(self, AvailableStates.Follow)
