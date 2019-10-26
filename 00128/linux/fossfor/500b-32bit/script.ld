     PHDRS
     {
       interp PT_INTERP ;
       text PT_LOAD ;
       data PT_LOAD ;
       dynamic PT_DYNAMIC ;
     }
     
     SECTIONS
     {
       .interp : { *(.interp) } :interp :text
       .text : { *(.text) } :text
       .dynamic : { *(.dynamic) } :dynamic :data
     }
