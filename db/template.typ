#import "@preview/gentle-clues:1.0.0" as clues

#let author = "Chtholly Boss"
#let subject = "数据库系统概念"

// * DIY emph *
#let apply-emph(body) = {
  show emph: it => underline(it, offset: 0.1em, evade: false)
  show emph: set text(blue)
  body
}

// * DIY strong *
#let apply-strong(body) = {
  show strong: set text(red)
  body
}

// template
#let apply-template(body) = {
  body
}

// * Math Operators
#let to = math.op($arrow.r$)
#let dto = math.op($arrow.r.double$)

// * Admonitions
#let memo = clues.memo.with(title: "Remember")

// * Layout
#let grid-left-right(l, r, rev: false, ratio: (1fr, 1fr)) = {
  let gl = l 
  let gr = r
  if rev {
    gl = r
    gr = l
  }

  grid(
    columns: ratio,
    gl, gr
  )
}
