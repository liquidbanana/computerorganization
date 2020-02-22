

.include "convenience.asm"
.data
.eqv arena_height 12
.eqv arena_width 12

	player:	.byte 0 0 6 0 0 
		.byte 6 5 5 5 6
		.byte 0 4 5 4 0
		.byte 0 6 6 6 0
		.byte 0 6 0 6 0
		
	player_x: 	.word 7
	player_y: 	.word 0
	tile_x: 	.word 0
	tile_y: 	.word 0
	pixel_x: 	.word 0
	pixel_y: 	.word 0
	wall:		.word 0
	jump_height: 	.word 13
	player_dir:	.word 0

.globl player_x
.globl player_y
.globl player_dir
.globl tile_x
.globl tile_y
.globl pixel_x
.globl pixel_y
	# if player_dir = 0, last movement was right
	# if player_idr = 1, last movement was left

	

.globl wall
.globl display_player
.globl move_player
.globl tile2pixel
.globl pixel2tile
.globl check_wall
.globl check_wall_pixel

.text
display_player:
	enter 	s0, s1, s2
	lw s0, collide
	lw s1, blink
	
	beq s0, 0, draw_normal					# check whether or not to proceed normally
	beq s0, 1, draw_with_blink				# check whether or not to draw with the blinking
		
	draw_with_blink:
		beq s1, 0, reset_blinking			# reset the blink timer
		andi s2, s1, 1					# check whether or not the blink timer decremented to an even value
		
		beq s2, 0, draw_normal				# if it is even, draw the player
		beq s2, 1, donot_draw_player			# if it is odd, don't draw the player
	
	reset_blinking: 
		li t0, 0
		sw t0, inv					# set invincibility equal to 0
		
		li t0, 240					# set the blink counter
		sw t0, blink
	
		li t0, 0					# set collide = 0
		sw t0, collide
		
	draw_normal:					
		lw a0, player_x
		lw a1, player_y
		la a2, player
		jal display_blit_5x5				# draw player
	
		dec s1
		sw s1, blink					# decrement the blink counter
		j end_display_player				
		
	
	donot_draw_player:
		dec s1
		sw s1, blink
	
	end_display_player:
		leave s0, s1
	
	
	
	
	
# new global function move_player
move_player: 
	enter s0, s1
	lw s0, player_x
	lw s1, player_y
	
	move_left:
		lw t0, left_pressed 	# if left pressed, t0 = 1, if not left pressed t0 = 0
		bne t0, 1, move_right	# if left not pressed, go to right
		ble s0, 2, move_right	# blocking the bounds of the blue border
		beq t0, 1, actually_move_left	# if all other conditions are false, allow the guy to move
		
	actually_move_left:
		#print_int s0
		sub s0, s0, 1		# move left
		sw s0, player_x		# store move in player's x coordinate
			
		move a0, s0		
		move a1, s1
		jal check_wall		# calling the check wall function
		lw t3, wall		# seeing if there is a one stored in the check wall matrix
		beq t3, 1, undo_left	# if wall = 1, we undo the move we just did
		li t0, 1
		sw t0, player_dir
		
		b move_right		# otherwise, we change movements
		
		
	
	undo_left: 
		li t3, 0		# resetting the wall variable back to zero so the player can move again
		sw t3, wall		# storing t3 back into wall variable
		add s0, s0, 1		# undoing the left move
		sw s0, player_x		# storing the undo back into undo left
	
		
	move_right:
		lw t0, right_pressed	# if right pressed we want to move right
		bne t0, 1, move_up	# check if right pressed
		bge s0, 57, move_up	# if not pressed, go up
		beq t0, 1, actually_move_right	#if right pressed we want to actually move right
		
	actually_move_right:	
		add s0, s0, 1		# add 1 to x coordinate
		sw s0, player_x		# store back to player_x
		
		move a0, s0
		move a1, s1
		jal check_wall		# check if right going into a wall
		lw t3, wall		# check if wall variable has a 1
		beq t3, 1, undo_right	# undo the right movement
		
		li t0, 0
		sw t0, player_dir
		
		b move_up
		
	undo_right:			# undo the right move if there's a wall
		li t3, 0		
		sw t3, wall	
		sub s0, s0, 1		# reset the wall back to 0
		sw s0, player_x		# store the movement back into player x
			
	move_up:
		lw t0, up_pressed	# check if up pressed
		bne t0, 1, move_down	# if not pressed, move down
		blez s1, move_down	# if at bounds, move down
		# beq t0, 1, actually_move_up
		lw t2, jump_height	# check if the jump height is not at 0
		beqz t2, move_down
		
	actually_move_up:
		lw t4, jump_height	# decrement the amount the player can jump
		dec t4
		sw t4, jump_height	# store back into jump heigt
		
		sub s1, s1, 1		# move up
		sw s1, player_y		# store back into player_y
		
		move a0, s0		
		move a1, s1
		jal check_wall		# check if you are running into a wall
		lw t3, wall		
		beq t3, 1, undo_up	# check if you need to undo the up movement if you run into a wall
		b move_end
	
	undo_up:
		li t3, 0
		sw t3, wall
		add s1, s1, 1
		sw s1, player_y
		
		
	move_down:
		lw t0, jump_height	# gravity
		sub t0, t0, t0		# set jump height to zero so that you fall
		sw t0, jump_height	# store back into jump_height
		# lw t0, down_pressed
		#bne t0, 1, move_end
		#bgt s1, 49, move_end
		#beq t0, 1, actually_move_down
			
	actually_move_down:
		add s1, s1, 1
		sw s1, player_y
		
		move a0, s0
		move a1, s1
		jal check_wall
		lw t3, wall
		beq t3, 1, undo_down
		b move_end
		
	undo_down:
		li t0, 13
		sw t0, jump_height	# set the players ability to jump back to original
		
		li t3, 0		# reset the wall variable back to 0
		sw t3, wall
		sub s1, s1, 1		# undo the down motion
		sw s1, player_y		# store the undone motion in player_y
		
	
