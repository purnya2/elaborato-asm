##########################################################################
# filename: pressionegomme.s
###########################################################################

.section .data

    timespec:
        .long 0
        .long  5000000000
    input_buffer: .space 64

    pressione:
        .string     "\nPressione gomme resettata\n"
        pressionelen = . - pressione

    dot:
        .string "."
    


.section .text
.global pressionegomme


.type pressionegomme, @function

pressionegomme:

    xorl %ecx, %ecx

    pressioneloop:
    cmpl $3, %ecx
    je exitpressioneloop
    push %ecx

    movl $162, %eax
    movl $timespec, %ebx
    int $0x80

    movl	$1,%edx     
    movl	$dot,%ecx
    movl	$1, %ebx		
    movl	$4,%eax		       
    int	$0x80
    pop %ecx

    incl    %ecx
    jmp pressioneloop


    exitpressioneloop:
    movl $162, %eax
    movl $timespec, %ebx
    int $0x80

    movl	$pressionelen,%edx             
    movl	$pressione,%ecx		
    movl	$1, %ebx	    
    movl	$4,%eax		  
    int	$0x80
    movl $1, timespec

    movl $162, %eax
    movl $timespec, %ebx
    int $0x80

    movl $0, timespec

    call clear 
    
    ret
    
