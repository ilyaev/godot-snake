extends Node2D

onready var caption = get_node("caption")
onready var global = get_node("/root/global")

func _ready():
	global.connect("rpc_response", self, "on_rpc_response")
	pass

func on_rpc_response(response, command):
	if command == 'highscoreSnapshot':
		var table = response.data.highscoreSnapshot[0]
		update_table(table)

func update_table(table):
	print("UPDATE TABLE:")
	caption.set_text(table.caption + ' Hall Of Fame')
	var index = 0
	for row in table.rows:
		index = index + 1
		var si = String(index)
		get_node("name" + si).set_text(row.name)
		get_node("score" + si).set_text(String(row.score))
	show()