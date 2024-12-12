#import "template.typ": *

#show: apply-template.with(author: "马奕斌")

#set heading(numbering: "1.1.1")
#show heading.where(level: 1): set heading(numbering: (.., num) => {
  sym.circle
})

#include "src/lab4.typ"
#pagebreak()
#include "src/lab5.typ"
