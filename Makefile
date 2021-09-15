META_FOLDER = wit
OUTPUT = build
ZOTERO = http://127.0.0.1:23119/better-bibtex/export/collection?/4/RL3U73PY.bibtex
REF_NAME = ref.bib
STATS_NAME = stats.wit.txt
TEX_TEMPLATE_NAME = ieeetemplate.tex
INPUT_FILE = main.md
OUTPUT_FILE = main.tex
META_YAML = meta.yaml

all: normal logs

# The follow logs the number of words written and dumps it into a file
logs:
	@(date +"%Y-%m-%d %T" | tr "\n" ", "; wc $(INPUT_FILE) | xargs | tr " " ", ") >> $(META_FOLDER)/$(STATS_NAME)

ieeetemplate:
	@echo "Downloading biobliography file from Zotero..."
	@curl $(ZOTERO) --output $(OUTPUT)/$(REF_NAME) --silent
	@cp $(OUTPUT)/$(REF_NAME) $(REF_NAME)
	@echo "Running pandoc..."
	@pandoc --citeproc -s --natbib $(META_FOLDER)/$(META_YAML) --template=$(META_FOLDER)/$(TEX_TEMPLATE_NAME) -N \
	 -f markdown -t latex+raw_tex -o $(OUTPUT)/$(OUTPUT_FILE) $(INPUT_FILE)
	@sed -ie 's/\\cite[t,p]{/\\cite{/g' $(OUTPUT)/$(OUTPUT_FILE)
	@sed -ie 's/{natbib}/{cite}/' $(OUTPUT)/$(OUTPUT_FILE)
	@pdflatex -aux-directory=$(OUTPUT) -output-directory=$(OUTPUT) $(OUTPUT)/$(OUTPUT_FILE)
	@bibtex $(OUTPUT)/main
	@pdflatex -aux-directory=$(OUTPUT) -output-directory=$(OUTPUT) $(OUTPUT)/$(OUTPUT_FILE)
	@pdflatex -aux-directory=$(OUTPUT) -output-directory=$(OUTPUT) $(OUTPUT)/$(OUTPUT_FILE)
	@rm $(REF_NAME)


tufte:
	@echo "Downloading biobliography file from Zotero..."
	@curl $(ZOTERO) --output $(OUTPUT)/$(REF_NAME) --silent
	@cp $(OUTPUT)/$(REF_NAME) $(REF_NAME)
	@echo "Running pandoc..."
	@pandoc --citeproc -s --natbib $(META_FOLDER)/$(META_YAML) --template=$(META_FOLDER)/tuftetemplate.tex -N \
	 -f markdown -t latex+raw_tex -o $(OUTPUT)/$(OUTPUT_FILE) $(INPUT_FILE)
	@sed -ie 's/\\cite[t,p]{/\\cite{/g' $(OUTPUT)/$(OUTPUT_FILE)
	@sed -ie 's/{natbib}/{cite}/' $(OUTPUT)/$(OUTPUT_FILE)
	@pdflatex -aux-directory=$(OUTPUT) -output-directory=$(OUTPUT) $(OUTPUT)/$(OUTPUT_FILE)
	@bibtex $(OUTPUT)/main
	@pdflatex -aux-directory=$(OUTPUT) -output-directory=$(OUTPUT) $(OUTPUT)/$(OUTPUT_FILE)
	@pdflatex -aux-directory=$(OUTPUT) -output-directory=$(OUTPUT) $(OUTPUT)/$(OUTPUT_FILE)
	@rm $(REF_NAME)

normal:
	@echo "Downloading biobliography file from Zotero..."
	@curl $(ZOTERO) --output $(OUTPUT)/$(REF_NAME) --silent
	@cp $(OUTPUT)/$(REF_NAME) $(REF_NAME)
	@echo "Running pandoc..."
	@pandoc --citeproc --bibliography=$(REF_NAME) -s --natbib $(META_FOLDER)/$(META_YAML) -N \
	 -f markdown -t latex+raw_tex -o $(OUTPUT)/$(OUTPUT_FILE) $(INPUT_FILE)
	@sed -ie 's/\\cite[t,p]{/\\cite{/g' $(OUTPUT)/$(OUTPUT_FILE)
	@sed -ie 's/{natbib}/{cite}/' $(OUTPUT)/$(OUTPUT_FILE)
	@pdflatex -aux-directory=$(OUTPUT) -output-directory=$(OUTPUT) $(OUTPUT)/$(OUTPUT_FILE)
	@bibtex $(OUTPUT)/main
	@pdflatex -aux-directory=$(OUTPUT) -output-directory=$(OUTPUT) $(OUTPUT)/$(OUTPUT_FILE)
	@pdflatex -aux-directory=$(OUTPUT) -output-directory=$(OUTPUT) $(OUTPUT)/$(OUTPUT_FILE)
	@rm $(REF_NAME)
