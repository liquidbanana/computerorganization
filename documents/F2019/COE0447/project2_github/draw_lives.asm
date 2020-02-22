



.include "convenience.asm"
.data
	heart:	.byte	0 1 0 1 0
		.byte	1 1 1 7 1
		.byte	0 1 1 1 0
		.byte	0 0 1 0 0
		.byte	0 0 0 0 0
		
	block:	.byte 2 3 2 3 3 
		.byte 3 2 2 3 2
		.byte 2 3 2 3 2
		.byte 3 2 2 3 3
		.byte 3 2 3 2 2

	array_of_live_structs: .word 56 58 1
				.word 50 58 1
				.word 44 58 1


	.eqv	life_x			0 # This is the offset of variable pixel_x
	.eqv	life_y			4 # This is the offset of variable pixel_y
	.eqv	life_active		8 # This is the offset of variable pixel 
	
	lives_counter: .word 0
	lives_left: .word 3

.text

.globl draw_lives
.globl lives_counter
.globl lives_get_element
.globl array_of_live_structs
.globl lives_left


draw_lives:
	enter s0, s1, s2
	lw s0, lives_counter
	li s1, 0
	lw s2, lives_left
	
	draw_lives_loop:
		bge s1, s2, end_life		# check if we have printed all the lives already
		move a0, s1
		jal lives_get_element		
		move t0, v0			# get the attributes of the current life
		
		lw a0, life_x(t0)
		lw a1, life_y(t0)
		la a2, heart
		jal display_blit_5x5		# print the life
	
		
		add s1, s1, 1			# increment the counter
		j draw_lives_loop
		
	end_life:
		leave s0, s1
	
		
		
		
# new global function enemies_get_elemen
lives_get_element:
	enter
	la	t0, array_of_live_structs
				# First we load the address of the beginning of the array
	mul	t1, a0, 12	# Then we multiply the index by 12
				#	(the size of a pixel struct) to calculate the offset
	add	v0, t0, t1	# Finally add the offset to the address of the beginning of the array
	# Now v0 contains the address of the element i of the array
	leave
	
	
#		move a0, s1		# x coordinate
#		move a1, s2		# y coordinate
#		la a2, heart		# address pointing to heart
#		jal display_blit_5x5	# display heart
#
#		beq s0, s4, end_life	# check to see if we are at the end of printing the lives
#		sub s1, s1, 6		# modify x coordinates
#		blt s1, 44, end_the_game
#		add s4, s4, 1		# increment the print count for lives
#		j life



	
