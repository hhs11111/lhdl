extends CharacterBody2D

@export var speed: float = 300.0
@export var max_health: int = 100
@export var attack_power: int = 10
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 0.5

var current_health: int
var current_weapon: Weapon = null
var is_attacking: bool = false
var last_attack_time: float = 0.0
var skills: Array[Skill] = []
var ultimate_charge: float = 0.0
var ultimate_max: float = 100.0
var is_dashing: bool = false
var dash_cooldown: float = 2.0
var last_dash_time: float = 0.0

var animation_player: AnimationPlayer
var hitbox: Area2D
var weapon_node: Node2D

enum CharacterClass {
    WARRIOR,
    MAGE,
    ARCHER,
    ASSASSIN
}

@export var character_class: CharacterClass = CharacterClass.WARRIOR

func _ready():
    animation_player = $AnimationPlayer
    hitbox = $Hitbox
    weapon_node = $Weapon
    current_health = max_health
    init_skills()

func init_skills():
    skills = []
    match character_class:
        CharacterClass.WARRIOR:
            skills.append(Skill.new("旋风斩", 1.5, 20, skill_warrior_1))
            skills.append(Skill.new("冲锋", 2.0, 30, skill_warrior_2))
            skills.append(Skill.new("格挡", 3.0, 0, skill_warrior_3))
        CharacterClass.MAGE:
            skills.append(Skill.new("火球术", 1.0, 25, skill_mage_1))
            skills.append(Skill.new("冰霜新星", 2.5, 35, skill_mage_2))
            skills.append(Skill.new("瞬移", 1.5, 0, skill_mage_3))
        CharacterClass.ARCHER:
            skills.append(Skill.new("多重射击", 1.2, 15, skill_archer_1))
            skills.append(Skill.new("穿透箭", 2.0, 40, skill_archer_2))
            skills.append(Skill.new("闪避", 1.0, 0, skill_archer_3))
        CharacterClass.ASSASSIN:
            skills.append(Skill.new("影袭", 0.8, 30, skill_assassin_1))
            skills.append(Skill.new("烟雾弹", 2.5, 0, skill_assassin_2))
            skills.append(Skill.new("致命一击", 3.0, 60, skill_assassin_3))

func _physics_process(delta: float):
    handle_movement(delta)
    handle_attack()
    handle_skills()
    update_ultimate_charge(delta)

func handle_movement(delta: float):
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
        animation_player.play("walk")
        if input_dir.x < 0:
            $Sprite.flip_h = true
        else:
            $Sprite.flip_h = false
    else:
        velocity = Vector2.ZERO
        if not is_attacking:
            animation_player.play("idle")
    
    if Input.is_action_just_pressed("move_down") and not is_dashing and Time.get_ticks_msec() - last_dash_time > dash_cooldown * 1000:
        dash()
    
    move_and_slide()

func handle_attack():
    if Input.is_action_pressed("attack") and not is_attacking:
        var now: float = Time.get_ticks_msec()
        if now - last_attack_time > attack_cooldown * 1000:
            attack()

func attack():
    is_attacking = true
    last_attack_time = Time.get_ticks_msec()
    animation_player.play("attack")
    
    var attack_direction: Vector2 = Vector2.RIGHT
    if $Sprite.flip_h:
        attack_direction = Vector2.LEFT
    
    var area = get_world_2d().direct_space_state.intersect_shape(
        CollisionShape2D.new(),
        Transform2D(0, attack_direction * attack_range)
    )
    
    for collider in area:
        if collider.is_in_group("enemies"):
            collider.take_damage(get_total_attack_power())
            ultimate_charge += 5.0
    
    await animation_player.animation_finished
    is_attacking = false

func handle_skills():
    for i in range(3):
        if Input.is_action_just_pressed("skill_" + str(i + 1)):
            use_skill(i)

func use_skill(index: int):
    if index < skills.size():
        var skill = skills[index]
        skill.use(self)

func skill_warrior_1():
    print("释放旋风斩")
    ultimate_charge += 10.0

func skill_warrior_2():
    print("释放冲锋")
    ultimate_charge += 15.0

func skill_warrior_3():
    print("释放格挡")
    ultimate_charge += 5.0

func skill_mage_1():
    print("释放火球术")
    ultimate_charge += 10.0

func skill_mage_2():
    print("释放冰霜新星")
    ultimate_charge += 15.0

func skill_mage_3():
    print("释放瞬移")
    ultimate_charge += 5.0

func skill_archer_1():
    print("释放多重射击")
    ultimate_charge += 10.0

func skill_archer_2():
    print("释放穿透箭")
    ultimate_charge += 15.0

func skill_archer_3():
    print("释放闪避")
    ultimate_charge += 5.0

func skill_assassin_1():
    print("释放影袭")
    ultimate_charge += 10.0

func skill_assassin_2():
    print("释放烟雾弹")
    ultimate_charge += 10.0

func skill_assassin_3():
    print("释放致命一击")
    ultimate_charge += 20.0

func update_ultimate_charge(delta: float):
    ultimate_charge = min(ultimate_charge, ultimate_max)

func use_ultimate():
    if ultimate_charge >= ultimate_max:
        match character_class:
            CharacterClass.WARRIOR:
                print("释放战士大招：战神降临")
            CharacterClass.MAGE:
                print("释放法师大招：陨石术")
            CharacterClass.ARCHER:
                print("释放弓箭手大招：箭雨")
            CharacterClass.ASSASSIN:
                print("释放刺客大招：暗影爆发")
        ultimate_charge = 0.0

func dash():
    is_dashing = true
    last_dash_time = Time.get_ticks_msec()
    var dash_dir = Vector2.DOWN
    velocity = dash_dir * speed * 2
    await get_tree().create_timer(0.3).timeout
    is_dashing = false

func take_damage(damage: int):
    current_health -= damage
    if current_health <= 0:
        die()

func die():
    animation_player.play("die")
    await animation_player.animation_finished
    queue_free()

func get_total_attack_power() -> int:
    var power = attack_power
    if current_weapon:
        power += current_weapon.attack_bonus
    return power

func equip_weapon(weapon: Weapon):
    current_weapon = weapon
    weapon_node.add_child(weapon)

func _on_body_entered(body: Node2D):
    if body.is_in_group("items"):
        pickup_item(body)

func pickup_item(item: Node2D):
    if item.has_method("on_pickup"):
        item.on_pickup(self)
    item.queue_free()