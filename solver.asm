# CS 21 A -- S1 AY 2020-2021
# John Carlo A. Sumabat -- 11/27/2020
# cs21mp1c.asm -- Machine Problem Part C

.data
    arr: .byte 0:66		# array containing the board
    color: .byte 0:1		# player color
    enemies: .byte 0:2		# array containing enemy pieces
    kingrow: .word 0:1		# row number of enemy's king row
    cur: .word 0:1		# number of enemies captured
    moves: .byte 0:385		# array c-#-#-#-#ontaining winning moves
    yes: .asciiz "\nYES\n"	# string to print when solution found
    no: .asciiz "\nNO"		# string to print otherwise
    
.text
	
###############################
# MAIN - Initalizing the input
###############################

main:
	la	$a0, arr			# load arr address
	li	$a1, 10			# set character limit
	li	$v0, 8			# read string
#----------------------------------------------------------------------------------------
input:
	syscall
	addi	$a0, $a0, 8		# get address of next 8th character
	addi	$t0, $t0, 1		# increment counter
	bne	$t0, 8, input		# read 8 rows
#----------------------------------------------------------------------------------------
	li	$v0, 12			# get character input
	syscall
	move	$s0, $v0
	sb	$s0, color		# color to move
#----------------------------------------------------------------------------------------
main_if1:
	bne	$s0, 'W', main_else1	# if color is white:
	li	$t0, 'b'			#    set 'b' and 'B' as enemies
	sb	$t0, enemies
	li	$t0, 'B'
	sb	$t0, enemies+1
	li	$t0, 0
	sb	$t0, kingrow		#    set king's row as 0
	j 	main_endif1
main_else1:				# else:
	li	$t0, 'w'			#    set 'w' and 'W' as enemies
	sb	$t0, enemies
	li	$t0, 'W'
	sb	$t0, enemies+1
	li	$t0, 7
	sb	$t0, kingrow		#    set king's row as 7
main_endif1:
#----------------------------------------------------------------------------------------
	li	$t0, 0			# int i = 0
main_forloop1:				# for (i = 0; i < row size; i++)
	bge	$t0, 8, main_endforloop1
	li	$t1, 0			# int j = 0
#----------------------------------------------------------------------------------------
main_forloop2:				# for (j = 0; j < col size; j++)
	bge	$t1, 8, main_endforloop2
	mul	$t2, $t0, 8		# idx = col size * i
	add	$t2, $t2, $t1		# idx = col size * i + j
	lb	$t3, arr($t2)		# arr(idx) = input
#----------------------------------------------------------------------------------------
main_if2:
	bne	$s0, 'W', main_else2	# if color == 'W':	
	bne	$t3, 'b', main_elseif2_1	#   if tile == 'b':
	addi	$s2, $s2, 1		#   enemycount++
main_elseif2_1:
	bne	$t3, 'B', main_endif2	#   elif tile == 'B':
	addi	$s2, $s2, 1		#   enemycount++
	j	main_endif2		#
main_else2:				# else:
	bne	$t3, 'w', main_elseif2_2	#   if tile == 'w':
	addi	$s2, $s2, 1		#   enemycount++
main_elseif2_2:				
	bne	$t3, 'W', main_endif2	#   elif tile == 'W':
	addi	$s2, $s2, 1		#   enemycount++
main_endif2:
	addi	$t1, $t1, 1		# j++
	j	main_forloop2
#----------------------------------------------------------------------------------------
main_endforloop2:			# end for
	addi	$t0, $t0, 1		# i++
	j	main_forloop1   	
#----------------------------------------------------------------------------------------
main_endforloop1:
	li	$v0, 0


###############################
# MAIN - Traversing the array
###############################

read:
	li	$t0, 0			# int i = 0
	li	$s1, '#'			# load hash char
	li	$a2, -1			# direction parameter
	move	$a3, $s2			# enemycount parameter
#----------------------------------------------------------------------------------------
read_forloop1:				# for (i = 0; i < row size; i++)
	bge	$t0, 8, read_endforloop1
	li	$t1, 0			# int j = 0
