extends CharacterBody2D

@export var speed: float = 250.0
@export var max_health: int = 100
@export var attack_power: int = 10
@export var attack_range: float = 80.0
@export var attack_cooldown: float = 0.4

var current_health: int
var current_weapon_attack: int = 0
var current_armor_defense: int = 0
var is_attacking: bool = false
var last_attack_time: int = 0
var ultimate_charge: float = 0.0
var ultimate_max: float = 100.0
var gold: int = 0
var gems: int = 0
var level: int = 1
var experience: int = 0
var experience_for_next_level: int = 100
var facing_right: bool = true

var _sprite: Sprite2D = null
var _attack_flash_timer: float = 0.0
var _damage_flash_timer: float = 0.0
var _skill_cooldowns: Array[float] = [0.0, 0.0, 0.0]
var _ultimate_cooldown: float = 0.0
var _skill_effects: Array = []

enum CharacterClass {
    WARRIOR,
    MAGE,
    ARCHER,
    ASSASSIN
}

@export var character_class: CharacterClass = CharacterClass.WARRIOR

func _ready():
    name = "Player"
    add_to_group("players")
    current_health = max_health
    
    var collision = CollisionShape2D.new()
    var circle = CircleShape2D.new()
    circle.radius = 16
    collision.shape = circle
    collision.position = Vector2(0, 0)
    add_child(collision)
    
    var hitbox = Area2D.new()
    var hitbox_shape = CollisionShape2D.new()
    var hitbox_circle = CircleShape2D.new()
    hitbox_circle.radius = 16
    hitbox_shape.shape = hitbox_circle
    hitbox.add_child(hitbox_shape)
    add_child(hitbox)
    hitbox.body_entered.connect(_on_body_entered)
    hitbox.area_entered.connect(_on_area_entered)
    
    _setup_visuals()

func _setup_visuals():
    if _sprite:
        _sprite.queue_free()
    _sprite = Sprite2D.new()
    _sprite.centered = true
    add_child(_sprite)
    
    var texture = ImageTexture.create_from_image(_create_player_image())
    _sprite.texture = texture

func _physics_process(delta: float):
    _handle_movement(delta)
    _handle_attack()
    _handle_skills()
    _update_cooldowns(delta)
    
    if _damage_flash_timer > 0:
        _damage_flash_timer -= delta
        _sprite.modulate = Color(1.0, 0.3, 0.3, 1.0)
    elif _attack_flash_timer > 0:
        _attack_flash_timer -= delta
        _sprite.modulate = Color(1.0, 1.0, 0.7, 1.0)
    else:
        _sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
    
    for i in range(_skill_effects.size()):
        _skill_effects[i] = _skill_effects[i] - delta

func _handle_movement(delta: float):
    var input_dir: Vector2 = Vector2.ZERO
    
    if Input.is_action_pressed("move_left"):
        input_dir.x -= 1
    if Input.is_action_pressed("move_right"):
        input_dir.x += 1
    if Input.is_action_pressed("move_up"):
        input_dir.y -= 1
    if Input.is_action_pressed("move_down"):
        input_dir.y += 1
    
    input_dir = input_dir.normalized()
    
    if input_dir != Vector2.ZERO:
        velocity = input_dir * speed
        if input_dir.x < 0:
            facing_right = false
        elif input_dir.x > 0:
            facing_right = true
        _sprite.flip_h = not facing_right
    else:
        velocity = velocity.lerp(Vector2.ZERO, 0.5)
    
    move_and_slide()

func _handle_attack():
    if Input.is_action_pressed("attack") and not is_attacking:
        var now: int = Time.get_ticks_msec()
        if now - last_attack_time > attack_cooldown * 1000:
            attack()

func attack():
    is_attacking = true
    last_attack_time = Time.get_ticks_msec()
    _attack_flash_timer = 0.15
    
    var attack_dir: Vector2 = Vector2.RIGHT if facing_right else Vector2.LEFT
    var attack_pos = global_position + attack_dir * 30
    
    var hit = false
    var enemies_list = get_tree().get_nodes_in_group("enemies")
    for enemy in enemies_list:
        var dist = enemy.global_position.distance_to(attack_pos)
        if dist < attack_range:
            var dmg = get_total_attack_power()
            if randf() < 0.1:
                dmg = int(dmg * 1.5)
            enemy.take_damage(dmg)
            hit = true
            ultimate_charge = min(ultimate_charge + 3.0, ultimate_max)
    
    await get_tree().create_timer(0.25).timeout
    is_attacking = false

