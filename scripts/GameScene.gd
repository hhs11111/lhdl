extends Node2D

@onready var player: Node2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var ui_layer: CanvasLayer = $UILayer
@onready var map: TileMap = $Map
@onready var enemy_container: Node2D = $EnemyContainer

var drop_system: Node = null
var wave_manager: Node = null
var current_wave: int = 1
var enemies_spawned: int = 0
var enemies_killed: int = 0
var enemies_per_wave: int = 5
var max_enemies_on_screen: int = 3

func _ready():
    drop_system = DropSystem.new()
    get_tree().root.add_child(drop_system)
    
    wave_manager = WaveManager.new()
    add_child(wave_manager)
    
    player.add_to_group("players")
    camera.target = player
    
    start_wave(1)

func _process(delta: float):
    if enemies_killed >= enemies_per_wave:
        current_wave += 1
        enemies_per_wave = 5 + current_wave * 2
        enemies_killed = 0
        enemies_spawned = 0
        start_wave(current_wave)

func start_wave(wave: int):
    print("开始第 ", wave, " 波")
    spawn_enemy()

func spawn_enemy():
    if enemies_spawned >= enemies_per_wave:
        return
    
    var active_enemies = get_tree().get_nodes_in_group("enemies").size()
    if active_enemies >= max_enemies_on_screen:
        return
    
    var enemy_scene = preload("res://prefabs/Enemy.tscn")
    var enemy = enemy_scene.instantiate()
    
    var spawn_positions = [
        Vector2(0, 0),
        Vector2(800, 0),
        Vector2(0, 600),
        Vector2(800, 600),
        Vector2(400, 0),
        Vector2(0, 300),
        Vector2(800, 300),
        Vector2(400, 600)
    ]
    
    var spawn_pos = spawn_positions[rand_range(0, spawn_positions.size() - 1)]
    enemy.global_position = spawn_pos
    
    enemy.max_health = 50 + current_wave * 10
    enemy.attack_power = 5 + current_wave * 2
    enemy.experience = 10 + current_wave * 5
    enemy.gold = 5 + current_wave * 2
    enemy.drop_rate = min(0.3 + current_wave * 0.05, 0.8)
    
    enemy_container.add_child(enemy)
    enemies_spawned += 1
    
    enemy.connect("died", self, "_on_enemy_died")

func _on_enemy_died():
    enemies_killed += 1
    spawn_enemy()

func set_player_class(class_index: int):
    player.character_class = class_index

func _on_player_died():
    get_tree().change_scene_to_file("res://scenes/GameOverScene.tscn")