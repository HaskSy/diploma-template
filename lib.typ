#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.8": codly-languages
#import "@preview/glossarium:0.5.4": *
#import "@preview/outrageous:0.4.0"
#import "@preview/ctheorems:1.1.3": *
#import "@preview/tablem:0.2.0": tablem, three-line-table
#show: thmrules

#let template(
  font-type: "CMU Serif", font-size: 12pt, link-color: black, glossary-list: [], body,
) = {
  set text(
    font: font-type, lang: "ru", size: font-size, fallback: true, hyphenate: true,
  )

  set page(
    margin: (top: 3.49cm, bottom: 3.49cm, left: 3.15cm, right: 3.15cm), // размер полей (ГОСТ 7.0.11-2011, 5.3.7)
    width: 21cm,
  )

  set par(
    justify: true,
    // Удивительно, но в типографской штуке каждый элемент считался параграфом
    // И это вызвало проблемы, быть не может!
    // @see: https://github.com/typst/typst/pull/5768
    first-line-indent: (amount: 1.5em, all: true),
    leading: 0.6em,
  )

  set heading(numbering: "1.", outlined: true, supplement: [Раздел])
  show heading: it => {
    set align(left)
    set text(font: font-type, size: font-size)
    set block(above: 2em, below: 1.2em) // Заголовки отделяют от текста сверху и снизу тремя интервалами (ГОСТ Р 7.0.11-2011, 5.3.5)

    if it.level == 1 {
      // Без weak получается пустая страница из ниоткуда
      pagebreak(weak: true) // новая страница для разделов 1 уровня
      counter(figure).update(0) // сброс значения счетчика рисунков
      counter(math.equation).update(0) // сброс значения счетчика уравнений
      // Чтобы первый уровень был кричащим
      text(size: 17.2pt, it)
    } else if it.level == 2 {
      text(size: 15pt, it)
    } else {
      it
    }
  }

  // Не отображать ссылки на figure
  set ref(supplement: it => {
    if it.func() == figure {}
  })

  // настройка codly для кода
  show: codly-init.with()
  codly(languages: 
    (..codly-languages,
     cangjie: (
        name: "Cangjie",
        icon: box(
          image("attachments/icons/cangjie.svg", height: 0.9em),
          baseline: 0.05em,
          inset: 0pt,
          outset: 0pt,
        ) + h(0.3em),
        color: rgb("#64d8cc"))),
  display-icon: true)

  // глоссарий, чтобы было хорошо
  show: make-glossary
  show link: set text(fill: link-color)

  //TODO: Нумерация уравнений

  // Рисунки
  // show figure.where(kind: "thmenv"): align.with(left)
  // show figure: align.with(center)
  set figure(supplement: it => {
    if it.func() == image {
      [Рисунок]
    } else if it.func() == raw {
      [Листинг]
    } else if it.func() == table {
      [Таблица]
    } else {
      auto
    }
  })

  show figure: it => {
    if (it.kind == "thmenv") {
        show figure.caption: it => {}
        set text(hyphenate: true)
        align(left, it)
    } else {
        align(center, it)
    }
  }

  set figure.caption(separator: [ -- ])
  set figure(numbering: num =>
  ((counter(heading.where(level: 1)).get() + (num,)).map(str).join(".")))

  // TODO: настройка таблиц

  // Списки
  set enum(indent: 1.5em)
  set list(indent: 1.5em)

  state("section").update("body")

  // Нумерация уравнений
  let eq_number(it) = {
    let part_number = counter(heading.where(level: 1)).get()
    part_number
    it
  }
  set math.equation(
    numbering: num =>
    (
      "(" + (counter(heading.where(level: 1)).get() + (num,)).map(str).join(".") + ")"
    ), supplement: [Уравнение],
  )

  // сквозная нумерация
  set page(
    numbering: "1", // сквозная нумерация
    number-align: center + bottom, // Не уверен что правильно, но что нет
  )
  counter(page).update(1)

  // Содержание
  // Здесь делается некоторая магия, чтобы заставить первый уровень иметь обводку "bold" и не ставить никаких точечек
  // У меня почему-то ехал alignment, если я делал это штатными средствами
  show outline.entry: outrageous.show-entry.with(font-weight: ("bold", auto), font: (font-type, font-type))
  show outline.entry: it => {
    if (it.level == 1) {
      v(8.5pt)
      it
    } else {
      it
    }
  }
  outline(title: "Оглавление", depth: 3, indent: 1.5em)

  body
}

#let appendix(body) = {
  counter(heading).update(0)

  // headings using letters
  show heading.where(level: 1): set heading(numbering: "Приложение A. ", supplement: [Приложение])
  show heading.where(level: 2): set heading(numbering: "A.1 ", supplement: [Приложение])

  set figure(numbering: (x) => context{
    let idx = numbering("A", counter(heading).at(here()).first())
    [#idx.#numbering("1", x)]
  })

  // Чтобы всё считалось в аппендиксе локально
  show heading: it => {
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: math.equation)).update(0)
    counter(figure.where(kind: raw)).update(0)

    it
  }

  body
}

#let icon(image) = {
  box(height: .8em, baseline: 0.05em, image)
  h(0.1em)
}

#let theorem = thmbox("теорема", "Теорема", fill: rgb("#eeffee"))
#let corollary = thmplain("следствие", "Следствие", base: "теорема", titlefmt: strong)
#let definition = thmbox(
    "определение",
    "Определение",
    inset: 0em,
    base_level: 1,
    padding: (top: 0em, bottom: 0em),
    namefmt: x => [#strong(x)],
    titlefmt: x => strong(x + "."),
    separator: [#h(0.4em)--- ]
  )
}

#let example = thmplain("пример", "Пример").with(numbering: none)
#let proof = thmproof("доказательство", "Доказательство")
#let noindent(body) = {
    set par(
    first-line-indent: (amount: 0em, all: true)
    )
    body
}

#let TODO(body) = {
    [*TODO: #body*]
}

#let three-line-table = tablem.with(
  render: (columns: auto, ..args) => {
    table(
      columns: columns,
      stroke: none,
      align: center + horizon,
      table.hline(y: 0),
      table.hline(y: 1, stroke: .5pt),
      ..args,
      table.hline(),
    )
  }
)
