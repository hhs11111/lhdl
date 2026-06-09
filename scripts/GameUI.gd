extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var mana_bar: ProgressBar = $ManaBar
@onready var ultimate_bar: ProgressBar = $UltimateBar
@onready var level_label: Label = $LevelLabel
@onready var gold_label: Label = $GoldLabel
@onready var exp_bar: ProgressBar = $ExpBar
@onready var skill_1_button: Button = $SkillButtons/Skill1
@onready var skill_2_button: Button = $SkillButtons/Skill2
@onready var skill_3_button: Button = $SkillButtons/Skill3
@onready var ultimate_button: Button = $UltimateButton
@onready var joystick: Control = $Joystick

var player: Node2D = null
var skill_cooldowns = [0.0, 0.0, 0.0]

func _ready():
    find_player()
    update_ui()

func find_player():
    var players = get_tree().get_nodes_in_group("players")
    if players.size() > 0:
        player = players[0]

func update_ui():
    if player == null:
        find_player()
        return
    
    if player.has_method("get_current_health"):
        health_bar.value = player.get_current_health()
        health_bar.max_value = player.max_health
    
    if player.has_method("get_ultimate_charge"):
        ultimate_bar.value = player.get_ultimate_charge()
        ultimate_bar.max_value = player.ultimate_max
    
    if player.has_method("get_level"):
        level_label.text = "Lv." + str(player.get_level())
    
    if player.has_method("get_gold"):
        gold_label.text = str(player.get_gold()) + " G"
    
    if player.has_method("get_exp"):
        exp_bar.value = player.get_exp()
        exp_bar.max_value = player.get_exp_for_next_level()
    
    if player.has_method("get_skills"):
        var skills = player.get_skills()
        for i in range(min(3, skills.size())):
            var cooldown = skills[i].get_cooldown_remaining()
            skill_cooldowns[i] = cooldown
            update_skill_button(i, cooldown)
    
    if player.has_method("get_ultimate_charge"):
        var charge = player.get_ultimate_charge()
        ultimate_button.disabled = charge < player.ultimate_max
        ultimate_button.modulate = Color(1, 1, 1, min(1, charge / player.ultimate_max))

func update_skill_button(index: int, cooldown: float):
    var buttons = [skill_1_button, skill_2_button, skill_3_button]
    if index >= buttons.size():
        return
    
    var button = buttons[index]
    if cooldown > 0:
        button.disabled = true
        button.text = str(int(cooldown))
    else:
        button.disabled = false
        button.text = str(index + 1)

func _physics_process(delta: float):
    update_ui()
    
    for i in range(3):
        if skill_cooldowns[i] > 0:
            skill_cooldowns[i] -= delta
            update_skill_button(i, skill_cooldowns[i])

func _on_skill_1_button_pressed():
    if player and not skill_1_button.disabled:
        player.use_skill(0)

func _on_skill_2_button_pressed():
    if player and not skill_2_button.disabled:
        player.use_skill(1)

func _on_skill_3_button_pressed():
    if player and not skill_3_button.disabled:
        player.use_skill(2)

func _on_ultimate_button_pressed():
    if player and not ultimate_button.disabled:
        player.use_ultimate()

func _on_joystick_input(event: InputEvent):
    if player == null:
        return
    
    if event is InputEventScreenTouch:
        joystick.rect_scale = Vector2(1.2, 1.2) if event.pressed else Vector2(1, 1)
    
    if event is InputEventScreenDrag:
        var center = joystick.rect_position + joystick.rect_size / 2
        var direction = (event.position - center).normalized()
        var distance = event.position.distance_to(center)
        
        if distance > 30:
            player.set_move_direction(direction)