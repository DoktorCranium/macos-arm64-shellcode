/*
 * Compile: clang fork.c -o fork.exe 
*/

#include <stdio.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <string.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <strings.h>
#include <unistd.h>
#include <poll.h>
#include <pthread.h>
#include <stdint.h>

int (*sc)();

char shellcode[] = "<SHELLCODE-GOES-HERE>";

int main(int argc, char **argv) {

   system ("/usr/bin/clear");
   printf ("========================================\n");
   printf ("Fork shellcode exercise for MacOS ARM64 \n");
   printf ("========================================\n");
   printf ("[*] Waiting \n");
   system("/bin/sleep 1");
   printf(".");
   fflush(stdout);
   system("/bin/sleep 1");
   printf("..");
   fflush(stdout);
   system("/bin/sleep 1");
   printf("...");
   fflush(stdout);
   system("/bin/sleep 1");
   printf("....");
   printf ("\n[*] Forking\n");

   pid_t process_id = 0;
   pid_t sid = 0;
   process_id = fork();
   if (process_id < 0)
      {
         printf("Fork failed!\n");
         exit(1);
      }
   if (process_id > 0)
      {
         printf("[-] Forked PID %d \n", process_id);
         exit(0);
      }

    printf("[>] Shellcode Length: %zd Bytes\n", strlen(shellcode));
 
    void *ptr = mmap(0, 0x1000, PROT_WRITE | PROT_READ, MAP_ANON | MAP_PRIVATE | MAP_JIT, -1, 0);
 
    if (ptr == MAP_FAILED) {
        perror("mmap");
        exit(-1);
    }
    printf("[+] SUCCESS: mmap\n");
    printf("    |-> Return = %p\n", ptr);
 
    void *dst = memcpy(ptr, shellcode, sizeof(shellcode));
    printf("[+] SUCCESS: memcpy\n");
    printf("    |-> Return = %p\n", dst);

    int status = mprotect(ptr, 0x1000, PROT_EXEC | PROT_READ);

    if (status == -1) {
        perror("mprotect");
        exit(-1);
    }
    printf("[+] SUCCESS: mprotect\n");
    printf("    |-> Return = %d\n", status);

    printf("[>] Trying to execute shellcode...\n");

    sc = ptr;
    sc();
 
    return 0;
}
