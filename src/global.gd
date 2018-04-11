extends Node

var current_scene = null

const APP_STATE_START_SCREEN = 0
const APP_STATE_PLAY = 1
const APP_STATE_TOOLS = 2

const CONTROL_DPAD = "0"
const CONTROL_SLIDER = "1"
const TRY_LIMIT = 50

var state = APP_STATE_START_SCREEN
var control_mode = CONTROL_SLIDER

var user_file = 'user://user.json'
var user = {}
var _start_time = 0

var rpc_class = preload("res://src/rpc.gd")
var rpc
var _thread_pool

const RPC_HANDSHAKE = 'handshake'
const RPC_NEW_SCORE = 'newScore'
const RPC_HS_SNAPSHOT = 'highscoreSnapshot'
const RPC_SCORE_RANK = 'rankByScore'

var last_objects = 0
var map_ref
var mutex = Mutex.new()

var DQN

var perf = {
	"objects": 0,
	"nodes": 0
}

const actions = [{
    dx = 0,
    dy = 1
},
{
    dx = 0,
    dy = -1
},
{
    dx = 1,
    dy = 0
},
{
    dx = -1,
    dy = 0
}]



var rpc_attempt_counter = 0

signal rpc_response
signal action_ready

func _init():
	_thread_pool = [
		Thread.new(),
		Thread.new(),
		Thread.new()
	]
	DQN = preload("dqn/agent.gd").new()
	rpc = rpc_class.new()
	rpc.connect("response", self, "on_rpc_response")
	rpc.connect("initialized", self, "handshake")
	randomize()
	load_user_info()

func update_name(name):
	user.name = name
	var ufile = File.new()
	ufile.open(user_file, File.WRITE)
	ufile.store_line(user.to_json())
	ufile.close()

func load_user_info():
	var ufile = File.new()

	if not ufile.file_exists(user_file):
		user = {
			"userid": gen_user_id(),
			"name": 'Rookie',
			"maxScore": 0
		}
		ufile.open(user_file, File.WRITE)
		ufile.store_line(user.to_json())
		ufile.close()
	else:
		ufile.open(user_file, File.READ)
		user.parse_json(ufile.get_line())
		ufile.close()


func is_deleted(node):
	return str(node) == '[Deleted Object]'


func handshake():
	call_server_async(gen_rpc_query(["mutation", RPC_HANDSHAKE, {"userid": user.userid, "name": user.name}, '{_id, maxScore}']))

func load_highscore():
	call_server_async(gen_rpc_query(["query", RPC_HS_SNAPSHOT, {}, '{caption,rows{name,score}}']))


func load_rank_by_score(score):
	call_server_async(gen_rpc_query(["query", RPC_SCORE_RANK, {"score": score}, '{rank, rankText}']))

func post_score(score, name = ""):
	if not name:
		name = user.name
	call_server_async(gen_rpc_query(['mutation', RPC_NEW_SCORE, {"name": name, "score": int(score), "userid": user._id}, '{name,score}']))
	if int(score) > int(user.maxScore):
		user.maxScore = str(score)
		var ufile = File.new()
		ufile.open(user_file, File.WRITE)
		ufile.store_line(user.to_json())
		ufile.close()
		return true
	return false


func gen_user_id():
	var result = String(rand_range(100, 1000)) + '-' + String(rand_range(100,10000)) + '-' + String(rand_range(100,100000))
	return result

func call_server(body):
	return rpc.call(body)

func call_server_async(body):
	var next_thread = fetch_thread()
	if rpc.state != rpc.STATE_READY:
		var timer = Timer.new()
		timer.set_one_shot(true)
		timer.connect("timeout", self, "call_atempt", [body, timer])
		timer.set_wait_time(0.5)
		timer.set_timer_process_mode(Timer.TIMER_PROCESS_FIXED)
		timer.start()
		add_child(timer)
	else:
		rpc_attempt_counter = 0
		next_thread.start(rpc, "call", [body, next_thread])

