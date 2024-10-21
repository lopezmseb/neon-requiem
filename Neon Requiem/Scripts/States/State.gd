extends Node
class_name State

signal onNewState

# To be ran, when the State changes and enters into a new State.
func Enter():
	pass

# To be ran when the current state ends
func Exit():
	pass
	
# Ran on every frame (process)
func Update(delta: float):
	pass
	
# Ran on every physics frame (60 frames per second)
func Physics_Update(delta: float):
	pass
