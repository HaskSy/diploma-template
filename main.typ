#import "lib.typ": *
#import "./common/glossary.typ": glossary-entries
#import "./common/acronym.typ": acronym-entries
#import "./common/symbols.typ": symbols-entries

// Делаем вот так, и голова не болит
// Хотя зачем нам в принципе эта фигня там -- вопрос хороший
#let back-refs-on-right(entry) = {
  return text()[#h(1fr) #get-entry-back-references(entry).join(",")]
}

#show: template.with()

#register-glossary(symbols-entries)
#register-glossary(acronym-entries)
#register-glossary(glossary-entries)

#include "./sections/intro.typ"
#include "./sections/section1.typ"
#include "./sections/section2.typ"
#include "./sections/section3.typ"
#include "./sections/section4.typ"
// #include "./sections/section5.typ"
#include "./sections/conclusion.typ"

// Всё, хватит с нас чиселок
#show heading: set heading(numbering: none)

#bibliography(
  title: "Список литературы", "common/bibliography.bib", style: "gost-r-705-2008-numeric",
)

#show heading: set heading(numbering: none)
#include "./sections/appendix.typ"

// Только если есть реальные термины..
#hide([
= Список сокращений и условных обозначений
#print-glossary(
  acronym-entries, user-print-back-references: back-refs-on-right,
)
])
