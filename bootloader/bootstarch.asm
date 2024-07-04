
[ORG 0x7C00]

mov [BOOT_DISK], dl
 
CODE_SEG equ gdt_code_segement - gdt_start
DATA_SEG equ gdt_data_segment  - gdt_start

    cli             ;Disable Interrupt
    lgdt [gdt_description]

    ;Enable 32-bit mode 
    mov eax,    cr0
    or  eax,     1
    mov cr0,    eax

    jmp CODE_SEG:start_protected_mode      ;Far jump to 32-bit mode

;NOTE : WE ARE IN LITTLE ENDIAN MODE
gdt_start:

    gdt_null_segement:      ;First Segement
        dq 0x0              ;64-bits set to 0

    gdt_code_segement:
        ;(FIRST WORD)
        dw 0xffff       ;First 16 bits of limit(4 Gigabytes)            [First 16-bit Upper Limit]
        dw 0x0          ;First 16 bits of starting address              [First 16-bit Lower Limit]

        ;(SECOND WORD)
        ;Bits : 0 - 7

        db 0x0          ;Last  16 bits of starting address              [Last  16-bit Lower Limit]

        ;Bits : 8 - 15
        ;[8]    =  Set on First access by CPU (Not Important for me rn so we it will be set to 0)
        ;[9]    =  Should the code be Readable | 0: NO | 1: YES
        ;[10]   =  Conforming/Racist Bit | Should less privilaged code be able to access this segement
        ;[11]   =  Specify if code segement or data segement | 0: Code | 1: Data
        ;It becomes 0101 but since we are in little endian we get 1010
        ;[12]   =  This bit is set if the segment is either a code or a data segement
        ;[13-14]   -----> Privilege Level
            ;(00)    =  Most Privilege
            ;(11)    =  Least Privilege
        ;[15]   =  Set to 1 if segement is present
        db 0b10011010

        ;Bits       :   16-23
        ;[16-19]    =   16-19 bit in segement limiter                     [Last 4-Bits Upper Limit] 
        ;[20]       =   Available to programmers (Can be used for your own purpose)
        ;[21]       =   Reserved by Intel | Should always be 0
        ;[22]       =   Size (Should be set to 1 in case of 32-bit code)
        ;[23]       =   Granularity | If this bit is set the limiter is multipled by 4 KiB | Gives us 4 GiB

        db 0b11001111

        ;Bits 23-31 - Last 16 bit of Base Address [Last 16-bit of base address]

        db 0x0

    gdt_data_segment:
        ;First Word
        dw 0xffff
        dw 0x0

        ;Second Word
        db 0x0
        ;[9] = Read/Write Access
        ;[10] = Expand direction bit | We want to grow downward
        db 0b10010010
        ;Last 16 bit
        db 0b11001111
        db 0x0

gdt_end:

gdt_description:
    ;Address
    ;0-15  =    Limit | Size of GDT
    ;15-47 =    memory Address where gdt lives
    dw gdt_end - gdt_start - 1
    dd gdt_start

[bits 32]
start_protected_mode:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov gs, ax
    mov fs, ax

    mov esp, 090000h    ;Stack begining 

    mov al, 'B'
    mov ah, 0x02
    mov ebx, 0xb8000
    mov esi, 0
    jmp loop

loop:
    mov [ebx + esi], ax
    add esi, 2
    cmp esi, 4000
    jnz loop
    jmp $

BOOT_DISK:  db  0x0

times 510-($-$$) db 0
dw 0xaa55
