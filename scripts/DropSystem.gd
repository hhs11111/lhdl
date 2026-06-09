extends Node

var drop_tables = {
    "common": [
        {type: "gold", chance: 0.5, min: 5, max: 15},
        {type: "health", chance: 0.2, min: 10, max: 20},
        {type: "weapon", chance: 0.1, rarity: "common"},
        {type: "armor", chance: 0.1, rarity: "common"},
        {type: "gem", chance: 0.1, min: 1, max: 3}
    ],
    "rare": [
        {type: "gold", chance: 0.4, min: 20, max: 50},
        {type: "health", chance: 0.2, min: 20, max: 40},
        {type: "weapon", chance: 0.15, rarity: "uncommon"},
        {type: "armor", chance: 0.15, rarity: "uncommon"},
        {type: "gem", chance: 0.1, min: 3, max: 6}
    ],
    "boss": [
        {type: "gold", chance: 0.3, min: 100, max: 200},
        {type: "health", chance: 0.2, min: 50, max: 100},
        {type: "weapon", chance: 0.2, rarity: "epic"},
        {type: "armor", chance: 0.2, rarity: "epic"},
        {type: "legendary", chance: 0.1}
    ]
}

var weapon_names = {
    "sword": ["短剑", "长剑", "巨剑", "圣剑", "暗影剑"],
    "axe": ["手斧", "战斧", "巨斧", "烈焰斧", "冰霜斧"],
    "bow": ["短弓", "长弓", "猎弓", "精灵弓", "暗影弓"],
    "staff": ["木杖", "法杖", "元素杖", "虚空杖", "星辰杖"],
    "dagger": ["匕首", "双刃", "毒刃", "影刃", "致命刃"],
    "spear": ["短矛", "长矛", "骑枪", "龙枪", "雷霆枪"]
}

var armor_names = {
    "helmet": ["皮帽", "铁盔", "钢盔", "龙鳞盔", "皇冠"],
    "chest": ["皮甲", "锁甲", "板甲", "龙鳞甲", "神圣甲"],
    "boots": ["皮靴", "铁靴", "钢靴", "疾风靴", "飞行靴"],
    "gloves": ["皮手套", "铁手套", "钢手套", "力量手套", "魔法手套"]
}

func _ready():
    set_name("DropSystem")

func spawn_drop(position: Vector2, drop_rate: float, gold_amount: int, exp_amount: int):
    spawn_gold(position, gold_amount)
    spawn_experience(position, exp_amount)
    
    if randf() < drop_rate:
        var drop_table = "common"
        if drop_rate > 0.5:
            drop_table = "rare"
        elif drop_rate > 0.8:
            drop_table = "boss"
        
        roll_drop(position, drop_table)

func roll_drop(position: Vector2, table_name: String):
    var table = drop_tables.get(table_name, drop_tables["common"])
    
    for drop in table:
        if randf() < drop.chance:
            spawn_item(position, drop)

func spawn_item(position: Vector2, drop: Dictionary):
    match drop.type:
        "gold":
            var amount = rand_range(drop.min, drop.max)
            spawn_gold(position, int(amount))
        "health":
            var amount = rand_range(drop.min, drop.max)
            spawn_health(position, int(amount))
        "gem":
            var amount = rand_range(drop.min, drop.max)
            spawn_gem(position, int(amount))
        "weapon":
            spawn_weapon(position, drop.rarity)
        "armor":
            spawn_armor(position, drop.rarity)
        "legendary":
            if randf() < 0.5:
                spawn_weapon(position, "legendary")
            else:
                spawn_armor(position, "legendary")

func spawn_gold(position: Vector2, amount: int):
    var gold_scene = preload("res://prefabs/Gold.tscn")
    var gold = gold_scene.instantiate()
    gold.amount = amount
    gold.global_position = position + Vector2(rand_range(-20, 20), rand_range(-20, 20))
    get_tree().current_scene.add_child(gold)