#----------------------------------------------------------------------------------------
read_forloop2:				# for (j = 0; j < col size; j++)
	bge	$t1, 8, read_endforloop2
	
	mul	$t2, $t0, 8		# idx = col size * i
	add	$t2, $t2, $t1		# idx = col size * i + j
	lb	$t3, arr($t2)		# get current tile at idx
	
	sb	$s1, arr($t2)		# make current tile empty
	move	$a0, $t0		 	# row parameter
	move	$a1, $t1			# column parameter
	
	li	$s2, 'a'			# set column name
	add	$s2, $s2, $a1
	sb	$s2, moves
	li	$s2, '8'			# set row name
	sub	$s2, $s2, $a0
	sb	$s2, moves+1
	li	$s2, ' '
	sb	$s2, moves+2		# moves now contains "<tilename> "
#----------------------------------------------------------------------------------------
read_if1:
	bne	$s0, 'W', read_else1	# if color == 'W':	
	bne	$t3, 'w', read_elseif1_1	#   if tile == 'w':
	jal	jump			#   call jump
read_elseif1_1:
	bne	$t3, 'W', read_endif1	#   elif tile == 'W':
	jal	kjump			#   call kjump
	j	read_endif1
read_else1:				# else:
	bne	$t3, 'b', read_elseif1_2	#  if tile == 'b':
	jal	jump			#  call jump
read_elseif1_2:				
	bne	$t3, 'B', read_endif1	#  elif tile == 'B':
	jal	kjump			#  call kjump
read_endif1:
	sb	$t3, arr($t2)		# return tile to original state
#----------------------------------------------------------------------------------------
	beq	$v0, 1, output		# break if solution found
	addi	$t1, $t1, 1		# j++
	j	read_forloop2
read_endforloop2:			# end for
	addi	$t0, $t0, 1		# i++
	j	read_forloop1
#----------------------------------------------------------------------------------------
read_endforloop1:
#----------------------------------------------------------------------------------------
output:
	move	$s0, $v0			# print result
	li	$v0, 4
read_if2:
	beqz	$s0, read_else2		# if $s0 == 1: print "YES"
	la	$a0, yes
	syscall
	
	lw	$t1, cur			# print winning moves
	mul	$t2, $t1, 6		# add null character to last part of string
	subi	$t2, $t2, 1		# to indicate end of moves
	sb	$0,  moves($t2)
		
	li	$v0, 4
	la	$a0, moves
	syscall
	
	j	read_endif2
read_else2:				# else: print "NO"
	la	$a0, no
	syscall
read_endif2:
#	jal	print
	li	$v0, 10			# terminate program
	syscall
	
###############################
# JUMP - Checking for solutions
###############################
			
jump:	####preamble####
	subi 	$sp, $sp, 32	# set up stack frame for 8 variables
	sw	$ra,  ($sp)
	sw	$a0, 4($sp)
	sw	$a1, 8($sp)
	sw	$a2, 12($sp)
	sw	$a3, 16($sp)
	sw	$s0, 20($sp)
	sw	$s1, 24($sp)
	sw	$s2, 28($sp)	
	####preamble####
#----------------------------------------------------------------------------------------
	bne	$a2, -1, jump_endif1	# check if initial call:
	move	$s0, $a2			# use $s0 as temporary direction holder
	lb	$t4, color		# check color
#----------------------------------------------------------------------------------------
jump_if1:
	bne	$t4, 'W', jump_else1	# if white:
	j	jump_if5
jump_else1:				# else:
	j	jump_else5
jump_endif1:
	li	$s1, 0			# set $s1 to 0 in case flag previously set to -1
#----------------------------------------------------------------------------------------
jump_if2:				# check if coordinates within bounds
	ble	$a0, -1, jump_return	
	bge	$a0, 8, jump_return
	ble	$a1, -1, jump_return
	bge	$a1, 8, jump_return
	
	mul	$t4, $a0, 8		# idx = col size * row
	add	$t4, $t4, $a1		# idx = col size * row + col
	lb	$t5, arr($t4)		# get element at current tile
	
	bne	$t5, '#', jump_return	# check if tile unoccupied
