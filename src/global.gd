extends Node

var current_scene = null

const APP_STATE_START_SCREEN = 0
const APP_STATE_PLAY = 1
const APP_STATE_TOOLS = 2

const CONTROL_DPAD = "0"
const CONTROL_SLIDER = "1"

var state = APP_STATE_START_SCREEN
var control_mode = CONTROL_DPAD

var user_file = 'user://user.json'
var user = {}

var rpc_class = preload("res://src/rpc.gd")
var rpc
var _thr
var _thread_pool

signal rpc_response

func _init():
	_thread_pool = [
		Thread.new(),
		Thread.new(),
		Thread.new()
	]
	rpc = rpc_class.new()
	rpc.connect("response", self, "on_rpc_response")
	rpc.connect("initialized", self, "handshake")
	randomize()
	load_user_info()

func get_free_thread():
	var result
	var index = 0
	for one in _thread_pool:
		if not one.is_active():
			return index
		index = index + 1
	return -1

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
			"name": 'rookie'
		}
		ufile.open(user_file, File.WRITE)
		ufile.store_line(user.to_json())
		ufile.close()
	else:
		ufile.open(user_file, File.READ)
		user.parse_json(ufile.get_line())
		ufile.close()



func handshake():
	call_server_async(gen_rpc_query(["mutation", "handshake", user, '{userid}']))
	load_highscore()

func load_highscore():
	call_server_async(gen_rpc_query(["query", "highscoreSnapshot", {}, '{caption,rows{name,score}}']))


func post_score(score, name = ""):
	if not name:
		name = user.name
	call_server_async(gen_rpc_query(['mutation', 'newScore', {"name": name, "score": int(score), "userid": user.userid}, '{name,score}']))


func gen_user_id():
	var result = String(rand_range(100, 1000)) + '-' + String(rand_range(100,10000)) + '-' + String(rand_range(100,100000))
	return result

func call_server(body):
	return rpc.call(body)

func call_server_async(body):
	var next_thread = get_free_thread()
	if next_thread > 0 or rpc.state != rpc.STATE_READY:
		var timer = Timer.new()
		timer.set_one_shot(true)
		timer.connect("timeout", self, "call_atempt", [body, timer])
		timer.set_wait_time(0.2)
		timer.set_timer_process_mode(Timer.TIMER_PROCESS_FIXED)
		timer.start()
		add_child(timer)
	else:
		_thread_pool[next_thread].start(rpc, "call", [body, _thread_pool[next_thread]])

func call_atempt(body, timer):
	print("Call Next Atempt: ")
	timer.queue_free()
	call_server_async(body)

func on_rpc_response(response, thread, body):
	var command = 'graphql'
	var js = {}
	js.parse_json(body)
	var query = js.query
	command = query.split("{")[1].split("(")[0].split('{')[0]

	if thread:
		thread.wait_to_finish()
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

func back_to_start():
	state = APP_STATE_START_SCREEN
	goto_scene("res://src/start/start.tscn")

func tools():
	state = APP_STATE_TOOLS
	goto_scene("res://src/academy.tscn")

func _deferred_goto_scene(path):
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene( current_scene )
	current_scene.on_scene_enter()


func arr_join(arr, separator = ""):
	var output = "";
	for s in arr:
		output += str(s) + separator
	output = output.left( output.length() - separator.length() )
	return output

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