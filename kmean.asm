.data

input_point_prompt : .asciiz "Please type in 20 digits, odd digits are x, even digits are y, do not press enter\n"
input_centroid_prompt: .asciiz "Enter values follow by an Enter key,there should be total of 4 Enter x,y for CenE, and x,y for cenI\n"
option_for_given_centroid: .asciiz "do you want to use the centroid (2,4),(6,2)? y/n \n"
option_for_given_point: .asciiz "do you want to use the default set of points, the one given in the example?  y/n. \n"
.align 2
option_read: .space 4
.align 2


agroup: .asciiz " is belong to centroidE\n"
bgroup: .asciiz " is belong to centroidI\n"




.align 2

_A: .word 0x41,0x00,0x32,0x32 #A(2,2)
_B: .word 0x42,0x00,0x35,0x33 #B(5,3)
_C: .word 0x43,0x00,0x31,0x35 #C(1,5)
_D: .word 0x44,0x00,0x33,0x33 #D(3,3)
_E: .word 0x45,0x00,0x32,0x34 #E(2,4)
_F: .word 0x46,0x00,0x32,0x31 #F(2,1)
_G: .word 0x47,0x00,0x34,0x32 #G(4,2)
_H: .word 0x48,0x00,0x35,0x31 #H(5,1)
_I: .word 0x49,0x00,0x36,0x32 #I(6,2)
_J: .word 0x4A,0x00,0x35,0x32 #J(5,2)

_cen1: .word 0x2,0x4
_cen2: .word 0x6,0x2

.align 2

#t2 gobal counter for groupone t3 global couter for grouptwo
groupone: .space 40

.align 2

grouptwo: .space 40

.align 2

.text

#### s7 keep track of grouptwo, address of points belong to groupB###
## s6 keep track of group one, address of points belogn to groupA###

main:

userin:
li $v0,4
la $a0, option_for_given_centroid
syscall

li $v0,8
la $a0, option_read
li $a1, 2
syscall

lw $t0 , ($a0)
li $t1 , 0x6e
bne $t0, $t1 pick_again

li $v0,4
la, $a0, input_centroid_prompt
syscall

la $t1 _cen1
li $v0,5
syscall
sw $v0 ,($t1)

li $v0,5
syscall
addi $t1,4
sw $v0,($t1)

la $t1 _cen2
li $v0,5
syscall
sw $v0 ,($t1)

li $v0,5
syscall
addi $t1,4
sw $v0,($t1)
############ above for centroid input

pick_again:
li $v0,4
la $a0, option_for_given_point
syscall

li $v0,8
la $a0, option_read
li $a1, 2
syscall

lw $t0 , ($a0)
li $t1 , 0x6e
bne $t0,$t1 print_cent

####input for 20 values
li $s1,0
la $t0, _A
li $v0, 4
la $a0, input_point_prompt
syscall
inputpoint:
li $v0, 12
syscall
addi $t0,8
sw $v0,($t0)

addi $t0,4
li $v0, 12
syscall
sw $v0,($t0)

addi $s1,1
li $v0,10
addi $t0,4
bne $s1 ,$v0, inputpoint

##########
print_cent:
li $a0,0x0a
li $v0,11
syscall
#initialize group counter
li $t2,0
li $t3,0

#print the centroid#####
la, $t0, _cen1
lw $a0,($t0)
li $v0,1
syscall

addi $t0,4
lw $a0,($t0)
li $v0,1
syscall

li $a0,10
li $v0,11
syscall

la, $t0, _cen2
lw $a0,($t0)
li $v0,1
syscall

addi $t0,4
lw $a0,($t0)
li $v0,1
syscall

li $a0,10
li $v0,11
syscall


li $s4,0 # reset s4 to run main

la $s8, _A        #load the first point x and y, s8 should have addr of points
la, $s7, grouptwo  #store the point to memeory s7 mem pointer
la, $s6, groupone  #store the point to meme s6
next_point:
  la $s0, _cen1     ##load the first centroid
  lw $a0, ($s0)     ## into a0 and a1 for x and y
  lw $a1, 4($s0)


  lw $a2, 8($s8)
  lw $a3, 12($s8)

  addi $a2, -48
  addi $a3, -48

  jal distance

  add $s1, $s0, $0

  la $s0, _cen2   #load the second centroid
  lw $a0, ($s0)
  lw $a1, 4($s0)


  jal distance
  add $s2, $s0, $0      #save the dis on s2

  blt $s1,$s2 groupA
  bgt $s1,$s2 groupB


  add $s4, 1                      #s4 is the counter
  bgt $s4, 9 exit
  jal next             #next point
  j next_point


################ Find the distance between two point##########
########## a0 a1 for centroid x,y, a2, a3 for arg x, y############
########## return s0 #####################
distance:
  addi $sp, $sp, -28
  sw $s1,   ($sp)
  sw $s2, 24($sp)
  sw $a0, 20($sp)
  sw $a1, 16($sp)
  sw $a2, 12($sp)
  sw $a3, 8($sp)
  sw $ra, 4($sp)

  sub $s1, $a0, $a2
  mul $s1, $s1, $s1

  sub $s2, $a1,$a3
  mul $s2, $s2, $s2

  add $s0, $s1, $s2

  lw $s1,   ($sp)
  lw $s2, 24($sp)
  lw $a0, 20($sp)
  lw $a1, 16($sp)
  lw $a2, 12($sp)
  lw $a3, 8($sp)
  lw $ra, 4($sp)
  addi $sp, $sp, 28
  jr $ra



