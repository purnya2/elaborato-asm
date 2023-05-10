# as --march=i386 --32 test2.s -o test2.o && ld -m elf_i386 test2.o -o test2 && ./test2
# as --march=i386 --32 test.s -o test.o && ld -m elf_i386 test.o -o test && ./test

.global _start

.data
    format: .string "%s"
    date_buffer: .space 9


.text
_start:
    # Get current time
    movl $13, %eax       # System call number for sys_time
    leal date_buffer, %ebx       # Clear EBX register (not used for sys_time)
    int $0x80             # Trigger the system call

    # Print the date
    movl $4, %eax         # System call number for sys_write
    movl $1, %ebx         # File descriptor (stdout)
    movl $date_buffer, %ecx # Load address of the date buffer
    movl $9, %edx         # Length of the string to print
    int $0x80             # Trigger the system call

    xor %eax, %eax

    mov    $1,%al               # 1 = Syscall for Exit()
    mov    $0,%ebx              # The status code we want to provide.
    int    $0x80                # Poke kernel. This will end the program.