func spawn_experience(position: Vector2, amount: int):
    var exp_scene = preload("res://prefabs/ExperienceOrb.tscn")
    var exp = exp_scene.instantiate()
    exp.amount = amount
    exp.global_position = position + Vector2(rand_range(-20, 20), rand_range(-20, 20))
    get_tree().current_scene.add_child(exp)

func spawn_health(position: Vector2, amount: int):
    var health_scene = preload("res://prefabs/HealthPotion.tscn")
    var health = health_scene.instantiate()
    health.amount = amount
    health.global_position = position + Vector2(rand_range(-20, 20), rand_range(-20, 20))
    get_tree().current_scene.add_child(health)

func spawn_gem(position: Vector2, amount: int):
    var gem_scene = preload("res://prefabs/Gem.tscn")
    var gem = gem_scene.instantiate()
    gem.amount = amount
    gem.global_position = position + Vector2(rand_range(-20, 20), rand_range(-20, 20))
    get_tree().current_scene.add_child(gem)

func spawn_weapon(position: Vector2, rarity_str: String):
    var weapon_scene = preload("res://prefabs/Weapon.tscn")
    var weapon = weapon_scene.instantiate()
    
    var weapon_types = ["sword", "axe", "bow", "staff", "dagger", "spear"]
    var weapon_type = weapon_types[rand_range(0, weapon_types.size() - 1)]
    
    weapon.weapon_type = get_weapon_type_enum(weapon_type)
    weapon.rarity = get_rarity_enum(rarity_str)
    weapon.name = get_weapon_name(weapon_type, weapon.rarity)
    weapon.attack_bonus = calculate_weapon_stats(weapon.rarity)
    
    weapon.global_position = position + Vector2(rand_range(-20, 20), rand_range(-20, 20))
    get_tree().current_scene.add_child(weapon)

func spawn_armor(position: Vector2, rarity_str: String):
    var armor_scene = preload("res://prefabs/Armor.tscn")
    var armor = armor_scene.instantiate()
    
    var armor_types = ["helmet", "chest", "boots", "gloves"]
    var armor_type = armor_types[rand_range(0, armor_types.size() - 1)]
    
    armor.armor_type = get_armor_type_enum(armor_type)
    armor.rarity = get_rarity_enum(rarity_str)
    armor.name = get_armor_name(armor_type, armor.rarity)
    armor.defense = calculate_armor_stats(armor.rarity)
    
    armor.global_position = position + Vector2(rand_range(-20, 20), rand_range(-20, 20))
    get_tree().current_scene.add_child(armor)

func get_weapon_type_enum(type_str: String) -> int:
    var types = {"sword": 0, "axe": 1, "bow": 2, "staff": 3, "dagger": 4, "spear": 5}
    return types.get(type_str, 0)

func get_armor_type_enum(type_str: String) -> int:
    var types = {"helmet": 0, "chest": 1, "boots": 2, "gloves": 3}
    return types.get(type_str, 0)

func get_rarity_enum(rarity_str: String) -> int:
    var rarities = {"common": 0, "uncommon": 1, "rare": 2, "epic": 3, "legendary": 4}
    return rarities.get(rarity_str, 0)

func get_weapon_name(weapon_type: String, rarity: int) -> String:
    var names = weapon_names.get(weapon_type, ["武器"])
    var index = min(rarity, names.size() - 1)
    return names[index]

func get_armor_name(armor_type: String, rarity: int) -> String:
    var names = armor_names.get(armor_type, ["护甲"])
    var index = min(rarity, names.size() - 1)
    return names[index]

func calculate_weapon_stats(rarity: int) -> int:
    var base = 5
    var multipliers = [1.0, 1.5, 2.0, 3.0, 5.0]
    return int(base * multipliers[min(rarity, multipliers.size() - 1)] * (1 + rand_range(0, 0.3)))

func calculate_armor_stats(rarity: int) -> int:
    var base = 5
    var multipliers = [1.0, 1.5, 2.0, 3.0, 5.0]
    return int(base * multipliers[min(rarity, multipliers.size() - 1)] * (1 + rand_range(0, 0.3)))