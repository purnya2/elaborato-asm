##########################################################################
# filename: onoffmenu.s
###########################################################################

.section 
.data

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

.global onoffmenu

.type onoffmenu, @function
# di cosa ha bisogno:
# the esi offset, $options, $optionslen, $input_buffer

onoffmenu:
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


        ret

        selectsubup:
        movl $on, %eax
        movl %eax, values(%esi)
        movl $onlen, %eax
        movl %eax, valueslen(%esi)
        ret

        selectsubdown:
        movl $off, %eax
        movl %eax, values(%esi)
        movl $offlen, %eax
        movl %eax, valueslen(%esi)
        ret

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
