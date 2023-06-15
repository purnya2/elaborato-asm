##########################################################################
# filename: main.s
##########################################################################

# Global variables section

.section .data	

	# General useful data	   

	input_buffer:					# Variable that reserves space of 64 bytes as a buffer for the sys_read call (large space!)
    		.space 64       


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
		
		

    	# Menu options
    
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
            	.string    "Frecce direzione "
            	len7 = . - opt7
        opt8:
            	.string    "Reset pressione gomme "
            	len8 = . - opt8

    

    	# Menu values
    
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



    	# Arrays of pointers towards the options, values, and their lengths
    	
	options:
        	.long opt1, opt2, opt3, opt4, opt5, opt6, opt7, opt8
        	
        optionslen:
        	.long len1, len2, len3, len4, len5, len6, len7, len8

        values:
        	.long v1, v2, v3, v4, v5, v6, v7, v8
            
        valueslen:
		.long vlen1, vlen2, vlen3, vlen4, vlen5, vlen6, vlen7, vlen8
            
            
            
    	# Key required to access supervisore mode
    	
	superkey: 
        	.string "2244"
        	

# Instructions section

.section .text		

	.global  _start

_start:

	# Clear the screen
	
	call	clear

	# Check command line argument count
	
    	movl    (%esp), %ecx			# Put in ECX the value inside the cell pointed by stack pointer (to get the argument count)
    	cmpl	$1, %ecx     		   	# Check if it's equal to one (there's only one argument, the program's name)
    	je     exitcheck       		   	# Exit this check if there is only one argument

    	# Compare the string of the first argument with the "superkey" variable
    	
    	movl    8(%esp), %esi			# Get the value of the first parameter (4 characters, one memory cell if one cell is 32 bit wide)
    	leal	superkey, %edi 			
    	cmpsl                                   # Compare the strings stored in %ESI and %EDI (usually cmpsl ALWAYS compares ONLY between %ESI and %EDI)
    	jne	exitcheck                       # If the code is not the one defined in "superkey", don't allow the supervisor mode and jump in the next label

    	movl    $opt1supervisor, options        # Modify the first option to make it look like "Setting Automobile (supervisor):"
    	movl    $len1supervisor, optionslen     # Modify the length as well, as it's necessary for the "sys_write" call

    	movl    $8, maxselect                   # Increase the amount of menu options that will be shown

exitcheck:

    	movl    $0, %ecx                        # Register ECX here is used as a variable for the index value that we use loop through 6 times (8 if the supervisore mode is enabled)
    	movl    $0, %esi                        # This contains the shift value used to iterate through an array (in C, it's used as if we're doing "array[ESI]")


# START OF THE MENU LOOP
    
menuloop: 		   		 	# Start of the loop that shows the main menu by showing the lines one by one

        cmpl    maxselect,%ecx           	# If the index has reached the end of the iterations(6 or 8), then we jump to the endloop label, in order to, well, end the loop
        je      endmenuloop

        pushl	%ecx                        	# Temporarily push in the stack the index of the loop inside ecx, on top of the stack (We'll need ECX  later)


        # PRINT SELECTION (EITHER [ ] OR [o])

	popl    %ecx                    	# Temporarily retrieve from the stack what position/index we're in
        cmpl    selection, %ecx         	# Check if the current number line matches with the number of the selection
        pushl   %ecx                    	# Put back in the stack the position/index
        jne     notselected             	# If it's not equal, jump to the label that prints "[ ] ", otherwise do the following that will print "[o] "

        movl	$4,%edx                 	# Length of the string (if you count "[o] " you can see that it's made of 4 characters/4 bytes)	       
        leal	selectedicon,%ecx		# String to write on the screen (print "[o] ")
        movl	$1, %ebx		        # File descriptor (stdout)
        movl	$4,%eax		            	# System call number (sys_write)
        int	$0x80                  		# Poke the kernel to tell it that we want to (EAX)SYS_WRITE the (ECX)string that is (EDX)4 bytes long in the (EBX)stdout

        jmp	exitselection  			# Here we have printed "[o] "! if we don't want to also print "[ ] " we must jump into this label in order to avoid the next lines of code

