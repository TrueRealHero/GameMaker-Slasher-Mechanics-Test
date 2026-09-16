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

body_width = 20;
body_height = 40;
body_bottom_offset = 0;

jump_speed = -11;
jump_active = true;

// =========================
// AI
// =========================

target = noone;
ai_state = EnemyAIState.IDLE;

detection_range = 300;
attack_range = 70;
attack_level_tolerance = 35;
move_speed = 2;
attack_cooldown = 30;

// Прыжок только для преодоления препятствий.
jump_height_threshold = 48;
jump_check_distance = 28;
jump_target_distance = 300;
jump_cooldown = 0;

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
sprite_run = sRunEnemy;
sprite_jump = sJumpEnemy;
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

scr_movement_initialize_grounded(id);
