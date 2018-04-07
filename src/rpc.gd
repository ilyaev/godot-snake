extends Node

const ERROR = 1
const OK = 0

const STATE_NOT_INITED = 0
const STATE_READY = 1
const STATE_PROCESSING = 2

var state = STATE_NOT_INITED

var _host = "pbartz-api-dispatcher.herokuapp.com"
var _port = 80
var _error = ""
var _response = ""

var _thread
var _thread_pool = []

signal response
signal initialized

var client = HTTPClient.new()

func get(url):
	return _request( HTTPClient.METHOD_GET, url, "" )

func _init():
	_thread = Thread.new()
	_thread_pool = [
		Thread.new(),
		Thread.new(),
		Thread.new()
	]
	_thread_pool[0].start(self, "init_host", _thread_pool[0])

func get_free_thread():
	var result
	var index = 0
	for one in _thread_pool:
		if not one.is_active():
			return index
		index = index + 1
	return -1


func init_host(thread):
	state = STATE_NOT_INITED
	var raw = post("/", '{"query":"query {godotSnakeServerHost {host,port}}","variables":null}')
	var dict = {}
	if raw and raw[0] == '{':
		dict.parse_json(raw)
	if dict.has('data'):
		_host = dict.data.godotSnakeServerHost.host
		_port = dict.data.godotSnakeServerHost.port
		state = STATE_READY
		print("RPC Ready: ", _host,":", _port)
		emit_signal("initialized")
	thread.wait_to_finish()

func call(params):
	var body = params[0]
	var thread = params[1]
	if state != STATE_READY:
		print("RPC api not ready for: ", body)
		return
	state = STATE_PROCESSING
	var raw = post("/", body)
	# print("RPC BODT: ", body)
	# print("RPC RESPONSE: ", raw)
	var dict = {}
	if raw and raw[0] == '{':
		dict.parse_json(raw)

	emit_signal("response", dict, thread, body)
	state = STATE_READY
	return dict

# TODO, form encode collections if desired
func post(url, body):
	return _request( HTTPClient.METHOD_POST, url, body)

func put(url, body):
	return _request( HTTPClient.METHOD_PUT, url, body)

func delete(url):
	return _request( HTTPClient.METHOD_DELETE, url, "" )

func _request(method, url, body):
	_response = ""
	var res = _connect()
	if( res == ERROR ):
		return _getErr()
	else:
		client.request( method, url, StringArray(["User-Agent: godot game engine", "Content-Type: application/json","Content-Length: " + String(body.length())]), body)
		# TODO, Content-Type and other headers

	res = _poll()
	if( res != OK ):
		return _getErr()

	client.close()
	return _response

func _connect():
	client.connect(_host, _port)
	var res = _poll()
	if( res != OK ):
		return ERROR
	return OK

func _getErr():
	return _error

func _setError(msg):
	_error = str(msg)
	return ERROR

func _poll():
	var status = -1
	var current_status
	while(true):
		client.poll()
		current_status = client.get_status()
		if( status != current_status ):
			status = current_status
			# print("HTTPClient entered status ", status)
			if( status == HTTPClient.STATUS_RESOLVING ):
				continue
			if( status == HTTPClient.STATUS_REQUESTING ):
				continue
			if( status == HTTPClient.STATUS_CONNECTING ):
				continue
			if( status == HTTPClient.STATUS_CONNECTED ):
				return OK
			if( status == HTTPClient.STATUS_DISCONNECTED ):
				return _setError("Disconnected from Host")
			if( status == HTTPClient.STATUS_CANT_RESOLVE ):
				return _setError("Can't Resolve Host")
			if( status == HTTPClient.STATUS_CANT_CONNECT ):
				return _setError("Can't Connect to Host")
			if( status == HTTPClient.STATUS_CONNECTION_ERROR ):
				return _setError("Connection Error")
			if( status == HTTPClient.STATUS_BODY ):
				return _parseBody()

func _parseBody():
	_response = client.read_response_body_chunk().get_string_from_ascii()
	var response_code = client.get_response_code()
	if( response_code >= 200 && response_code < 300 ):
		return OK

	if( response_code >= 400 ):
		return _setError( "HTTP:" + str(response_code) )
	return OK

