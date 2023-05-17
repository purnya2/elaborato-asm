
.data

    # variable that reserves space of 64 bytes as a buffer for the sys_read call
    input_buffer: .space 64


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

    lampeggi:
            .long 3

    # ### Menu options########################################################
        opt1:
            .string    "Setting Automobile: "
            len1 = . - opt1 

        opt1supervisor:
            .string    "Setting Automobile (supervisor): "
            len1supervisor = . - opt1supervisor 
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

    # ### Menu values#########################################################
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



    # arrays of pointers towards the options, values, and their lengths
        options:
            .long opt1, opt2, opt3, opt4, opt5, opt6, opt7, opt8
        optionslen:
            .long len1, len2, len3, len4, len5, len6, len7, len8

        values:
            .long v1, v2, v3, v4, v5, v6, v7, v8
            
        valueslen:
            .long vlen1, vlen2, vlen3, vlen4, vlen5, vlen6, vlen7, vlen8
    #key required to access supervisore mode
    superkey: 
        .string "2244"

.global  _start
.text

_start:

    call clear # Clear the screen

    # Check command line argument count
    movl    (%esp), %ecx
    cmpl    $1, %ecx
    jle     exitcheck

    # compare the string of the first argument with the superkey variable
    movl    8(%esp), %esi
    leal    superkey, %edi 
    cmpsl                                   # compare the strings stored in %esi and %edi (usually cmpsl ALWAYS compares ONLY between %esi and %edi)
    jne     exitcheck                       # if it's not equal, don't do the following operations and exit to this label

    movl    $opt1supervisor, options        # Modify the first option to make it look like "Setting Automobile (supervisor):"
    movl    $len1supervisor, optionslen     # Modify the length as well, as it's necessary for the sys_write call

    movl    $8, maxselect                   # increase the amount of menu options that will be shown

    exitcheck:

    movl    $0, %ecx                        # ecx here is used as a variable for the index value that we use loop through 6 times (8 if the supervisore mode is enabled)
    movl    $0, %esi                        # this contains the shift value used to iterate through an array. (in C, it's used as if we're doing "array[esi]")


    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # START OF THE MENU LOOP
    
        menuloop: # start of the loop that shows the main menu by showing the lines loop by loop

        cmpl    maxselect,%ecx              # If the index has reached the end of the iterations(6 or 8), then we jump to the endloop label, in order to, well, end the loop
        je      endmenuloop

        pushl   %ecx                        # temporarily push in the stack the index of the loop inside ecx, on top of the stack, 
                                            # because we need to use the ECX register for the sys_write interrupt


        # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
        # PRINT SELECTION (EITHER [ ] OR [o])

            popl    %ecx                    # Temporarily retrieve from the stack what position/index we're in
            cmpl    selection, %ecx         # Check if the current number line matches with the number of the selection.
            pushl   %ecx                    # Put back in the stack the position/index
            jne     notselected             # If it's not equal, jump to the label that prints "[ ] ", otherwise do the following that will print "[o] "

            movl	$4,%edx                 # length of the string (if you count "[o] " you can see that it's made of 4 characters/4 bytes)	       
            leal	selectedicon,%ecx		# string to write on the screen (print "[o] ")
            movl	$1, %ebx		        # file descriptor (stdout)
            movl	$4,%eax		            # system call number (sys_write)
            int	    $0x80                   # poke the kernel to tell it that we want to (EAX)SYS_WRITE the (ECX)string that is (EDX)4 bytes long in the (EBX)stdout

            jmp exitselection               # Here we have printed "[o] "! if we don't want to also print "[ ] " we must jump into this label in order to avoid the next lines of code

            notselected:                    # If we have to write "[ ] " we need to be jumped here

            movl	$4,%edx                 # length of the string (if you count "[ ] " you can see that it's STILL made of 4 characters/4 bytes)	       
            leal	notselectedicon,%ecx    # string to write on the screen (print "[ ] ")
            movl	$1, %ebx		        # file descriptor (stdout)
            movl	$4,%eax		            # system call number (sys_write)
            int	    $0x80                   # poke the kernel to tell it that we want to (EAX)SYS_WRITE the (ECX)string that is (EDX)4 bytes long in the (EBX)stdout

            exitselection:
            
        # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 


        #here we access the arrays optionslen and options. We shift the position of the index by updating the %esi value in each loop
        movl	optionslen(%esi),%edx   # length of the string      
        movl	options(%esi),%ecx		# string to write on the screen
        movl	$1, %ebx		        # file descriptor (stdout)
        movl	$4,%eax		            # system call number (sys_write)
        int	    $0x80    

        #here we access the arrays valueslen and values. We shift the position of the index by updating the %esi value in each loop
        movl	valueslen(%esi),%edx    # length of the string	       
        movl	values(%esi),%ecx		# string to write on the screen
        movl	$1, %ebx		        # file descriptor (stdout)
        movl	$4,%eax		            # system call number (sys_write)
        int	    $0x80  

        popl    %ecx                    # get back the index value by popping the stack and putting the value onto ecx

        addl    $1, %ecx                # add 1 to ECX, this is the same as doing i++ in a for loop in C
        addl    $4, %esi                # we shift by 4 the value of esi because the arrays are composed of pointers that are 4 bytes long

        jmp     menuloop                # repeat the loop

        endmenuloop:
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
 
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # READ INPUT
        movl    $0, input_buffer        # reset the input_buffer (we need to do this because the input_buffer contains dirty values from previous iterations)

        movl	$128,%edx	            # length of the buffer
        movl	$input_buffer,%ecx		# where to store the bufffer
        movl	$0, %ebx		        # file descriptor (stdin)
        movl	$3,%eax		            # system call number (sys_read)
        int	$0x80  
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

    call    clear

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # SELECTION LOGIC  
        # This is the part where we handle how the movement of the selection goes thanks to the input by the user


        # We first need to check of the input is valid. We are specifically checking here if there's an escape character($10) in the 
        # third byte of the input. This is to invalidate an output that looks like up+up+enter or down+right+enter. 
        # I have decided that the only inputs that are valid are strictly up+enter, down+enter, right+enter
        movl    $3, %esi                
        movb    input_buffer(%esi), %cl
        movb    $10, %ch
        cmpb    %ch, %cl    
        jne     exitselectionlogic              # Invalid input was found! exit the selection logic section without doing any change

        movl $2, %esi
        movb input_buffer(%esi), %bl

        cmpb %bl, up                            # Check ARROW UP
        je selectup

        cmpb %bl, down                          # Check ARROW DOWN
        je selectdown

        cmpb %bl, right                         # Check ARROW RIGHT
        je sottomenu                            # if the arrow right is selected, we will hop into a sottomenu

        jmp exitselectionlogic

        selectup:                               # handle arrow up
        subl $1, selection
        cmpl $-1, selection
        jne exitselectionlogic
        movl maxselect, %ebx
        subl $1, %ebx
        movl %ebx, selection
        jmp exitselectionlogic

        selectdown:                             # handle arrow down
        addl $1, selection
        movl maxselect, %ebx
        cmpl %ebx, selection
        jne exitselectionlogic
        movl $0, selection
        jmp exitselectionlogic

        exitselectionlogic:
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

    returntomenuloop:

    # In order to avoid unexpected behavior, we reset the following registers
    xorl    %ecx, %ecx                  # reset the register ecx
    xorl    %esi, %esi                  # reset the register esi

    jmp     menuloop


