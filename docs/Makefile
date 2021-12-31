all: report
report: ./report/report.md
	pandoc ./report/report.md --template ./template.latex --pdf-engine=xelatex -V geometry:a4paper -V geometry:margin=3cm -so artifacts/main.tex
	cd artifacts && xelatex main.tex && mv main.pdf report.pdf

clean: rm -rf artifacts

.PHONY: all clean
