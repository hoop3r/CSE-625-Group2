# CSE-625 Group 2

LaTeX sources for assignments. Each assignment is a top-level folder with its
own `main.tex`

Compiled PDFs are published as GitHub Releases

## Assignment 1 Layout

```
assignment_1/
  main.tex            # document root
  bibliography.bib    # biblatex/biber sources
  sections/           # \input'd section files
  scripts/            # benchmark scripts
```

## Publishing a PDF

Tag the commit you want to submit and push the tag:

```
git tag v1.0.0
git push origin v1.0.0
```