extends Node2D

onready var piece_class = preload('res://src/animation/vortex_piece.tscn')
var sample
var path
var curve
var target_positions = []

func _ready():
	sample = piece_class.instance()
	path = sample.get_node('path')
	curve = path.get_curve()

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		print("Free SAMPLE")
		sample.free()


func get_point(index):
	return target_positions[index]

func init_target_positions(bcount):
	var index = 0
	var points = curve.tesselate(1)
	var keys = float(points.size())
	target_positions = [points[0]]
	return target_positions
	# var step = keys / bcount
	# for index in range(0, bcount):
	# 	var point = points[int(round(index * step))]
	# 	index = index + 1
	# 	target_positions.append(point)
	# return target_positions
