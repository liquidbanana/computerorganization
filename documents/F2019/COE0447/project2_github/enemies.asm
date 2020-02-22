

.include "convenience.asm"
.data
	# We don't need this array to be visible outside! So no .globl
	array_of_enemy_structs:	.word	42 05 0 0
					.word	25 35 0 1
					.word	30 35 0 0
					.word	25 45 0 0
					.word	57 45 0 0
	
	dude:	.byte 0 0 1 0 0 
		.byte 7 7 1 7 7
		.byte 0 7 1 7 0
		.byte 0 7 1 7 0
		.byte 0 7 0 7 0
	
	collide: .word 0
	blink: .word 240
	inv: .word 0
	enemy_counter: .word 0
	win_lose: .word 0
	

## This file only defines .eqv so that it can be included by other files

.eqv	enemy_x			0 # This is the offset of variable pixel_x
.eqv	enemy_y			4 # This is the offset of variable pixel_y
.eqv	dead_alive		8 # This is the offset of variable pixel selected
.eqv	enemy_direction		12 # This is the offset of variable pixel selected


.text
.globl enemies_get_element
.globl draw_dude
.globl move_enemies
.globl check_enemies_wall
.globl bullet_enemies
.globl player_enemies
.globl collide
.globl blink
.globl inv
.globl enemy_counter
.globl win_lose

# new global function pplayer_enemies
# we will check the player and the enemies collisions
player_enemies:
	enter s0, s1, s2, s3, s4, s5
	# s0 = player_x
	# s1 = player_y
	# s2 = counter
	# s3 = attributes of current enemy
	# s4 = enemy_x
	# s5 = enemy_y
	li s2, 0			
	
	
	player_start_check:
		lw s0, player_x
		lw s1, player_y
	
		move a0, s2
		jal enemies_get_element
		move s3, v0					# define which enemy we are controlling
		
		lw s4, enemy_x(s3)
		lw s5, enemy_y(s3)
	
	player_check_lines: 					# check the bounds of the enemy block to see if the bullet has hit the enemy	
		
		player_vertical:
			add s0, s0, 5
			blt s0, s4, player_no_collision	# if not in bounds, no collision
			
			sub s0, s0, 5
			add s4, s4, 5
			bgt s0, s4, player_no_collision	# if not in bounds, no collision
		
		
		player_horizontal:
			add s1, s1, 5
			blt s1, s5, player_no_collision	# if not in horiz bounds no collision
			
			sub s1, s1, 5
			add s5, s5, 5
			bgt s1, s5, player_no_collision	# if not in horiz bounds no collision


	player_collision:

		lw t0, dead_alive(s3)				# check if the person is dead already, no collision
		beq t0, 1, player_no_collision
		
		li t0, 1
		sw t0, collide
		
		lw t0, inv
		beq t0, 0, dec_life
		beq t0, 1, player_no_collision
		
		
	dec_life:
		li t0, 1				# set invincibility to one
		sw t0, inv
		
		li t0, 240				# set blink to one
		sw t0, blink
		
		
		lw t0, lives_left			# decrement the lives that you have
		dec t0
		sw t0, lives_left
		
		lw t0, lives_counter			# increment the lives counter
		inc t0
		sw t0, lives_counter
		
		beq t0, 3, end_gameplay		# if you lose all of your lives, end the game
		
		
	player_no_collision:
		add s2, s2, 1					# go to the next enemy
		blt s2, 5, player_start_check			# until you have checked all 5 enemies	
		b end_collision_check
		
	end_gameplay:
		li t0, 1
		sw t0, win_lose		
				
						
	end_collision_check:
		leave s0, s1, s2, s3, s4, s5

# new global function bullet_enemies
# we will check the collisions between the bullet and the enemies
bullet_enemies:
	enter s0, s1, s2, s3, s4, s5
	# s0 = bullet_x
	# s1 = bullet_y
	# s2 = counter
	# s3 = attributes of current enemy
	# s4 = enemy_x
	# s5 = enemy_y
	li s2, 0				# counter
	
	
	start_check:
		lw s0, bullet_x
		lw s1, bullet_y
	

		move a0, s2
		jal enemies_get_element
		move s3, v0					# define which enemy we are controlling
		
		lw s4, enemy_x(s3)
		lw s5, enemy_y(s3)
	
	check_lines: 						# check the bounds of the enemy block to see if the bullet has hit the enemy	
		
		vertical:
			blt s0, s4, no_collision		# if not in bounds, no collision
			add s4, s4, 5
			bgt s0, s4, no_collision		# if not in bounds, no collision
		
		
		horizontal:
			blt s1, s5, no_collision		# if not in horiz bounds no collision
			add s5, s5, 5
			bgt s1, s5, no_collision		# if not in horiz bounds no collision


	bullet_collision:
		lw t0, bullet_active				# check if the bullet is active
		beq t0, 0, no_collision			# if the bullet is active, no collision
			
		lw t0, dead_alive(s3)				# check if the person is dead already, no collision
		beq t0, 1, no_collision		
		
		lw t0, enemy_counter
		print_int t0
		inc t0
		sw t0, enemy_counter
		beq t0, 5, lose_the_game
		
		
		li t0, 1					# otherwise, store a 1 in here to indicate the enemy is dead
		sw t0, dead_alive(s3)			
		
		li t0, 0
		sw t0, bullet_active				# when the enemy is dead, deactivate the bullet
		b no_collision

	lose_the_game:
		li t0, 1
		sw t0, win_lose

	no_collision:
		add s2, s2, 1					# go to the next enemy
		blt s2, 5, start_check				# until you have checked all 5 enemies
		leave s0, s1, s2, s3, s4, s5

