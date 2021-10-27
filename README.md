Reverse connect shellcode for MacOS ARM64 systems (Big Sur/Monterey) 

- To run  ./reverse-shellcode-generator-macos-arm64.sh 
- Copy the generated shellcode to clipboard 
- Insert shellcode into fork.c 

Currently the generator only works on ARM64 Macs 
Shellcode generated can be used in C code directly 

Example fork program included to insert the generated shellcode 

Main concept used from  https://github.com/daem0nc0re/macOS_ARM64_Shellcode 
