##########################################################################

# Compile: as --march=i386 --32 ./hello_world_gas.s -o hello_world_gas.o
#    Link: ld -m elf_i386 hello_world_gas.o -o hello_world_gas
# as --march=i386 --32 main.s -o main.o && ld -m elf_i386 main.o -o main && ./main

###########################################################################


.data

    dot:
        .string "."


    timespec:
        .long 0
        .long  5000000000
    # variable that reserves space of 128 bytes as a buffer for the sys_read call
    input_buffer: .space 128

    # ### Sub Menu options####################################################
        onoffpart1:
            .string     "/---- "
            onoffpartlen1 = . - onoffpart1

        onoffpart2:
            .string     "----/\n"
            onoffpartlen2 = . - onoffpart2

        on:
            .string     "ON\n"
            onlen = . - on

        off:
            .string     "OFF\n"
            offlen = . - off

        pressione:
            .string     "\nPressione gomme resettata\n"
            pressionelen = . - pressione
        
        lampeggi:
            .long 3
        lampeggiascii:
            .byte '0'

        lampeggimsg:
            .string     "\nNumero dei lampeggi corrente : "
            lampeggimsglen = . - lampeggimsg
        lampeggimsginput:
            .string     "\ninserisci nuovo numero di lampeggi (da 2 a 6) : "
            lampeggimsginputlen = . - lampeggimsginput

    # ########################################################################

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



.global  _start


.text

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


_start:


    call clear


    # Check command line argument
    movl (%esp), %ecx
    cmpl $1, %ecx
    jle exitcheck

    movl 8(%esp), %esi
    leal superkey, %edi 
    cmpsl
    jne exitcheck


    movl    $opt1supervisor, options
    movl    $len1supervisor, optionslen

    movl    $8, maxselect
    exitcheck:
    

    #call clear

    

    movl $0, %ecx # ecx here is used as a variable for the index value
    movl $0, %esi # this contains the shift value used to iterate through an array. (in C, it's used as if we're doing "array[esi]")

    

    menuloop: # loop that shows the main menu



    cmpl maxselect,%ecx # If the index has reached the end of the iterations, then we jump to the endloop label
    je endmenuloop

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


    endmenuloop:

 
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # READ INPUT
        movl $0, input_buffer

        movl	$128,%edx	            # length of the buffer
        movl	$input_buffer,%ecx		# where to store the bufffer
        movl	$0, %ebx		        # file descriptor (stdin)
        movl	$3,%eax		            # system call number (sys_read)
        int	$0x80  

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
    movb input_buffer, %bl
    call clear

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # SELECTION LOGIC
        movl    $3, %esi
        movb    input_buffer(%esi), %cl
        movb    $10, %ch
        cmpb    %ch, %cl
        jne     exitinput

        movl $2, %esi        
        movb input_buffer(%esi), %bl

        cmpb %bl, up
        je selectup

        cmpb %bl, down
        je selectdown

        cmpb %bl, right
        je sottomenu

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

    returntomenuloop:
    xor %ecx, %ecx # reset the register ecx
    xor %esi, %esi # reset the register esi

    jmp menuloop
sottomenu:
    cmpl    $0, selection # Setting Automobile
    je returntomenuloop  

    cmpl    $1, selection # Data
    je returntomenuloop

    cmpl    $2, selection # Ora
    je returntomenuloop

    cmpl    $3, selection # Blocco automatico porte
    je sm_bloccoautomaticoporte

    cmpl    $4, selection # Back-home
    je sm_backhome

    cmpl    $5, selection # Check Olio
    je returntomenuloop

    cmpl    $6, selection # Freccie direzione
    je sm_frecciedirezione

    cmpl    $7, selection # Reset pressione Gomme
    je sm_pressionegomme


    je returntomenuloop



quit:
    xor %eax, %eax

    mov    $1,%al               # 1 = Syscall for Exit()
    mov    $0,%ebx              # The status code we want to provide.
    int    $0x80                # Poke kernel. This will end the program.



sm_bloccoautomaticoporte:
    call clear
    
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # print title 
        movl	$1,%ebx	       
        movl	$4,%eax
        movl	$onoffpartlen1,%edx
        movl	$onoffpart1,%ecx
        int	$0x80

        movl	$4,%eax
        movl	$len4,%edx
        movl	$opt4,%ecx
        int	$0x80

        movl	$4,%eax
        movl	$onoffpartlen2,%edx
        movl	$onoffpart2,%ecx
        int	$0x80
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


    xorl %ecx, %ecx


    movl	$1,%ebx	       
    movl	$4,%eax
    movl	$onlen,%edx
    movl	$on,%ecx
    int	$0x80




    movl	$1,%ebx	       
    movl	$4,%eax
    movl	$offlen,%edx
    movl	$off,%ecx
    int	$0x80


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
    # SUBSELECTION LOGIC
        movl    $3, %esi
        movb    input_buffer(%esi), %cl
        movb    $10, %ch
        cmpb    %ch, %cl
        jne     sm_bloccoautomaticoporte

        movl $2, %esi        
        movb input_buffer(%esi), %bl
        movl $12, %esi

        cmpb %bl, up
        je selectsubup

        cmpb %bl, down
        je selectsubdown


        jmp returntomenuloop

        selectsubup:
        movl $on, %eax
        movl %eax, values(%esi)
        movl $onlen, %eax
        movl %eax, valueslen(%esi)
        jmp returntomenuloop

        selectsubdown:
        movl $off, %eax
        movl %eax, values(%esi)
        movl $offlen, %eax
        movl %eax, valueslen(%esi)
        jmp returntomenuloop

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #



