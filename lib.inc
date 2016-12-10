# Library of useful assembly functions
# (c) 2016 Ivailo Kassamakov

.arch i686

#######################################################
# Function: Return a command-line argument
# Calling convention: none
# Inputs:	
#   rax - index of wanted argument (0 is the program name)
#   rsi - pointer to the argv[] array
# Return:
#   rax - pointer to the argument string (0-terminated) 
# Registers destroyed:
#   None
# Global vars:
#   None
#######################################################
get_argv:
    leaq (%rsi, %rax, 8), %rax
    movq (%rax), %rax
	ret

# Macro: print a format string with a value in register 
# e.g. printf(fmtStr, regName)
# Registers destroyed: RAX
.macro printf_1s fmtStr, param1
.ifdef LINUX
	leaq \fmtStr(%rip), %rdi
	leaq \param1(%rip), %rsi
.else
	leaq \fmtStr(%rip), %rdx
	leaq \param1(%rip), %rcx
.endif
	movq $0, %rax
	callq printf
.endm # Macro: printf_1s

# Macro: print a format string with a value in register 
# e.g. printf(fmtStr, regName)
# Registers destroyed: RAX
.macro printf_1r fmtStr, param1
.ifdef LINUX
	leaq \fmtStr(%rip), %rdi
	movq \param1, %rsi
.else
	leaq \fmtStr(%rip), %rcx
	movq \param1, %rdx
.endif
	movq $0, %rax
	callq printf
.endm

# Macro: put a param from a mem location into
# the appropriate register for a given x64_x86
# calling convention
.macro PUT_PARAM_m parnb, memloc
.ifdef LINUX
	.if \parnb==1
		movq \memloc, %rdi
	.elseif \parnb==2
		movq \memloc, %rsi
	.else
		.error "Macro PUT_PARAM_m: NOT IMPLEMENTED"
	.endif
.else
	.if \parnb==1
		movq \memloc, %rcx
	.elseif \parnb==2
		movq \memloc, %rdx
	.else
		.error "Macro PUT_PARAM_m: NOT IMPLEMENTED"
	.endif
.endif
.endm # Macro: PUT_PARAM_m

# Macro: store a register param into a mem location,
# the register being appropriate for a given x64_x86
# calling convention
.macro GET_PARAM_m parnb, memloc
.ifdef LINUX
	.if \parnb==1
		movq %rdi, \memloc
	.elseif \parnb==2
		movq %rsi, \memloc
	.else
		.error "Macro GET_PARAM_m: NOT IMPLEMENTED"
	.endif
.else
	.if \parnb==1
		movq %rcx, \memloc
	.elseif \parnb==2
		movq %rdx, \memloc
	.else
		.error "Macro GET_PARAM_m: NOT IMPLEMENTED"
	.endif
.endif
.endm # Macro: GET_PARAM_m

# EOF
