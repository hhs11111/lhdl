extends CharacterBody2D

@export var max_health: int = 50
@export var attack_power: int = 5
@export var speed: float = 100.0
@export var experience: int = 10
@export var gold_amount: int = 5
@export var drop_rate: float = 0.3

var current_health: int
var is_alive: bool = true
var _sprite: Sprite2D = null
var _damage_flash_timer: float = 0.0
var _attack_cooldown: float = 1.0
var _last_attack_timer: float = 0.0

enum EnemyType {
    SLIME,
    GOBLIN,
    SKELETON,
    ORC,
    DEMON,
    BOSS
}

@export var enemy_type: EnemyType = EnemyType.SLIME

signal died

func _ready():
    name = "Enemy"
    add_to_group("enemies")
    current_health = max_health
    
    _sprite = Sprite2D.new()
    _sprite.centered = true
    add_child(_sprite)
    
    var texture = ImageTexture.create_from_image(_create_enemy_image())
    _sprite.texture = texture
    
    var collision = CollisionShape2D.new()
    var circle = CircleShape2D.new()
    circle.radius = 14
    collision.shape = circle
    add_child(collision)

func _physics_process(delta: float):
    if not is_alive:
        return
    
    var players = get_tree().get_nodes_in_group("players")
    var player = null
    if players.size() > 0:
        player = players[0]
    
    if player:
        var direction = (player.global_position - global_position).normalized()
        velocity = direction * speed
        
        if velocity.length() > 0:
            _sprite.flip_h = direction.x < 0
        
        move_and_slide()
        
        var dist = global_position.distance_to(player.global_position)
        _last_attack_timer -= delta
        if dist < 40 and _last_attack_timer <= 0:
            _last_attack_timer = _attack_cooldown
            if player.has_method("take_damage"):
                player.take_damage(attack_power)
    
    if _damage_flash_timer > 0:
        _damage_flash_timer -= delta
        _sprite.modulate = Color(1.0, 0.3, 0.3, 1.0)
    else:
        _sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

func take_damage(damage: int):
    current_health -= damage
    _damage_flash_timer = 0.2
    
    if current_health <= 0 and is_alive:
        _die()

func _die():
    is_alive = false
    drop_loot()
    emit_signal("died")
    
    var tween = create_tween()
    tween.tween_property(_sprite, "scale", Vector2(0, 0), 0.3)
    tween.tween_callback(queue_free)

func drop_loot():
    var gold_scene = load("res://scenes/Gold.tscn")
    if gold_scene:
        var gold = gold_scene.instantiate()
        gold.amount = gold_amount
        gold.global_position = global_position + Vector2(randf_range(-15, 15), randf_range(-15, 15))
        get_parent().add_child(gold)
    
    var exp_scene = load("res://scenes/ExpOrb.tscn")
    if exp_scene:
        var exp = exp_scene.instantiate()
        exp.amount = experience
        exp.global_position = global_position + Vector2(randf_range(-15, 15), randf_range(-15, 15))
        get_parent().add_child(exp)
    
    if randf() < drop_rate * 0.3:
        var hp_scene = load("res://scenes/HealthPotion.tscn")
        if hp_scene:
            var hp = hp_scene.instantiate()
            hp.amount = 20
            hp.global_position = global_position + Vector2(randf_range(-15, 15), randf_range(-15, 15))
            get_parent().add_child(hp)
    
    if randf() < drop_rate * 0.4:
        var weapon_scene = load("res://scenes/WeaponPickup.tscn")
        if weapon_scene:
            var weapon = weapon_scene.instantiate()
            weapon.attack_bonus = 5 + int(randf() * 15)
            weapon.rarity = int(randf() * 5)
            weapon.global_position = global_position + Vector2(randf_range(-15, 15), randf_range(-15, 15))
            get_parent().add_child(weapon)
    
    if randf() < drop_rate * 0.15:
        var gem_scene = load("res://scenes/Gem.tscn")
        if gem_scene:
            var gem = gem_scene.instantiate()
            gem.amount = 1
            gem.global_position = global_position + Vector2(randf_range(-15, 15), randf_range(-15, 15))
            get_parent().add_child(gem)

func _create_enemy_image() -> Image:
    var enemy_colors = [
        [Color(0.4, 0.8, 0.4), Color(0.2, 0.5, 0.2)],
        [Color(0.6, 0.5, 0.3), Color(0.4, 0.3, 0.2)],
        [Color(0.9, 0.9, 0.85), Color(0.5, 0.5, 0.5)],
        [Color(0.5, 0.4, 0.3), Color(0.3, 0.2, 0.15)],
        [Color(0.8, 0.3, 0.3), Color(0.4, 0.1, 0.1)],
        [Color(0.7, 0.2, 0.7), Color(0.4, 0.1, 0.4)]
    ]
    
    var idx = min(int(enemy_type), enemy_colors.size() - 1)
    var colors = enemy_colors[idx]
    var main_color = colors[0]
    var edge_color = colors[1]
    
    var img = Image.create(28, 28, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))
    
    for y in range(28):
        for x in range(28):
            var cx = x - 14
            var cy = y - 14
            var dist = sqrt(cx * cx + cy * cy)
            
            if dist < 12:
                if dist < 8:
                    img.set_pixel(x, y, main_color)
                else:
                    img.set_pixel(x, y, edge_color)
    
    img.set_pixel(9, 10, Color(0, 0, 0, 1))
    img.set_pixel(10, 10, Color(0, 0, 0, 1))
    img.set_pixel(17, 10, Color(0, 0, 0, 1))
    img.set_pixel(18, 10, Color(0, 0, 0, 1))
    
    return img
