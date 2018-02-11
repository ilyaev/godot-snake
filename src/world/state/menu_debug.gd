extends "res://src/world/state/base.gd"

var menu_class = preload("res://src/world/debug_menu.tscn")
var menu

const MENU_NEXT_LEVEL = 1
const MENU_WALL = 2
const MENU_GAMEOVER = 3
const MENU_SPAWN_KEY = 4

var snake_speed = 0

func _init():
    name = 'DEBUG_MENU'

func do_on_enter():
    menu = menu_class.instance()
    snake_speed = scene.snake.speed
    scene.snake.set_state(scene.snake.SNAKE_STATE_INVINCIBLE)
    scene.snake.set_speed(1.5)
    menu.menu_items = [
		{"label": "Hit The Wall", "action": MENU_WALL},
		{"label": "Next Level", "action": MENU_NEXT_LEVEL},
        {"label" :"Game Over", "action": MENU_GAMEOVER},
        {"label": "Spawn Key", "action": MENU_SPAWN_KEY}
	]
    menu.connect("on_action", self, "on_action")
    scene.hud.add_child(menu)
    pass

func on_action(action):

    var hide_menu = true
    var pop_state = true

    if action == MENU_WALL:
        scene.snake.set_state(scene.snake.SNAKE_STATE_NORMAL)
        scene.snake.snake_collide()
    if action == MENU_NEXT_LEVEL:
        scene.snake_next_level()
    if action == MENU_GAMEOVER:
        scene.set_state(scene.STATE_GAME_OVER, scene)
        pop_state = false
    if action == MENU_SPAWN_KEY:
        scene.spawn_food()
        hide_menu = false
        pass

    if hide_menu and pop_state:
        scene.pop_state()

func do_on_exit():
    scene.snake.set_speed(snake_speed)
    scene.snake.set_state(scene.snake.SNAKE_STATE_NORMAL)
    scene.hud.remove_child(menu)
    pass

func ui_command(cmd):
    .ui_command(cmd)

func process(delta):
    scene.camera.align_to(scene.snake.head.get_pos())

func game_tick():
    pass
