BITS 32
section .text
    global putchar_fd

putchar_fd:
    push ebx

    mov ebx, [esp + 8]    ; fd
    mov ecx, [esp + 12]   ; buf
    mov edx, 1            ; count
    mov eax, 4            ; sys_write
    int 0x80

    pop ebx
    ret