sottomenu:
    cmpl    $0, selection               # Setting Automobile 
    je      returntomenuloop  

    cmpl    $1, selection               # Data !! NOT IMPLEMENTED !!
    je      returntomenuloop

    cmpl    $2, selection               # Ora !! NOT IMPLEMENTED !!
    je      returntomenuloop

    cmpl    $3, selection               # Blocco automatico porte
    je      sm_bloccoautomaticoporte

    cmpl    $4, selection               # Back-home
    je      sm_backhome

    cmpl    $5, selection               # Check Olio !! NOT IMPLEMENTED !!
    je      returntomenuloop

    cmpl    $6, selection               # Freccie direzione
    je      sm_frecciedirezione

    cmpl    $7, selection               # Reset pressione Gomme
    je      sm_pressionegomme


    je      returntomenuloop


sm_bloccoautomaticoporte:
    call    clear

    movl    $opt4, %ecx                 # ECX is used in the function to store the string of the title
    movl    $len4, %edx                 # EDX is used in the function to store the length of the title

    call    onoffmenu                   # Function onoffmenu
    movl    $12, %esi

    # Modify the values in the right position
    movl    %eax, values(%esi)
    movl    %ebx, valueslen(%esi)


    jmp returntomenuloop


sm_backhome:

    call clear

    movl $opt5, %ecx
    movl $len5, %edx

    call onoffmenu
    movl $16, %esi                      # notice how the value is +4 compared to the previous sottomenu

    movl %eax, values(%esi)
    movl %ebx, valueslen(%esi)

    jmp returntomenuloop



sm_frecciedirezione:

    movl lampeggi, %eax                 # EAX is used in the function to let it know how many LAMPEGGI we got

    movl $opt7, %ecx
    movl $len7, %edx
    
    call frecciedirezione
    movb %ah, lampeggi                  # Set new value for LAMPEGGI
    jmp returntomenuloop

    

sm_pressionegomme:
    call pressionegomme                 # pretty simple function
    jmp returntomenuloop
