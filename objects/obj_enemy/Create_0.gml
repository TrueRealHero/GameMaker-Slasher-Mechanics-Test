// Состояние врага.
hp = 200;
dead = false;

// Реакция на попадание.
hurt_timer = 0;
hurt_source = noone;
knockback_speed = 0;

// Временно используем отдельный idle/hurt sprite.
sprite_idle = sIdleEnemy;
sprite_hurt = sHurtEnemy;
sprite_index = sprite_idle;
image_index = 0;
image_speed = 1;

// Hurtbox создаётся отдельно от самого врага.
hurtbox = scr_hurtbox_create(id, 0, -27, 35, 40);
