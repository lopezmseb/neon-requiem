extends Node

# Colors
const DEFENSIVE = "DEFENSIVE"
const OFFENSIVE = "OFFENSIVE"

const OUTLINE_CLRS : Dictionary = {
	DEFENSIVE : Color("70f13d"),
	OFFENSIVE : Color("ff6cb1")
}

const MATCHUPS : Dictionary = {
	DEFENSIVE : OFFENSIVE,
	OFFENSIVE: DEFENSIVE
}

const OPPOSITE_MULTIPLIER = 0.5
const SAME_MULTIPLIER = 1

