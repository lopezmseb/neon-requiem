extends Node
class_name AttackComponent

const DEFAULT_ATTACK = 10.0
const DEFAULT_MULT  = 1.0

@export var baseAttack: float = DEFAULT_ATTACK
@export var mult : float = DEFAULT_MULT

func _init(attack: float = DEFAULT_ATTACK):
	baseAttack = attack

# Useless for now, but more useful when we have multipliers
func calculateDamage():
	return baseAttack * mult
	
func updateMult(n_mult: float):
	mult *= n_mult
