global _main
extern _LoadLibraryA@4

section .data
userDllName: db 'USER32.DLL', 0          ; string for LoadLibraryA
messageText: db 'CAN I HACK THE PC?', 0   ; message text for MessageBoxA

section .text
_main:
    ; 1) Load USER32.DLL using LoadLibraryA
    push userDllName                 ; push pointer to "USER32.DLL"
    call _LoadLibraryA@4             ; call LoadLibraryA(userDllName)

    ; 2) Prepare MessageBoxA arguments on the stack
    push 23h                         ; uType = MB_YESNOCANCEL (example style)
    push 0                           ; hWnd = NULL (no parent window)
    push messageText                 ; lpText = pointer to our message string
    push 0                           ; lpCaption = NULL (default title)

    ; 3) Call MessageBoxA with a hardcoded address
    ;    In a real exploit, this address is specific to the target process and OS.
    mov ebx, 751D8830h               ; ebx = address of MessageBoxA
    call ebx                         ; call MessageBoxA(NULL, otazka_MB, NULL, 0x23)

    ; 4) Exit cleanly using ExitProcess
    push eax                         ; push return value from MessageBoxA as exit code
    mov ebx, 7437ADB0h               ; ebx = address of ExitProcess
    call ebx                         ; call ExitProcess(eax)

    ; 5) Fallback exit if the first ExitProcess did not return
    push 0                           ; exit code 0
    call ebx                         ; call ExitProcess(0)

; Notes:
; - This payload is written for a specific Windows 32-bit target.
; - The hardcoded MessageBoxA and ExitProcess addresses are not portable.
; - In a buffer overflow exploit, the attacker aims to redirect execution to shellcode like this.
; - LoadLibraryA is used here to ensure USER32.DLL is available before calling MessageBoxA.
