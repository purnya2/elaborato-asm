##########################################################################
# filename: pressionegomme.s
##########################################################################

# Global variables section

.section .data

	
	
	timespec:			# Struct used from the function "nanosleep" 
    
        	.long 0			# How many seconds to wait
        	.long 0 	  	# How many nanoseconds to wait (in addition to the seconds)
        
	input_buffer:
		.space 64

	pressione:
        	.string     "\nPressione gomme resettata!\n"
        	pressionelen = . - pressione

	dot:
        	.string "."
    
# Instructions section

.section .text

	.global pressionegomme

.type pressionegomme, @function

pressionegomme:

	xorl	%ecx, %ecx		# Clear ECX register
	movl	$1, timespec	# Initialize the structure "timespec" with a number of seconds equal to one

pressioneloop:
    
    	# Check if three "dots" have been printed
    	# Otherwise, push ECX on the top of the stack in order to not loose it later
    
    	cmpl	$3, %ecx
	je	exitpressioneloop
	push	%ecx

   	# Wait TOT time according to the struct defined in the variables section
    
    	movl	$162, %eax		# System call number '162', "nanosleep"
    	movl	$timespec, %ebx		# Struct address
    	int	$0x80

    	# Print one dot
    
	movl	$1,%edx     
    	movl	$dot,%ecx
    	movl	$1, %ebx		
    	movl	$4,%eax		       
    	int	$0x80
 
	# Retrieve the number of the dots printed from the stack and increment it, then repeat the cicle
    
	pop 	%ecx	
	incl    %ecx
	jmp 	pressioneloop


exitpressioneloop:
 
	# Wait TOT time according to the struct defined in the variables section
    
   	movl	$162, %eax		# System call number '162', "nanosleep"
    	movl	$timespec, %ebx         # Struct address
    	int	$0x80


	# Print "\nPressione gomme resettata!\n"
    
	movl	$pressionelen,%edx             
	movl	$pressione,%ecx		
   	movl	$1, %ebx	    
    	movl	$4,%eax		  
    	int	$0x80
    
    	# Change the time to wait
    
    	movl	$1, timespec

    	# Wait TOT time according to the struct defined in the variables section
    
   	movl	$162, %eax		# System call number '162', "nanosleep"
    	movl	$timespec, %ebx         # Struct address
    	int	$0x80
    
    	# Clear the screen and return back to the caller
    
	call clear 
	
	ret
