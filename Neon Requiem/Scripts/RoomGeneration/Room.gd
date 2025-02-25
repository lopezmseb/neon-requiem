extends RigidBody2D

var size

func makeRoom(_pos, _size):
	# Set Params
	position = _pos
	size = _size
	
	# Set Collision Shape to room 
	var collisionShape = RectangleShape2D.new()
	collisionShape.extents = size
	collisionShape.custom_solver_bias = 0.75
	$CollisionShape2D.shape = collisionShape	
	


func _on_collision_shape_2d_child_entered_tree(node):
	pass