jump_endif2:
#----------------------------------------------------------------------------------------
jump_if3:				# check direction, store temporary coordinates
	bne	$a2, 1, jump_elseif3_1	# check if up, left
	addi	$s0, $a0, 1		
	addi	$s1, $a1, 1
	j	jump_endif3
jump_elseif3_1:
	bne	$a2, 2, jump_elseif3_2	# check if up, right
	addi	$s0, $a0, 1
	addi	$s1, $a1, -1
	j	jump_endif3
jump_elseif3_2:
	bne	$a2, 3, jump_elseif3_3	# check if down, left
	addi	$s0, $a0, -1
	addi	$s1, $a1, 1
	j	jump_endif3
jump_elseif3_3:				# check if down, right
	addi	$s0, $a0, -1
	addi	$s1, $a1, -1
jump_endif3:
#----------------------------------------------------------------------------------------
	mul	$t4, $s0, 8		# idx = col size * row
	add	$t4, $t4, $s1		# idx = col size * row + col
	lb	$s2, arr($t4)		# get element at previous tile
#----------------------------------------------------------------------------------------
jump_if4	:				# check if previous tile contained enemy
	lb	$t5, enemies
	beq	$s2, $t5, jump_else4
	lb	$t5, enemies + 1
	beq	$s2, $t5, jump_else4
	j	jump_return		# if no enemy, return 0	
jump_else4:
	subi	$a3, $a3, 1		# decrement enemycount
#----------------------------------------------------------------------------------------	
	lw	$s1, cur			# load current move number
	addi	$s0, $s1, 1		# increment movecount
	sw	$s0, cur		
	mul	$s1, $s1, 6
	addi	$s1, $s1, 3		# obtain current string index
#----------------------------------------------------------------------------------------
	li	$s0, 'a'			# set column name
	add	$s0, $s0, $a1
	sb	$s0, moves($s1)		# modify both current and next line
	sb	$s0, moves+3($s1)
	li	$s0, '8'			# set row name
	sub	$s0, $s0, $a0
	sb	$s0, moves+1($s1)
	sb	$s0, moves+4($s1)
	li	$s0, '\n'
	sb	$s0, moves+2($s1)	# moves now includes "<this tile>\n<this tile> "
	li	$s0, ' '
	sb	$s0, moves+5($s1)
	
	li	$s1, -1			# raise flag
#----------------------------------------------------------------------------------------	
jump_endif4:
#----------------------------------------------------------------------------------------	
	beq	$a3, 0, jump_BASE	# if no more enemies, return 1
	lw	$t5, kingrow		# else, if in enemy's king's row, return 0
	beq	$a0, $t5, jump_return
#----------------------------------------------------------------------------------------	
jump_recurse:				# else, recurse	
	li	$t5, 'X'			# remove enemy from previous tile
	sb	$t5, arr($t4)
	move	$s0, $t4
	lb	$t4, color		# check color
#----------------------------------------------------------------------------------------
jump_if5:
	bne	$t4, 'W', jump_else5	# if white:
	subi	$a0, $a0, 2		# check up, left
	subi	$a1, $a1, 2
	li	$a2, 1
	jal	jump
	beq	$v0, 1, jump_endrecurse	# break if solution found
	addi	$a1, $a1, 4		# check up, right
	li	$a2, 2
	jal	jump
	beq	$v0, 1, jump_endrecurse
	j	jump_endif5	
jump_else5:				# else
	addi	$a0, $a0, 2		# check down, left
	subi	$a1, $a1, 2
	li	$a2, 3
	jal	jump
	beq	$v0, 1, jump_endrecurse
	addi	$a1, $a1, 4		# check down, right
	li	$a2, 4
	jal	jump
jump_endif5:
#----------------------------------------------------------------------------------------
jump_endrecurse:
	beq	$s0, -1, jump_return	# check if initial call
	sb	$s2, arr($s0)		# restore tile
	j	jump_return
