class_name Skill

var name: String
var cooldown: float
var damage: int
var cast_time: float = 0.5
var last_use_time: float = 0.0
var effect_func: Callable = null

func _init(skill_name: String, skill_cooldown: float, skill_damage: int, skill_effect: Callable = null):
    name = skill_name
    cooldown = skill_cooldown
    damage = skill_damage
    effect_func = skill_effect

func can_use() -> bool:
    var now = Time.get_ticks_msec()
    return now - last_use_time >= cooldown * 1000

func use(player: Node2D):
    if can_use():
        last_use_time = Time.get_ticks_msec()
        if effect_func != null:
            effect_func.call()
        return true
    return false

func get_cooldown_remaining() -> float:
    var now = Time.get_ticks_msec()
    var elapsed = (now - last_use_time) / 1000.0
    return max(0.0, cooldown - elapsed)