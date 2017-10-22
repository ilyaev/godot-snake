extends TileMap

onready var foreground = get_node("../foreground")
onready var snakes = get_node("../snakes")
onready var layers = []
onready var map = get_node("map")

var maxX = 0
var maxY = 0
var half_size = 0
var wall_map = {}
var cell_id_to_index = {}
var astar

const TILE_WALL = 1
const TILE_GRASS = 0
const TILE_WALL_LEFT = 3
const TILE_WALL_RIGHT = 2
const TILE_WALL_UP = 5
const TILE_WALL_DOWN = 4

func _ready():

	half_size = get_cell_size().x / 2

	layers.append(foreground)
	for layer in foreground.get_children():
		layers.append(layer)

	adjust_map()
	build_wall_map()

func map_to_screen(pos):
	return map.map_to_world(Vector2(pos.x, pos.y)) + Vector2(half_size, half_size)

func get_cell_id(x, y):
	return str(x, 'x', y)

func get_path(from, to):
	var from_cell = get_cell_id(from.x, from.y)
	var to_cell = get_cell_id(to.x, to.y)

	if !wall_map.has(from_cell) or !wall_map.has(to_cell) or wall_map[from_cell] or wall_map[to_cell]:
		return []

	return astar.get_point_path(cell_id_to_index[from_cell],
			cell_id_to_index[to_cell])

func build_astar():
	if astar:
		astar.clear()
	else:
		astar = AStar.new()

	for x in range(maxX):
		for y in range(maxY):
			var cell_id = get_cell_id(x, y)
			var cell_index = cell_id_to_index[cell_id]
			if !wall_map[cell_id]:
				astar.add_point(cell_index, Vector3(x, y, 0))

	for x in range(maxX):
		for y in range(maxY):
			var cell_id = get_cell_id(x, y)
			var cell_index = cell_id_to_index[cell_id]
			if !wall_map[cell_id]:
				for cell in [get_cell_id(x-1, y), get_cell_id(x+1, y), get_cell_id(x, y-1), get_cell_id(x, y+1)]:
					if wall_map.has(cell) and !wall_map[cell]:
						astar.connect_points(cell_index, cell_id_to_index[cell])


func build_wall_map():
	var index = 1
	for x in range(maxX):
		for y in range(maxY):
			var cell_id = get_cell_id(x,y)
			cell_id_to_index[cell_id] = index
			index = index + 1
			if get_cell(x, y) == TILE_WALL:
				wall_map[cell_id] = true
			else:
				wall_map[cell_id] = false

	for snake in snakes.get_children():
		var cell = world_to_map(snake.head.get_pos())
		wall_map[get_cell_id(cell.x, cell.y)] = true
		for body in snake.tail.get_children():
			var cell = world_to_map(body.get_pos())
			wall_map[get_cell_id(cell.x, cell.y)] = true

	build_astar()


func adjust_map():
	maxX = map.get_used_rect().end.x
	maxY = map.get_used_rect().end.y
	for x in range(map.get_used_rect().end.x):
		for y in range(map.get_used_rect().end.y):
			map.set_cell(x, y, TILE_GRASS)
			if get_cell(x,y) == TILE_WALL:
				continue
			var d_map = {
				"self": get_cell(x, y),
				"left": get_cell(x-1, y),
				"right": get_cell(x+1, y),
				"up": get_cell(x, y-1),
				"down": get_cell(x, y+1)
			}

			var index = 0

			if d_map.left == 1 or x == 0:
				layers[index].set_cell(x,y,TILE_WALL_LEFT)
				index += 1
			if d_map.right == 1 or x == maxX - 1:
				layers[index].set_cell(x,y,TILE_WALL_RIGHT)
				index += 1
			if d_map.up == 1 or y == 0:
				layers[index].set_cell(x,y,TILE_WALL_UP)
				index += 1
			if d_map.down == 1 or y == maxY - 1:
				layers[index].set_cell(x,y,TILE_WALL_DOWN)
				index += 1
