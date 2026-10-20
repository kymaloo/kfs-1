BITS 32
section .text
    global strlen

strlen:
    xor ecx, ecx
.loop:
    mov al, [edi + ecx]
    test al, al
    je .done
    inc ecx
    jmp .loop
.done:
    mov eax, ecx
    ret