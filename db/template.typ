#import "@preview/gentle-clues:1.0.0" as gc
#import "@preview/gentle-clues:1.0.0": gentle-clues
#import "@preview/cetz:0.3.1"

#let author = "Chtholly Boss"

// * Global Settings
#let apply-template(body) = {
  set page(footer: context [
    #set align(right)
    #set text(size: 10pt)
    #line(length: 100%)
    #counter(page).display("1")
  ])
  show emph: it => {
    set text(rgb("#e67700"))
    underline(it)
  }
  show link: it => {
    set text(blue)
    underline(it)
  }

  // * Admonitions
  show: gc.gentle-clues.with(
    breakable: true,
    stroke-width: 0.3em,
    border-width: 0.2em,
  )

  show math.equation: it => {
    math.display(it)
  }

  set quote(block: true)
  show quote: it => {
    set align(center)
    box(
      radius: 0.2em,
      outset: 0.3em,
      fill: luma(95%),
    )[#it]
  }

  set table(align: center + horizon)
  body
}

#let apply-header(body) = {
  show heading.where(level: 1): set heading(numbering: "一、")
  show heading.where(level: 2): set heading(numbering: (.., num) => {
    str(num) + ". "
  })
  show heading.where(level: 3): set heading(numbering: (..nums) => {
    let n = nums.pos().map(str)
    n.at(1) + "." + n.at(2) + ". "
  })
  body
}

// * Math Operators
#let to = math.op($arrow.r$)

// * Emojis
#let inline-emoji(path) = box(
  baseline: 20%,
  height: 1.2em,
  image(path),
)

#let board(content) = {
  show: gc.gentle-clues.with(headless: true, breakable: true)
  gc.example(content)
  show: gc.gentle-clues.with(headless: false)
}
// * Template Libraries
#let qs(q, a, rel: none) = {
  set box(
    outset: 0.3em,
    width: 100%,
  )

  stack(
    dir: ttb,
    board[
      #text(fill: red)[*Question*: ]
      \ #q
    ],
    board[
      #text(fill: green)[*Solution*: ]\ #a
    ],
    if rel != none {
      board[
        #text(fill: blue)[*Related Problem*: ]\ #rel
      ]
    },
  )
}

#let choice(q, ans: none, dir: ltr, a: none, b: none, c: none, d: none) = {
  q
  [( #emph(ans) ) ]
  stack(
      dir: dir,
      // spacing: 4em,
      spacing: if dir == ltr {1fr} else { 1em },
      [A. #a],
      [B. #b],
      [C. #c],
      [D. #d],
    )
}

#let judge(q, ans: false) = {
  q
  if ans {
    inline-emoji("assets/true.svg")
  } else {
    inline-emoji("assets/false.svg")
  }
}

#let b = "_____"