notselected:                    		# If we have to write "[ ] " we need to be jumped here

	movl	$4,%edx                 	# Length of the string (if you count "[ ] " you can see that it's STILL made of 4 characters/4 bytes)	       
	leal	notselectedicon,%ecx    	# String to write on the screen (print "[ ] ")
	movl	$1, %ebx			# File descriptor (stdout)
	movl	$4,%eax		        	# System call number (sys_write)
	int	$0x80                  	 	# Poke the kernel to tell it that we want to (EAX)SYS_WRITE the (ECX)string that is (EDX)4 bytes long in the (EBX)stdout

exitselection:

        # Here we access the arrays optionslen and options
        # We shift the position of the index by updating the %ESI value in each loop
        
        movl	optionslen(%esi),%edx   	
        movl	options(%esi),%ecx		
        movl	$1, %ebx		        
        movl	$4,%eax		            	
        int	$0x80    
	
        # Here we access the arrays valueslen and values
        # We shift the position of the index by updating the %ESI value in each loop
        
	movl	valueslen(%esi),%edx          
        movl	values(%esi),%ecx		
        movl	$1, %ebx		        
        movl	$4,%eax		            
        int	$0x80  

        popl    %ecx                   	 	# Get back the index value by popping the stack and putting the value onto ECX

        addl    $1, %ecx                	# Add '1' to ECX, this is the same as doing i++ in a for loop in C
        addl    $4, %esi                	# Shift by 4 the value of esi because the arrays are composed of pointers that are 4 bytes long

        jmp     menuloop                	# Repeat the loop

endmenuloop:

        
	# # # # # # # # # # # # # # # # # # # # READ INPUT ZONE # # # # # # # # # # # # # # # # # #

        movl $0, input_buffer		    	# Reset the input_buffer (we need to do this because the input_buffer contains dirty values from previous iterations)

        movl	$128,%edx	            	# Length of the buffer
        movl	$input_buffer,%ecx	    	# Where to store the bufffer
        movl	$0, %ebx		    	# File descriptor (stdin)
        movl	$3,%eax		            	# System call number (sys_read)
        int	$0x80  			    	# Poke the kernel

   	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #       
         
	call	clear  				# Clear the screen
	
	# # # # # # # # # # # # # # # # # # SUBSELECTION LOGIC ZONE # # # # # # # # # # # # # # # #

    	
        # This is the part where we handle how the movement of the selection goes thanks to the input by the user

        # We first need to check if the input is valid
        # We are specifically checking here if there's an escape character($10) in the third byte of the input
        # This is to invalidate an output that looks like up+up+enter or down+right+enter 
        # Only inputs that are valid are strictly up+enter, down+enter, right+enter
        
        # Check if the second character is an "ENTER"
        	
        movl	$3, %esi                	# Shift is three because the arrow is in the form ".[*" where '*' is replaced according to the type of arrow
        movb    input_buffer(%esi), %cl 	
        movb    $10, %ch		  	
        cmpb    %ch, %cl    			
        jne     exitselectionlogic              # Invalid input was found, so exit the selection logic section without doing any change (then loop will be repeated)

	# Load the first character and do things according to it	
	
        movl	$2, %esi				
        movb 	input_buffer(%esi), %bl

        cmpb 	%bl, up                         # Check ARROW UP
        je 	selectup

        cmpb 	%bl, down                       # Check ARROW DOWN
        je 	selectdown

        cmpb 	%bl, right                      # Check ARROW RIGHT
        je 	sottomenu                       # If the arrow right is selected, we will hop into a "sottomenu"

        jmp 	exitselectionlogic		# No more need to select something as something as just been selected

# Handle arrow up

selectup:                               	

        subl	$1, selection			# Go backwards		
        cmpl 	$-1, selection
        jne 	exitselectionlogic		# Everything is ok if selection is not '-1', we can exit, otherwise we have to skip to the last menu option
        movl 	maxselect, %ebx
        subl 	$1, %ebx			# Here we have maxselect-1
        movl 	%ebx, selection	        	# We select the last item in the menu (that is in position 'maxselect-1')
        jmp 	exitselectionlogic

