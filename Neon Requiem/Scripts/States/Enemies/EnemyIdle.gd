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
		wanderingTime -= delta
	else:
		RandomizeWander()
		
func Physics_Update(delta):
	if enemy:
		enemy.velocity = direction * speed
		
	var playerDirection = player.global_position - enemy.global_position
	
	if(playerDirection.length() < 100):
		onNewState.emit(self, AvailableStates.Follow)
	
