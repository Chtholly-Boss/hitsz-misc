// Page Settings 
#set page(paper: "a4")
#set page(header: align(center, text(fill: gray)[《编译原理》实验报告]))
// Header Settings
#set heading(numbering: "1.1")

// Body
#include "cover.typ"

// Page Count After Cover
#counter(page).update(1)
#set page(footer: context [
  #set align(center)
  #set text(size: 10pt)
  #counter(page).display("1")
])

// Contents
#align(center, text(size: 20pt)[目录])
#outline(
  title: none,
  indent: auto
)
#pagebreak()

#include "./part1.typ"
#include "./part2.typ"
#include "./part3.typ"
#include "./part4.typ"
#include "./part5.typ"