func call_atempt(body, timer):
	timer.queue_free()
	rpc_attempt_counter = rpc_attempt_counter + 1
	if rpc_attempt_counter > TRY_LIMIT:
		print("TRY Limit reached")
		return
	call_server_async(body)

func on_rpc_response(response, thread, body):
	var command = 'graphql'
	var js = {}

	js.parse_json(body)
	var query = js.query

	command = query.split("{")[1].split("(")[0].split('{')[0]

	if thread:
		thread.wait_to_finish()

	if typeof(response) == TYPE_DICTIONARY and response.has('data'):
		if command == RPC_HANDSHAKE:
			user._id = response.data.handshake._id
			user.maxScore = response.data.handshake.maxScore
			update_name(user.name)
		emit_signal("rpc_response", response, command)

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )
	if current_scene.has_method("on_scene_enter"):
		current_scene.on_scene_enter()

func set_control_style(mode):
	control_mode = mode

func get_control_style():
	return control_mode

func goto_scene(path):
	call_deferred("_deferred_goto_scene",path)

func _notification(what):
	pass

func start_game():
	state = APP_STATE_PLAY
	goto_scene("res://src/world/root.tscn")

func print_objects(chapter = ""):
	var new_objects = Performance.get_monitor(Performance.OBJECT_COUNT)
	print(chapter, " - obj: ", Performance.get_monitor(Performance.OBJECT_COUNT), " diff: ", new_objects - last_objects)
	last_objects = new_objects

func back_to_start():
	state = APP_STATE_START_SCREEN
	goto_scene("res://src/start/start.tscn")

func tools():
	state = APP_STATE_TOOLS
	goto_scene("res://src/academy.tscn")

func _deferred_goto_scene(path):
	if current_scene.has_method("on_scene_exit"):
		current_scene.on_scene_exit()

	if current_scene.has_method("free"):
		if current_scene._thread_pool.size() > 0:
			for tp in current_scene._thread_pool:
				if tp and tp.is_active():
					tp.wait_to_finish()
		if current_scene.snakes and current_scene.snakes.get_children().size() > 0:
			for sn in current_scene.snakes.get_children():
				if sn.thread and sn.thread.is_active():
					sn.thread.wait_to_finish()
		current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene( current_scene )
	current_scene.on_scene_enter()


func start_time():
	_start_time = OS.get_ticks_msec()

func end_time(caption = "TS"):
	print(caption, ': ', OS.get_ticks_msec() - _start_time)

func arr_join(arr, separator = ""):
	var output = "";
	for s in arr:
		output += str(s) + separator
	output = output.left( output.length() - separator.length() )
	return output

func calculate_dqn_action(timeout, state, snake_id):
	var thread = fetch_thread()
	thread.start(self, '_calculate_dqn_action', [thread, timeout, state, snake_id])

func _calculate_dqn_action(params):
	mutex.lock()
	var action = DQN.act(params[2])
	var world = get_node('/root/world')
	if world and !is_deleted(world):
		var target = world.get_snake_by_id(params[3])
		if target:
			target.calculating = false
			target.next_action = [actions[action]]
	mutex.unlock()
	params[0].wait_to_finish()


func fetch_thread():
	for thread in _thread_pool:
		if !thread.is_active():
			return thread
	var new_thread = Thread.new()
	_thread_pool.append(new_thread)
	print("NEW THREAD!: ", _thread_pool.size())
	return new_thread

func gen_rpc_query(params = ["no", "no", {}, '{}']):
	var scope = params[0]
	var method = params[1]
	var args = params[2]
	var projection = '{}'
	if params.size() >= 4:
		projection = params[3]

	var method_params = ""

	if args.size() > 0:
		var akeys = args.keys()
		var rows = []
		for key in akeys:
			var val = args[key]
			var one = key + ':'
			if typeof(val) == TYPE_STRING:
				one = one + '\"' + val + '\"'
			else:
				one = one + String(val)
			rows.append(one)
		method_params = '(' + arr_join(rows,",") + ')'



	var query = scope + '{' + method + method_params + projection + '}'

	var result = {
		"query": query,
		"variables": {}
	}

	return result.to_json()