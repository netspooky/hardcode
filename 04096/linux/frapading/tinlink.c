/* tinlink 1.0.0 */
/* This is public domain */
/* this program will take a "bin" file produced by nasm (or anyhing else) and convert it
 * into the smallest "elf" file possible (producing a wrong file, that
 * I am sure to be loadable by Linux 2.2.1 but other versions may very
 * well not load it at all !)
 *
 * The primary use of this program is to produce small "elf", thus making
 * possible the creation of 4Ko intros under Linux (well, it's possible
 * without this program, but because the "elf" will be very small, you
 * can put more code).
 *
 * Note that you can specify the size of your program in RAM (bigger than
 * "bin" file size, and that the memory is everywhere read/write/exe, thus
 * no need to mmap a shit to allocate memory or to make automodifying code.
 *
 * Note too that the starting address that you'll use in nasm (with an "org")
 * must be a multiple of 4096 then you add sizeof(Elf32_Ehdr)-8+sizeof(Elf32_Phdr)-2 = 74
 * to this value.
 * So for example : org 0x800004a (=0x8000000+74)
 * and running this program with this value for start address.
 *
 * Sed - Wed Aug 25 21:59:32 MET DST 1999
 *
 * Documentation comes from ELF.something.tar.gz on tsx-11 in packages/GCC or
 * something like that.
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>

#define DEFAULT_START (unsigned char *)(0x8000000+sizeof(Elf32_Ehdr)-8+sizeof(Elf32_Phdr)-2)
#define DEFAULT_OUTPUT "a.out"

typedef unsigned char *		Elf32_Addr;
typedef unsigned short		Elf32_Half;
typedef unsigned long		Elf32_Off;
typedef int			Elf32_Sword;
typedef unsigned int		Elf32_Word;

#define EI_NIDENT 16
/* e_shentsize, e_shnum and e_shstrndx are not used by the elf-loader in Linux (at
 * least 2.2.1, I've got the source in front of my eyes, and a grep on it tells me
 * that), so let's fuck it away !
 */
typedef struct {
  unsigned char	e_ident[EI_NIDENT];	/* 0x7f ELF 1 1 1 0 0 0 0 0 0 0 0 0 */
  Elf32_Half	e_type;			/* 2 */
  Elf32_Half	e_machine;		/* 3 */
  Elf32_Word	e_version;		/* 1 */
  Elf32_Addr	e_entry;		/* 0x8000000 for example (to deal with nasm) */
  Elf32_Off	e_phoff;		/* 52 = sizeof(Elf32_Ehdr) */
  Elf32_Off	e_shoff;		/* ?? 0 */
  Elf32_Word	e_flags;		/* 0 */
  Elf32_Half	e_ehsize;		/* 52 = sizeof(Elf32_Ehdr) */
  Elf32_Half	e_phentsize;		/* sizeof(Elf32_Phdr) */
  Elf32_Half	e_phnum;		/* ?? 1 */
  Elf32_Half	e_shentsize;		/* ?? 0 */
  Elf32_Half	e_shnum;		/* ?? 0 */
  Elf32_Half	e_shstrndx;		/* SHN_UNDEF = 0 */
} Elf32_Ehdr;

/* p_type is 1 like e_phnum, so we merge the both :) Yes it works ! because of LSB (little endianess).
 * p_align is not used, we forget it too.
 */
typedef struct {
  Elf32_Word	p_type;			/* 1 = PT_LOAD */
  Elf32_Off	p_offset;		/* sizeof(Elf32_Ehdr)+sizeof(Elf32_Phdr) */
  Elf32_Addr	p_vaddr;		/* 0x8000000 same as e_entry in Elf32_Ehdr */
  Elf32_Addr	p_paddr;		/* unspecified => 0 */
  Elf32_Word	p_filesz;		/* size of code in file */
  Elf32_Word	p_memsz;		/* size of code in memory */
  Elf32_Word	p_flags;		/* 7 = rwx, 5=r-x */
  Elf32_Word	p_align;		/* 0 or 1 ?? */
} Elf32_Phdr;

/* return 0 if ok, -1 otherwise */
int create_code(char *to, char *code, unsigned int filesize, unsigned int size, unsigned char *start)
{
  Elf32_Ehdr h = {
    {0x7f, 'E', 'L', 'F', 1, 1, 1, '/', 'd', 'e', 'v', '/', 'd', 's', 'p', 0},
    2, 3, 1, start, sizeof(Elf32_Ehdr)-8, 0, 0,
    sizeof(Elf32_Ehdr)-8, sizeof(Elf32_Phdr)-2, 1, 0, 0, 0
  };
  Elf32_Phdr p = {
    1, sizeof(Elf32_Ehdr)-8+sizeof(Elf32_Phdr)-2,
    start, 0, filesize, size, 7, 0
  };
  int fd=open(to, O_WRONLY|O_CREAT|O_TRUNC, 0755);

  if (fd==-1) {
    perror("open");
    return -1;
  }
  if (write(fd, &h, sizeof(h)-8)!=sizeof(h)-8 ||
      write(fd, &p, sizeof(p)-2)!=sizeof(p)-2 ||
      write(fd, code, filesize) != filesize) {
    perror("write");
    close(fd);
    return -1;
  }
  if (close(fd)==-1) {
    perror("close");
    return -1;
  }
  return 0;
}

