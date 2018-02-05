extends TileMap

onready var foreground = get_node("/root/world/foreground")
onready var snakes = get_node("/root/world/snakes")
onready var layers = []
onready var map = get_node("/root/world/map")
onready var walls = get_node("/root/world/walls")

var maxX = 0
var maxY = 0
var half_size = 0
var snake_size = 0
var wall_map = {}
var cell_id_to_index = {}
var astar
var spawn_spots = []
var spawn_spots_player = []
var food_map = {}
var lock_spots = []
var unlocked = 0
var portal_open = false

const TILE_WALL = 1
const TILE_GRASS = 8
const TILE_GRASS_PIT = 13
const TILE_WALL_LEFT = 5
const TILE_WALL_RIGHT = 4
const TILE_WALL_UP = 7
const TILE_WALL_DOWN = 6
const GRASS_TILES = [0, 9, 10, 11]
const PIT_TILES = [14, 15, 16,17,18,19,20,21,22,23,24]
const PLAYER_PIT_TILES = [13, 25,26,27,28,29,30,31,32,33]
const TILE_LOCK = 34
const TILE_UNLOCK = 35
const TILE_PORTAL = 36


func _ready():
	snake_size = get_cell_size().x
	half_size = snake_size / 2

	layers.append(foreground)
	for layer in foreground.get_children():
		layers.append(layer)

func unlock_next():
	var result = Vector2(-1,-1)
	if unlocked < lock_spots.size():
		var lock = lock_spots[unlocked]
		# walls.set_cell(lock.x, lock.y, TILE_UNLOCK)
		# unlocked += 1
		result = map_to_screen(Vector2(lock.x, lock.y))
	# if unlocked >= lock_spots.size() and !portal_open:
	# 	open_portal()
	return result

func do_unlock_next(pos):
	var cell = world_to_map(pos)
	var lock = lock_spots[unlocked]
	walls.set_cell(lock.x, lock.y, TILE_UNLOCK)
	unlocked += 1
	if unlocked >= lock_spots.size() and !portal_open:
		open_portal()



func open_portal():
	portal_open = true
	for spot in lock_spots:
		walls.set_cell(spot.x, spot.y, TILE_PORTAL)


func is_portal(cell):
	return walls.get_cell(cell.x, cell.y) == TILE_LOCK
	# return portal_open and walls.get_cell(cell.x, cell.y) == TILE_PORTAL

func apply_level(level):
	var lmap = level.get_node('map')
	var wmap = level.get_node('walls')
	if level.get_node('academy') and level.get_node('academy').get_children().size() > 0:
		var alevel = level.get_node('academy').get_children()[0]
		lmap = alevel.get_node('map')
		wmap = alevel.get_node('walls')
	maxX = lmap.get_used_rect().end.x
	maxY = lmap.get_used_rect().end.y
	map.clear()
	walls.clear()
	wall_map.clear()
	for layer in layers:
		layer.clear()
	map.set_cell(maxX - 1, maxY - 1, get_grass_tile())
	for x in range(maxX):
		for y in range(maxY):
			var v2 = Vector2(x, y)
			if lmap.get_cell(x,y) != -1:
				map.set_cellv(v2, lmap.get_cell(x,y))
			if wmap.get_cell(x,y) != -1:
				set_cellv(v2, wmap.get_cell(x,y))

	# set_cell(5,5, TILE_WALL)
	adjust_map()
	build_wall_map()
	load_locks()
	spawn_spots_player.clear()
	spawn_spots.clear()

func load_locks():
	lock_spots.clear()
	unlocked = 0
	portal_open = false
	for x in range(maxX):
		for y in range(maxY):
			if walls.get_cell(x,y) == TILE_LOCK:
				lock_spots.append(Vector2(x,y))

func clear_food_map():
	food_map.clear()
	pass

func add_food_to_map(pos):
	var cell = world_to_map(pos)
	var cid = String(cell.x) + ':' + String(cell.y)
	food_map[cid] = true

func remove_food_from_map(pos):
	var cell = world_to_map(pos)
	var cid = String(cell.x) + ':' + String(cell.y)
	food_map[cid] = false

func is_food_map(cell):
	var cid = String(cell.x) + ':' + String(cell.y)
	if food_map.has(cid):
		return food_map[cid]
	else:
		return false

func buildSubMap(cx, cy, drange, result):
	var c = 0
	for dx in range(-drange / 2, drange / 2):
		for dy in range(-drange/2, drange / 2):
			var v = 0
			var cell = Vector2(cx + dx, cy + dy)
			if is_wall(cell):
				v = -1
			if is_food_map(cell):
				v = 1
			result.append(v)


