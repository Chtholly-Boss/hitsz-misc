#import "@preview/gentle-clues:1.0.0" as clues
#import "@preview/syntree:0.2.0": tree

#let ex = clues.example
#let synex(content) = clues.example(title: "Synthetic Example", content)
#let btw(content) = clues.info(title: "BTW", content)
#let def(content) = clues.info(title: "Definition", content)

#let ans(it) = underline(text(fill: blue, weight: "bold", it))
#let to = sym.arrow.r