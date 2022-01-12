all: report slides

report: ./report/report.md
	pandoc ./report/report.md --template ./template.latex --pdf-engine=xelatex -V geometry:a4paper -V geometry:margin=3cm -so artifacts/main.tex
	cd artifacts && xelatex main.tex && mv main.pdf report.pdf

slides: ./slides/slides.md
	pandoc -t beamer ./slides/slides.md --slide-level 2 --pdf-engine=xelatex -o artifacts/slides.pdf

clean: rm -rf artifacts

.PHONY: all clean
