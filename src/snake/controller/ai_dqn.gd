extends "base.gd"

var DQN
var features
var params
var map

const FEATURE_HEAD_COORDINATES = 1
const FEATURE_CLOSEST_FOOD_DICRECTION = 2
const FEATURE_TAIL_DIRECTION = 3
const FEATURE_VISION_CLOSE_RANGE = 4
const FEATURE_VISION_FAR_RANGE = 5
const FEATURE_VISION_MID_RANGE = 6
const FEATURE_TAIL_SIZE = 7
const FEATURE_HUNGER = 8
const FEATURE_FULL_SCAN_6 = 10
const FEATURE_FULL_SCAN_4 = 9
const FEATURE_FULL_SCAN_12 = 12

const MAX_DIST_TO_FOOD = 8


func _init():
    name = 'AI_DQN'

func initialize(params):
    DQN = params[0]
    params = DQN.dict.params
    features = DQN.dict.params.features


func build_state():
    var result = []
    var pos = snake.map.world_to_map(snake.head.get_pos())
    var food_pos = Vector2(0,0)
    if snake.food:
        food_pos = snake.map.world_to_map(snake.food.get_pos())
    var maxX = snake.map.maxX - 1
    var maxY = snake.map.maxY - 1
    var invincible = false
    if snake.state_id == snake.SNAKE_STATE_INVINCIBLE:
        invincible = true
    for featureStr in features:
       var feature = int(featureStr)
       if feature == FEATURE_HEAD_COORDINATES:
            result.append(pos.x / maxX)
            result.append(pos.y / maxY)
       elif feature == FEATURE_CLOSEST_FOOD_DICRECTION:
            result.append(1 - min(MAX_DIST_TO_FOOD,max(food_pos.x - pos.x, -1 * MAX_DIST_TO_FOOD)) / MAX_DIST_TO_FOOD)
            result.append(1 - min(MAX_DIST_TO_FOOD,max(food_pos.y - pos.y, -1 * MAX_DIST_TO_FOOD)) / MAX_DIST_TO_FOOD)
            result.append(1 - (food_pos.x - pos.x) / maxX)
            result.append(1 - (food_pos.y - pos.y) / maxY)
       elif feature == FEATURE_FULL_SCAN_6:
            snake.map.buildSubMap(pos.x, pos.y, 6, result, invincible)
       elif feature == FEATURE_FULL_SCAN_4:
            snake.map.buildSubMap(pos.x, pos.y, 4, result, invincible)
       elif feature == FEATURE_FULL_SCAN_12:
            snake.map.buildSubMap(pos.x, pos.y, 12, result, invincible)
       elif feature == FEATURE_VISION_CLOSE_RANGE:
            for action in global.actions:
                var flag = 0
                if snake.map.is_wall(Vector2(pos.x + action.dx, pos.y + action.dy)):
                    flag = 1
                result.append(flag)

    return result


func random_action():
    var avail = []
    var pos = snake.map.world_to_map(snake.head.get_pos())
    for direction in global.actions:
        if !snake.map.is_wall(Vector2(pos.x + direction.dx, pos.y + direction.dy)):
            avail.append(direction)

    if avail.size() > 0:
        return avail[rand_range(0, avail.size())]
    else:
        return global.actions[0]


func next_command():
    var size = snake.tail.get_children().size()
    var random_chance = max(2, 20 - size * size)
    var action = global.actions[0]
    var pos = snake.map.world_to_map(snake.head.get_pos())

    if rand_range(0, 100) < random_chance:
        action = random_action()
        var command = Vector2(action.dx, action.dy)
        snake.set_target(command * snake.map.snake_size)
        snake.further_command()
    else:
        var state = build_state()
        if snake:
            # snake.calculating = true
            snake.set_fixed_process(false)
            # global.calculate_dqn_action(0.01, state, snake.id)
            snake.map.world.ai_worker.add_task({
                "state": state,
                "snake_id": snake.id
            })


