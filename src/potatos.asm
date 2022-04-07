[org 0x7c00]        ; origin from 0x7C00 memory location where BIOS will load us

; to print a char we need to switch to teletype mode
mov ah, 0x0e                ; switch to teletype mode (Write Character in TTY Mode)
mov bx, welcome             ; point the 
call printstring

; begin the main loop
jmp loop

loop:
    ; print the prompt
    mov ah, 0x0e                ; switch to teletype mode (Write Character in TTY Mode)
    mov bx, prompt
    call printstring

    ; read a character
    mov ah, 0                   ; read character mode
    int 0x16                    ; call keyboard services interrupt (with read character mode)
    mov [char], al              ; save the read char from al into char var

    ; change back to printing mode
    mov ah, 0x0e

    ; print the character we just read
    mov al, [char]
    int 0x10                ; call print interrupt

    ; print newline
    mov bx, newline 
    call printstring

    jmp loop

printstring:                ; takes pointer bx to a string
    mov al, [bx]            ; move the first character in bx to al (the byte to print)  
    cmp al, 0               ; bx == 0
    je end                  ; if end of string jump to end -> ret
    int 0x10                ; call print interrupt
    inc bx                  ; increment the bx pointer to point to the next char in the string
    jmp printstring
end:
    ret

; infinite loop: jump to current instruction pointer
jmp $                       

; variables
welcome: db "Welcome to PotatOS", 10, 13, 0
prompt: db "> ", 0
newline: db 10, 13, 0
char: db 0

; ensure file is 512 bytes long
times 510-($-$$) db 0       ; 
db 0x55, 0xaa               ; 