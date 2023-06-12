##########################################################################
# filename: onoffmenu.s
##########################################################################

# Global variables section

.section .data

	input_buffer: 
    		.space 64

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

# Static non-initialized variables section

.section .bss

	.lcomm	title, 4
	.lcomm	length, 4

    

# Instructions section

.section .text

	.global onoffmenu			


.type onoffmenu, @function			# This function needs: the "esi" offset, $options, $optionslen, $input_buffer


onoffmenu:

    # Move the title and it's length in the local variables because we will need ECX and EDX after to print other things, so we save them in order to not loose them
    # Both ECX and EDX were set by the caller ("main.s")
    
    movl	%edx, length
    movl	%ecx, title
    
    # Push on the stack the old value and it's length, if the users presses "ENTER" and exits the menu those must not change
    
    pushl	%eax
    pushl	%ebx

invalidinputrepeat:

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

    	xorl %ecx, %ecx				# Clear both ECX and EDX

    	# Print the instructions (part 1)
    
    	movl	$1,%ebx	       
    	movl	$4,%eax
    	movl	$instructionsonlen,%edx
    	movl	$instructionson,%ecx
    	int	$0x80

    	# Print the instructions (part 2)
    
    	movl	$1,%ebx	       
    	movl	$4,%eax
   	movl	$instructionsofflen,%edx
    	movl	$instructionsoff,%ecx
    	int	$0x80
        
   	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


	# # # # # # # # # # # # # # # # # # # # READ INPUT ZONE # # # # # # # # # # # # # # # # # #

        movl $0, input_buffer		    	# Clear the input buffer

        movl	$128,%edx	            	# Length of the buffer
        movl	$input_buffer,%ecx	    	# Where to store the bufffer
        movl	$0, %ebx		    	# File descriptor (stdin)
        movl	$3,%eax		            	# System call number (sys_read)
        int	$0x80  			    	# Poke the kernel

   	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
    
    	call clear				# Clear the screen

     	# # # # # # # # # # # # # # # # # # SUBSELECTION LOGIC ZONE # # # # # # # # # # # # # # # #
     	
     	# Firstly we check if the user has pressed "ENTER" to exit without changing the old value
     	# This and it's length are retreived from the stack
     	# In case, return to the caller
     	
     	movl    $0, %esi                
        movb    input_buffer(%esi), %cl 	
        movb    $10, %ch		  	
        cmpb    %ch, %cl    			
        jne     notenter		
        
     	popl	%ebx
     	popl	%eax
     	
     	ret
     	
notenter:     	
 
 	# Secondly we check if the second character inserted by the user is an "ENTER"
 	# If it's not, input is invalidated
 	# Then we will check the first character
 
        movl    $3, %esi                	# Shift is three because the arrow is in the form ".[*" where '*' is replaced according to the type of arrow
        movb    input_buffer(%esi), %cl 	
        movb    $10, %ch		  	
        cmpb    %ch, %cl    			
        jne     invalidinputrepeat		

	# Put the first character read in the lower part (bits from 0 to 7) of EBX
	
        movl    $2, %esi        
        movb    input_buffer(%esi), %bl
        
        # Check if the user has pressed UP button
        
        cmpb    %bl, up
        je      selectsubup             

        # Check if the user has pressed DOWN button
         
        cmpb    %bl, down
        je      selectsubdown

	# If something else has been inserted, input is invalid, so repeat the cicle
	
        jne     invalidinputrepeat


selectsubup:

	# Move the string "ON" and it's length in both EAX and EBX
	# They will be used by the caller display the new settings
	# Then return to the caller

        movl    $on, %eax
        movl    $onlen, %ebx
        
        popl	%edx
        popl	%edx
        
        ret

selectsubdown:

	# Move the string "OFF" and it's length in both EAX and EBX
	# They will be used by the caller display the new settings
	# Then return to the caller

        movl    $off, %eax
        movl    $offlen, %ebx
        
        popl	%edx
        popl	%edx
        
        ret

	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


