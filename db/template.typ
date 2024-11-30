#import "@preview/gentle-clues:1.0.0" as gc

#let author = "Chtholly Boss"

// * Global Settings
#let apply-template(body) = {
  
  show emph: it => {
    set text(rgb("#e67700"))
    underline(it)
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

// * Admonitions
#show: gc.gentle-clues.with(
  breakable: true,
  stroke-width: 0.3em,
  border-width: 0.2em,
)

#let pitfall(content) = gc.clue(
  content,
  // accent-color: rgb("#b2b6b6"),
  title: "Pitfall",
  icon: image("assets/pitfall.svg"),
)

#let idea(content) = gc.idea(content)
// #let board(content) = gc.
#let board(content) = {
  show: gc.gentle-clues.with(headless: true) 
  gc.example(
    content
  )
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
    outset: 0.5em,
    width: 100%, 
    )
  box(
    fill: rgb("#ffec99"),
    radius: 0.6em,
    stroke: black,
    stack(
      dir: ttb, 
      spacing: 0.8em,
      box(stroke: (bottom: 2pt))[
        Question: \
        #question
      ],
      box()[
        Solution: \
        #solution
      ]
    )
  )
}
