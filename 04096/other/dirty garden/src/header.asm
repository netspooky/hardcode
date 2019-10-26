# This file has been adopted from "A Whirlwind Tutorial on Creating Really
# Teensy ELF Executables for Linux" by Brian Raiter with the necessary changes
# for the FreeBSD operating system.

# .org 0x08048000
.equ ehdrsize, phdr - ehdr
.equ phdrsize, hdrend - phdr
.global dlopen
.global dlsym

.align 2
ehdr:                                      # Elf32_Ehdr
	.byte 0x7F, 0x45, 0x4C, 0x46, 1, 1, 1, 3 # e_ident
	.byte 0, 0, 0, 0, 0, 0, 0, 0
	.short 2                                 # e_type
	.short 3                                 # e_machine
	.long 1                                  # e_version
	.long _start # + 0x08048000              # e_entry
	.long phdr - ehdr                        # e_phoff
	.long 0                                  # e_shoff
	.long 0                                  # e_flags
	.short ehdrsize                          # e_ehsize
	.short phdrsize                          # e_phentsize
	.short 1                                 # e_phnum
	.short 0                                 # e_shentsize
	.short 0                                 # e_shnum
	.short 0                                 # e_shstrndx
phdr:                                      # Elf32_Phdr
	.long 1                                  # p_type
	.long 0                                  # p_offset
	.long 0x08048000                         # p_vaddr
	.long 0x08048000                         # p_paddr
	.long end - ehdr                         # p_filesz
	.long end - ehdr                         # p_memsz
	.long 5                                  # p_flags
	.long 0x1000                             # p_align
hdrend:

.section .dynsym
	.long 0, 0, 0, 0
	.long dlopen_name - dynstr
	.long 0
dlopen:
	.long 0, 0x12
	.long dlsym_name - dynstr
	.long 0
dlsym:
	.long 0, 0x12
.section .dynstr
dynstr:
	.byte 0
	.string "libthr.so.3"
dlopen_name:
	.string "dlopen"
dlsym_name:
	.string "dlsym"