#----------------------------------------------------------------------------------------
jump_return:
	beq	$v0, 1, jump_return_sub	# decrement movecount if no solution yet found
	slti	$s1, $s1, 0		# AND enemy was captured
	
	lw	$s0, cur			
	sub	$s0, $s0, $s1
	sw	$s0, cur
jump_return_sub:
	####end####
	lw	$ra,  ($sp)		# tear down stack frame	
	lw	$a0, 4($sp)
	lw	$a1, 8($sp)
	lw	$a2, 12($sp)
	lw	$a3, 16($sp)
	lw	$s0, 20($sp)
	lw	$s1, 24($sp)
	lw	$s2, 28($sp)
	addi 	$sp, $sp, 32
	####end####
	jr	$ra
#----------------------------------------------------------------------------------------
jump_BASE:
	li	$v0, 1
	j	jump_return

################################
# KJUMP - Checking for solutions
################################
			
kjump:	####preamble####
	subi 	$sp, $sp, 32		# set up stack frame for 8 variables
	sw	$ra,  ($sp)
	sw	$a0, 4($sp)
	sw	$a1, 8($sp)
	sw	$a2, 12($sp)
	sw	$a3, 16($sp)
	sw	$s0, 20($sp)
	sw	$s1, 24($sp)
	sw	$s2, 28($sp)	
	####preamble####
#----------------------------------------------------------------------------------------
	bne	$a2, -1, kjump_if1	# check if initial call:
	move	$s0, $a2			# use $s0 as temporary direction holder
	j	kjump_recurse1_sub
#----------------------------------------------------------------------------------------
kjump_if1:
	li	$s1, 0			# set $s1 to 0 in case flag previously set to -1
	
	ble	$a0, -1, kjump_return	# check if coordinates within bounds
	bge	$a0, 8, kjump_return
	ble	$a1, -1, kjump_return
	bge	$a1, 8, kjump_return
	
	mul	$t4, $a0, 8		# idx = col size * row
	add	$t4, $t4, $a1		# idx = col size * row + col
	lb	$t5, arr($t4)		# get element at current tile
	
	lb	$s2, enemies		# check if current tile has enemy
	beq	$s2, $t5, kjump_endif1
	lb	$s2, enemies + 1
	beq	$s2, $t5, kjump_endif1
	bne	$t5, '#', kjump_return	# if current tile captured/has ally, return 0
kjump_endif1:				# else, check previous tile
	move	$t6, $t5
#----------------------------------------------------------------------------------------
kjump_if2:				# check direction, store temporary coordinates
	bne	$a2, 1, kjump_elseif2_1	# check if up, left
	addi	$s0, $a0, 1		
	addi	$s1, $a1, 1
	j	kjump_endif2
kjump_elseif2_1:
	bne	$a2, 2, kjump_elseif2_2	# check if up, right
	addi	$s0, $a0, 1
	addi	$s1, $a1, -1
	j	kjump_endif2
kjump_elseif2_2:
	bne	$a2, 3, kjump_elseif2_3	# check if down, left
	addi	$s0, $a0, -1
	addi	$s1, $a1, 1
	j	kjump_endif2
kjump_elseif2_3:				# check if down, right
	addi	$s0, $a0, -1
	addi	$s1, $a1, -1
kjump_endif2:
#----------------------------------------------------------------------------------------
	mul	$t4, $s0, 8		# idx = col size * row
	add	$t4, $t4, $s1		# idx = col size * row + col
	lb	$s2, arr($t4)		# get element at previous tile
#----------------------------------------------------------------------------------------
kjump_if3:				# check if previous tile contained enemy
	lb	$t5, enemies
	beq	$s2, $t5, kjump_elseif3
	lb	$t5, enemies + 1
	beq	$s2, $t5, kjump_elseif3
	bne	$s2, '#', kjump_return	# if previous tile captured/has ally, return 0
	j	kjump_recurse2		# if no enemy, keep checking in same direction
kjump_elseif3:
	bne	$t6, '#', kjump_return	# return zero if current tile also occupied
