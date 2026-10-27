BITS 32
section .text
    global strlen

strlen:
    mov  edx, [esp + 4]
    xor  eax, eax
.loop:
    cmp  byte [edx + eax], 0
    je   .done
    inc  eax
    jmp  .loop
.done:
    ret