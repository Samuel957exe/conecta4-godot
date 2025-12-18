extends Node

enum GameMode {
	PVP, # Player vs Player
	PVE  # Player vs Environment (CPU)
}

var current_mode = GameMode.PVP
var cpu_difficulty = 1 # 0: Random, 1: Basic
