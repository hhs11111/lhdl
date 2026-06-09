extends Node2D

var player: Node2D = null
var camera: Camera2D = null
var hud: CanvasLayer = null
var wave_label: Label
var hp_label: Label
var exp_label: Label
var gold_label: Label

var joystick_area: ColorRect
var joystick_knob: ColorRect
var joystick_active: bool = false
var joystick_start: Vector2 = Vector2.ZERO
var joystick_output: Vector2 = Vector2.ZERO

var attack_button: Button
var skill1_button: Button
var skill2_button: Button
var skill3_button: Button
var ultimate_button: Button

var enemy_spawn_timer: float = 0.0
var enemy_spawn_interval: float = 2.0
var wave: int = 1
var enemies_killed_in_wave: int = 0
var enemies_in_wave: int = 5
var max_enemies: int = 8
var selected_class: int = 0
var game_over: bool = false

func _ready():
    randomize()
    _load_class()
    _setup_scene()
    _spawn_player()
    _spawn_initial_enemies()
    _build_hud()
    _build_mobile_ui()

func _load_class():
    var file = FileAccess.open("user://class_save.txt", FileAccess.READ)
    if file:
        var line = file.get_line()
        if line.is_valid_int():
            selected_class = int(line)
        file.close()

func _setup_scene():
    var bg = ColorRect.new()
    bg.color = Color(0.15, 0.12, 0.2, 1.0)
    bg.size = Vector2(3000, 3000)
    bg.position = Vector2(-1500, -1500)
    bg.z_index = -100
    add_child(bg)

    for i in range(80):
        var decor = ColorRect.new()
        decor.color = Color(0.2 + randf() * 0.1, 0.25 + randf() * 0.1, 0.3 + randf() * 0.1, 0.5)
        decor.size = Vector2(20 + randf() * 60, 20 + randf() * 60)
        decor.position = Vector2(randf_range(-1200, 1200), randf_range(-1200, 1200))
        decor.z_index = -50
        decor.rotation = randf() * 3.14159
        add_child(decor)

    camera = Camera2D.new()
    camera.zoom = Vector2(1.0, 1.0)
    camera.make_current()
    add_child(camera)

func _spawn_player():
    var player_scene = load("res://scenes/Player.tscn")
    if not player_scene:
        print("ERROR: 找不到玩家场景")
        return

    player = player_scene.instantiate()
    player.position = Vector2(0, 0)
    player.character_class = selected_class
    if player.has_method("_setup_visuals"):
        player._setup_visuals()
    add_child(player)

func _build_hud():
    hud = CanvasLayer.new()
    hud.layer = 100
    add_child(hud)

    wave_label = Label.new()
    wave_label.text = "第 1 波"
    wave_label.add_theme_font_size_override("font_size", 28)
    wave_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3, 1.0))
    wave_label.position = Vector2(20, 20)
    hud.add_child(wave_label)

    hp_label = Label.new()
    hp_label.text = "HP: 100/100"
    hp_label.add_theme_font_size_override("font_size", 20)
    hp_label.add_theme_color_override("font_color", Color(0.8, 0.4, 0.4, 1.0))
    hp_label.position = Vector2(20, 70)
    hud.add_child(hp_label)

    exp_label = Label.new()
    exp_label.text = "LV 1  EXP: 0/100"
    exp_label.add_theme_font_size_override("font_size", 20)
    exp_label.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0, 1.0))
    exp_label.position = Vector2(20, 110)
    hud.add_child(exp_label)

    gold_label = Label.new()
    gold_label.text = "金币: 0  宝石: 0"
    gold_label.add_theme_font_size_override("font_size", 20)
    gold_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4, 1.0))
    gold_label.position = Vector2(20, 150)
    hud.add_child(gold_label)

func _build_mobile_ui():
    joystick_area = ColorRect.new()
    joystick_area.color = Color(0.3, 0.3, 0.3, 0.4)
    joystick_area.size = Vector2(150, 150)
    joystick_area.position = Vector2(30, 420)
    joystick_area.roundness = 10
    joystick_area.z_index = 101
    hud.add_child(joystick_area)

    joystick_knob = ColorRect.new()
    joystick_knob.color = Color(0.6, 0.6, 0.6, 0.8)
    joystick_knob.size = Vector2(70, 70)
    joystick_knob.position = Vector2(40, 430)
    joystick_knob.roundness = 10
    joystick_knob.z_index = 102
    hud.add_child(joystick_knob)

    attack_button = Button.new()
    attack_button.text = "攻"
    attack_button.add_theme_font_size_override("font_size", 48)
    attack_button.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4, 1.0))
    attack_button.size = Vector2(90, 90)
    attack_button.position = Vector2(680, 480)
    attack_button.roundness = 10
    attack_button.z_index = 101
    hud.add_child(attack_button)

    skill1_button = Button.new()
    skill1_button.text = "1"
    skill1_button.add_theme_font_size_override("font_size", 24)
    skill1_button.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0, 1.0))
    skill1_button.size = Vector2(60, 60)
    skill1_button.position = Vector2(620, 400)
    skill1_button.roundness = 8
    skill1_button.z_index = 101
    hud.add_child(skill1_button)

    skill2_button = Button.new()
    skill2_button.text = "2"
    skill2_button.add_theme_font_size_override("font_size", 24)
    skill2_button.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6, 1.0))
    skill2_button.size = Vector2(60, 60)
    skill2_button.position = Vector2(690, 400)
    skill2_button.roundness = 8
    skill2_button.z_index = 101
    hud.add_child(skill2_button)

    skill3_button = Button.new()
    skill3_button.text = "3"
    skill3_button.add_theme_font_size_override("font_size", 24)
    skill3_button.add_theme_color_override("font_color", Color(1.0, 0.8, 0.4, 1.0))
    skill3_button.size = Vector2(60, 60)
    skill3_button.position = Vector2(760, 400)
    skill3_button.roundness = 8
    skill3_button.z_index = 101
    hud.add_child(skill3_button)

    ultimate_button = Button.new()
    ultimate_button.text = "大"
    ultimate_button.add_theme_font_size_override("font_size", 32)
    ultimate_button.add_theme_color_override("font_color", Color(0.9, 0.4, 1.0, 1.0))
    ultimate_button.size = Vector2(70, 70)
    ultimate_button.position = Vector2(695, 320)
    ultimate_button.roundness = 8
    ultimate_button.z_index = 101
    hud.add_child(ultimate_button)

    attack_button.pressed.connect(_on_attack_pressed)
    skill1_button.pressed.connect(_on_skill1_pressed)
    skill2_button.pressed.connect(_on_skill2_pressed)
    skill3_button.pressed.connect(_on_skill3_pressed)
    ultimate_button.pressed.connect(_on_ultimate_pressed)