/* print usage and return -1 */
int usage(char *n)
{
  fprintf(stderr, "Usage : %s\n"
	  "\t\t[-c <input file (no default, you MUST set this)>]\n"
	  "\t\t[-o <output file (default \"%s\")>]\n"
	  "\t\t[-s <start address (default to 0x%x)>]\n"
	  "\t\t[-m <memory size (default to input file size)>]\n",
	  n, DEFAULT_OUTPUT, (int)DEFAULT_START);
  return -1;
}

/* return 0 if 0, -1 otherwise */
/* the parser may be buggy. Too much if to test. */
int main(int nb, char **v)
{
  int fd;
  unsigned char *start=DEFAULT_START;
  unsigned char *output=DEFAULT_OUTPUT;
  unsigned char *input=(unsigned char *)0;
  unsigned long size=0;
  unsigned long filesize=0;
  unsigned char *code;
  int i=1;
  int c=0, o=0, s=0, m=0;

  while (i<nb) {
    if (v[i][0]!='-') {
      fprintf(stderr, "Error with argument \"%s\"\n", v[i]);
      return usage(v[0]);
    }
    switch(v[i][1]) {
      default :
	fprintf(stderr, "Error with argument \"%s\"\n", v[i]);
	return usage(v[0]);
      case 'c' :
	if (v[i][2]!=0) {
	  fprintf(stderr, "Error with argument \"%s\"\n", v[i]);
	  return usage(v[0]);
	}
	if (c) {
	  fprintf(stderr, "Error, you gave several \"-c\" arguments\n");
	  return usage(v[0]);
	}
	c=1;
	i++;
	if (i>=nb) {
	  fprintf(stderr, "Error with option \"%s\"\n", v[i-1]);
	  return usage(v[0]);
	}
	input=v[i];
	break;
      case 'o' :
	if (v[i][2]!=0) {
	  fprintf(stderr, "Error with argument \"%s\"\n", v[i]);
	  return usage(v[0]);
	}
	if (o) {
	  fprintf(stderr, "Error, you gave several \"-o\" arguments\n");
	  return usage(v[0]);
	}
	o=1;
	i++;
	if (i>=nb) {
	  fprintf(stderr, "Error with option \"%s\"\n", v[i-1]);
	  return usage(v[0]);
	}
	output=v[i];
	break;
      case 's' :
	if (v[i][2]!=0) {
	  fprintf(stderr, "Error with argument \"%s\"\n", v[i]);
	  return usage(v[0]);
	}
	if (s) {
	  fprintf(stderr, "Error, you gave several \"-s\" arguments\n");
	  return usage(v[0]);
	}
	s=1;
	i++;
	if (i>=nb) {
	  fprintf(stderr, "Error with option \"%s\"\n", v[i-1]);
	  return usage(v[0]);
	}
	if (sscanf(v[i], "%p", &start)!=1) {
	  perror("sscanf");
	  return usage(v[0]);
	}
	break;
      case 'm' : {
	char *res=(char *)0;

	if (v[i][2]!=0) {
	  fprintf(stderr, "Error with argument \"%s\"\n", v[i]);
	  return usage(v[0]);
	}
	if (m) {
	  fprintf(stderr, "Error, you gave several \"-m\" arguments\n");
	  return usage(v[0]);
	}
	m=1;
	i++;
	if (i>=nb) {
	  fprintf(stderr, "Error with option \"%s\"\n", v[i-1]);
	  return usage(v[0]);
	}

	size=strtoul(v[i], &res, 10);
	if (errno==ERANGE || strlen(v[i])==0 || *res!='\0') {
	  if (errno==ERANGE)
	    perror("main.c : errno");
	  fprintf(stderr, "You surely gave a wrong memory size for the -m option\n");
	  return usage(v[0]);
	}
	break;
      }
    }
    i++;
  }

  if (!c) {
    fprintf(stderr, "Error - you must give an input file name\n");
    return usage(v[0]);
  }

  if ((fd=open(input, O_RDONLY))==-1) {
    perror("open");
    return usage(v[0]);
  }

  if ((filesize=lseek(fd, 0, SEEK_END))==1) {
    perror("lseek");
    close(fd);
    return usage(v[0]);
  }
  if (lseek(fd, 0, SEEK_SET)!=0) {
    perror("lseek");
    close(fd);
    return usage(v[0]);
  }
  if (!(code=(unsigned char *)malloc(filesize))) {
    perror("malloc");
    close(fd);
    return usage(v[0]);
  }
  if (read(fd, code, filesize)!=filesize) {
    perror("read");
    close(fd);
    free(code);
    return usage(v[0]);
  }
  close(fd);
  if (!m)
    size=filesize;
  if (size<filesize) {
    fprintf(stderr, "Error, you specified a size too small\n");
    free(code);
    return usage(v[0]);
  }

  if (create_code(output, code, filesize, size, start)==-1) {
    free(code);
    return -1;
  }
  free(code);
  return 0;
}