#### print groupA with the distance###
groupA:
  addi $sp, $sp, -8
  sw $a0,  ($sp)
  sw $ra, 4($sp)

                      #$s8 contain the addr of point
  add, $a0, $s8, $0
  li, $v0, 4
  syscall

  la, $a0, agroup
  syscall

              #save to mem
  sw $s8, ($s6)
  addi $s6, $s6, 4
  addi $t2,1   #increment groupone counter

  lw $a0, ($sp)
  lw $ra, 4($sp)
  addi $sp, $sp, 8
  addi $ra, $ra, 12    #this might cause issue hard coding return address
  jr $ra


  #### print groupB with the distance###
groupB:

  addi $sp, $sp, -8
  sw $a0,  ($sp)
  sw $ra, 4($sp)


  add, $a0, $s8, $0
  li, $v0, 4
  syscall

  la, $a0, bgroup
  syscall


  sw $s8, ($s7)
  addi $s7, $s7, 4
  addi $t3, 1  #increment grouptwo counter

  lw $a0, ($sp)
  lw $ra, 4($sp)
  addi $sp, $sp, 8
  addi $ra, $ra, 20    #this might cause issue hardcoding return address
  jr $ra


######### next go point #######
next:
  addi $sp, $sp, -8
  sw $a0,  ($sp)
  sw $ra, 4($sp)

  addi $s8, $s8,16

  lw $a0, ($sp)
  lw $ra, 4($sp)
  addi $sp, $sp, 8
  jr $ra
##### go netx point####


######update centroid one#######
updateone:
    addi $sp, $sp, -40
    sw $a0,   ($sp)
    sw $a2, 36($sp)
    sw $v0, 32($sp)
    sw $s6, 28($sp)
    sw $s3, 24($sp)
    sw $s4, 20($sp)
    sw $s5, 16($sp)
    sw $s2, 12($sp)
    sw $s1, 8($sp)
    sw $ra, 4($sp)
#
    beq $t2,$0 not_store
    la, $s1, groupone
    li $s4,0     #x
    li $s5,0     #y
    li $s6,0     # loop counter
sumloop:
    lw $a0, ($s1)
    addi $a0,8
    lw $s2,($a0) #$s2 is x
    addi $a0,4
    lw $s3,($a0)  #$s3 is y
    add $s4,$s2,$s4
    add $s5,$s3,$s5
    addi $s4,-48  #convert to int
    addi $s5,-48
                    #$4 is the result of sum x
                    #$5 is the result of sum y
    addi $s6,1
    addi $s1,4
    blt $s6, $t2 sumloop

    add $s2,$t2,$0
    beq $s2, $0 not_store
    div $s4, $s2
    mfhi $a2 # reminder to $a2
    mflo $v0 # quotient to $v0

    la, $a0, _cen1
    sw $v0, ($a0)

    addi $a0,4


    div $s5, $s2
    mfhi $a2 # reminder to $a2
    mflo $v0 # quotient to $v0

    sw $v0, ($a0)

not_store:
#
    lw $a0,   ($sp)
    lw $a2, 36($sp)
    lw $v0, 32($sp)
    lw $s6, 28($sp)
    lw $s3, 24($sp)
    lw $s4, 20($sp)
    lw $s5, 16($sp)
    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 40
    jr $ra
######update centroid######

######update centroid two#######
updatetwo:
    addi $sp, $sp, -40
    sw $a0,   ($sp)
    sw $a2, 36($sp)
    sw $v0, 32($sp)
    sw $s6, 28($sp)
    sw $s3, 24($sp)
    sw $s4, 20($sp)
    sw $s5, 16($sp)
    sw $s2, 12($sp)
    sw $s1, 8($sp)
    sw $ra, 4($sp)
#
    beq $t3,$0 not_store2
    la, $s1, grouptwo
    li $s4,0     #x
    li $s5,0     #y
    li $s6,0     # loop counter
sumloop2:
    lw $a0, ($s1)
    addi $a0,8
    lw $s2,($a0) #$s2 is x
    addi $a0,4
    lw $s3,($a0)  #$s3 is y
    add $s4,$s2,$s4
    add $s5,$s3,$s5
    addi $s4,-48  #convert to int
    addi $s5,-48
                    #$4 is the result of sum x
                    #$5 is the result of sum y
    addi $s6,1
    addi $s1,4
    blt $s6, $t3 sumloop2

    add $s2,$t3,$0
    beq $s2, $0 not_store2
    div $s4, $s2
    mfhi $a2 # reminder to $a2
    mflo $v0 # quotient to $v0

    la, $a0, _cen2
    sw $v0, ($a0)

    addi $a0,4


    div $s5, $s2
    mfhi $a2 # reminder to $a2
    mflo $v0 # quotient to $v0

    sw $v0, ($a0)

not_store2:
#
    lw $a0,   ($sp)
    lw $a2, 36($sp)
    lw $v0, 32($sp)
    lw $s6, 28($sp)
    lw $s3, 24($sp)
    lw $s4, 20($sp)
    lw $s5, 16($sp)
    lw $s2, 12($sp)
    lw $s1, 8($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 40
    jr $ra
######update centroid######

####finish########
exit:

  la,$t0,_cen1
  la,$t1,_cen2

  lw $s0,($t0)
  lw $s1,($t1)

  addi $t0,4
  addi $t1,4

  lw $s2,($t0)
  lw $s3,($t1)

  jal updateone
  jal updatetwo

  la,$t0,_cen1
  la,$t1,_cen2

  lw $s4,($t0)
  lw $s5,($t1)

  addi $t0,4
  addi $t1,4

  lw $s6,($t0)
  lw $s7,($t1)




  bne $s0,$s4, print_cent
  bne $s1,$s5, print_cent
  bne $s2,$s6, print_cent
  bne $s3,$s7, print_cent



  li $v0,10
  syscall
