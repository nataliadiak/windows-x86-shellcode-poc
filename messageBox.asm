global _main
extern _LoadLibraryA@4

section .data
nazUser: db 'USER32.DLL', 0
otazka_MB: db 'MUZU HACKNOUT PC?', 0

section .text
_main:

push nazUser              ; push   & 'USER32.DLL'
                          ; mov ebx, 74378500  (= & LoadlibraryA), kdyz kod bude casti jine ap., ktera uz ma kernel32
call _LoadLibraryA@4      ; call   & LoadlibraryA(nazUser)
push 23h                  ; push   uType   (= [?] | [YESNOCANCEL])
push 0                    ; bez nazvu okna, (default="error")
push otazka_MB            ; push   & 'MUZU HACKNOUT PC?'
push 0 
mov  ebx, 751D8830h       ; mov    ebx,  & MessageBoxA                    
call ebx                  ; call   & MessageBoxA(0,otazka_MB,0,23h) 
push eax                  ; push   exitCode (=return MessageBoxA, uklada se do eax v x86) 
mov ebx, 7437ADB0h        ; mov    ebx,  & ExitProcess
call ebx                  ; call   & ExitProcess(eax) 
push  0               
call  ebx                 ; call   & ExitProcess(0)