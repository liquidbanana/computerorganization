

.include "convenience.asm"

# global veriables
.data
.eqv arena_height 12
.eqv arena_width 12

bullet_x: .word 60
bullet_y: .word 10
bullet_active: .word 0
bullet_side: .word 0

.text
# global functions
.globl shoot
.globl bullet_x
.globl bullet_y
.globl bullet_active
.globl bullet_side
.globl draw_bullet
shoot:
	enter s0, s1, s2, s3
	
	lw s2, bullet_side
	
	
	bullet_move:
		lw s0, bullet_x				# s0 = bullet_x
		lw s1, bullet_y				# s1 = bulelt_y
		
		lw t0, bullet_active	
		beq t0, 1, decide_direction		# check if the bullet is activated by b

		lw t0, action_pressed			# check to see if we should activate the bullet
		beq t0, 0, bullet_move_end		# if not, don't do anything
		beq t0, 1, set_direction		# if yes, decide the direction it should go in
		
		
	decide_direction: 				# check where to send the bullet if active
		lw s2, bullet_side			# checking to see where the bullet should go
		beq s2, 0, bullet_right		# if s2 = 0, bullet goes right
		beq s2, 1, bullet_left			# if s2 = 1, bullet goes left
		
		
	set_direction:					# decide whhere the bullet should go based on the player
		lw s3, player_dir			
		beq s3, 0, bullet_move_right		# if s3 = 0, bullet goes right
		beq s3, 1, bullet_move_left		# if s3 = 1, bullet goes left
		
		
		
	bullet_move_right:				# restting the bullet side to 0 if we are moving right
		li t0, 0
		sw t0, bullet_side			
		
		li t0, 1
		sw t0, bullet_active			# setting the bullet to active
		
		lw s0, player_x				# spawning the bullet on the right side of the player
		lw s1, player_y
		add s1, s1, 1
		add s0, s0, 5
		sw s0, bullet_x				# storing the spawned bulet's coordinates
		sw s1, bullet_y
		
		
	bullet_right:
		bgt s0, 60, deactive_bullet		# checking to see if the bullet hits any bounds
		inc s0					# actually moving the bullet right
	
		move a0, s0				# checking to see if the bullet hits a wall
		move a1, s1
		jal check_wall_pixel
		lw t0, wall
		
		beq t0, 1, deactive_bullet		# if the bullet hits the wall, make it go away
		sw s0, bullet_x				# if the bullet doesn't hit the wall, keep goin
		j bullet_move_end
				
				
	bullet_move_left:
		li t0, 1				# setting the bullet side to left
		sw t0, bullet_side
	
		li t0, 1				# sertting the bullet to active
		sw t0, bullet_active
		
		lw s0, player_x
		lw s1, player_y
		add s1, s1, 1				# spawning the bullet on the left side of the player
		sub s0, s0, 1
		sw s0, bullet_x
		sw s1, bullet_y
		
		
	bullet_left:
		blt s0, 2, deactive_bullet		# if we hit a wall, deactivate the bullet
		dec s0					# actually move the bullet left
	
		move a0, s0	
		move a1, s1
		jal check_wall_pixel			# check if the bullet hit the wall
		lw t0, wall
		
		beq t0, 1, deactive_bullet		# if there's a wall, deactivate the bullet
		sw s0, bullet_x				# if there's no wall, keep moving the bullet
		j bullet_move_end
		

	deactive_bullet:				# deactive the bullet				
		li t0, 0
		sw t0, bullet_active			# set bullet_active = 0
	
	
	bullet_move_end:	
		li t0, 0
		sw t0, wall
		leave s0, s1, s2, s3
	

		
draw_bullet:					# decide whether or not the draw the bullet based on the B key
	enter
	lw t0, bullet_active
	beq t0, 0, do_not_draw_bullet
	beq t0, 1, actually_draw_bullet
	
	actually_draw_bullet:			# if B key is pressed, we will actually spawn the bullet
	lw a0, bullet_x
	lw a1, bullet_y
	li a2, 1
	jal display_set_pixel
	
	do_not_draw_bullet:			# if the bullet is not active, we will not draw anything
	leave
	

	