func _handle_skills():
    for i in range(3):
        if Input.is_action_just_pressed("skill_" + str(i + 1)):
            use_skill(i)
    
    if Input.is_action_just_pressed("ultimate"):
        use_ultimate()

func use_skill(index: int):
    if _skill_cooldowns[index] > 0:
        return
    
    _skill_cooldowns[index] = 3.0
    
    var skill_damage = int(get_total_attack_power() * 2.0)
    var skill_range = 150.0
    
    match index:
        0:
            skill_range = 100.0
            skill_damage = int(get_total_attack_power() * 1.5)
        1:
            skill_range = 180.0
            skill_damage = int(get_total_attack_power() * 2.5)
        2:
            skill_range = 200.0
            skill_damage = int(get_total_attack_power() * 3.0)
    
    var enemies_list = get_tree().get_nodes_in_group("enemies")
    for enemy in enemies_list:
        var dist = enemy.global_position.distance_to(global_position)
        if dist < skill_range:
            enemy.take_damage(skill_damage)
    
    ultimate_charge = min(ultimate_charge + 8.0, ultimate_max)
    print("释放技能 ", index + 1, "！")

func use_ultimate():
    if ultimate_charge < ultimate_max:
        return
    
    ultimate_charge = 0.0
    
    var enemies_list = get_tree().get_nodes_in_group("enemies")
    for enemy in enemies_list:
        if enemy.global_position.distance_to(global_position) < 300:
            enemy.take_damage(int(get_total_attack_power() * 6.0))
    
    print("[终极技能] 释放！")

func _update_cooldowns(delta: float):
    for i in range(3):
        if _skill_cooldowns[i] > 0:
            _skill_cooldowns[i] -= delta

func take_damage(damage: int):
    var actual_damage = max(1, damage - current_armor_defense)
    current_health -= actual_damage
    _damage_flash_timer = 0.2
    
    if current_health <= 0:
        die()

func die():
    print("玩家死亡！")
    
    var game_scene = get_tree().current_scene
    if game_scene and game_scene.has_method("player_died"):
        game_scene.player_died()
    
    queue_free()

func get_total_attack_power() -> int:
    return attack_power + current_weapon_attack

func equip_weapon(attack_bonus: int):
    current_weapon_attack = attack_bonus
    print("装备武器！攻击力 +", attack_bonus)

func equip_armor(defense: int):
    current_armor_defense = defense
    print("装备护甲！防御力 +", defense)

func add_gold(amount: int):
    gold += amount

func add_gem(amount: int):
    gems += amount

func add_experience(amount: int):
    experience += amount
    while experience >= experience_for_next_level:
        experience -= experience_for_next_level
        level += 1
        experience_for_next_level = int(experience_for_next_level * 1.3)
        max_health += 20
        current_health = max_health
        attack_power += 5
        print("升级！等级 ", level)

func heal(amount: int):
    current_health = min(current_health + amount, max_health)

func _on_body_entered(body: Node2D):
    if body.has_method("on_pickup"):
        body.on_pickup(self)
        body.queue_free()

func _on_area_entered(area: Area2D):
    if area.has_method("on_pickup"):
        area.on_pickup(self)
        area.queue_free()

func _create_player_image() -> Image:
    var class_colors = [
        [Color(0.85, 0.75, 0.5), Color(0.6, 0.45, 0.25)],
        [Color(0.6, 0.45, 0.9), Color(0.4, 0.3, 0.6)],
        [Color(0.5, 0.7, 0.4), Color(0.35, 0.5, 0.25)],
        [Color(0.35, 0.3, 0.4), Color(0.2, 0.15, 0.25)]
    ]
    
    var colors = class_colors[min(character_class, class_colors.size() - 1)]
    var main_color = colors[0]
    var edge_color = colors[1]
    
    var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
    img.fill(Color(0, 0, 0, 0))
    
    for y in range(32):
        for x in range(32):
            var cx = x - 16
            var cy = y - 16
            var dist = sqrt(cx * cx + cy * cy)
            
            if dist < 14:
                if dist < 10:
                    img.set_pixel(x, y, main_color)
                else:
                    img.set_pixel(x, y, edge_color)
    
    for y in range(10, 14):
        for x in range(10, 14):
            img.set_pixel(x, y, Color(0.9, 0.85, 0.7))
        for x in range(18, 22):
            img.set_pixel(x, y, Color(0.9, 0.85, 0.7))
    
    img.set_pixel(11, 11, Color(0, 0, 0))
    img.set_pixel(20, 11, Color(0, 0, 0))
    
    return img
