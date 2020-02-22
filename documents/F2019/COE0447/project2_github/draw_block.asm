

.include "convenience.asm"
.globl board


.data	

	block:	.byte 2 3 2 3 3 
		.byte 3 2 2 3 2
		.byte 2 3 2 3 2
		.byte 3 2 2 3 3
		.byte 3 2 3 2 2
		
	board: 	.word 0,0,0,0,0,0,0,0,0,0,0,0
		.word 0,0,0,1,0,0,0,0,0,0,1,0
		.word 0,0,0,1,1,1,1,1,1,1,1,0
		.word 0,1,0,0,0,0,0,0,0,0,0,0
		.word 0,1,1,0,0,0,0,0,0,0,0,0
		.word 0,0,0,0,1,0,0,1,0,0,0,0
		.word 0,0,0,0,0,1,1,0,0,0,0,0
		.word 0,0,1,0,0,0,0,0,0,1,0,0
		.word 0,1,1,1,1,1,1,1,1,1,1,0
		.word 0,0,0,0,0,0,0,0,0,0,0,0
		.word 1,1,1,1,1,1,1,1,1,1,1,1
		.word 0,0,0,0,0,0,0,0,0,0,0,0
		
.eqv arena_height 12
.eqv arena_width 12
	
.text
.globl draw_block
draw_block:
	enter s0, s1, s2, s3
	li s0, 0		# row
	li s1, 0		# col
	
	li s2, 2		# top right corner x
	li s3, 0		# top right corner y
	
	block_loop:
		beq s1, arena_width, block_increment_row
		beq s0, arena_height, block_end
		
		la a0, board	# address of board
		move a1, s0	# row 
		move a2, s1	# col
		li a3, arena_width
		jal calc_addr
		
		move t0, v0
		lbu t0, (t0)

		beq t0, 0, block_increment_col	# check whether or not to move to the next element
		beq t0, 1, print_block	# check whether or not there's a 1 so that we can print the block
	
	print_block:		# print the block
		move a0, s2
		move a1, s3
		la a2, block
		jal display_blit_5x5
		j block_increment_col

	block_increment_col:	# move on from printing the block
		add s1, s1, 1
		add s2, s2, 5
		j block_loop
		
	block_increment_row:	# increment the row and reset all the boundaries
		li s1, 0
		li s2, 2
		add s0, s0, 1
		add s3, s3, 5
		j block_loop
		
	block_end: 																																																																																																																										
		leave s0, s1, s2, s3		
