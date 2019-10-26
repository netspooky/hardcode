#ifndef ASM_EXIT_H
#define ASM_EXIT_H

/** \file
 * \brief Header for asm_exit() macro.
 *
 * This file declares a macro that expands to the shortest possible assembly
 * routine usable to exit the program. The macro is named asm_exit().
 *
 * Due to the requirement of making this procedure as short as possible, the
 * return value of the program is undefined.
 */

/** \cond */
#if defined(__FreeBSD__) || defined(__linux__)
#if defined(__x86_64)
#define asm_exit() asm volatile("movq $1,%rax\nsyscall")
#elif defined(__i386)
#define asm_exit() asm volatile("movl $1,%eax\nint $128")
#else
#error "no assembler exit procedure defined for current architecture"
#endif
#else
#error "no assembler exit procerude defined for current operating system"
#endif
/** \endcond */

#endif
