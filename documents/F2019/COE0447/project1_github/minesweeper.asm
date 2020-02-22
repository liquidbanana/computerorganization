# Project 1: MARSweeper

.data
	# here are the eqv values
	.eqv board_size 25
	.eqv board_height 5
	.eqv board_width 5
	.eqv number_of_mines 5
	
	# here is the debug mode
	debug: .word 0
	
	# here are the instructions
	asciiz_instructions: .asciiz "\nWelcome to MARSweeper. \nIt plays just like MINESweeper, except you need to enter the coordinates of the block you want to reveal! \nYou win a point for each tile you reveal that does not hide a mine.\nRemember that the index for the rows and columns will start at 0!\n"
	asciiz_get_row: .asciiz "\nPlease choose the row you want to reveal: "
	asciiz_get_col: .asciiz "Please choose the column you want to reveal: "
	asciiz_invalid: .asciiz "\nYour input is invalid."
	asciiz_repeat:	.asciiz "You already input that coordinate. Please choose another!"
	asciiz_win:	.asciiz "\n\nYour score is now: "
	asciiz_lose:	.asciiz "\n\nYOU LOSE! You landed on a mine. Your final score is: " 
	asciiz_win_game: .asciiz "\nYOU WIN! The board is clear. Your score is: "

	star: .asciiz "*" 
	newLine: .asciiz "\n"
	space: .asciiz " "

	# store the user guess
	word_user_row: .word 0
	word_user_col: .word 0
	
	# here are the initial two matrices
	# this is the board we will change
	hidden_board:	.word 0: board_size
	
	# this is the board we will reveal to the user	      	
	user_board:	.word 0: board_size
	
