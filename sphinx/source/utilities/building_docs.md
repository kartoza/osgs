# Building Documentation

## HTML Docs

```
sudo dnf install sphinx
pip3 install --upgrade myst-parser
pip install sphinx-sizzle-theme

```



See https://sphinx-themes.org/sample-sites/sphinx-sizzle-theme/ for theme specific info.

See https://www.sphinx-doc.org/en/master/usage/markdown.html for Markdown in Sphinx support notes (and the docs at https://myst-parser.readthedocs.io/en/latest/syntax/optional.html). Especially, note the admonitions docs which are used to make little alert etc boxes in the docs:  https://myst-parser.readthedocs.io/en/latest/syntax/optional.html#html-admonitions

## PDF Docs

On fedora I just install the huge, full texlive package:

```
sudo dnf install texlive-scheme-full

``` 

Then build:

```
make latexpdf
```

Sometimes you need to run it a second time if it is a fresh build.

After the build is done, the PDF will be at:

```
docs/build/latex/osgs.pdf
```
