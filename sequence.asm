section .data
  ;defining syscall numbers
  SYS_EXIT    equ 60
  SYS_READ    equ 0
  SYS_OPEN    equ 2
  SYS_CLOSE   equ 3
  ARG_NUM     equ 2;number of arguments
  O_RDONLY    equ 0
  BUF_SIZE    equ 1024

section .bss
  fd          resd 1
  buffer      resb BUF_SIZE
  numbers     resw 256
  EOF_found   resb 1

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
  mov   rdx, 0   ;no additional flags for sys_open
  syscall

  ;check if opening input file was successful
  cmp   rax, 0
  jl    _exit_error

  mov   [fd], rax   ;store file descriptor

;rbx - pointer to buffer
;r12 - how many zeros were read
;r13 - how many numbers were read since last 0
;r14 - power of the first set
;r15 - number from buffer

;read from file into buffer
_read_input:
  ;check if EOF was already found
  cmp   byte [EOF_found], 1
  je    _EOF_reached

  mov   rax, SYS_READ
  mov   rdi, [fd]
  mov   rsi, buffer
  mov   rdx, BUF_SIZE
  syscall

  ;clear rbx which we will use as a pointer to buffer
  xor   rbx, rbx

  ;check for EOF
  cmp   rax, BUF_SIZE
  je    _check_sequence
  mov   byte [EOF_found], 1

  cmp   rax, 0
  je    _EOF_reached

_check_sequence:
  ;check if buffer is empty
  cmp   rbx, rax   ;rax still holds number of bytes read from sys_read
  jnb   _read_input

  ;read next number from buffer
  movzx r15, byte [buffer + rbx]   ;r15 holds next number from buffer
  inc   rbx
  cmp   r15, 0
  je    _zero_found

  ;process next number different from 0
  inc   r13   ;r13 holds how many numbers were read since last 0
  cmp   r12w, word [numbers + r15 * 2]
  jne   _exit_error

  inc   word [numbers + r15 * 2]   ;increment count for this number
  jmp   _check_sequence

;process next 0
_zero_found:
  cmp   r12, 0
  jne   _process_zero
  ;this is first zero, setup needed values
  xor   r14, r14
  mov   r14, r13   ;r14 holds power of the first set

_process_zero:
  cmp   r14, r13
  jne   _exit_error   ;power of current permutation differs from the power of original set

  xor   r13, r13   ;set numbers read since last 0 to zero
  inc   r12   ;increment number of zeros that were read
                                                                                                      ;TODO write overflow fix
  
  jmp   _check_sequence

_EOF_reached:
  cmp   r12, 0
  je    _exit_error   ;no zeros were read
  cmp   r13, 0
  jne   _exit_error   ;last number wasnt 0
  jmp   _exit_success

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