func map_to_screen(pos):
	return map.map_to_world(Vector2(pos.x, pos.y)) + Vector2(half_size, half_size)

func get_cell_id(x, y):
	return str(x, 'x', y)

func is_wall(cell):
	var cell_id = get_cell_id(cell.x, cell.y)
	if wall_map.has(cell_id) and !wall_map[cell_id]:
		return false
	else:
		return true

func is_wall_world(pos):
	var cell = world_to_map(pos)
	var cell_id = get_cell_id(cell.x, cell.y)
	if wall_map.has(cell_id) and !wall_map[cell_id]:
		return false
	else:
		return true

func get_next_player_spawn_pos():
	if spawn_spots_player.size() == 0:
		for x in range(maxX):
			for y in range(maxY):
				if PLAYER_PIT_TILES.has(map.get_cell(x,y)):
					spawn_spots_player.append(Vector2(x,y))

	return spawn_spots_player[rand_range(0, spawn_spots_player.size())]

func get_next_spawn_pos():
	if spawn_spots.size() == 0:
		for x in range(maxX):
			for y in range(maxY):
				if PIT_TILES.has(map.get_cell(x,y)):
					spawn_spots.append(Vector2(x,y))

	return spawn_spots[rand_range(0, spawn_spots.size())]

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
	return

	var existing_connections = []

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
						var connection_key = String(cell_index) + '/' + String(cell_id_to_index[cell])
						if !existing_connections.has(connection_key):
							existing_connections.append(connection_key)
							existing_connections.append(String(cell_id_to_index[cell]) + '/' + String(cell_index))
							astar.connect_points(cell_index, cell_id_to_index[cell], true)


func get_grass_tile():
	if rand_range(1, 100) < 50:
		var index = rand_range(1, GRASS_TILES.size())
		return GRASS_TILES[index]
	else:
		return TILE_GRASS


func add_wall(pos):
	var cell = world_to_map(pos)
	var cell_id = get_cell_id(cell.x, cell.y)
	if !cell_id_to_index.has(cell_id):
		return
	var cell_index = cell_id_to_index[cell_id]
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if (dx == 0 or dy == 0) and (dx + dy) != 0:
				var id = get_cell_id(cell.x + dx, cell.y + dy)
				if  cell_id_to_index.has(id) and astar.has_point(cell_id_to_index[id]):
					var index = cell_id_to_index[id]
					if astar.are_points_connected(cell_index, index):
						astar.disconnect_points(cell_index, index)
	wall_map[cell_id] = true


func remove_wall(pos):
	var cell = world_to_map(pos)
	var cell_id = get_cell_id(cell.x, cell.y)
	if !cell_id_to_index.has(cell_id) or get_cell(cell.x, cell.y) == TILE_WALL:
		return
	var cell_index = cell_id_to_index[cell_id]
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if (dx == 0 or dy == 0) and (dx + dy) != 0:
				var id = get_cell_id(cell.x + dx, cell.y + dy)
				if cell_id_to_index.has(id) and astar.has_point(cell_id_to_index[id]):
					var index = cell_id_to_index[id]
					if !astar.are_points_connected(cell_index, index):
						astar.connect_points(cell_index, index, true)
	wall_map[cell_id] = false


func build_wall_map():
	var start_time = OS.get_ticks_msec()
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
	if !astar:
		build_astar()
	var run_time = OS.get_ticks_msec() -  start_time


func adjust_map():
	maxX = map.get_used_rect().end.x
	maxY = map.get_used_rect().end.y
	for x in range(map.get_used_rect().end.x):
		for y in range(map.get_used_rect().end.y):
			if !PIT_TILES.has(map.get_cell(x,y)) and !PLAYER_PIT_TILES.has(map.get_cell(x,y)):
				map.set_cellv(Vector2(x, y), get_grass_tile())

			var d_map = {
				"self": get_cell(x, y),
				"left": get_cell(x - 1, y),
				"right": get_cell(x + 1, y),
				"up": get_cell(x, y - 1),
				"down": get_cell(x, y + 1)
			}

			if get_cell(x,y) != TILE_WALL:
				var index = 0

				if d_map.left == TILE_WALL or x == 0:
					layers[index].set_cellv(Vector2(x, y),TILE_WALL_LEFT)
					index += 1
				if d_map.right == TILE_WALL or x == maxX - 1:
					layers[index].set_cellv(Vector2(x, y),TILE_WALL_RIGHT)
					index += 1
				if d_map.up == TILE_WALL or y == 0:
					layers[index].set_cellv(Vector2(x, y),TILE_WALL_UP)
					index += 1
				if d_map.down == TILE_WALL or y == maxY - 1:
					layers[index].set_cellv(Vector2(x, y),TILE_WALL_DOWN)
					index += 1