func _spawn_initial_enemies():
    for i in range(3):
        _spawn_enemy()

func _spawn_enemy():
    var enemy_scene = load("res://scenes/Enemy.tscn")
    if not enemy_scene:
        return

    var enemy = enemy_scene.instantiate()

    var angle = randf() * 6.28318
    var dist = 300 + randf() * 200
    var spawn_pos = Vector2(cos(angle) * dist, sin(angle) * dist)

    if player:
        spawn_pos += player.position

    enemy.position = spawn_pos
    enemy.max_health = 40 + wave * 10
    enemy.attack_power = 3 + wave * 2
    enemy.speed = 70 + wave * 5
    enemy.experience = 10 + wave * 3
    enemy.gold_amount = 5 + wave * 2
    enemy.drop_rate = 0.2 + float(wave) * 0.02
    enemy.enemy_type = int(randf() * 5)

    enemy.died.connect(_on_enemy_died)

    add_child(enemy)

func _physics_process(delta: float):
    if game_over:
        return

    if camera and player:
        camera.position = camera.position.lerp(player.position, 0.1)

    _update_hud()
    _update_joystick()

    if Input.is_action_just_pressed("ui_cancel"):
        get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
        return

    enemy_spawn_timer += delta
    var current_enemy_count = get_tree().get_nodes_in_group("enemies").size()

    if current_enemy_count < max_enemies and enemy_spawn_timer >= enemy_spawn_interval:
        enemy_spawn_timer = 0
        _spawn_enemy()

func _update_hud():
    if not player:
        return

    wave_label.text = "第 %d 波" % wave
    hp_label.text = "HP: %d/%d" % [player.get("current_health"), player.get("max_health")]
    exp_label.text = "LV %d  EXP: %d/%d" % [player.get("level"), player.get("experience"), player.get("experience_for_next_level")]
    gold_label.text = "金币: %d  宝石: %d" % [player.get("gold"), player.get("gems")]

func _update_joystick():
    if joystick_active and player and player.has_method("set_joystick_input"):
        var input_dir = joystick_output.normalized()
        player.set_joystick_input(input_dir)

func _on_attack_pressed():
    if player and player.has_method("do_attack"):
        player.do_attack()

func _on_skill1_pressed():
    if player and player.has_method("do_skill"):
        player.do_skill(0)

func _on_skill2_pressed():
    if player and player.has_method("do_skill"):
        player.do_skill(1)

func _on_skill3_pressed():
    if player and player.has_method("do_skill"):
        player.do_skill(2)

func _on_ultimate_pressed():
    if player and player.has_method("do_ultimate"):
        player.do_ultimate()

func _input(event: InputEvent):
    if event is InputEventScreenTouch:
        var touch_pos = event.position
        var joystick_center = Vector2(105, 495)
        if event.pressed:
            if touch_pos.distance_to(joystick_center) < 90:
                joystick_active = true
                joystick_start = touch_pos
                joystick_output = Vector2.ZERO
        else:
            if joystick_active:
                joystick_active = false
                joystick_output = Vector2.ZERO
                joystick_knob.position = Vector2(40, 430)
                if player and player.has_method("set_joystick_input"):
                    player.set_joystick_input(Vector2.ZERO)

    elif event is InputEventScreenDrag and joystick_active:
        var delta = event.position - joystick_start
        joystick_output = delta.clamped(60)
        var knob_pos = Vector2(40, 430) + joystick_output * 0.8
        joystick_knob.position = knob_pos

func _on_enemy_died():
    enemies_killed_in_wave += 1

    if enemies_killed_in_wave >= enemies_in_wave:
        wave += 1
        enemies_killed_in_wave = 0
        enemies_in_wave = 5 + wave * 2
        max_enemies = min(3 + wave, 15)
        enemy_spawn_interval = max(0.5, 2.5 - float(wave) * 0.15)
        print("=== 进入第 ", wave, " 波！敌人总数: ", enemies_in_wave, " ===")

func player_died():
    game_over = true
    print("=== 游戏结束！坚持到了第 ", wave, " 波 ===")

    await get_tree().create_timer(2.0).timeout
    get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
