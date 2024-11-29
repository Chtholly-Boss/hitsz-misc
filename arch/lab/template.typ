#let apply-template(body, author:()) = {
  set document(author: author)  

  show link: set text(blue)
  show link: it => underline(it)

  show raw.where(block: true): it => {
    set block(
      fill: luma(93%),
      width: 100%,
      outset: 5pt,
      radius: 1em)
    set align(center)
    it
  } 

  show quote: set block(fill: luma(95%), radius: 1em)
  set quote(block: true)
  body
}

