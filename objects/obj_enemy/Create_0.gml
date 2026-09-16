// =========================
// Основные параметры врага
// =========================

hp = 200;
dead = false;

// =========================
// Реакция на попадание
// =========================

hurt_timer = 0;
hurt_source = noone;
knockback_speed = 0;

// =========================
// Физика
// =========================

ground = layer_tilemap_get_id("Col");

hsp = 0;
vsp = 0;
grounded = false;

// =========================
// AI
// =========================

target = noone;
ai_state = EnemyAIState.IDLE;

detection_range = 500;
attack_range = 70;
move_speed = 2;
attack_cooldown = 30;

// =========================
// Combat
// =========================

current_move = undefined;
move_phase = CombatMovePhase.STARTUP;
move_timer = 0;

move_hit_registered = false;
move_hit_targets = [];

current_damage = 0;
current_knockback = 0;

// =========================
// Sprites
// =========================

sprite_idle = sIdleEnemy;
sprite_hurt = sHurtEnemy;
sprite_attack = sAttack1Enemy;
sprite_index = sprite_idle;
image_index = 0;
image_speed = 1;
image_xscale = 1;
facing = 1;

// =========================
// Hurtbox
// =========================

hurtbox = scr_hurtbox_create(id, 0, -27, 35, 40);
