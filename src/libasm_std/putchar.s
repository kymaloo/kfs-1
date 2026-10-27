BITS 32
section .text
    global putchar
    extern terminal_putchar

putchar:
    push dword [esp + 4]
    call terminal_putchar
    add  esp, 4
    mov  eax, 1
    ret