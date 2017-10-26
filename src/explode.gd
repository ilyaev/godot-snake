extends Particles2D


var tween

func _ready():
	tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "visibility/opacity", 1, 0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()



func _on_timer_timeout():
	queue_free()
