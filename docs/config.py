#!/usr/bin/env python3

import getopt
import os
import sys
from typing import Optional
import toml

VERBOSE = False


def debug(*args):
    if VERBOSE:
        print(args)


def or_if(value, default):
    if value is None:
        return default
    else:
        return value


TOML_PATH = "./config.toml"

HELP_MESSAGE = """
Report, slides and documentation template and automated compile tool.

Use :
config.py [options]

Options:
    -h --help Displays this help
    -v --verbose Enables debug messages
    -f --force Forces overwriting of file headers
"""


def create_folders(report, slides, doc):
    """Creates new empty folders"""
    for path in [report, slides, doc]:
        if path is not None and not os.path.isdir(path):
            os.mkdir(path)


def generate_report_header(report) -> str:

    header = "---\n"
    if report.get("title") is not None:
        header += ("title: " + report.get("title") + "\n")
    if report.get("author") is not None:
        authors = "author:"
        (au, af) = (report.get("author"), report.get("affiliation"))
        if isinstance(au, list):
            authors += "\n"
            for i in range(len(au)):
                (u, f) = (au[i], af[i])
                authors += ("- name: " + u + "\n")
                if f is not None and len(f) > 0:
                    authors += ("  affiliation: " + f + "\n")
        else:
            authors += (" " + au + "\n")
            if af is not None and isinstance(af, str) and len(af) > 0:
                authors += ("affiliation: " + af + "\n")
        header += authors
    if report.get("abstract"):
        header += "abstract:\n"
    if report.get("toc"):
        header += "toc: true\n"
    if report.get("twocolumns"):
        header += "twocolumns: true\n"
    if report.get("numbersections"):
        header += "numbersections: true\n"

    latex_args = report.get("latex-args")
    if latex_args is None:
        latex_args = []
    latex_packages = report.get("latex-packages")
    if latex_packages is None:
        latex_packages = []
    if len(latex_args) > 0 or len(latex_packages) > 0:
        latex_includes = "header-includes:\n"
        for pack in latex_packages:
            latex_includes += ("    - \\usepackage{" + pack + "}\n")
        for arg in latex_args:
            latex_includes += ("    - " + arg + "\n")
        header += latex_includes

    yaml_args = report.get("yaml-args")
    if yaml_args is not None:
        for k in yaml_args.keys():
            header += (k + ": " + str(yaml_args[k]) + "\n")

    header += "---\n"
    return header


def write_header(header, path):
    to_rewrite = [header]
    try:
        with open(path, "r") as f:
            lines = f.readlines()
            i = 0
            if lines[0][:3] == "---":
                i += 1
                while i < len(lines) and lines[i][:3] != "---":
                    i += 1
                i += 1
            for j in range(i, len(lines)):
                to_rewrite.append(lines[j])
    except:
        pass

    with open(path, "w") as f:
        f.writelines(to_rewrite)


def generate_report(report, path, force=False):
    header = generate_report_header(report)
    if os.path.isfile(path):
        if force:
            print("Overwriting report header.")
            write_header(header, path)
        else:
            print(
                "Will not overwrite report header. Pass -f or --force to force overwriting")
    else:
        write_header(header, path)


def generate_makefile(toml):
    makefile = ""
    artifacts = toml["fs"]["artifacts"]
    make_report = ""
    make_slides = ""
    make_doc = ""

    comp_all = "all:"

    # report
    if toml.get("compilation").get("report"):
        comp_all += " report"
        report = toml["report"]
        latex_engine = toml["utilitaries"]["latex"]
        pandoc = toml["utilitaries"]["pandoc"]
        make_bib = or_if(report.get("references"), False)

        pandoc_flags = "--template ./template.latex --pdf-engine=xelatex -V geometry:a4paper -V geometry:margin=3cm"

        report_path = os.path.join(
            "./", toml["fs"]["report"], report["name"]) + ".md"

        if make_bib:
            bibtex_file = os.path.join("./", or_if(toml.get("fs").get("report"), "report"), or_if(
                report.get("references-file"), "references.bib"))
            bibtex_engine = toml["utilitaries"]["bibtex"]
            compilation_1 = "\tcp {0} {1}\n".format(bibtex_file, artifacts)
            compilation_2 = "\tcd {0} && ".format(artifacts)
            compilation_3 = "{0} {2} && {1} {3} && {0} {2} && {0} {2} && mv {4} {5}.pdf\n".format(
                latex_engine, bibtex_engine, "main.tex", "main", "main.pdf", report["name"])
            compilation = compilation_1 + compilation_2 + compilation_3

        else:
            compilation_1 = "\tcd {0} && ".format(artifacts)
            compilation_2 = "{0} {1} && mv {2} {3}.pdf\n".format(
                latex_engine, "main.tex", "main.pdf", report["name"])
            compilation = compilation_1 + compilation_2

        comp_pandoc = "\t{0} {1} {2} -so {3}/main.tex\n".format(
            pandoc, report_path, pandoc_flags, artifacts)
        make_report += "report: {0}\n".format(report_path) + \
            comp_pandoc + compilation
    comp_all += '\n'
    phony = "\n.PHONY: all clean\n"
    clean = "\nclean: rm -rf {0}\n".format(artifacts)
    with open("./Makefile", 'w') as f:
        f.write(comp_all + make_report +
                make_slides + make_doc + clean + phony)


def main(arguments):
    TOML = None
    try:
        res = getopt.getopt(arguments, "Ffhv", ["help", "verbose", "force"])
    except:
        print(HELP_MESSAGE)
        return

    try:
        TOML = toml.load(TOML_PATH)
    except:
        print("Failed to load TOML config file. Aborting.")

    force_rewrite = False
    for opt, value in res[0]:
        if opt == "-h" or opt == "--help":
            print(HELP_MESSAGE)
            return
        if opt == "-v" or opt == "--verbose":
            VERBOSE = True
        if opt == "-f" or opt == "--force":
            force_rewrite = True
    report = TOML["report"]
    slides = TOML["slides"]
    doc = TOML["documentation"]
    common = TOML["common"]
    compilation = TOML["compilation"]
    for (k, v) in common.items():
        if isinstance(v, str) or isinstance(v, list):
            if report.get(k) is None:
                report[k] = v
            if doc.get(k) is None:
                doc[k] = v
            if slides.get(k) is None:
                slides[k] = v
    if compilation["report"]:
        if not os.path.isdir(or_if(TOML.get("fs").get("report"), "report")):
            os.mkdir(or_if(TOML.get("fs").get("report"), "report"))
        report_path = os.path.join(
            "./", or_if(TOML.get("fs").get("report"), "report"), or_if(report.get("name"), "report.md"))
        generate_report(report, report_path + ".md", force=force_rewrite)
        if TOML["report"].get("references"):
            bibtex_file = os.path.join("./", or_if(TOML.get("fs").get("report"), "report"), or_if(
                report.get("references-file"), "references.bib"))
            if not os.path.isfile(bibtex_file):
                with open(bibtex_file, 'a') as bib:
                    bib.write("%% Auto-generated bib file")

    if not os.path.isdir(TOML["fs"]["artifacts"]):
        os.mkdir(TOML["fs"]["artifacts"])
    generate_makefile(TOML)


if __name__ == "__main__":
    arguments = sys.argv[1:]
    main(arguments)
