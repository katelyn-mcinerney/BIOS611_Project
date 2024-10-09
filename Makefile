.PHONY: clean
.PHONY: init

init:
	mkdir -p data/derived_data
	mkdir -p figures

clean:
	rm report.html
	rm -rf data/derived_data
	rm -rf figures
	mkdir -p data/derived_data
	mkdir -p figures
	
report.Rmd:

report.html: report.Rmd
	R -e "Sys.setenv(RSTUDIO_PANDOC=dirname(Sys.getenv('RSTUDIO_PANDOC'))); rmarkdown::render('report.Rmd', output_format = 'html_document', output_dir = '.')"