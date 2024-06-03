

# Quarto word count


- [Why counting words is hard](#why-counting-words-is-hard)
- [Using the word count script](#using-the-word-count-script)
  - [Installing](#installing)
  - [Usage](#usage)
  - [Terminal output](#terminal-output)
  - [Shortcodes](#shortcodes)
  - [No counting](#no-counting)
  - [Appendices](#appendices)
- [Example](#example)
- [Credits](#credits)
- [How this all works](#how-this-all-works)

<!-- README.md is generated from README.qmd. Please edit that file -->

## Why counting words is hard

In academic writing and publishing, word counts are important, since
many journals specify word limits for submitted articles. Counting how
many words you have in a Quarto Markdown file is tricky, though, for a
bunch of reasons:

1.  **Compatibility with Word**: Academic publishing portals tend to
    care about Microsoft Word-like counts, but lots of R and Python
    functions for counting words in a document treat word boundaries
    differently.

    For instance, Word considers hyphenated words to be one word (e.g.,
    “A super-neat kick-in-the-pants example” is 4 words in Word), while
    `stringi::stri_count_words()` counts them as multiple words (e.g. “A
    super-neat kick-in-the-pants example” is 8 words with {stringi}).
    Making matters worse, {stringi} counts “/” as a word boundary, so
    URLs can severely inflate your actual word count.

2.  **Extra text elements**: Academic writing typically doesn’t count
    the title, abstract, table text, table and figure captions, or
    equations as words in the manuscript.

    In computational documents like Quarto Markdown, these often don’t
    appear until the document is rendered, so simply running a
    word-counting function on a `.qmd` file will count the code
    generating tables and figures, again inflating the word count.

3.  **Citations and bibliography**: Academic writing typically counts
    references as part of the word count (even though IT SHOULDN’T).
    However, in Quarto Markdown (and all other flavors of pandoc-based
    markdown), citations don’t get counted until the bibliography is
    generated, which only happens when the document is rendered.

    Simply running a word-counting function on a `.qmd` file (or
    something like the super neat
    [{wordcountaddin}](https://github.com/benmarwick/wordcountaddin))
    will see citekeys in the document like `@Lovelace1842`, but it will
    only count them as individual words (e.g. not “(Lovelace 1842)” in
    in-text styles or ‘Ada Augusta Lovelace, “Sketch of the Analytical
    Engine…,” *Taylor’s Scientific Memoirs* 3 (1842): 666–731.’ in
    footnote styles), and more importantly, it will not count any of the
    automatically generated references in the final bibliography list.

This extension fixes all three of these issues by relying on a [Lua
filter](_extensions/wordcount/wordcount.lua) to count the words after
the document has been rendered and before it has been converted to its
final output format. [Frederik Aust (@crsh)](https://github.com/crsh)
uses the same Lua filter for counting words in R Markdown documents with
the [{rmdfiltr}](https://github.com/crsh/rmdfiltr) package (I actually
just copied and slightly expanded [that package’s
`inst/wordcount.lua`](https://github.com/crsh/rmdfiltr/blob/master/inst/wordcount.lua)).
The filter works really well and [is generally comparable to Word’s word
count](https://cran.r-project.org/web/packages/rmdfiltr/vignettes/wordcount.html).
You should definitely glance through the [“How this all works”
section](#how-this-all-works) to understand… um… how it works.

## Using the word count script

### Installing

``` bash
quarto add andrewheiss/quarto-wordcount
```

{quarto-wordcount} requires Quarto version \>= 1.4.551

This will install the extension under the `_extensions` subdirectory. If
you’re using version control, you will want to check in this directory.

### Usage

There are two ways to enable the extension: (1) as an output format and
(2) as a filter.

#### Output format

You can specify one of four different output formats in your YAML
settings: `wordcount-html`, `wordcount-pdf`, `wordcount-docx`:

``` yaml
title: Something
format:
  wordcount-html: default
```

The `wordcount-FORMAT` format type is really just a wrapper for each
base format (HTML, PDF, Word, and Markdown), so all other HTML-, PDF-,
Word-, and Markdown-specific options work like normal:

``` yaml
title: Something
format:
  wordcount-html:
    toc: true
    fig-align: center
    cap-location: margin
```

#### Filter

If you’re using a [custom output
format](https://quarto.org/docs/extensions/listing-formats.html) like
[{hikmah-academic-quarto}](https://github.com/andrewheiss/hikmah-academic-quarto)
or a [journal article
format](https://quarto.org/docs/extensions/listing-journals.html) like
[{jss}](https://github.com/quarto-journals/jss), you can’t use the
`wordcount-html` format, since you can’t combine output formats.

To enable word counting for *any* format, including custom formats, you
can add the extension Lua scripts as filters. You need to specify three
settings:

1.  `citeproc: false` must be set so that Quarto doesn’t try to process
    citations
2.  The path to `citeproc.lua` so that citations are processed before
    counting words—[this must come *before*
    `wordcount.lua`](#how-this-all-works)
3.  The path to `wordcount.lua` so that words are counted

``` yaml
title: Something
format:
  html:  # Regular built-in format
    citeproc: false
    filters:
      - at: pre-quarto
        path: _extensions/andrewheiss/wordcount/citeproc.lua
      - at: pre-quarto
        path: _extensions/andrewheiss/wordcount/wordcount.lua
  jss-pdf:  # Custom third-party format
    citeproc: false
    filters:
      - at: pre-quarto
        path: _extensions/andrewheiss/wordcount/citeproc.lua
      - at: pre-quarto
        path: _extensions/andrewheiss/wordcount/wordcount.lua
```

### Terminal output

The word count will appear in the terminal output when rendering the
document. It shows multiple values:

- **Overall totals**: (1) the total count of everything, including the
  body, notes, references, and appendix sections, and (2) the count for
  just the body and notes.

  The journals I typically work with count the body + notes + references
  towards the total word count. When shrinking manuscripts to fit word
  limits, I find it helpful to split the references count off from the
  body + notes so I can more easily see where edits might be most
  efficient (e.g. re-word sentences vs. remove references)

- **Individual section totals**: counts for the (1) text body, (2)
  notes, (3) references, and (4) appendix

``` text
Overall totals:
--------------------------------
- 451 total words
- 378 words in body and notes

Section totals:
--------------------------------
- 315 words in text body
- 63 words in notes
- 53 words in reference section
- 20 words in appendix section
```

### Shortcodes

There are also multiple shortcodes you can use to include different word
counts directly in the document:

- Use `{{< words-total >}}` to include a count of all words

- Use `{{< words-body >}}` to include a count of the words in the text
  body only, omitting the references, notes, and appendix

- Use `{{< words-ref >}}` to include a count of the words in the
  reference section

- Use `{{< words-append >}}` to include a count of the words in the
  appendix, which must be wrapped in a div with the `#appendix-count` id
  ([see below for more details](#appendices))

- Use `{{< words-note >}}` to include a count of the words in the notes:

- Use `{{< words-sum ARG >}}` where `ARG` is some concatenation of the
  four countable areas: `body`, `ref`, `append`, and `note`.

  For example, `{{< words-sum body-note >}}` includes a count of the
  words in the body and notes; `{{< words-sum ref-append >}}` includes a
  count of the words in the references and appendix

You can use shortcodes in your YAML metadata too:

``` yaml
title: Something
subtitle: "{{< words-sum body-note-ref >}} words"
```

### No counting

If you want to omit text from the word count, you can include it in a
[fenced
div](https://quarto.org/docs/authoring/markdown-basics.html#sec-divs-and-spans)
with the `{.no-count}` class:

``` markdown
::: {.no-count}

These words don't count.

:::
```

### Appendices

In academic writing, it’s often helpful to have a separate word count
for content in the appendices, since things there don’t typically count
against journal word limits. [Quarto has a neat feature for
automatically creating an appendix
section](https://quarto.org/docs/authoring/appendices.html) and moving
content there automatically as needed. It does this (I think) with a
fancy Lua filter.

However, Quarto’s appendix-generating process comes *after* any custom
Lua filters, so even though the final rendered document creates a div
with the id “appendix”, that div isn’t accessible when counting words
(since it doesn’t exist yet), so there’s no easy way to extract the
appendix words from the rest of the text.

So, as a (temporary?) workaround (until I can figure out how to make
this Lua filter run after the creation of the appendix div?), you can
get a separate word count for the appendix by creating your own fenced
div with the id `appendix-count`:

``` markdown
# Introduction

Regular text goes here.

::: {#appendix-count}

# Appendix {.appendix}

More words here

:::
```

## Example

You can see a minimal sample document at [`template.qmd`](template.qmd).

## Credits

The original [`wordcount.lua`](_extensions/wordcount/wordcount.lua)
filter came from [Frederik Aust’s (@crsh)](https://github.com/crsh)
[{rmdfiltr}](https://github.com/crsh/rmdfiltr) package.

## How this all works

Behind the scenes, pandoc typically converts a Markdown document to an
abstract syntax tree (AST), or an output-agnostic representation of all
the document elements. In AST form, it’s easy to use the [Lua
language](https://pandoc.org/lua-filters.html) to extract or exclude
specific elements of the document (i.e. exclude captions or only look at
the references).

Quarto was designed to be language-agnostic, so {rmdfiltr}’s approach of
using R to dynamically set the path to its Lua filters in YAML front
matter does not work with Quarto files. ([See this comment from the
Quarto team stating that you cannot use R output in the Quarto YAML
header](https://github.com/quarto-dev/quarto-cli/issues/1391#issuecomment-1185348644).)

But it’s still possible to use the fancy {rmdfiltr} Lua filter with
Quarto with a little trickery!

In order to include citations in the word count, we have to feed the
word count filter a version of the document that has been processed with
the [`--citeproc`
option](https://pandoc.org/MANUAL.html#citation-rendering) enabled.
However, in both R Markdown/knitr and in Quarto, the `--citeproc` flag
is designed to be the last possible option, resulting in pandoc commands
that look something like this:

``` sh
pandoc whatever.md --output whatever.html --lua-filter wordcount.lua --citeproc
```

The order of these arguments matter, so having
`--lua-filter wordcount.lua` come before `--citeproc` makes it so the
words will be counted before the bibliography is generated, which isn’t
great.

{rmdfiltr} gets around this ordering issue by editing the YAML front
matter to (1) disable citeproc in general and (2) specify the
`--citeproc` flag before running the filter:

``` yaml
output:
  html_document:
    citeproc: false
    pandoc_args:
      - '--citeproc'
      - '--lua-filter'
      - '/path/to/rmdfiltr/wordcount.lua'
```

That generates a pandoc command like this, with `--citeproc` first, so
the generated references get counted:

``` sh
pandoc whatever.md --output whatever.html --citeproc --lua-filter wordcount.lua
```

Quarto doesn’t have a `pandoc_args` option though. Instead, it has a
`filters` YAML key that lets you specify a list of Lua filters to apply
to the document at specific steps in the rendering process:

``` yaml
format:
  html:
    citeproc: false
    filters: 
      - "/path/to/wordcount.lua"
```

However, there’s no obvious way to reposition the `--citeproc` argument
and it will automatically appear at the end, making it so generated
references aren’t counted.

Fortunately, [this GitHub
comment](https://github.com/quarto-dev/quarto-cli/issues/2294#issuecomment-1238954661)
shows that it’s possible to make a Lua filter that basically behaves
like `--citeproc` by feeding the whole document to
`pandoc.utils.citeproc()`. That means we can create a little Lua script
like `citeproc.lua`:

``` lua
-- Lua filter that behaves like `--citeproc`
function Pandoc (doc)
  return pandoc.utils.citeproc(doc)
end
```

…and then include *that* as a filter:

``` yaml
format:
  html:
    citeproc: false
    filters:
      - at: pre-quarto
        path: "path/to/citeproc.lua"
      - at: pre-quarto
        path: "path/to/wordcount.lua"
```

This creates a pandoc command that looks something like this, feeding
the document to the citeproc “filter” first, then feeding that to the
word count script:

``` sh
pandoc whatever.md --output whatever.html  --lua-filter citeproc.lua --lua-filter wordcount.lua
```
