## rpc.gd
# An experiment in using HTTPClient
# for blocking RPCs
# @author bibby<bibby@bbby.org>
#
# get( url )
# post( url, body )
# put( url, body )
# delete( url )

extends Node

const ERROR = 1
const OK = 0

# TODO, setter for domain
var _host = "localhost"
var _port = 80
var _error = ""
var _response = ""

signal response

var client = HTTPClient.new()

func get(url):
	return _request( HTTPClient.METHOD_GET, url, "" )


func call(body):
	var raw = post("/", body)
	print("RPC BODT: ", body)
	print("RPC RESPONSE: ", raw)
	var dict = {}
	if raw and raw[0] == '{':
		dict.parse_json(raw)
	emit_signal("response", dict)
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
			print("HTTPClient entered status ", status)
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

