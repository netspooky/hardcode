#ifndef LINKER_H
#define LINKER_H

#include <elf.h>
#include <link.h>
#include <string.h>
#include "clib.h"

typedef uint32_t gnu_hash_t; // as defined by standard

extern const struct link_map* _link_map; // Provided by linker.ld linker-script

// We're using the string from dynsym. Symbol is provided by linker-script
extern const char _libc_filename;

static const gnu_hash_t linker_dlopen_mode_hash = 0xf2cb98a2;

// This is the hash-function used for gnu-style hash-tables in elf.
// While it doesn't really matter what function we use -- we don't use the
// hash-tables at all -- it should be fine
static regparm gnu_hash_t linker_gnu_hash(const char* s)
{
    gnu_hash_t h = 5381;

    for (; *s != '\0'; s++)
    {
        h = h * 33 + *s;
    }

    return h;
}

static regparm const struct link_map* linker_map_for_library(const char* library)
{
    // assume the entry exists to save some bytes
    const struct link_map* map = _link_map;
    // At least one call directly to a shared library is needed, otherwise the
    // linker omits the sections for dynamic linking completly.
    // This strstr() call is this one!
    while (strstr(map->l_name, library) == NULL)
    {
        map = map->l_next;
    }

    return map;
}

static regparm const void* linker_get_table(const struct link_map* map, int type)
{
    const ElfW(Dyn)* dyn = (const ElfW(Dyn)*)map->l_ld;
    while (dyn->d_tag != type)
    {
        dyn += 1;
    }

    return (void*)dyn->d_un.d_ptr;
}

// Gnah. After implementing symbol-lookups via gnu hash-table, I realized that
// there're still libraries out using the old sysv-style hash-tables.
// NVidias GL implementation is the one that made problems on my system.
// Therefore, to avoid the size-overhead of implementing both, we keep it way
// simpler here and just walk the symbol table to find symbols.
static regparm void* linker_lookup_symbol(const char* library, gnu_hash_t hash)
{
    // To keep the code short, we trust in the library to be loaded and finding
    // the symbol.
    // If this isn't the case, it'll behave undefined and segfault eventually.

    const struct link_map* map = (const struct link_map*)linker_map_for_library(library);
    const ElfW(Sym)* symtab = (const ElfW(Sym)*)linker_get_table(map, DT_SYMTAB);
    const char* strtab = (const char*)linker_get_table(map, DT_STRTAB);

    while (hash != linker_gnu_hash(strtab + symtab->st_name))
    {
        symtab += 1;
    }

    return (void*)(map->l_addr + symtab->st_value);
}

static regparm void linker_load_library(const char* filename)
{
    // Yay! Using internals of libc! Let's just cross fingers this won't change too fast :/
    void* (*__libc_dlopen_mode_fn)(const char*, int)
            = (void* (*)(const char*, int))linker_lookup_symbol(&_libc_filename, linker_dlopen_mode_hash);
    __libc_dlopen_mode_fn(filename, RTLD_NOW | RTLD_GLOBAL);
}

#endif

