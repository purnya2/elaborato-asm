##########################################################################
# filename: onoffmenu.s
###########################################################################

.section .data

    lampeggimsg:
        .string     "\nNumero dei lampeggi corrente : "
        lampeggimsglen = . - lampeggimsg
        
    lampeggimsginput:
        .string     "\ninserisci nuovo numero di lampeggi (da 2 a 6) (default: 3) : "
        lampeggimsginputlen = . - lampeggimsginput

    input_buffer: .space 64

    header1:
        .string     "/---- "
        headerlen1 = . - header1

    header2:
        .string     "----/\n"
        headerlen2 = . - header2

    lampeggi:
        .long 3
    lampeggiascii:
        .byte '0'

   

.section .bss
    .lcomm title, 4
    .lcomm length, 4

    


.section .text
.global frecciedirezione


.type frecciedirezione, @function


frecciedirezione:
    movl %edx, length
    movl %ecx, title
    movl %eax, lampeggi

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
    
    call clear

    # default 3 (controls if you've put only the enter key)
    movl    $0, %esi
    movb    input_buffer(%esi), %cl
    movb    $10, %ch
    cmpb    %ch, %cl
    je     defaultvalue

    # ccontrols if the input has more than 2 digits
    movl    $1, %esi
    movb    input_buffer(%esi), %cl
    movb    $10, %ch
    cmpb    %ch, %cl
    jne     greater_than_nine

    movb    input_buffer, %cl           # Moves the first byte into the cl (low part of ECX)
    subb    $48, %cl 

    # CH > 2 ?
    # if yes -> jump to check_if_upper_than_six
    # if no -> return 2
    movb    $2, %ch
    cmpb    %ch, %cl 
    jg      check_if_upper_than_six
    movb    %ch, %ah
    ret

    # CH < 6 ?
    # if yes -> return 6
    # if no -> jump to return_value
    check_if_upper_than_six:
    movb    $6, %ch 
    cmpb    %ch, %cl 
    jl      return_value
    movb    %ch, %ah
    ret

    return_value:
    movb    %cl, %ah                    # return the inputted value!!
    ret

    greater_than_nine:
    movb    $6, %ch
    movb    %ch, %ah
    ret

    defaultvalue:
    movb    $3, %ch
    movb    %ch, %ah
    ret

 # TODO metti in ordine
