BITS 32
section .data
null_str db "(null)", 0

section .text
    global putstr
    extern strlen
    extern terminal_writestring

putstr:
    push ebx
    push esi
    mov  esi, [esp + 12]      ; s (2 push + adresse de retour = +12)
    test esi, esi
    jnz  .done
    mov  esi, null_str
.done:
    push esi
    call strlen
    mov  ebx, eax
    call terminal_writestring
    add  esp, 4
    mov  eax, ebx
    pop  esi
    pop  ebx
    ret