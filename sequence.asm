section .data
  ;defining syscall numbers
  SYS_EXIT    equ 60
  SYS_READ    equ 0
  SYS_WRITE   equ 1
  SYS_OPEN    equ 2
  SYS_CLOSE   equ 3
  ARG_NUM     equ 2;number of arguments
  O_RDONLY    equ 0


section .bss
  fd          resb 8

section .text
  global _start

_start:
  ;check if program was executed with correct number of arguments
  pop   rbx
  cmp   rbx, ARG_NUM
  jne   _exit_error

  ;open file given as first argument
  pop   rax   ;skip "./sequence"
  pop   rdi   ;get input file
  mov   rax, SYS_OPEN
  mov   rsi, O_RDONLY
  mov   rdx, 0 ;no additional flags for sys_open
  syscall

  ;check if opening input file was successful
  cmp   rax, 0
  jl    _exit_error

  mov   [fd], rax ;store file descriptor





;program completed succesfully, given sequence is correct
_exit_success:
  mov   rax, SYS_EXIT
  mov   rdi, 0
  syscall

;program encountered an error, either it was executed with
;wrong parameters or the given sequence is not correct
_exit_error:
  mov   rax, SYS_EXIT
  mov   rdi, 1
  syscall