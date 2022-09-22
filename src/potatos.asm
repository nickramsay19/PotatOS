[org 0x7c00]        ; origin from 0x7C00 memory location where BIOS will load us

; to print a char we need to switch to teletype mode
mov ah, 0x0e                ; switch to teletype mode (Write Character in TTY Mode)
mov bx, welcome             ; point the 
call printstring

; begin the main loop
jmp loop

; wait/loop until an RTC time update is finished
waitRTCUpdate:
    ; get the "Update in progress flag"
    mov al, 0x0A        ; choose the IO port 0x70 "Status Register A"
    or al, 10000000b    ; set the first bit to 1: this disable NMI; NMI is bundled with IO port 0x70 which we dont want.
    out 0x70, al        ; select the CMOS register in al on IO Port 0x70.
    in al, 0x71         ; move the "status register A" value into al
    cmp al, 00000010b   ; check if the 7th bit (Update in progress flag) is set
    je waitRTCUpdate
    ret                 ; no update in progress, finish

fixSeconds:
.fixSeconds10:
    ; 9, 10, 17
    cmp al, 10
    jle .fixSeconds20
    sub al, 6
.fixSeconds20:
    ; 18, 19, 26
    cmp al, 20
    jle .fixSeconds30
    sub al, 6
.fixSeconds30:
    ; 28, 29, 36
    cmp al, 20
    jle .fixSeconds40
    sub al, 6
.fixSeconds40:
    ; 28, 29, 36
    cmp al, 40
    jle .fixSeconds50
    sub al, 6
.fixSeconds50:
    ret

printTimeBCD:

    ; ----- PRINT HOUR -----
    mov al, 0x04        ; set the "seconds" value (0-89)
    or al, 10000000b    ; set the first bit to 1: this disable NMI; NMI is bundled with IO port 0x70 which we dont want.
    out 0x70, al        ; select the CMOS register on IO Port 0x70
    in al, 0x71         ; move the "seconds" into al
    ;mov dl, al          ; make a copy of al in dl (we will use this dl to print the top digit for BCD format
    push ax             ; make a copy of al before changes
    ;print top nibble
    and al, 11110000b   ; clear the bottom 4 bits for printing
    shr al, 4           ; shift the top 4 bits down to the bottom 4 bits
    add al, '0'         ; convert al to char
    mov ah, 0x0e        ; switch to teletype mode (Write Character in TTY Mode), this might be unneeded here
    int 0x10            ; call print iterrupt
    ; print lower nibble of al which is in BCD format
    pop ax              ; reset al to original value
    and al, 00001111b   ; clear the top 4 bits for printing
    add al, '0'         ; convert al to char
    mov ah, 0x0e        ; switch to teletype mode (Write Character in TTY Mode)
    int 0x10            ; call print iterrupt

    ; ----- PRINT COLON SEPARATOR -----
    mov al, ':'         ; convert al to char
    mov ah, 0x0e        ; switch to teletype mode (Write Character in TTY Mode)
    int 0x10            ; call print iterrupt

    ; ----- PRINT MINUTE -----
    mov al, 0x02        ; set the "seconds" value (0-89)
    or al, 10000000b    ; set the first bit to 1: this disable NMI; NMI is bundled with IO port 0x70 which we dont want.
    out 0x70, al        ; select the CMOS register on IO Port 0x70
    in al, 0x71         ; move the "seconds" into al
    ;mov dl, al          ; make a copy of al in dl (we will use this dl to print the top digit for BCD format
    push ax             ; make a copy of al before changes
    ;print top nibble
    and al, 11110000b   ; clear the bottom 4 bits for printing
    shr al, 4           ; shift the top 4 bits down to the bottom 4 bits
    add al, '0'         ; convert al to char
    mov ah, 0x0e        ; switch to teletype mode (Write Character in TTY Mode), this might be unneeded here
    int 0x10            ; call print iterrupt
    ; print lower nibble of al which is in BCD format
    pop ax              ; reset al to original value
    and al, 00001111b   ; clear the top 4 bits for printing
    add al, '0'         ; convert al to char
    mov ah, 0x0e        ; switch to teletype mode (Write Character in TTY Mode)
    int 0x10            ; call print iterrupt

    ; ----- PRINT COLON SEPARATOR -----
    mov al, ':'         ; convert al to char
    mov ah, 0x0e        ; switch to teletype mode (Write Character in TTY Mode)
    int 0x10            ; call print iterrupt

    ; ----- PRINT SECONDS -----
    ; read the clock time     
    mov al, 0x00        ; set the "seconds" value (0-89)
    or al, 10000000b    ; set the first bit to 1: this disable NMI; NMI is bundled with IO port 0x70 which we dont want.
    out 0x70, al        ; select the CMOS register on IO Port 0x70
    in al, 0x71         ; move the "seconds" into al
    ;mov dl, al          ; make a copy of al in dl (we will use this dl to print the top digit for BCD format
    push ax             ; make a copy of al before changes
    ;print top nibble
    and al, 11110000b   ; clear the bottom 4 bits for printing
    shr al, 4           ; shift the top 4 bits down to the bottom 4 bits
    add al, '0'         ; convert al to char
    mov ah, 0x0e        ; switch to teletype mode (Write Character in TTY Mode), this might be unneeded here
    int 0x10            ; call print iterrupt
    ; print lower nibble of al which is in BCD format
    pop ax              ; reset al to original value
    and al, 00001111b   ; clear the top 4 bits for printing
    add al, '0'         ; convert al to char
    mov ah, 0x0e        ; switch to teletype mode (Write Character in TTY Mode)
    int 0x10            ; call print iterrupt

    ; return
    ret

inputLoop:
    ; read a character
    mov ah, 0                   ; read character mode
    int 0x16                    ; call keyboard services interrupt (with read character mode)
    mov [char], al              ; save the read char from al into char var

    ; check if user pressed 'ENTER'
    ; if so end loop
    cmp al, 0x0D    ; 'ENTER'
    je .doneInputLoop

    ; PRINT THE CHARACTER USER ENTERED
    mov ah, 0x0e    ; change back to printing mode
    mov al, [char]  ; print the character we just read
    int 0x10        ; call print interrupt

    ; loop again
    jmp inputLoop

.doneInputLoop:
    mov ah, 0x0e    ; change back to printing mode
    mov bx, newline 
    call printstring
    ret

loop:
    ; ------- PRINT PROMPT ------- 
    ; print prompt part 1
    ; print the prompt string ("] > ")
    mov ah, 0x0e                ; switch to teletype mode (Write Character in TTY Mode)
    mov bx, prompt1
    call printstring
    ; print time between brackets
    call printTimeBCD
    ; print the prompt string ("] > ")
    mov ah, 0x0e               ; switch to teletype mode (Write Character in TTY Mode)
    mov bx, prompt2
    call printstring

    ; ------- GET USER INPUT ------- 
    call inputLoop

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
prompt1: db "[", 0
prompt2: db "] > ", 0
newline: db 10, 13, 0
char: db 0
user: db 0,0,0,0,0,0,0,0 ; 8 bytes
time: db 0, 0

; ensure file is 512 bytes long
times 510-($-$$) db 0       ; 
db 0x55, 0xaa               ; 