kjump_else3:				# else, capture enemy
	subi	$a3, $a3, 1		# decrement enemycount
#----------------------------------------------------------------------------------------
	lw	$s1, cur			# load current move number
	addi	$s0, $s1, 1		# increment movecount
	sw	$s0, cur		
	mul	$s1, $s1, 6
	addi	$s1, $s1, 3		# obtain current string index
#----------------------------------------------------------------------------------------
	li	$s0, 'a'			# set column name
	add	$s0, $s0, $a1
	sb	$s0, moves($s1)		# modify both current and next line
	sb	$s0, moves+3($s1)
	li	$s0, '8'			# set row name
	sub	$s0, $s0, $a0
	sb	$s0, moves+1($s1)
	sb	$s0, moves+4($s1)
	li	$s0, '\n'
	sb	$s0, moves+2($s1)	# moves now includes "<prev tile> <currtile>\n"
	li	$s0, ' '
	sb	$s0, moves+5($s1)

	li	$s1, -1			# raise flag
#----------------------------------------------------------------------------------------
kjump_endif3:
	beq	$a3, 0, kjump_BASE	# if no more enemies, return 1
#----------------------------------------------------------------------------------------	
kjump_recurse1:				# else, recurse
	li	$t5, 'X'			# remove enemy from previous tile
	sb	$t5, arr($t4)
	move	$s0, $t4
#----------------------------------------------------------------------------------------
kjump_recurse1_sub:
	subi	$a0, $a0, 2		# check up, left
	subi	$a1, $a1, 2
	li	$a2, 1
	jal	kjump
	beq	$v0, 1, kjump_endrecurse1# break if solution found
	addi	$a1, $a1, 4		# check up, right
	li	$a2, 2
	jal	kjump
	beq	$v0, 1, kjump_endrecurse1
	addi	$a0, $a0, 4		# check down, right
	li	$a2, 4
	jal	kjump
	beq	$v0, 1, kjump_endrecurse1
	subi	$a1, $a1, 4		# check down, left
	li	$a2, 3
	jal	kjump
#----------------------------------------------------------------------------------------
kjump_endrecurse1:
	beq	$s0, -1, kjump_return	# check if no replacement was made
	sb	$s2, arr($s0)		# restore tile
	j	kjump_return
#----------------------------------------------------------------------------------------
kjump_recurse2:
kjump_if4:				# check direction, store temporary coordinates
	bne	$a2, 1, kjump_elseif4_1	# check up, left
	subi	$a0, $a0, 1		
	subi	$a1, $a1, 1
	jal	kjump
	j	kjump_endif4
kjump_elseif4_1:
	bne	$a2, 2, kjump_elseif4_2	# check up, right
	subi	$a0, $a0, 1
	addi	$a1, $a1, 1
	jal	kjump
	j	kjump_endif4
kjump_elseif4_2:
	bne	$a2, 3, kjump_elseif4_3	# check down, left
	addi	$a0, $a0, 1
	subi	$a1, $a1, 1
	jal	kjump
	j	kjump_endif4
kjump_elseif4_3:				# check down, right
	addi	$a0, $a0, 1
	addi	$a1, $a1, 1
	jal	kjump
	j	kjump_endif4
kjump_endif4:
	j	kjump_return
	
kjump_return:
	beq	$v0, 1, kjump_return_sub	# decrement movecount if no solution yet found
	slti	$s1, $s1, 0		# AND enemy captured
	lw	$s0, cur			
	sub	$s0, $s0, $s1
	sw	$s0, cur
kjump_return_sub:
	####end####
	lw	$ra,  ($sp)		# tear down stack frame	
	lw	$a0, 4($sp)
	lw	$a1, 8($sp)
	lw	$a2, 12($sp)
	lw	$a3, 16($sp)
	lw	$s0, 20($sp)
	lw	$s1, 24($sp)
	lw	$s2, 28($sp)
	addi 	$sp, $sp, 32
	####end####
	jr	$ra
#----------------------------------------------------------------------------------------
kjump_BASE:
	li	$v0, 1
	j	kjump_return
