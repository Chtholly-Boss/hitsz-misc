#import "@preview/gentle-clues:1.0.0" as clues
#import "@preview/syntree:0.2.0": tree

#let ex = clues.example
#let synex(content) = clues.example(title: "Synthetic Example", content)
#let btw(content) = clues.info(title: "BTW", content)
#let def(content) = clues.info(title: "Definition", content)

#let ans(it) = underline(text(fill: blue, weight: "bold", it))

// Alpha, Beta, Gamma,...
#let alpha = sym.alpha
#let beta = sym.beta
#let gamma = sym.gamma
#let delta = sym.delta
#let epsilon = sym.epsilon
// Arrows
#let to = sym.arrow.r
#let dto = sym.arrow.double
// Miscelaneous
#let dot = sym.dot
