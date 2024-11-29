#import "template.typ":*

#show: apply-template.with(
  author: ("马奕斌")

)

// * Labs 
#set heading(numbering: "1.1.1")
#show heading.where(level: 1): set heading(
  numbering: (.., num) => {
    "Lab " + str(num) + ": "
  })


#include "src/lab1.typ"
#include "src/lab2.typ"
#include "src/lab3.typ"

#show heading.where(level: 1): set heading(numbering: none)
