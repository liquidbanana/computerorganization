.include "convenience.asm"
.include "game_settings.asm"


#	Defines the number of frames per second: 16ms -> 60fps
.eqv	GAME_TICK_MS		16

.data
# don't get rid of these, they're used by wait_for_next_frame.
last_frame_time:  .word 0
frame_counter:    .word 0

.text
# --------------------------------------------------------------------------------------------------

.globl game
game:
	# set up anything you need to here,
	# and wait for the user to press a key to start.

	# Wait for a key input
_game_wait:
	jal	start
	jal	input_get_keys
	beqz	v0, _game_wait

_game_loop:
	# check for input,
	jal     handle_input

	# update everything,
	jal draw_blue_border
	jal draw_lives
	jal draw_block
	jal display_player
	jal move_player
	jal draw_bullet
	jal shoot
	jal draw_dude
	jal move_enemies
	jal bullet_enemies
	jal player_enemies
	

	# draw everything

	jal	display_update_and_clear

	## This function will block waiting for the next frame!
	jal	wait_for_next_frame

	lw t0, win_lose
	beq t0, 1, _game_over
	b	_game_loop

_game_over:
	lw t0, lives_left
	bne t0, 0, winner
	
		loser: 
			jal you_lose
			jal	display_update_and_clear
			exit
			
		winner:
			jal you_win	
			jal	display_update_and_clear				
			exit





# --------------------------------------------------------------------------------------------------
# call once per main loop to keep the game running at 60FPS.
# if your code is too slow (longer than 16ms per frame), the framerate will drop.
# otherwise, this will account for different lengths of processing per frame.

wait_for_next_frame:
	enter	s0
	lw	s0, last_frame_time
_wait_next_frame_loop:
	# while (sys_time() - last_frame_time) < GAME_TICK_MS {}
	li	v0, 30
	syscall # why does this return a value in a0 instead of v0????????????
	sub	t1, a0, s0
	bltu	t1, GAME_TICK_MS, _wait_next_frame_loop

	# save the time
	sw	a0, last_frame_time

	# frame_counter++
	lw	t0, frame_counter
	inc	t0
	sw	t0, frame_counter
	leave	s0

# --------------------------------------------------------------------------------------------------
