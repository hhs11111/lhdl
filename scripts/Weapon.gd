extends Node2D

enum WeaponType {
    SWORD,
    AXE,
    BOW,
    STAFF,
    DAGGER,
    SPEAR
}

enum Rarity {
    COMMON,
    UNCOMMON,
    RARE,
    EPIC,
    LEGENDARY
}

@export var weapon_type: WeaponType = WeaponType.SWORD
@export var rarity: Rarity = Rarity.COMMON
@export var attack_bonus: int = 5
@export var attack_speed: float = 1.0
@export var critical_chance: float = 0.05
@export var critical_damage: float = 1.5
@export var name: String = "普通武器"
@export var description: String = "一把普通的武器"

func _ready():
    set_rarity_color()

func set_rarity_color():
    var sprite = $Sprite
    match rarity:
        Rarity.COMMON:
            sprite.modulate = Color(0.8, 0.8, 0.8)
        Rarity.UNCOMMON:
            sprite.modulate = Color(0.0, 1.0, 0.0)
        Rarity.RARE:
            sprite.modulate = Color(0.0, 0.5, 1.0)
        Rarity.EPIC:
            sprite.modulate = Color(0.5, 0.0, 1.0)
        Rarity.LEGENDARY:
            sprite.modulate = Color(1.0, 0.7, 0.0)

func get_rarity_name() -> String:
    match rarity:
        Rarity.COMMON: return "普通"
        Rarity.UNCOMMON: return "优秀"
        Rarity.RARE: return "稀有"
        Rarity.EPIC: return "史诗"
        Rarity.LEGENDARY: return "传说"
    return ""

func get_weapon_type_name() -> String:
    match weapon_type:
        WeaponType.SWORD: return "剑"
        WeaponType.AXE: return "斧"
        WeaponType.BOW: return "弓"
        WeaponType.STAFF: return "法杖"
        WeaponType.DAGGER: return "匕首"
        WeaponType.SPEAR: return "矛"
    return ""