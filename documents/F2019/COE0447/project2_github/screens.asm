
.include "convenience.asm"
.data
	win_msg: .asciiz "YOU WIN"
	score: .asciiz "SCORE: "
	lose_msg: .asciiz "YOU LOSE"
	start_msg: .asciiz "2 START"
	press_key: .asciiz "PRESS KEY"
	# to: .asciiz "2"
	

.text
.globl you_win
.globl you_lose
.globl start

start:
	enter					# print the welcome message, only works sometimes
	li a0, 6
	li a1, 25
	la a2 press_key
	jal display_draw_text
	
	li a0, 16
	li a1, 32
	la a2 start_msg
	jal display_draw_text
	leave



you_win: 				# print the you win message + the score
	enter
	li a0, 8
	li a1, 25
	la a2 win_msg
	jal display_draw_text
	
	li a0, 16
	li a1, 32
	la a2 score
	jal display_draw_text
	
	li a0, 50
	li a1, 32
	lw a2, enemy_counter
	jal display_draw_int
	leave
	
you_lose:				# print the you lose message + the score
	enter
	li a0, 8
	li a1, 25
	la a2 lose_msg
	jal display_draw_text
	
	li a0, 16
	li a1, 32
	la a2 score
	jal display_draw_text
	
	li a0, 50
	li a1, 32
	lw a2, enemy_counter
	jal display_draw_int
	leave
