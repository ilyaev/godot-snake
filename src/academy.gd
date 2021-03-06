extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var maxX = 0
var maxY = 0

const TILE_WALL = 1
const TILE_GRASS = 8
const TILE_GRASS_PIT = 13
const TILE_WALL_LEFT = 5
const TILE_WALL_RIGHT = 4
const TILE_WALL_UP = 7
const TILE_WALL_DOWN = 6
const TILE_INNER_WALL = 12
const GRASS_TILES = [0, 9, 10, 11]
const PIT_TILES = [13, 14, 15, 16,17,18,19,20,21,22,23,24,14]
const PLAYER_PIT_TILES = [25,26,27,28,29,30,31,32,33,13]

var index = {
	levels = []
}

func _ready():
	pass

func on_scene_enter():
	for level in get_children():
		export_level(level)
		var file = File.new()
		if file.open('res://export/levels.js', File.WRITE) != 0:
			return

		file.store_line('module.exports = ' + index.to_json())
		file.close()

func export_level(level):
	var map = level.get_node('map')
	var walls = level.get_node('walls')
	maxX = map.get_used_rect().end.x
	maxY = map.get_used_rect().end.y
	var fileName = 'res://export/' + map.get_name() + '.json'
	var data = {
		maxX = maxX,
		name = level.get_name(),
		maxFood = level.max_food,
		maxRival = level.max_enemy,
		maxY = maxY,
		walls = [],
		pits = []
	}

	for x in range(maxX):
		for y in range(maxY):
			var cell_id = walls.get_cell(x,y)
			var map_id = map.get_cell(x,y)
			if cell_id == TILE_WALL or map_id == TILE_INNER_WALL:
				data.walls.append({
					x = x,
					y = y
				})
			if PLAYER_PIT_TILES.has(map_id) or PIT_TILES.has(map_id):
				data.pits.append({
					x = x,
					y = y
				})

	var file = File.new()
	if file.open(fileName, File.WRITE) != 0:
		return

	file.store_line(data.to_json())
	file.close()
	index.levels.append(data)