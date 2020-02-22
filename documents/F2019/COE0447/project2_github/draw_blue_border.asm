

.include "convenience.asm"
.data
.text
.globl draw_blue_border
draw_blue_border:
	
	enter
	left_side:
				# start at coordinates (0,0)
		li a0, 0 	# height of the left border
		li a1, 0 	# width
		li a2, 2
		li a3, 64
		li v1, 5
		
		jal display_fill_rect
		

	right_side:
				# start coordinates at (63,0)
		li a0, 62 	# height of the left border
		li a1, 0 	# width
		li a2, 2
		li a3, 64
		li v1, 5
		
		jal display_fill_rect

	bottom_border:
				# start at coordinates (0, 55)
		li a0, 0 	# height of the left border
		li a1, 55 	# width
		li a2, 64
		li a3, 2
		li v1, 5
		
		jal display_fill_rect

	leave
