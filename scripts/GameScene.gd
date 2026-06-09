extends Node2D

var player: Node2D = null
var camera: Camera2D = null
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
    _setup_scene()
    _spawn_player()
    _spawn_initial_enemies()

func _setup_scene():
    var bg = ColorRect.new()
    bg.color = Color(0.15, 0.12, 0.2, 1.0)
    bg.size = Vector2(3000, 3000)
    bg.position = Vector2(-1500, -1500)
    bg.z_index = -100
    add_child(bg)
    
    for i in range(50):
        var decor = ColorRect.new()
        decor.color = Color(0.2 + randf() * 0.1, 0.25 + randf() * 0.1, 0.3 + randf() * 0.1, 0.5)
        decor.size = Vector2(20 + randf() * 60, 20 + randf() * 60)
        decor.position = Vector2(randf_range(-1000, 1000), randf_range(-1000, 1000))
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
    add_child(player)

func set_player_class(class_idx: int):
    selected_class = class_idx
    if player:
        player.character_class = class_idx
        if player.has_method("_setup_visuals"):
            player._setup_visuals()

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
    
    enemy_spawn_timer += delta
    var current_enemy_count = get_tree().get_nodes_in_group("enemies").size()
    
    if current_enemy_count < max_enemies and enemy_spawn_timer >= enemy_spawn_interval:
        enemy_spawn_timer = 0
        _spawn_enemy()

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