sm_backhome:
    call clear

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # print title 
        movl	$1,%ebx	       
        movl	$4,%eax
        movl	$onoffpartlen1,%edx
        movl	$onoffpart1,%ecx
        int	$0x80

        movl	$4,%eax
        movl	$len5,%edx
        movl	$opt5,%ecx
        int	$0x80

        movl	$4,%eax
        movl	$onoffpartlen2,%edx
        movl	$onoffpart2,%ecx
        int	$0x80
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


    xorl %ecx, %ecx



    movl	$1,%ebx	       
    movl	$4,%eax
    movl	$onlen,%edx
    movl	$on,%ecx
    int	$0x80


    movl	$1,%ebx	       
    movl	$4,%eax
    movl	$offlen,%edx
    movl	$off,%ecx
    int	$0x80


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
    # SUBSELECTION LOGIC

        movl    $3, %esi
        movb    input_buffer(%esi), %cl
        movb    $10, %ch
        cmpb    %ch, %cl
        jne     sm_backhome

        movl $2, %esi        
        movb input_buffer(%esi), %bl
        movl $16, %esi

        cmpb %bl, up
        je selectsubup2

        cmpb %bl, down
        je selectsubdown2

        jmp returntomenuloop

        selectsubup2:
        movl $on, %eax
        movl %eax, values(%esi)
        movl $onlen, %eax
        movl %eax, valueslen(%esi)
        jmp returntomenuloop

        selectsubdown2:
        movl $off, %eax
        movl %eax, values(%esi)
        movl $offlen, %eax
        movl %eax, valueslen(%esi)
        jmp returntomenuloop

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


sm_frecciedirezione:

    call clear

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # print title 
        movl	$1,%ebx	       
        movl	$4,%eax
        movl	$onoffpartlen1,%edx
        movl	$onoffpart1,%ecx
        int	$0x80

        movl	$4,%eax
        movl	$opt7,%ecx
        movl	$len7,%edx     
        int	$0x80

        movl	$4,%eax
        movl	$onoffpartlen2,%edx
        movl	$onoffpart2,%ecx
        int	$0x80
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

    movl	$4,%eax
    movl	$lampeggimsglen,%edx
    movl	$lampeggimsg,%ecx
    int	$0x80


    movl	$4,%eax
    movl	$1,%edx
    movl    lampeggi, %ecx
    addl    $48, %ecx
    movl    %ecx, lampeggiascii
    movl    $lampeggiascii, %ecx
    int	$0x80

    movl	$4,%eax
    movl	$lampeggimsginputlen,%edx
    movl	$lampeggimsginput,%ecx
    int	$0x80


    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # READ INPUT
        movl $0, input_buffer

        movl	$128,%edx	            # length of the buffer
        movl	$input_buffer,%ecx		# where to store the bufffer
        movl	$0, %ebx		        # file descriptor (stdin)
        movl	$3,%eax		            # system call number (sys_read)
        int	$0x80  

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

    # movl $4
    # movb input_buffer, %bl
    # movb $10, %al
    # cmpb %al, %bl

    call clear

    movl    $1, %esi
    movb    input_buffer(%esi), %cl
    movb    $10, %ch
    cmpb    %ch, %cl
    jne     skip3


    movb    input_buffer, %cl
    subb    $48, %cl 

    movb    $2, %ch
    cmpb    %ch, %cl 
    jg      skip1
    movb    %ch, lampeggi
    jmp returntomenuloop

    skip1:

    movb    $6, %ch 
    cmpb    %ch, %cl 
    jl      skip2
    movb    %ch, lampeggi
    jmp returntomenuloop

    skip2:
    movb    %cl, lampeggi

    jmp returntomenuloop

    skip3:
    movb    $6, %ch
    movb    %ch, lampeggi
    jmp returntomenuloop

    

sm_pressionegomme:

    

    xorl %ecx, %ecx

    pressioneloop:
    cmpl $3, %ecx
    push %ecx
    je exitpressioneloop


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

    call clear

    jmp returntomenuloop
