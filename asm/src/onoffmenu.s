##########################################################################
# filename: onoffmenu.s
###########################################################################

.section .data

    input_buffer: .space 64

    header1:
        .string     "/---- "
        headerlen1 = . - header1

    header2:
        .string     "----/\n"
        headerlen2 = . - header2

    instructionson:
        .string     "Freccia SU + <invio> per selezionare ON\n"
        instructionsonlen = . - instructionson
    instructionsoff:
        .string     "Freccia GIU + <invio> per selezionare OFF\n"
        instructionsofflen = . - instructionsoff
    on:
        .string     "ON\n"
        onlen = . - on

    off:
        .string     "OFF\n"
        offlen = . - off

    up:
        .byte 'A'
    down:
        .byte 'B'

.section .bss
    .lcomm title, 4
    .lcomm length, 4

    


.section .text
.global onoffmenu


.type onoffmenu, @function
# di cosa ha bisogno:
# the esi offset, $options, $optionslen, $input_buffer


onoffmenu:
    movl %edx, length
    movl %ecx, title

    invalidinputrepeat:



    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    # PRINT TITLE

        # print "/---- "
        movl	$1,%ebx	       
        movl	$4,%eax
        movl	$headerlen1,%edx
        movl	$header1,%ecx
        int	$0x80


        # print title
        movl	$1,%ebx	       
        movl	$4,%eax
        movl	length,%edx
        movl	title,%ecx
        int	$0x80

        int	$0x80

        # print "----/\n"
        movl	$4,%eax
        movl	$headerlen2,%edx
        movl	$header2,%ecx
        int	$0x80
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


    xorl %ecx, %ecx


    movl	$1,%ebx	       
    movl	$4,%eax
    movl	$instructionsonlen,%edx
    movl	$instructionson,%ecx
    int	$0x80

    movl	$1,%ebx	       
    movl	$4,%eax
    movl	$instructionsofflen,%edx
    movl	$instructionsoff,%ecx
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
        movb    $10, %ch                # check if the third byte has the escape character
        cmpb    %ch, %cl
        jne     invalidinputrepeat

        movl    $2, %esi        
        movb    input_buffer(%esi), %bl

        cmpb    %bl, up
        je      selectsubup             

        cmpb    %bl, down
        je      selectsubdown


        jne     invalidinputrepeat

        selectsubup:
        movl    $on, %eax
        movl    $onlen, %ebx
        ret

        selectsubdown:
        movl    $off, %eax
        movl    $offlen, %ebx
        ret

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


