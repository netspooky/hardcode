OUTPUT_FORMAT("binary")
OUTPUT_ARCH(i386)

SECTIONS {
	.main 0x400000 :
	{
		*(.text)
		*(.rodata)
		*(.data)
	}
	.bss : { *(.bss) }
}
