.title "Challenges.re/2"

.arch i686
#.code32

.data

v:
.long -1,31, 8,30, -1, 7,-1,-1, 29,-1,26, 6, -1,-1, 2,-1
.long -1,28,-1,-1, -1,19,25,-1, 5,-1,17,-1, 23,14, 1,-1
.long  9,-1,-1,-1, 27,-1, 3,-1, -1,-1,20,-1, 18,24,15,10
.long -1,-1, 4,-1, 21,-1,16,11, -1,22,-1,12, 13,-1, 0,-1

noParamsStr: .string "No command-line params. Exiting!\n"
convStr: .string "Converting %s\n"

eaxStr: .string "EAX"
edxStr: .string "EDX"

regFmtStr: .string "Register %s: 0x%08x = %s\n"

.lcomm bin_digits, 40 # 32 bits + 7 '_'s + 1 EOS

.text
.global main

    # eax - 32-bit value to convert to binary (destroyed)
reg2bin:
    pushq %rcx
    pushq %rbx
    pushq %rdx
    pushf
    
    movl $32,%ecx
    movl $0x11111110, %edx
    leaq bin_digits(%rip), %rbx
    leaq 7(%rbx, %rcx), %rbx
.L1:
    decq %rbx
    shrl $1, %edx
    jc   .L4
    jmp .L5
.L4: # add a '_'
    movb $'_', (%rbx)
    decq %rbx
.L5: # don't add a '_'    
    shrl $1, %eax
    jc   .L0
    # bit is 0
    movb $0x30, (%rbx)
    loop .L1
    jmp  .L2
.L0: # bit is 1
    movb $0x31, (%rbx)
    loop .L1
.L2:
    popf
    popq %rdx
    popq %rbx
    popq %rcx
    ret

    # eax - register value to print (preserved)
    # r8 - register name string (preserved)
printReg:
    pushq %rax
    pushq %r8
    pushq %r9
    pushq %rdx
    pushq %rcx
    pushf
    
    movq %r8, %rdx
    movq %rax, %r8
    
    call reg2bin
    leaq bin_digits(%rip), %r9
    leaq regFmtStr(%rip), %rcx
    callq printf
    
    popf
    popq %rcx
    popq %rdx
    popq %r9
    popq %r8
    popq %rax
    ret
    
main:
    testq %rcx, %rcx  # ecx = argc
    decq %rcx
    jg  .L12
    # no command line params - 
    leaq noParamsStr(%rip), %rcx
    callq printf
    ret
    
.L12:
    leaq convStr(%rip), %rcx
    leaq 8(%rdx), %rdx # goto argv[1]
    movq (%rdx), %rdx
    pushq %rdx
    callq printf # %rdx already contains the string of the 1st param
    
    popq %rcx
    callq atoi
    
    #movl $1, %eax
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

    movabs $v, %rbx
    movl (%rbx, %rax, 4), %eax
    
    leaq eaxStr(%rip), %r8
    call printReg

    #movabs v(, %rax, 4), %rax

    #movl $0, %ebx
    #movl $1, %eax
    #int  $0x80
    movq $0, %rax
    ret
