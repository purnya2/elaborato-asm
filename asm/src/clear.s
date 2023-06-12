##########################################################################
# filename: clear.s
###########################################################################

.section .data

    # Escape sequence (a special set of characters) that communicate the terminal to clear the view
    # this is outputted at each loop, so that the view of the menu looks seamless
    clearcode:
        .byte 27, '[', '1', ';', '1', 'H', 27, '[', '2', 'J', 0
        lenclear = . - clearcode

.section .text
.global clear  	#Means that we can call this function in another file by using "call clear".


.type clear, @function

clear:
    # # # # # # # # # # # # # # CLEAR THE SCREEN # # # # # # # # # # # # # #

    
        movl	$lenclear,%edx	            # message length
        movl	$clearcode,%ecx		    # message to write
        movl	$1, %ebx		    # file descriptor (stdout)
        movl	$4,%eax		            # system call number (sys_write)
        int	$0x80                       # poke the kernel
        
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    
ret	#Return to the caller

