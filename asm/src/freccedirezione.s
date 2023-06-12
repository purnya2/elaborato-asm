##########################################################################
# filename: freccedirezione.s
##########################################################################

# Global variables section

.section .data

	lampeggimsg:    
        	.string     "\nNumero dei lampeggi corrente : "
        	lampeggimsglen = . - lampeggimsg
        
	lampeggimsginput:
    		.string     "\ninserisci nuovo numero di lampeggi (da 2 a 5) (default: 3) : "
        	lampeggimsginputlen = . - lampeggimsginput

	input_buffer: 
   		.space 64

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

# Static non-initialized variables section

.section .bss        
    .lcomm title, 4
    .lcomm length, 4

    
# Instructions section

.section .text
	
	.global freccedirezione


.type freccedirezione, @function

freccedirezione:

	# Move the title, it's length and "lampeggi" in the local variables because we will need EAX, ECX and EDX after to print other things, so we save them to not loose them
   	# Both ECX and EDX were set by the caller ("main.s")

   	movl	%edx, length
    	movl	%ecx, title
    	movl	%eax, lampeggi

	# # # # # # # # # # # # # # # # # # # # PRINT ZONE # # # # # # # # # # # # # # # # # # # # #


        # Print "/---- "
        
        movl	$1,%ebx	       
        movl	$4,%eax
        movl	$headerlen1,%edx
        movl	$header1,%ecx
        int	$0x80

        # Print the title from the local variables
        
        movl	$1,%ebx	       
        movl	$4,%eax
        movl	length,%edx
        movl	title,%ecx
        int	$0x80

        # Print "----/\n"
        
        movl	$4,%eax
        movl	$headerlen2,%edx
        movl	$header2,%ecx
        int	$0x80
        
        xorl 	%ecx, %ecx			# Clear both ECX and EDX

	# Print the string "Numero lampeggi corrente: "
	
	movl 	$4,%eax
	movl 	$lampeggimsglen,%edx
	movl 	$lampeggimsg,%ecx
	int 	$0x80
	
	# Print the number of "Lampeggi". Before we have to convert from INT (2 to 5) to CHAR ('2' to '5')
	
	movl 	$4,%eax
    	movl 	$1,%edx
   	movl 	lampeggi, %ecx
    	addl 	$48, %ecx			# $48 = 'A'
    	movl 	%ecx, lampeggiascii
    	movl 	$lampeggiascii, %ecx
    	int  	$0x80
        
        # Print the string "Inserisci nuovo numero di lampeggi (da 2 a 5) (default: 3) : "
        
        movl 	$4,%eax
   	movl 	$lampeggimsginputlen,%edx
   	movl 	$lampeggimsginput,%ecx
    	int  	$0x80
        
    	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


	# # # # # # # # # # # # # # # # # # # # READ INPUT # # # # # # # # # # # # # # # # # # # # # #

        movl $0, input_buffer			# Reset the input buffer

        movl	$128,%edx	            	# Length of the buffer
        movl	$input_buffer,%ecx	 	# Where to store the bufffer
        movl	$0, %ebx		        # File descriptor (stdin)
        movl	$3,%eax		            	# System call number (sys_read)
        int	$0x80  

    	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    	
    
	call	clear				# Clear the screen

   	# The default number of "Lampeggi" is '3', so if the user presses "ENTER" without inserting a number, '3' will be the new value
   	
    	movl	$0, %esi
    	movb	input_buffer(%esi), %cl
    	movb	$10, %ch
    	cmpb 	%ch, %cl
    	je 	defaultvalue
    	
    	# If the input has more than two digits, it is not valid (checks if the second character inserted by the user is either "ENTER" or not)
    	
    	movl    $1, %esi
    	movb    input_buffer(%esi), %cl
    	movb    $10, %ch
    	cmpb    %ch, %cl
    	jne     greater_than_nine
    	
	# The input inserted by the user (the first char, number of "Lampeggi") is converted from CHAR to INT in order to make comparisons in the next part
	
    	movb    input_buffer, %cl
    	subb    $48, %cl 

   	# Check if the input inserted by the user is greater-equal than two or not. If it's not, value '2' is assigned and function ends, otherwise there will be another check
    
    	movb    $2, %ch
    	cmpb    %ch, %cl 
    	jge      check_if_upper_than_six
    	movb    %ch, %ah
    	ret
    	
check_if_upper_than_six:

	# Check if the input inserted by the user is less-equal than 5 or not
	# If it's not, value 5 is assigned and function ends, otherwise the input inserted by the user is correct

    	movb    $5, %ch 
    	cmpb    %ch, %cl 
    	jl      return_value
    	
    	movb    %ch, %ah
    	ret

return_value:

	# The input inserted by the user is correct, so it is returned back to the caller
	
	movb    %cl, %ah
	ret

 greater_than_nine:
 
	# Value '5' is returned back to the caller because the user has inserted a value greater than five
 
   	movb    $5, %ch
	movb    %ch, %ah
	ret

defaultvalue:

    	# Defualt value '3' is returned back to the caller

	movb    $3, %ch
	movb    %ch, %ah
	ret









