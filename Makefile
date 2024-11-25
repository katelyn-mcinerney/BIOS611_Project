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
	
data/derived_data/tree_data_cleaned.csv: scripts/clean_data.R data/source_data/2015_Street_Tree_census_-_Tree_Data_20241009.csv
	Rscript scripts/clean_data.R

report.Rmd:

report.html: report.Rmd
	R -e "Sys.setenv(RSTUDIO_PANDOC=dirname(Sys.getenv('RSTUDIO_PANDOC'))); rmarkdown::render('report.Rmd', output_format = 'html_document', output_dir = '.')"