move_end:
	leave s0, s1
	
# new global function check_wall
check_wall:	
	enter s0, s1
	lw s0, player_x
	subi s0, s0, 2
	lw s1, player_y
	
	
	top_left_pixel: 	
		move a0, s0
		move a1, s1
		jal pixel2tile		# convert the top left corner to tile coordinate
		
		la a0, board		
		lw a1, tile_y
		lw a2, tile_x
		li a3, 12
		jal calc_addr		# calculate the coordinate
		move t0, v0
		lw t0, (t0)		# check if the coordinate has a 1 or a 0
		
		beq t0, 1, return_true_for_wall # return if there's a 1 in board matrix
		beq t0, 0, bottom_left_pixel
	
	bottom_left_pixel: 
		add s1, s1, 4		# go to the correct coordinate
		
		move a0, s0	
		move a1, s1
		jal pixel2tile		# same procedure as above

		la a0, board
		lw a1, tile_y
		lw a2, tile_x
		li a3, 12
		jal calc_addr
		move t0, v0
		lw t0, (t0)
		
		beq t0, 1, return_true_for_wall
	 	beq t0, 0, top_right_pixel
		
	top_right_pixel:
		add s0, s0, 4		# go to correct coordinate
		sub s1, s1, 4

		move a0, s0
		move a1, s1
		jal pixel2tile		# same procedure as above
		
		la a0, board
		lw a1, tile_y
		lw a2, tile_x
		li a3, 12
		jal calc_addr
		move t0, v0
		lbu t0, (t0)
		
		beq t0, 1, return_true_for_wall
		beq t0, 0, bottom_right_pixel
	
	bottom_right_pixel:
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
		
		beq t0, 1, return_true_for_wall
		beq t0, 0, end_check_wall
	
	return_true_for_wall:	
		li t1, 1	# load a 1 into wall
		sw t1, wall	# store a 1 into wall
		j end_check_wall
end_check_wall:
	leave s0, s1
	

check_wall_pixel:	
	enter s0, s1
	move s0, a0
	move s1, a1
			
	check_pixel: 
		sub s0, s0, 2	
		move a0, s0
		move a1, s1
		jal pixel2tile		# convert the top left corner to tile coordinate
		
		la a0, board		
		lw a1, tile_y
		lw a2, tile_x
		li a3, 12
		jal calc_addr		# calculate the coordinate
		move t0, v0
		lw t0, (t0)		# check if the coordinate has a 1 or a 0
		
		beq t0, 1, return_true_for_wall_pixel # return if there's a 1 in board matrix
		beq t0, 0, return_false
	
	return_true_for_wall_pixel:	
		li t1, 1	# load a 1 into wall
		sw t1, wall	# store a 1 into wall
		j end_check_pixel
		
	return_false:
		li t0, 0
		sw, t0, wall
		j end_check_pixel
		
end_check_pixel:
	leave s0, s1

	
# new global function	
tile2pixel:
	enter
	mul a0, a0, 5		# x coodinate
	mul a1, a1, 5 		# y coordinate
	sw a0, pixel_x		# storing the x coordinate back
	sw a1, pixel_y		# storing the y coordinate back
	leave

pixel2tile:
	enter			
	div a0, a0, 5 		# x coordinate
	div a1, a1, 5 		# y coordinate
	sw a0, tile_x		# storing the x coordinate back
	sw a1, tile_y		# storing the y coordinate back
	leave
