BITS 32
section .text
    global printf
    extern putchar
    extern putstr

; int format(char format, int *ap_addr)
; ap_addr = adresse de la variable ap (passée par adresse pour pouvoir l'avancer)
format:
    push ebp
    mov  ebp, esp
    mov  eax, [ebp + 8]           ; format
    mov  edx, [ebp + 12]          ; edx = &ap
    cmp  al, 'c'
    je   .c
    cmp  al, 's'
    je   .s
    cmp  al, '%'
    je   .pct
    mov  eax, -1                ; spécificateur inconnu
    jmp  .end
.c:
    mov  ecx, [edx]             ; lire où ap pointe
    add  dword [edx], 4         ; avancer ap de 4
    push dword [ecx]            ; la valeur de l'argument
    call putchar
    add  esp, 4
    jmp  .end
.s:
    mov  ecx, [edx]
    add  dword [edx], 4
    push dword [ecx]
    call putstr
    add  esp, 4
    jmp  .end
.pct:
    push '%'
    call putchar
    add  esp, 4
.end:
    pop  ebp
    ret

; int parse_percent(char *str, int *ap_addr)
parse_percent:
    push ebp
    mov  ebp, esp
    push ebx                    ; ebx = position dans le format
    push esi                    ; esi = size
    mov  ebx, [ebp+8]
    xor  esi, esi
.loop:
    movzx eax, byte [ebx]
    test eax, eax
    jz   .done                  ; fin de chaîne
    cmp  al, '%'
    jne  .plain
    inc  ebx                    ; on passe le '%'
    push dword [ebp + 12]       ; &ap
    movzx eax, byte [ebx]       ; spécificateur (0 si % en fin -> -1)
    push eax
    call format
    add  esp, 8
    cmp  eax, -1
    je   .end
    add  esi, eax
    jmp  .next
.plain:
    push eax
    call putchar
    add  esp, 4
    cmp  eax, -1
    je   .end
    inc  esi
.next:
    inc  ebx
    jmp  .loop
.done:
    mov  eax, esi
.end:
    pop  esi
    pop  ebx
    pop  ebp
    ret

printf:
    push ebp
    mov  ebp, esp
    lea  eax, [ebp + 12]        ; va_start : adresse du 1er argument variadique
    push eax                    ; ap = variable locale en [ebp-4]
    lea  eax, [ebp - 4]
    push eax                    ; &ap
    push dword [ebp+8]          ; format
    call parse_percent
    leave
    ret