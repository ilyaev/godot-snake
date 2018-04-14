extends Node2D

var thread
var running = false
var counter = 0
var queue = []
var queue_mutex
var DQN

signal done

func _init():
	queue_mutex = Mutex.new()
	thread = Thread.new()

func add_task(task):
	queue_mutex.lock()
	queue.append(task)
	queue_mutex.unlock()

func next_task():
	queue_mutex.lock()
	var result = {}
	if queue.size() > 0:
		result = queue.front()
		queue.pop_front()
	queue_mutex.unlock()
	return result

func _ready():
	start()

func start():
	if !running:
		running = true
		thread.start(self, 'process', thread)
		print('Real Start')

func stop():
	if running:
		running = false
		thread.wait_to_finish()
		print('Real Stop')

func get_queue_size():
	queue_mutex.lock()
	var result = 0
	result = queue.size()
	queue_mutex.unlock()
	return result

func process(t):
	print('start!')
	while running:
		var next = next_task()
		if next.has("state"):
			var action = DQN.act(next.state)
			call_deferred("emit_signal", "done", next.snake_id, action)
		else:
			OS.delay_msec(1)
	print('STOP!')


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		stop()