# Handle arrow down

 selectdown:                             
 
        addl	$1, selection			# Go forward
        movl	maxselect, %ebx	
        cmpl	%ebx, selection
        jne	exitselectionlogic		# Everything is ok if selection is not equal to "maxselect" (the maximum is 'maxselect-1'), otherwise we skip to the first option
        movl	$0, selection
        jmp	exitselectionlogic		# Unuseful here but it continues the pattern

exitselectionlogic:

	# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

returntomenuloop:

	# In order to avoid unexpected behavior, we reset the following registers
    
    	xorl    %ecx, %ecx                  	# Reset the register ECX
    	xorl    %esi, %esi                  	# Reset the register ESI

    	jmp     menuloop

# Handle "sottomenu"

sottomenu:

    	cmpl    $0, selection               	# Setting Automobile 
    	je      returntomenuloop  

    	cmpl    $1, selection               	# Data !! NOT IMPLEMENTED !!
    	je      returntomenuloop

    	cmpl    $2, selection               	# Ora !! NOT IMPLEMENTED !!
    	je      returntomenuloop

    	cmpl    $3, selection               	# Blocco automatico porte
    	je      sm_bloccoautomaticoporte

    	cmpl    $4, selection               	# Back-home
    	je      sm_backhome

    	cmpl    $5, selection               	# Check Olio !! NOT IMPLEMENTED !!
    	je      returntomenuloop

    	cmpl    $6, selection               	# Frecce direzione
    	je      sm_freccedirezione

    	cmpl    $7, selection               	# Reset pressione Gomme
    	je      sm_pressionegomme

#

sm_bloccoautomaticoporte:

	call    clear				# Option is selected, clear the screen

    	# Move the title "Blocco automatico porte: " and it's length to the registers, they will be used by the function called "onoffmenu"
    
    	movl    $opt4, %ecx                 	# ECX is used in the function to store the string of the title
    	movl    $len4, %edx                	# EDX is used in the function to store the length of the title

	# Put the current value and it's length into EAX and EBX, they'll be used by the function called
	
	movl	$12, %esi
    	movl	values(%esi), %eax
    	movl	valueslen(%esi), %ebx

	# Call the function

    	call    onoffmenu                   	# Function onoffmenu
    	movl    $12, %esi

    	# Modify the values in the right position taking them from the registers modified by the function called
    	
    	movl    %eax, values(%esi)
    	movl    %ebx, valueslen(%esi)

	jmp	returntomenuloop


sm_backhome:

	call    clear				# Option is selected, clear the screen
    
    	#We move the title "Back-home: " and it's length to the registers, they will be used by the function called "onoffmenu"
    	
    	movl	$opt5, %ecx
    	movl	$len5, %edx

    	# Put the current value and it's length into EAX and EBX, they'll be used by the function called
    	
    	movl	$16, %esi
    	movl	values(%esi), %eax
    	movl  	valueslen(%esi), %ebx

	# Call the function
	
    	call	onoffmenu			# Call the function
   	movl	$16, %esi                       # Notice how the value is "+4" compared to the previous sottomenu

    	movl	%eax, values(%esi)
    	movl	%ebx, valueslen(%esi)

    	jmp	returntomenuloop


sm_freccedirezione:

	movl	lampeggi, %eax                 # EAX is used in the function to let it know how many LAMPEGGI we got

	# We move the title "Frecce direzione " and it's length to the registers, they will be used by the function called "freccedirezione"
	
	movl	$opt7, %ecx
	movl	$len7, %edx
    
    	# Call the function and save the new value
    	
	call	freccedirezione
    	movb	%ah, lampeggi                  # Set new value for LAMPEGGI. Value is taken from the bits 8 to 15 of EAX. It has been set by the function called one line ago.
    	jmp	returntomenuloop

    

sm_pressionegomme:

    call	pressionegomme                 # Pretty simple function, no need to pass parameters
    jmp		returntomenuloop
    
    
    
