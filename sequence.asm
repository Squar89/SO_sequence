section .data
  ;defining syscall numbers
  SYS_EXIT    equ 60
  SYS_READ    equ 0
  SYS_WRITE   equ 1
  SYS_OPEN    equ 2
  SYS_CLOSE   equ 3

section .bss

section .text
  global _start

_start:
  mov rax, SYS_EXIT
  mov rbx, 0
  syscall
  
_exit:

_error:
