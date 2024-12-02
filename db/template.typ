#import "@preview/gentle-clues:1.0.0" as gc
#import "@preview/gentle-clues:1.0.0": gentle-clues

#let author = "Chtholly Boss"

// * Global Settings
#let apply-template(body) = {
  set page(
    footer: context [
      #set align(right)
      #set text(size: 10pt)
        #line(length: 100%)
      #counter(page).display("1")
    ] 
  ) 
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
  body
}

#let apply-header(body) = {
  show heading.where(level: 1): set heading(numbering: "一、")
  show heading.where(level: 2): set heading(
    numbering: (.., num) => {
      str(num) + ". "
    })
  show heading.where(level: 3): set heading(
    numbering: (..nums) => {
      let n = nums.pos().map(str)
      n.at(1) + "." + n.at(2) + ". "
    }
  )
  body
}

// * Math Operators
#let to = math.op($arrow.r$)
#let dto = math.op($arrow.r.double$)


#let pitfall(content) = gc.clue(
  content,
  // accent-color: rgb("#b2b6b6"),
  title: "Pitfall",
  icon: image("assets/pitfall.svg"),
)

#let idea(content) = gc.idea(content)
// #let board(content) = gc.
#let board(content) = {
  show: gc.gentle-clues.with(headless: true, breakable: true) 
  gc.example(
    content
  )
  show: gc.gentle-clues.with(headless: false)
}

// * Emojis 
#let inline-emoji(path) = box(
  baseline: 20%,
  height: 1.2em,
  image(path)
)

#let yes = inline-emoji("assets/true.svg")
#let no = inline-emoji("assets/false.svg")

// * Template Libraries
#let qs(question, solution) = {
  set box(
    outset: 0.3em,
    width: 100%, 
    )
  stack(
    dir: ttb,
    board[
      #text(fill: blue)[*Question*: ]
      \ #question
    ], 
    board[
      #text(fill: green)[*Solution*: ]\ #solution
    ]
  )
}

#let fill_blank(content, src: [2023年深圳]) = {
  [(#src) #content] 
}

#let mooc(content) = fill_blank(content, src: "MOOC")
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
