extends Node
class_name AttackComponent

const DEFAULT_ATTACK = 10.0
const DEFAULT_MULT  = 1.0

@export var baseAttack: float = DEFAULT_ATTACK
@export var mult : float = DEFAULT_MULT

func _init(attack: float = DEFAULT_ATTACK):
	baseAttack = attack

func calculateDamage(upgdradeInfoDict: Dictionary = {}):
	var attack = baseAttack
	
	var upgrades = get_children()
	upgrades.sort_custom(Upgrades.sortArrayByPriority)
		
	for i in upgrades:
		var upgrade = i as UpgradeStrategy
		attack = upgrade.Apply(attack, upgdradeInfoDict)
	
	return attack * mult
	
func updateMult(n_mult: float):
	mult *= n_mult
