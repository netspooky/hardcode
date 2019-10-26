/* Script for -z combreloc: combine and sort reloc sections */
OUTPUT_FORMAT("elf32-i386", "elf32-i386", "elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(_start)
SEARCH_DIR("/usr/i386-linux-gnu/lib32"); SEARCH_DIR("/usr/x86_64-linux-gnu/lib32"); SEARCH_DIR("=/usr/local/lib/i386-linux-gnu"); SEARCH_DIR("=/usr/local/lib32"); SEARCH_DIR("=/lib/i386-linux-gnu"); SEARCH_DIR("=/lib32"); SEARCH_DIR("=/usr/lib/i386-linux-gnu"); SEARCH_DIR("=/usr/lib32"); SEARCH_DIR("=/usr/local/lib"); SEARCH_DIR("=/lib"); SEARCH_DIR("=/usr/lib");
SECTIONS
{
    PROVIDE (__executable_start = SEGMENT_START("text-segment", 0x08048000));
    /* The link map is always the second entry of the GOT */
    PROVIDE (_link_map = LOADADDR(.got.plt) + 4);
    /* Well... this is reliable as long as libc is the only lib we're linking to directly */
    PROVIDE (_libc_filename = LOADADDR(.dynstr) + 1);
    /* Yay! screw_elf_header.py writes us strings to the elf-header, define symbols for them here! */
    PROVIDE (gl_functions_library = __executable_start + 46);
    PROVIDE (_some_null = __executable_start + 4);

    . = SEGMENT_START("text-segment", 0x08048000) + SIZEOF_HEADERS;

/* SECTIONS_BEGIN */
    .interp         : { *(.interp) }
    .dynamic        : { *(.dynamic) }
    .dynsym         : { *(.dynsym) }
    .got.plt        : { *(.got.plt) }
    .dynstr         : { *(.dynstr) }
    .hash           : { *(.hash) }
    .data           : { *(.data .data.*) }
    .text           : { *(.text .text.*) }
    .bss            : { *(.bss .bss.*) }
/* SECTIONS_END */

    /DISCARD/       :
    {
        *(.note.*)
        *(.debug_*)
        *(.gnu.hash)
        *(.rel.text .rel.text.*) *(.rel.data .rel.data.*)
        *(.got)
    }
}

