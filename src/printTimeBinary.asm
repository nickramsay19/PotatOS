; PRINT TIME FROM RTC WHEN RTC DATA IS IN BINARY FORMAT (NOT BCD)

printTimeBinary:

    ; wait for an RTC update to finish
    call waitRTCUpdate

    ; read the clock time     
    mov al, 0x00        ; set the "seconds" value (0-59)
    or al, 10000000b    ; set the first bit to 1: this disable NMI; NMI is bundled with IO port 0x70 which we dont want.
    out 0x70, al        ; select the CMOS register on IO Port 0x70
    in al, 0x71         ; move the "seconds" into al
    ;call fixSeconds     ; seconds number is buggy, change it to correct value
    ; ---DEBUG print entire num
    add al, '0'         ; convert the seconds int (0-59) to char
    mov ah, 0x0e        ; move to printing mode
    int 0x10            ; print the "seconds"
    sub al, '0'         ; restore al
    push ax
    mov al, ':'
    int 0x10            ; print the ":" separator
    pop ax  
    ; first digit print
    ; perform division to get the tens column and units column separately
    mov dx, 0   ; remainder
    ;mov ax, 64  ; dividend, al already set, 
    mov ah, 0   ; .. but we need to clear ah such that we are sure ax = al
    mov bx, 10  ; divisor
    div bx      ; perform ax = (ax/bx)    
    mov ah, 0 ; just to be sure
    ; now result in ax, remainder in dx. but, result will be in al (since we only divided up to 59)
    ; print remainder (result is already in al for printing)
    add al, '0'     ; convert to char
    mov ah, 0x0e    ; move to printing mode
    int 0x10        ; print the "seconds"
    ; second digit print
    mov al, dl      ; move remainder into print char al
    add al, '0'     ; convert to char
    int 0x10        ; print
    ret