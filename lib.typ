#import "@preview/itemize:0.2.0": config, default-enum

#let stanovy = "stanovy"
#let rad = "rad"
#let smernice = "smernice"
#let doc-types = (stanovy, rad, smernice)

#let nums-display = ("Čl. I", "1.", "a)", "(i)")
#let nums-ref = ("čl. I", "odst. 1", "písm. a", "bod i")
#let nums-ref-short = ("I", "1", "a", "i")
#let num-joiner = " "
#let num-joiner-short = "."

#let _common-prefix-len(a, b) = {
  let i = 0
  while a.len() > 0 and b.len() > 0 and a.first() == b.first() {
    a = a.slice(1)
    b = b.slice(1)
    i += 1
  }
  return i
}

#let _ref(it, kind, short) = context {
  let nums-ref-effective = if short { nums-ref-short } else { nums-ref }
  let num-joiner-effective = if short { num-joiner-short } else { num-joiner }

  if it.element == none { return it }
  let enum-label-ID = "__cdl_enum-label-ID__"
  let curr-parent-level = state("__enum-parent-number__", ())

  // get target coords
  let el = it.element
  let is-metadata = el.func() == metadata and el.value == enum-label-ID
  if el.func() not in (text, enum.item) and not is-metadata { return it }
  let enum-count = curr-parent-level.at(it.target)
  if enum-count.len() == 0 { return it }
  let last-section = counter(heading).at(el.location()).first()
  let coords = (last-section,) + enum-count

  // get source coords
  let src-enum-count = curr-parent-level.at(here())
  let src-last-section = counter(heading).at(here()).first()
  let src-coords = (src-last-section,) + src-enum-count

  let num
  if kind == "relative" {
    let enum-numbering = state("xxx", (numbering: nums-ref-effective.slice(1).join(num-joiner-effective), full: false))
    let common = _common-prefix-len(coords, src-coords)
    if common == coords.len() {
      let full-ref = std.numbering(enum-numbering.at(it.target).at("numbering"), ..coords)
      let full-src-ref = std.numbering(enum-numbering.at(it.target).at("numbering"), ..src-coords)
      panic(
        "Relative references are on, and you reference a section from within it: reference @"
          + str(it.target)
          + " references "
          + full-ref
          + " while itself being in "
          + full-src-ref,
      )
    }

    let enum-numbering2 = state("xxx", (
      numbering: nums-ref-effective.slice(common).join(num-joiner-effective),
      full: false,
    ))

    let numbering = enum-numbering2.at(it.target).at("numbering")
    num = std.numbering(numbering, ..coords.slice(common))
  } else if kind == "absolute" {
    let enum-numbering = state("xxx", (numbering: nums-ref-effective.join(num-joiner-effective), full: false))
    num = std.numbering(enum-numbering.at(it.target).at("numbering"), ..coords)
  } else if kind == "last" {
    let enum-numbering = state("xxx", (
      numbering: nums-ref-effective.slice(coords.len() - 1, count: 1).join(num-joiner-effective),
      full: false,
    ))
    num = std.numbering(enum-numbering.at(it.target).at("numbering"), coords.last())
  }

  set text(fill: blue, style: "italic")
  box(link(el.location(), num))
}
#let aref(it, short: false) = {
  show ref: it => _ref(it, "absolute", short)
  ref(it)
}
#let rref(it, short: false) = {
  show ref: it => _ref(it, "relative", short)
  ref(it)
}
#let lref(it, long: false) = {
  show ref: it => _ref(it, "last", not long)
  ref(it)
}

#let conf(
  tit: [],
  doc-type: none,
  doc-number: none,
  relative-refs: true,
  doc,
) = {
  set text(lang: "cs")
  set page(
    paper: "a4",
    margin: (x: 3cm, y: 2cm),
  )

  set heading(numbering: nums-display.first())
  show <unnumbered>: set heading(numbering: none)
  show heading: set align(center)
  show heading: it => block[
    #v(10pt)
    #if it.numbering != none [
      #counter(heading).display()\
    ]
    #it.body
    #v(6pt)
  ]

  set enum(
    full: true,
    // indent: 6pt,
    numbering: (..args) => {
      let n = args.pos().len()
      [#numbering(nums-display.slice(1).at(n - 1), args.pos().last())]
    },
  )
  show: default-enum

  let ref-kind = "absolute"
  if relative-refs {
    ref-kind = "relative"
  }
  show ref: it => _ref(it, ref-kind, false)

  set par(justify: true)

  set document(title: tit)
  show title: set align(center)

  if doc-type == stanovy {
    if doc-number != none {
      panic("doc-number is not allowed for stanovy")
    }
    set document(title: [STANOVY\ České HEMA asociace])
    title()
    doc
  } else if doc-types.contains(doc-type) {
    if doc-number == none {
      panic("doc-number is required for doc-type " + doc-type)
    }
    title()
    [
      #set align(center)
      // #set text(size: 1.3em)
      #if doc-type == rad [
        Řád ČHA č. #doc-number
      ] else if doc-type == smernice [
        Směrnice ČHA č. #doc-number
      ]
      #v(10pt)
    ]
    doc
  } else {
    panic("Unknown doc-type '" + doc-type + "'. Allowed values are " + doc-types.join(", ") + ".")
  }
}
