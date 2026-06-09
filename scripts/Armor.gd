extends Area2D

enum ArmorType {
    HELMET,
    CHEST,
    BOOTS,
    GLOVES
}

enum Rarity {
    COMMON,
    UNCOMMON,
    RARE,
    EPIC,
    LEGENDARY
}

@export var armor_type: ArmorType = ArmorType.CHEST
@export var rarity: Rarity = Rarity.COMMON
@export var defense: int = 5
@export var name: String = "普通护甲"
@export var description: String = "一件普通的护甲"

func _ready():
    add_to_group("items")
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

func get_armor_type_name() -> String:
    match armor_type:
        ArmorType.HELMET: return "头盔"
        ArmorType.CHEST: return "胸甲"
        ArmorType.BOOTS: return "靴子"
        ArmorType.GLOVES: return "手套"
    return ""

func _on_body_entered(body: Node2D):
    if body.is_in_group("players"):
        if body.has_method("equip_armor"):
            body.equip_armor(self)
        queue_free()

func on_pickup(player: Node2D):
    if player.has_method("equip_armor"):
        player.equip_armor(self)