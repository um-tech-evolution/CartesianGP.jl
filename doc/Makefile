# Shamelessly stolen from https://gist.github.com/sudarkoff/3956724

BUILD_DIR := _build

# pandoc is a handy tool for converting between numerous text formats:
# http://johnmacfarlane.net/pandoc/installing.html
PANDOC := pandoc

# pandoc options
# Liberation fonts: http://en.wikipedia.org/wiki/Liberation_fonts
PANDOC_PDF_OPTS := --toc --chapters --base-header-level=1 --number-sections --variable mainfont="Liberation Serif" --variable sansfont="Liberation Sans" --variable monofont="Liberation Mono" --variable fontsize=12pt --variable documentclass=book

MARKDOWN := $(wildcard *.md)
PDF := $(patsubst %.md,$(BUILD_DIR)/pdf/%.pdf,$(MARKDOWN))
DOCX := $(patsubst %.md,$(BUILD_DIR)/docx/%.docx,$(MARKDOWN))
HTML := $(patsubst %.md,$(BUILD_DIR)/html/%.html,$(MARKDOWN))

.PHONY: all checkdirs pdf doc html clean

all: checkdirs pdf docx html

checkdirs: $(BUILD_DIR)

pdf: checkdirs pdfdir $(PDF)

docx: checkdirs docxdir $(DOCX)

html: checkdirs htmldir $(HTML)

$(BUILD_DIR):
	@mkdir -p $@

pdfdir:
	@mkdir -p $(BUILD_DIR)/pdf

docxdir:
	@mkdir -p $(BUILD_DIR)/docx

htmldir:
	@mkdir -p $(BUILD_DIR)/html

# generate PDF
$(BUILD_DIR)/pdf/%.pdf: %.md
	$(PANDOC) $(PANDOC_PDF_OPTS) --self-contained -o $@ $<

# generate Microsoft Word documents (.docx)
$(BUILD_DIR)/docx/%.docx: %.md
	$(PANDOC) --self-contained -o $@ $<

# generate HTML files
$(BUILD_DIR)/html/%.html: %.md
	$(PANDOC) --self-contained -o $@ $<

clean:
	@rm -rf $(BUILD_DIR)