# new global function move_enemies
move_enemies: 
	enter s0, s1, s2, s3					# s0 is the counter of which enemy to move, s1 = enemy_x and enemy_y
	li s0, 0						# start moving the first enemy + increment the others

	start_movement:
		move a0, s0
		jal enemies_get_element
		move s3, v0					# define which enemy we are controlling
			
		lw t4, enemy_direction(s3)
		# print_int t4
		beq t4, 0, move_left
		beq t4, 1, move_right
		
	
	move_left:
		lw s1, enemy_x(s3)				# load enemy_x coordinate into s1
		lw s2, enemy_y(s3)				# load enemy_y coordinate into s2
	
		li t0, 1
		sw t0, enemy_direction(s3)
		
		sub s1, s1, 1					# move left
		move a0, s1	
		move a1, s2
		jal check_enemies_wall				# check if right going into a wall
			
		lw t3, wall					# check if wall variable has a 1
		beq t3, 1, enemy_move_continue			# undo the right movement
		
		
		beq s1, 1, enemy_move_continue
		
		sw s1, enemy_x(s3)				# store move in player's x coordinate
		li t0, 0
		sw t0, enemy_direction(s3)
		j enemy_move_continue
		
	move_right:	
		li t0, 0
		sw t0, enemy_direction(s3)
	
		lw s1, enemy_x(s3)				# load enemy_x coordinate into s1
		lw s2, enemy_y(s3)				# load enemy_y coordinate into s2
		
		add s1, s1, 1					# move left
		move a0, s1
		move a1, s2
		jal check_enemies_wall				# check if right going into a wall
		
		lw t3, wall					# check if wall variable has a 1
		beq t3, 1, enemy_move_continue			# undo the right movement
		beq s1, 58, enemy_move_continue
		
		sw s1, enemy_x(s3)				# store move in player's x coordinate
		li t0, 1
		sw t0, enemy_direction(s3)
		
		
	enemy_move_continue:
		#print_int s0
		li t0, 0
		sw t0, wall
		add s0, s0, 1
		blt s0, 5, start_movement 			# get all of the enemies to move
		bge s0, 5, move_enemies_end			# once it moves all 5. stop the loop
	
		
move_enemies_end:
	#li t0, 0
	#sw t0, wall
	leave s0, s1, s2, s3
	


# new global function check_enemies_wall
check_enemies_wall:	
	enter s0, s1
	
	move s0, a0
	subi s0, s0, 2
	move s1, a1

	enemies_top_left_pixel: 	
		move a0, s0
		move a1, s1
		jal pixel2tile					# convert the top left corner to tile coordinate
		
		la a0, board		
		lw a1, tile_y
		lw a2, tile_x
		li a3, 12
		jal calc_addr					# calculate the coordinate
		move t0, v0
		lw t0, (t0)					# check if the coordinate has a 1 or a 0
		
		beq t0, 1, enemies_return_true_for_wall 	# return if there's a 1 in board matrix
		beq t0, 0, enemies_bottom_left_pixel
	
	enemies_bottom_left_pixel: 
		add s1, s1, 4					# go to the correct coordinate
		
		move a0, s0	
		move a1, s1
		jal pixel2tile					# same procedure as above

		la a0, board
		lw a1, tile_y
		lw a2, tile_x
		li a3, 12
		jal calc_addr
		move t0, v0
		lw t0, (t0)
		
		beq t0, 1, enemies_return_true_for_wall
	 	beq t0, 0, enemies_top_right_pixel
		
	enemies_top_right_pixel:
		add s0, s0, 4					# go to correct coordinate
		sub s1, s1, 4

		move a0, s0
		move a1, s1
		jal pixel2tile					# same procedure as above
		
		la a0, board
		lw a1, tile_y
		lw a2, tile_x
		li a3, 12
		jal calc_addr
		move t0, v0
		lbu t0, (t0)
		
		beq t0, 1, enemies_return_true_for_wall
		beq t0, 0, enemies_bottom_right_pixel
	
	enemies_bottom_right_pixel:
		#sub s0, s0, 4
		add s1, s1, 4
	
		move a0, s0
		move a1, s1
		jal pixel2tile
		
		la a0, board
		lw a1, tile_y
		lw a2, tile_x
		li a3, 12
		jal calc_addr
		move t0, v0
		lbu t0, (t0)
		
		beq t0, 1, enemies_return_true_for_wall
		beq t0, 0, enemies_end_check_wall
	
	enemies_return_true_for_wall:	
		li t1, 1	# load a 1 into wall
		sw t1, wall	# store a 1 into wall
		j enemies_end_check_wall

enemies_end_check_wall:
	leave s0, s1


# new global function enemies_get_element
enemies_get_element:
	enter
	la	t0, array_of_enemy_structs
				# First we load the address of the beginning of the array
	mul	t1, a0, 16	# Then we multiply the index by 12
				#	(the size of a pixel struct) to calculate the offset
	add	v0, t0, t1	# Finally add the offset to the address of the beginning of the array
	# Now v0 contains the address of the element i of the array
	leave


# new global function draw dude
draw_dude: 
	enter s0 # s0 will be index of enemy array
	li s0, 0
	
	
	draw_loop:
		move a0, s0
		jal enemies_get_element
		move t0, v0
		
		lw t1, dead_alive(t0)
		beq t1, 1, donot_draw			# do not draw the dude (if he's dead)
		beq t1, 0, draw_the_dude		# draw the dude 
		
		
		draw_the_dude:
		lw a0, enemy_x(t0)
		lw a1, enemy_y(t0)
		la a2, dude
		jal display_blit_5x5			# draw the enemy
	
	
		donot_draw:
		inc s0
		beq s0, 5, end_draw_loop
		j draw_loop
		
	end_draw_loop:
		leave s0
	
