extends CharacterBody2D

@export var max_health: int = 50
@export var attack_power: int = 5
@export var speed: float = 100.0
@export var experience: int = 10
@export var gold: int = 5
@export var drop_rate: float = 0.3

var current_health: int
var is_alive: bool = true
var player: Node2D = null
var attack_cooldown: float = 1.0
var last_attack_time: float = 0.0
var animation_player: AnimationPlayer

enum EnemyType {
    SLIME,
    GOBLIN,
    SKELETON,
    ORC,
    DEMON,
    BOSS
}

@export var enemy_type: EnemyType = EnemyType.SLIME

func _ready():
    animation_player = $AnimationPlayer
    current_health = max_health
    add_to_group("enemies")

func _physics_process(delta: float):
    if not is_alive:
        return
    
    if player == null:
        find_player()
        return
    
    var direction = (player.global_position - global_position).normalized()
    velocity = direction * speed
    
    if velocity.length() > 0:
        animation_player.play("walk")
        $Sprite.flip_h = direction.x < 0
    else:
        animation_player.play("idle")
    
    move_and_slide()
    
    handle_attack()

func find_player():
    var players = get_tree().get_nodes_in_group("players")
    if players.size() > 0:
        player = players[0]

func handle_attack():
    if player == null:
        return
    
    var distance = global_position.distance_to(player.global_position)
    
    if distance < 50:
        var now = Time.get_ticks_msec()
        if now - last_attack_time > attack_cooldown * 1000:
            attack()

func attack():
    last_attack_time = Time.get_ticks_msec()
    animation_player.play("attack")
    
    if player.has_method("take_damage"):
        player.take_damage(attack_power)

func take_damage(damage: int):
    current_health -= damage
    
    if current_health <= 0:
        die()

func die():
    is_alive = false
    animation_player.play("die")
    drop_loot()
    
    await animation_player.animation_finished
    queue_free()

func drop_loot():
    var drop_system = get_node_or_null("/root/DropSystem")
    if drop_system != null:
        drop_system.spawn_drop(global_position, drop_rate, gold, experience)
    else:
        spawn_gold()
        spawn_experience()

func spawn_gold():
    var gold_scene = preload("res://prefabs/Gold.tscn")
    var gold_instance = gold_scene.instantiate()
    gold_instance.amount = gold
    gold_instance.global_position = global_position
    get_tree().current_scene.add_child(gold_instance)

func spawn_experience():
    var exp_scene = preload("res://prefabs/ExperienceOrb.tscn")
    var exp_instance = exp_scene.instantiate()
    exp_instance.amount = experience
    exp_instance.global_position = global_position
    get_tree().current_scene.add_child(exp_instance)