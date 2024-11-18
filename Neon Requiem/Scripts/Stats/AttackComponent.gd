class_name AttackComponent

const DEFAULT_ATTACK = 10
@export var baseAttack: float = DEFAULT_ATTACK

func _init(attack: float = DEFAULT_ATTACK):
	baseAttack = attack

# Useless for now, but more useful when we have multipliers
func calculateDamage():
	return baseAttack
