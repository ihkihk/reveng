.title "Challenges.re/2"

.arch i686
#.code32

.data

v:
.long -1,31, 8,30, -1, 7,-1,-1, 29,-1,26, 6, -1,-1, 2,-1
.long -1,28,-1,-1, -1,19,25,-1, 5,-1,17,-1, 23,14, 1,-1
.long  9,-1,-1,-1, 27,-1, 3,-1, -1,-1,20,-1, 18,24,15,10
.long -1,-1, 4,-1, 21,-1,16,11, -1,22,-1,12, 13,-1, 0,-1

afterShrlStr: .string "After shifting\n"
regFmtStr: .string "Binary value of register is %s\n"

.lcomm gg, 1
.lcomm bin_digits, 33

.text
.global main

print_reg_binary:
    pushq %rcx
    pushq %rbx
    pushf
    movl $32,%ecx
    shlq $32,%rax
    movl %ecx, %ebx
L1:
    shrq $1, %rax
    subl  $1,%ebx
    jc   L0
    movb $0x30,bin_digits(,%ebx)
    loop L1
    jmp  L2
L0: # bit is 1
    movb $0x31,bin_digits(,%ebx)
    loop L1
L2:
    popf
    popq %rbx
    popq %rcx
    ret

createBinString:

        ret

main:
    movl $0x12345678,%eax
    call print_reg_binary
    movq $bin_digits, %rsi
    movq $regFmtStr, %rdi
    xorq %rax, %rax
    call printf

    movl %edi, %edx
    shrl %edx
    #pushq %rdx
    #pushq $afterShrlStr
    orl  %edi, %edx

    movl %edx, %eax
    shrl $2, %eax
    orl  %edx, %eax

    movl %eax, %edx
    shrl $4, %edx
    orl  %eax, %edx

    movl %edx, %eax
    shrl $8, %eax
    orl  %edx, %eax

    movl %eax, %edx
    shrl $16, %edx
    orl  %eax, %edx

    imull $0x4badf0d, %edx, %eax

    shrl $26, %eax

    #movabs $v, %rbx
    #movl (%rbx, %rax, 4), %eax

    movl v(, %eax, 4), %eax

    movl $0, %ebx
    movl $1, %eax
    int  $0x80

    ret
