.title "Challenges.re/2"

.arch i686

.data

v:
.long -1,31, 8,30, -1, 7,-1,-1, 29,-1,26, 6, -1,-1, 2,-1
.long -1,28,-1,-1, -1,19,25,-1, 5,-1,17,-1, 23,14, 1,-1
.long  9,-1,-1,-1, 27,-1, 3,-1, -1,-1,20,-1, 18,24,15,10
.long -1,-1, 4,-1, 21,-1,16,11, -1,22,-1,12, 13,-1, 0,-1

helloStr: .string "Hello world!\n"
noParamsStr: .string "No command-line params. Exiting!\n"
convStr: .string "Converting %s\n"
convertedValStr: .string "Converted value: %d\n"

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

.ifdef LINUX
    movq %r8, %rsi
    movq %rax, %rdx
.else
    movq %r8, %rdx
    movq %rax, %r8
.endif

    call reg2bin
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

main:
    pushq %rbp
    movq  %rsp, %rbp
    pushq %rax
    pushq %rbx
    pushq %rcx
    pushq %rdx
    pushq %rdi
    pushq %rsi
    pushq %r8
    pushf

.ifdef LINUX
    decq %rdi # rdi = argc
.else
    decq %rcx # ecx = argc
.endif
    jg  .L12
    # no command line params -
.ifdef LINUX
    leaq noParamsStr(%rip), %rdi
.else
    leaq noParamsStr(%rip), %rcx
.endif
    callq printf
    jmp .L_fini

.L12:
.ifdef LINUX
    leaq 8(%rsi),%rax
    movq (%rax), %rsi
    leaq convStr(%rip), %rdi
    pushq %rsi
.else
    leaq convStr(%rip), %rcx
    leaq 8(%rdx), %rdx # goto argv[1]
    movq (%rdx), %rdx
    pushq %rdx
.endif
    movl $0, %eax
    callq printf # %rdx already contains the string of the 1st param

.ifdef LINUX
    popq %rdi
.else
    popq %rcx
.endif
    callq atoi

    # movl $1, %eax
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

.ifdef LINUX
    leaq convertedValStr(%rip), %rdi
    movq %rax, %rsi
.else
    leaq convertedValStr(%rip), %rcx
    movq %rax, %rdx
.endif
    callq printf

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

.ifdef LINUX
    movl $0, %ebx
    movl $1, %eax
    int  $0x80
.else
    movq $0, %rax
    ret
.endif
