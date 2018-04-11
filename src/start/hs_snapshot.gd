extends Node2D

onready var caption = get_node("title/caption")
onready var title = get_node("title")
onready var global = get_node("/root/global")
onready var row_class = preload('res://src/start/hs_item.tscn')
onready var rows = get_node("rows")

var start_pos = Vector2(-400, 0)
var current_index = 0
var all_data = []

func _ready():
	global.connect("rpc_response", self, "on_rpc_response")
	pass

func on_rpc_response(response, command):
	if command == global.RPC_HS_SNAPSHOT:
		var table = response.data.highscoreSnapshot[0]
		all_data = response.data.highscoreSnapshot
		current_index = 0

		update_table(table)

func update_table(table):
	for child in rows.get_children():
		child.update("","")
		child.queue_free()
	caption.set_text(table.caption)
	roll_in()
	var pos = 0
	for row in table.rows:
		var one = row_class.instance()
		one.set_pos(Vector2(0, pos))
		rows.add_child(one)
		one.update(row.name, row.score)
		pos = pos + one.height

	get_node('title').show()
	get_node('grandtitle').show()
	get_node('loading').hide()

func roll_in():
	title.set_pos(start_pos)
	var tween = Tween.new()
	tween.connect('tween_complete', self, "tween_complete", [tween])
	add_child(tween)
	var new_pos = Vector2(0,0)

	tween.interpolate_property(title, "transform/pos", start_pos, new_pos, 0.7, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()

func tween_complete(obj, key, tween):
	tween.queue_free()


func _on_Timer_timeout():
	current_index = current_index + 1
	if current_index >= all_data.size():
		current_index = 0

	if all_data.size() > 0:
		update_table(all_data[current_index])
