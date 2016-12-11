# Challenges.re/3
# Calcualate how many bits away from the 32-bit boundary
# is the last set bit in a given number.
# (c) 2016 Ivailo Kassamakov
# ABI: x64_x86 for Linux and Windows
# Libraries: libc
# To compile on Linux: gcc -Xassembler --defsym -Xassembler LINUX=1 ch2.s
		
.title "Challenges.re/3"

.arch i686

.include "lib.inc"

########################## DATA SECTION ###############
.data

v:
.long -1,31, 8,30, -1, 7,-1,-1, 29,-1,26, 6, -1,-1, 2,-1
.long -1,28,-1,-1, -1,19,25,-1, 5,-1,17,-1, 23,14, 1,-1
.long  9,-1,-1,-1, 27,-1, 3,-1, -1,-1,20,-1, 18,24,15,10
.long -1,-1, 4,-1, 21,-1,16,11, -1,22,-1,12, 13,-1, 0,-1

noParamsStr:     .string "No command-line params. Exiting!\n"
convStr:         .string "Converting %s\n"
convertedValStr: .string "Converted value: %d\n"
regFmtStr:       .string "Register %s: 0x%08x = %s\n"

eaxStr: .string "EAX"
edxStr: .string "EDX"

# The array that will contain the ASCII binary
# digits of the converted integer
.lcomm bin_digits, 40 # 32 bits + 7 '_'s + 1 EOS

########################## TEXT SECTION ##############
.text
.global main

#######################################################
# Function: Convert a 32-bit integer to binary string
# Calling convention: None
# Inputs:	
#   eax - 32-bit value to convert to binary
# Return:
#   None
# Registers destroyed:
#   None
# Global vars:
#   Changes the bin_digits array
#######################################################
int2bin:
	pushq %rax
    pushq %rcx
    pushq %rbx
    pushq %rdx
    pushf

	# Process the 32 bits in the integer
    movl $32, %ecx

	# Helper to calculate when to insert '_' separators
    movl $0x11111110, %edx
 
	# We start filling the array from the end
	# taking also in the consideration
	# the space needed for the 7 '_' separators
    leaq bin_digits(%rip), %rbx
	leaq 7(%rbx, %rcx), %rbx
		
.L_bits_loop:
	# Go to the previous elelment of the bin_digits array
    decq %rbx
	# See if we need to add a '_' separator
    shrl $1, %edx
    jc  .L_add_sep
    jmp .L_dont_add_sep
.L_add_sep:
    movb $'_', (%rbx)
    decq %rbx
.L_dont_add_sep:
	# Get the next bit of the integer, moving it to the C flag
    shrl $1, %eax
    jc   .L_bit_is_1
    # bit is 0
    movb $0x30, (%rbx) # Write a '0' to the digits array
    loop .L_bits_loop
    jmp  .L_end
.L_bit_is_1:
    movb $0x31, (%rbx) # Write a '1' to the digits array
    loop .L_bits_loop
		
.L_end:
    popf
    popq %rdx
    popq %rbx
    popq %rcx
	popq %rax
    ret # Function: int2bin

		
#######################################################
# Function: Call printf ...............
# Calling convention: None
# Inputs:	
#   eax - register value to print (preserved)
#   r8  - register name string (preserved)
# Return:
#   None
# Registers destroyed:
#   None
# Global vars:
#   None
#######################################################
printReg:
    pushq %rax
    pushq %r8
    pushq %r9
    pushq %rdx
    pushq %rcx
    pushf

.ifdef LINUX
    movq %r8, %rsi
    movq %rax, %rdx
.else
    movq %r8, %rdx
    movq %rax, %r8
.endif

    call int2bin
.ifdef LINUX
    leaq bin_digits(%rip), %rcx
    leaq regFmtStr(%rip), %rdi
.else
    leaq bin_digits(%rip), %r9
    leaq regFmtStr(%rip), %rcx
.endif
    movl $0, %eax
    callq printf

    popf
    popq %rcx
    popq %rdx
    popq %r9
    popq %r8
    popq %rax
    ret

		
#######################################################
# Function: MAIN
# Calling convention: x64_x86 Win/Linux
# Stack frame: RBP based, 1.local vars, 2.saved regs
# Inputs:	
#   edi - argc
#   esi - argv
# Return:
#   eax - 0
# Registers destroyed:
#   None
# Global vars:
#   None
#######################################################
main:
    pushq %rbp
    movq  %rsp, %rbp
	subq  $24, %rsp
	.equ ARGC_OFS, -8
	.equ ARGV_OFS, -16
	.equ CMDPARPTR_OFS, -24
    pushq %rax
    pushq %rbx
    pushq %rcx
    pushq %rdx
    pushq %rdi
    pushq %rsi
    pushq %r8
    pushf

	GET_PARAM_m 1, ARGC_OFS(%rbp)
	GET_PARAM_m 2, ARGV_OFS(%rbp)		
		
	# Check argc > 1?
	movq ARGC_OFS(%rbp), %rax 
    decq %rax
    jg  .L_cmd_line_param_exists
    # no command line params
	printf_1s noParamsStr
	jmp .L_fini

.L_cmd_line_param_exists:
	# Printf the number we're going to convert
	movq $1, %rax
	movq ARGV_OFS(%rbp), %rsi
	callq get_argv # rax <- ptr to rsi[rax]
	movq %rax, CMDPARPTR_OFS(%rbp)
	printf_1r convStr, %rax

	PUT_PARAM_m 1, CMDPARPTR_OFS(%rbp)
    callq atoi

    leaq eaxStr(%rip), %r8
    call printReg

    movl %eax, %edx
    shrl %edx
    orl  %eax, %edx

    movl %edx, %eax
    leaq edxStr(%rip), %r8
    call printReg

    movl %edx, %eax
    shrl $2, %eax
    orl  %edx, %eax

    leaq eaxStr(%rip), %r8
    call printReg

    movl %eax, %edx
    shrl $4, %edx
    orl  %eax, %edx

    movl %edx, %eax
    leaq edxStr(%rip), %r8
    call printReg

    movl %edx, %eax
    shrl $8, %eax
    orl  %edx, %eax

    leaq eaxStr(%rip), %r8
    call printReg

    movl %eax, %edx
    shrl $16, %edx
    orl  %eax, %edx

    movl %edx, %eax
    leaq edxStr(%rip), %r8
    call printReg

    imull $0x4badf0d, %edx, %eax

    leaq eaxStr(%rip), %r8
    call printReg

    shrl $26, %eax

    leaq eaxStr(%rip), %r8
    call printReg

    leaq v(%rip), %rbx
    movl (%rbx, %rax, 4), %eax

    leaq eaxStr(%rip), %r8
    call printReg

	printf_1r convertedValStr, %rax

.L_fini:
    popf
    popq %r8
    popq %rsi
    popq %rdi
    popq %rdx
    popq %rcx
    popq %rbx
    popq %rax
    popq %r9
	movq %rbp, %rsp
	popq %rbp

    movq $0, %rax
    ret

# EOF

