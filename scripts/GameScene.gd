extends Node2D

var player: Node2D = null
var camera: Camera2D = null
var hud: CanvasLayer = null
var wave_label: Label
var hp_label: Label
var exp_label: Label
var gold_label: Label
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

    var hint = Label.new()
    hint.text = "WASD 移动 | 空格 攻击 | 1/2/3 技能 | 4 大招 | Esc 返回菜单"
    hint.add_theme_font_size_override("font_size", 16)
    hint.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1.0))
    hint.position = Vector2(20, 560)
    hud.add_child(hint)

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
    exp_label.text = "LV %d  EXP: %d/%d" % [player.get("level"), player.get("exp"), player.get("exp_for_next_level")]
    gold_label.text = "金币: %d  宝石: %d" % [player.get("gold"), player.get("gems")]

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