.text
.globl main
main: 
	
	li s5, 0	# initializing a counter for the user's score
	li s6, 0	# initializing a counter for winning the game
	li t5, board_size
	li t6, number_of_mines
	sub s6, t5, t6	# this is the max amount of points the user can get to win the game

	
	jal instructions_func 	# print the instructions	
	jal print_board		# print the board to the user
	jal prompt_row		# ask for the row
	move s0, v0
	sw s0, word_user_row
	jal prompt_col		# ask for the column
	move s1, v0
	sw s1, word_user_col
	move a1, v0
	move a0, s0
	
	
	jal generate_board	# generate the board with the mines + increment
	jal increment_user_board # we are adding ones in the blank user board in order to increment the user board
	jal print_board

	
	gameLoop:	
	# ask user for a coordinate
	# check the coordinate
	# add a point or lose the game
	# print the board out
	# go back to the top
		jal win
		jal prompt_row		# ask for the row
		move s0, v0
		sw s0, word_user_row
		
		jal prompt_col		# ask for the column
		move s1, v0
		move a1, v0
		move a0, s0
		sw s1, word_user_col
		jal repeat_coord
		jal increment_user_board # we are adding ones in the blank user board (that usually has stars) in order to increment the user board
		jal print_board
		j gameLoop

	# end of program
	endgameLoop:
		la a0, asciiz_lose
		li v0, 4
		syscall
		
		move a0, s5
		li v0, 1
		syscall

	endgame:
		li v0, 10
		syscall
	
	# winning the game!
	win: 
		push ra
		# check if the user is still winning the game
		la a0, hidden_board
		lw a1, word_user_row	# user input
		lw a2, word_user_col	# user input
		jal calc_elem_addr	# getting the coordinate of the user input
		move t0, v0	# getting the address
		lw t0, (t0)	# loadng the value of the user input coordinate

		
		blt t0, 0, endgameLoop	# checking if the user coordinate will land on a mine
		j loop_win
		
		loop_win:

			add s5, s5, 1
			la a0, asciiz_win	# print out the win statement
			li v0, 4
			syscall
			
			move a0, s5
			li v0, 1		# print the score
			syscall
			beq s5, s6, loop_win_game
			j loop_win_end
			
		loop_win_game:
			la a0, asciiz_win_game
			li v0, 4
			syscall	
			
			move a0, s5
			li v0, 1
			syscall
			j endgame
			
		loop_win_end:
			pop ra
			jr ra
	
	# we are only printing the instructions here!
	instructions_func:
		la a0, asciiz_instructions
		li v0, 4
		syscall
		jr ra
	# end function


	# here we will get the user input for the row
	prompt_row:
		la a0, asciiz_get_row
		li v0,4
		syscall
		
		li v0, 5
		syscall
		move t0, v0
		blt t0, 0, invalid_row
		bge t0, board_height, invalid_row
		jr ra
	# end function
		
	
	# here we will get the user input for the row
	prompt_col:
		la a0, asciiz_get_col
		li v0,4
		syscall
		
		li v0, 5
		syscall
		move t1, v0
		blt t1, 0, invalid_col
		bge t1, board_width, invalid_col
		jr ra
	# end function
	
	# here we will get check the user inputs for the rows and cols if they are out of bounds
	invalid_row:
		la a0, asciiz_invalid
		li v0, 4
		syscall
		j prompt_row
		
	invalid_col:
		la a0, asciiz_invalid
		li v0, 4
		syscall
		j prompt_col
	# end function
	
	
	# here we are checking whether or not the user has already input a coordinate
	repeat_coord:
		push ra
		lw a1, word_user_row
		lw a2, word_user_col
		la a0, user_board
		jal calc_elem_addr
		move t0, v0
		lw t0, (t0)
		bne t0, 1, continue_game
		
		user_input_again:
		sub s5, s5, 1
		la a0, asciiz_repeat
		li v0, 4
		syscall
		jal gameLoop
		
		continue_game:
		pop ra
		jr ra
	# end function
	
	

	# in print board, we will check if debug has 0 or 1. if 0, we will print the board with stars and remove
	# a star with the underlying number. if 1, we will reveal the board and add a star 
	print_board:
		push ra 
		initialize_iteration:	
			li s3, 0				# row index (i)
			li s4, 0				# i
			li s0, 0				# iterateRowLoop counter (i++)
			j iterateRowLoop
			pop ra
			jr ra

		nextRow:					#after the loop has gone through all of the elements in the first row, we go to the next
			add s3, s3, 1
			li s4, 0
	
		iterateRowLoop: 
			bge s0, board_width, loop_end		# check whether or not the loop has gotten to the end of the row
			la a0, hidden_board			# load the hidden array
			move a1, s3				# give the row index to a1
			li a2, board_height			# load the col index into a2	
	
			jal calc_row_addr
			jal print_board_row
				
			addi s0, s0, 1				# count ++ for the next column we want to go to
			li s1, 0				# reset row counter as we go to the next row!!!!!!!!!1
	
		loop_element:
			li t0, board_height
			bge s1, t0, nextRow 			# branches to a new row
		
	check_debug:
		lw t7, debug
		beqz t7, nextrevealElement
		
		nextElement:	# DEBUG MODE
			# here i want to add a star to the hidden board for debug mode
			la a0, hidden_board			# base address of matrix 1
			move a1, s3				# row index
			move a2, s4				# element index
			li a3, board_width			# number of elements in row
		
			jal calc_elem_addr
			jal print_board_col

			addi s1, s1, 1				# counter++
			add s4, s4, 1				# increment element index
			j loop_element	
			
		nextrevealElement:	# REGULAR GAME MODE
			# here i want to remove a star to the user coordinate
			la a0, user_board		# base address of matrix 1
			move a1, s3				# row index
			move a2, s4				# element index
			li a3, board_width			# number of elements in row
		
			jal calc_elem_addr
			jal print_star

			addi s1, s1, 1				# counter++
			add s4, s4, 1				# increment element index
			j loop_element	

	loop_end:						# ending of the loop_end
		pop ra
		jr ra		
	# end function				

	
	print_board_row:
		push ra
		move t0, v0				# move the return in v0 from calc row addr to t0
		lw t0, (t0)				# load t0 (row 1, in the first iteration, sanity check)
		
		la a0, newLine				# print out a new line
		li v0, 4
		syscall

		board_row_end:
			la a0, space				# print out an indent for matrix format
			li v0, 4
			syscall
			pop ra
			jr ra
	

	print_board_col:
		push ra
		move t0, v0
		lw t0, (t0)
		
		# i already added a star to the user matrix, now I am going to check if i need to print the hidden index\
		la a0, user_board
		jal calc_elem_addr
		move t0, v0
		lw t0, (t0)
		beq t0, 1, add_star
		
		print_normal:
			la a0, hidden_board
			jal calc_elem_addr
			move t0, v0
			lw t0, (t0)
			
			move a0, t0
			li v0, 1
			syscall
			j board_col_end
		
		add_star:
			la a0, hidden_board
			jal calc_elem_addr
			move t0, v0
			lw t0, (t0)
			
			la a0, star
			li v0, 4
			syscall
			j board_col_end
		
		board_col_end:
			la a0, space				# print out an indent for matrix format
			li v0, 4
			syscall
			pop ra
			jr ra
		
	
	print_star:
		push ra
		# move t0, v0				# print out the first value in the row	
		
		
		la a0, user_board
		jal calc_elem_addr
		move t0, v0
		lw t0, (t0)
		beq t0, 1, remove_star
		
		
		print_star_normally:
			la a0, star
			li v0, 4
			syscall
			j print_star_end
		
		remove_star:
			la a0, hidden_board
			jal calc_elem_addr
			move a0, v0
			lw a0, (a0)
			li v0 1, 
			syscall
			j print_star_end
		

		print_star_end:
			la a0, space				# print out an indent for matrix format
			li v0, 4
			syscall
	
			pop ra
			jr ra
					
		
	# beginning of generate board function
	generate_board:
		push ra
		push s0		# user input for ROW
		push s1		# user input for COL
		push s2		# random number for ROW
		push s3		# random number for COL
		
		move s0, a0	# move argument from user into s0 ROW
		move s1, a1	# move argument from yser into s1 COL 
		
		# in the main function i have the row passed in as a0
		# in the main function i have the col passed in as a1
		# now I will need to load immediate eqv value
		
		li t0, number_of_mines
		la a2, hidden_board
		li t7, 0 	# t7 will be my counter!!1!
		
		
		generate_loop:
			jal random_row_generator
			move s2, v0	# move return from random row generator to s2
		
			jal random_col_generator
			move s3, v0	# move return from random col generator to s3
		
			# check if the random numbers are not equal to the user input numbers
			bne s2, s0, valid_input
			bne s3, s1, valid_input
			b generate_loop
		
		valid_input:
			la a0, hidden_board
			move a1, s2
			move a2, s3
			jal calc_elem_addr
			lw t6, (v0)
		
			beq t6, -1, generate_loop
			li t6, -1
			sw t6, (v0)
		
			# increment the tiles around the miles
			jal increment_mine_index
			
			add t7, t7, 1
			blt t7, number_of_mines, generate_loop
		
		pop s3
		pop s2	
		pop s1
		pop s0
		pop ra
		jr ra
		
	# begin random row generator function
	random_row_generator:
		push ra
		# a1 is upper bound
		# a0 lower bound
		li a0, 0
		li a1, board_width
		li v0, 42
		syscall
		move v0,a0

		pop ra
		jr ra
	# end random row generator function	
		
		
	# begin random col generator	
	random_col_generator:
		push ra
		li a0, 0		# load 0 into a0 as lower bound
		li a1, board_height	# load board_height into a1 as upper bound

		li v0, 42
		syscall
		move v0, a0		# move return form v0 to a0 as return argument

		pop ra
		jr ra
	# end random col generator
	
	# this function will mark the user board based on the user input	
	increment_user_board:		
		push ra
		li t1, 1
		la a0, user_board
		move a1, s0
		move a2, s1
		jal calc_elem_addr
		lw t5, (v0)
		sw t1, (v0)
		
		pop ra
		jr ra
	# end function
	
	
	calc_row_addr:
		push ra
		mul t8, a1, a2 				# t0 = a1 x a2 (index of the row X number of elements in the row)
		mul t8, t8, 4 				# t0 = t0 X 4 (+ size of address)
		add t8, t8, a0 				# t0 = t0 + a0(+ original address)
		move v0, t8 				# storing t0 in v0
		pop ra
		jr ra
	
	calc_elem_addr:
		push ra
		mul t8, a1, 20 				# t8 = a1 x 20 (index of the row x number of spaces you need to move)
		mul t9, a2, 4  				# t9 = a2 x 4  (index of col x address you want to move by)
		add t8, t8, t9
		add t8, t8, a0
		move v0, t8
		pop ra
		jr ra
		
	increment_mine_index:
		push ra
		# s2 is the random row generated
		# s3 is the random col generated
		
		north:
			sub s2, s2, 1 # go up one row
			blt s2, 0, north_east
			bge s3, board_width, north_east # check if the index of the column will be greater than zero
			blt s3, 0, north_east
			bge s2, board_height, north_east
		
	
			la a0, hidden_board		# load values and calculate element address
			move a1, s2
			move a2, s3
			jal calc_elem_addr
			move t0, v0			# move element address so we can check the actual value
			lw t5, (t0)
		
			beq t5, -1, north_east	# check if the index if there is already a mine here
			add t5, t5, 1	# increment the tiles around the mine!
			sw t5, (t0)
		
		north_east:
			add s3, s3, 1 # go over one column
			blt s2, 0, east
			bge s3, board_width, east # check if the index of the column will be greater than zero
			blt s3, 0, east
			bge s2, board_height, east
		
	
			la a0, hidden_board		# load values and calculate element address
			move a1, s2
			move a2, s3
			jal calc_elem_addr
			move t0, v0			# move element address so we can check the actual value
			lw t5, (t0)
		
			beq t5, -1, east	# check if the index if there is already a mine here
			add t5, t5, 1		# increment the tiles around the mine!
			sw t5, (t0)
		
		east:
			add s2, s2, 1 # go back down one row
			blt s2, 0, south_east
			bge s3, board_width, south_east # check if the index of the column will be greater than zero
			blt s3, 0, south_east
			bge s2, board_height, south_east
		
	
			la a0, hidden_board		# load values and calculate element address
			move a1, s2
			move a2, s3
			jal calc_elem_addr
			move t0, v0			# move element address so we can check the actual value
			lw t5, (t0)
		
			beq t5, -1, south_east	# check if the index if there is already a mine here
			add t5, t5, 1		# increment the tiles around the mine!
			sw t5, (t0)
	
		south_east:
			add s2, s2, 1 # go back down one row
			blt s2, 0, south
			bge s3, board_width, south # check if the index of the column will be greater than zero
			blt s3, 0, south
			bge s2, board_height, south
		
	
			la a0, hidden_board		# load values and calculate element address
			move a1, s2
			move a2, s3
			jal calc_elem_addr
			move t0, v0			# move element address so we can check the actual value
			lw t5, (t0)
			
			beq t5, -1, south	# check if the index if there is already a mine here
			add t5, t5, 1		# increment the tiles around the mine!
			sw t5, (t0)
		
		south:
			sub s3, s3, 1 # go left one column
			blt s2, 0, south_west
			bge s3, board_width, south_west # check if the index of the column will be greater than zero
			blt s3, 0, south_west
			bge s2, board_height, south_west
		
	
			la a0, hidden_board		# load values and calculate element address
			move a1, s2
			move a2, s3
			jal calc_elem_addr
			move t0, v0			# move element address so we can check the actual value
			lw t5, (t0)
			
			beq t5, -1, south_west	# check if the index if there is already a mine here
			add t5, t5, 1		# increment the tiles around the mine!
			sw t5, (t0)
		
		south_west:
			sub s3, s3, 1 
			blt s2, 0, west
			bge s3, board_width, west # check if the index of the column will be greater than zero
			blt s3, 0, west
			bge s2, board_height, west
		
	
			la a0, hidden_board		# load values and calculate element address
			move a1, s2
			move a2, s3
			jal calc_elem_addr
			move t0, v0			# move element address so we can check the actual value
			lw t5, (t0)
			
			beq t5, -1, west	# check if the index if there is already a mine here
			add t5, t5, 1		# increment the tiles around the mine!
			sw t5, (t0)
		
		west:
			sub s2, s2, 1
			blt s2, 0, north_west
			bge s3, board_width, north_west # check if the index of the column will be greater than zero
			blt s3, 0, north_west
			bge s2, board_height, north_west
		
	
			la a0, hidden_board		# load values and calculate element address
			move a1, s2
			move a2, s3
			jal calc_elem_addr
			move t0, v0			# move element address so we can check the actual value
			lw t5, (t0)
		
			beq t5, -1, north_west	# check if the index if there is already a mine here
			add t5, t5, 1		# increment the tiles around the mine!
			sw t5, (t0)
		
		north_west:
			sub s2, s2, 1 # go up one row
			blt s2, 0, end_increment_mine_index
			bge s3, board_width, end_increment_mine_index # check if the index of the column will be greater than zero
			blt s3, 0, end_increment_mine_index
			bge s2, board_height, end_increment_mine_index
		
	
			la a0, hidden_board		# load values and calculate element address
			move a1, s2
			move a2, s3
			jal calc_elem_addr
			move t0, v0			# move element address so we can check the actual value
			lw t5, (t0)
		
		beq t5, -1, end_increment_mine_index	# check if the index if there is already a mine here
		add t5, t5, 1		# increment the tiles around the mine!
		sw t5, (t0)
		
	
	end_increment_mine_index:
			pop ra
			jr ra
	
