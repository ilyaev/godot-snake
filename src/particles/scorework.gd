extends Node2D

func _ready():
	pass


func _on_Timer_timeout():
	var tween = Tween.new()
	tween.interpolate_property(self, "visibility/opacity", 1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	tween.connect("tween_complete", self, "on_finish", [tween])
	add_child(tween)

func on_finish(obj, key, tween):
	tween.queue_free()
	queue_free()
