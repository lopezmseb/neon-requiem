extends Node

@export var initialState: State

var states: Dictionary = {}
var currentState : State

#	This is the script for a state machine. For the state machine to work, the object/node
#	with this script must have children of the type State. Then, we will add all of them inside
#	the dictionary for use later. 
func _ready():
	for child in get_children():
		if(child is State):
			states[child.name.to_lower()] = child
			child.onNewState.connect(OnSignalSwitch)
		
	if(initialState):
		initialState.Enter()
		currentState = initialState

# Run the State.Update function for the current state on every frame			
func _process(delta):
	if(currentState):
		currentState.Update(delta)

# Run the State.Physics_Update function for the current state on every frame			
func _physics_process(delta):
	if(currentState):
		currentState.Physics_Update(delta)
		
func OnSignalSwitch(sourceState: State, targetStateName: String):
	# If sourceState is not the same as the currentState, then do nothing
	if(sourceState != currentState):
		return
	
	var targetState: State = states[targetStateName.to_lower()]
	
	if(currentState):
		currentState.Exit()
		
	targetState.Enter()
	
	currentState = targetState
	
	
