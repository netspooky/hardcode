#ifndef DNLOAD_ELF32_H
#define DNLOAD_ELF32_H

#if defined(__FreeBSD__)
#include <sys/link_elf.h>
#elif defined(__linux__)
#include <link.h>
#else
#error "no elf header location known for current platform"
#endif

#include "dnload_hash.h"

#include <stdio.h>

#if defined(__cplusplus)
extern "C" {
#endif

/** \brief ELF base address.
 *
 * NOTE: The following procedures are adapted from 'proof of concept' sources published by parcelshit and
 * las/Mercury for scouring the ELF headers for function addresses.
 */
#define ELF_BASE_ADDRESS 0x08048000

/** Get the program link map by following from ELF header.
 */
static struct link_map* elf32_get_link_map()
{
  Elf32_Ehdr *ehdr;
  Elf32_Phdr *phdr;
  Elf32_Dyn *dynamic;

  // Get the headers, ELF header is in a fixed location in memory. First phdr is located directly after.
  ehdr = (Elf32_Ehdr*)ELF_BASE_ADDRESS; 
  phdr = (Elf32_Phdr*)((size_t)ehdr + (size_t)ehdr->e_phoff);

  // Find the dynamic header.
  for(; (phdr->p_type != PT_DYNAMIC); ++phdr);
  dynamic = (Elf32_Dyn*)phdr->p_vaddr;

  // Find the debug entry in the dynamic header.
  for(; (dynamic->d_tag != DT_DEBUG); ++dynamic);

  return ((struct r_debug*)dynamic->d_un.d_ptr)->r_map;
}

/** Get address of one section from a given link map.
 *
 * @param lmap Link map.
 * @param op Tag to look for.
 */
static void* elf32_get_dynamic_section_value(struct link_map* lmap, int op)
{
  Elf32_Dyn* dynamic = (Elf32_Dyn*)lmap->l_ld;
  void* ret;

  // Find the desired tag in the dynamic header.
  for(; (dynamic->d_tag != op); ++dynamic);

  ret = (void*)dynamic->d_un.d_ptr;

  if(ret < (void*)lmap->l_addr)
  {
    return (uint8_t*)ret + (size_t)lmap->l_addr;
  }
  return ret;
}

/** Try to find a symbol in one link map.
 *
 * @param lmap Link map.
 * @param hash Symbol hash to find.
 * @return Symbol if found or NULL.
 */
static void* elf32_find_symbol_in_map(struct link_map* lmap, uint32_t hash)
{
  char* strtab = (char*)elf32_get_dynamic_section_value(lmap, DT_STRTAB);
  Elf32_Sym* symtab = (Elf32_Sym*)elf32_get_dynamic_section_value(lmap, DT_SYMTAB);
  uint32_t* hashtable = (uint32_t*)elf32_get_dynamic_section_value(lmap, DT_HASH);
  unsigned numchains = hashtable[1];
  unsigned ii;

  for(ii = 0; (ii < numchains); ++ii)
  {
    Elf32_Sym* sym = &symtab[ii];
    char *name = &strtab[sym->st_name];

    if(sdbm_hash((uint8_t*)name) == hash)
    {
      return (void*)sym->st_value;
    }
  }

  return NULL;
}

/** Find a symbol in any of the link maps.
 *
 * @param hash Hash of the function name string.
 * return Symbol found or NULL.
 */
static void* dnload_find_symbol(uint32_t hash)
{
  struct link_map* lmap = elf32_get_link_map();

  for(;;)
  {
    void* ret = elf32_find_symbol_in_map(lmap, hash);

    if(ret)
    {
      return (uint8_t*)ret + (size_t)lmap->l_addr;
    }

    lmap = lmap->l_next;
  }
}

#if defined(__cplusplus)
}
#endif

#endif
