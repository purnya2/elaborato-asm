##########################################################################

# Compile: as --march=i386 --32 ./hello_world_gas.s -o hello_world_gas.o
#    Link: ld -m elf_i386 hello_world_gas.o -o hello_world_gas
# as --march=i386 --32 test.s -o test.o && ld -m elf_i386 test.o -o test && ./test

###########################################################################
.global  _start


.data

    # variable that reserves space of 128 bytes as a buffer for the sys_read call
    input_buffer: .space 128

    notselectedicon: 
        .string "[ ] "
    selectedicon: 
        .string "[o] "
    selection: 
        .long 0

    maxselect:
        .long 6

    up:
        .byte 'A'
    down:
        .byte 'B'
    right:
        .byte 'C'

    # Escape sequence(a special set of characters) that communicate the terminal to clear the view
    # this is outputted at each loop, so that the view of the menu looks seamless
    clearcode:
        .byte 27, '[', '1', ';', '1', 'H', 27, '[', '2', 'J', 0
        lenclear = . - clearcode

    # ### Menu options########################################################
        opt1:
            .string    "Setting Automobile: "
            len1 = . - opt1 
        opt2:
            .string    "Data: "
            len2 = . - opt2 
        opt3:
            .string    "Ora: "
            len3 = . - opt3 
        opt4:
            .string    "Blocco automatico porte: "
            len4 = . - opt4 
        opt5:
            .string    "Back-home: "
            len5 = . - opt5 
        opt6:
            .string    "Check olio "
            len6 = . - opt6
        opt7:
            .string    "Freccie direzione "
            len7 = . - opt7
        opt8:
            .string    "Reset pressione gomme "
            len8 = . - opt8

    # ########################################################################

    # ### Menu values########################################################
        v1:
            .string    "\n"
            vlen1 = . - v1 
        v2:
            .string    "15/06/2014\n"
            vlen2 = . - v2 
        v3:
            .string    "15:32\n"
            vlen3 = . - v3 
        v4:
            .string    "ON\n"
            vlen4 = . - v4 
        v5:
            .string    "ON\n"
            vlen5 = . - v5 
        v6:
            .string    "\n"
            vlen6 = . - v6
        v7:
            .string    "\n"
            vlen7 = . - v7
        v8:
            .string    "\n"
            vlen8 = . - v8

    # ########################################################################

    # these both are arrays that contain pointers towards the various strings and lenghts
        options:
            .long opt1, opt2, opt3, opt4, opt5, opt6, opt7, opt8
        optionslen:
            .long len1, len2, len3, len4, len5, len6, len7, len8

        values:
            .long v1, v2, v3, v4, v5, v6, v7, v8
            
        valueslen:
            .long vlen1, vlen2, vlen3, vlen4, vlen5, vlen6, vlen7, vlen8
    
    superkey: 
        .string "2244"


.text
_start:

    # Check command line argument
    movl (%esp), %ecx
    cmpl $1, %ecx
    jle exitcheck

    movl 8(%esp), %esi
    leal superkey, %edi 
    cmpsl
    jne exitcheck
    movl $8, maxselect
    exitcheck:
    

    #call clear

    

    movl $0, %ecx # ecx here is used as a variable for the index value
    movl $0, %esi # this contains the shift value used to iterate through an array. (in C, it's used as if we're doing "array[esi]")

    

menuloop: # loop that shows the main menu

    cmpl maxselect,%ecx # If the index has reached the end of the iterations, then we jump to the endloop label
    je endloop

    pushl %ecx # temporarily push in the stuck the index of the loop inside ecx on top of the stack, because we need to use the register for the sys_write interrupt


    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # print selection 
        popl %ecx 
        cmpl    selection, %ecx
        pushl %ecx
        jne     notselected

        movl	$4,%edx                 # length of the string	       
        leal	selectedicon,%ecx		# string to write on the screen
        movl	$1, %ebx		        # file descriptor (stdout)
        movl	$4,%eax		            # system call number (sys_write)
        int	$0x80

        jmp exitselection

        notselected:

        movl	$4,%edx   # length of the string	       
        leal	notselectedicon,%ecx		# string to write on the screen
        movl	$1, %ebx		        # file descriptor (stdout)
        movl	$4,%eax		            # system call number (sys_write)
        int	$0x80

        exitselection:
    
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 


    movl	optionslen(%esi),%edx   # length of the string	       
    movl	options(%esi),%ecx		# string to write on the screen
    movl	$1, %ebx		        # file descriptor (stdout)
    movl	$4,%eax		            # system call number (sys_write)
    int	$0x80    

    movl	valueslen(%esi),%edx   # length of the string	       
    movl	values(%esi),%ecx		# string to write on the screen
    movl	$1, %ebx		        # file descriptor (stdout)
    movl	$4,%eax		            # system call number (sys_write)
    int	$0x80  

    popl %ecx # get back the index value by popping the stack and putting the value onto ecx

    addl $1, %ecx
    addl $4, %esi # we shift by 4 the value of esi because the arrays are composed of pointers that are 4 bytes long

    jmp menuloop # repeat the loop


endloop:

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # READ INPUT
        movl $0, input_buffer

        movl	$128,%edx	            # length of the buffer
        movl	$input_buffer,%ecx		# where to store the bufffer
        movl	$0, %ebx		        # file descriptor (stdin)
        movl	$3,%eax		            # system call number (sys_read)
        int	$0x80  

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
    
    call clear

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # SELECTION LOGIC
        movl $2, %esi        
        movb input_buffer(%esi), %bl
        cmpb %bl, up
        je selectup
        cmpb %bl, down
        je selectdown
        jmp exitinput

        selectup:
        subl $1, selection
        cmpl $-1, selection
        jne exitinput
        movl maxselect, %ebx
        subl $1, %ebx
        movl %ebx, selection
        jmp exitinput

        selectdown:
        addl $1, selection
        movl maxselect, %ebx
        
        cmpl %ebx, selection
        jne exitinput
        movl $0, selection
        jmp exitinput

        exitinput:
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    
    xor %ecx, %ecx # reset the register ecx
    xor %esi, %esi # reset the register esi



    jmp menuloop

quit:
    xor %eax, %eax

    mov    $1,%al               # 1 = Syscall for Exit()
    mov    $0,%ebx              # The status code we want to provide.
    int    $0x80                # Poke kernel. This will end the program.


clear:
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # CLEAR THE SCREEN
        movl	$lenclear,%edx	        # message length
        movl	$clearcode,%ecx		    # message to write
        movl	$1, %ebx		        # file descriptor (stdout)
        movl	$4,%eax		            # system call number (sys_write)
        int	$0x80                       # call kernel
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
    ret
