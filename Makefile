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
	
figures/tree_diameter_by_borough_histogram.png \
figures/tree_diameter_by_health_histogram.png: scripts/plot_tree_size_histogram.R data/derived_data/tree_data_cleaned.csv
	Rscript scripts/plot_tree_size_histogram.R
	
figures/tree_health_by_borough_barchart.png: scripts/plot_tree_health_by_borough_barchart.R data/derived_data/tree_data_cleaned.csv
	Rscript scripts/plot_tree_health_by_borough_barchart.R

figures/basic_tree_map.png: scripts/plot_basic_tree_map.R data/source_data/2015_Street_Tree_Census_Map_Data/geo_export_1007bd46-3e59-4990-bf97-4001ac2aacf6.shp \
														data/source_data/Borough_Boundaries_Map_Data/geo_export_a58cd0c5-58c7-4f7f-9338-5d9569be528d.shp
	Rscript scripts/plot_basic_tree_map.R
	
figures/tree_density_by_neighborhood_map.png: scripts/plot_tree_density_by_neighborhood_map.R data/derived_data/tree_data_cleaned.csv \
																									 data/source_data/2010_Neighborhood_Tabulation_Areas_Map_Data/geo_export_aef8b682-921e-4e21-9e8c-586c62434166.shp
	Rscript scripts/plot_tree_density_by_neighborhood_map.R

figures/top_borough_species_barchart.png: scripts/plot_top_borough_species_barchart.R data/derived_data/tree_data_cleaned.csv
	Rscript scripts/plot_top_borough_species_barchart.R
	
figures/ADABOOST_model_accuracy.png \
figures/ADABOOST_model_kappa.png \
figures/ADABOOST_var_importance.png \
figures/pca_tree_data.png \
figures/ADABOOST_model_confusion.txt \
figures/ADABOOST_model.txt: scripts/tree_health_by_problems.R data/derived_data/tree_data_cleaned.csv
	Rscript scripts/tree_health_by_problems.R

report.Rmd: figures/tree_diameter_by_borough_histogram.png figures/tree_diameter_by_health_histogram.png \
						figures/tree_health_by_borough_barchart.png figures/basic_tree_map.png figures/tree_density_by_neighborhood_map.png \
						figures/top_borough_species_barchart.png figures/ADABOOST_model_accuracy.png \
						figures/ADABOOST_model_kappa.png figures/ADABOOST_var_importance.png \
						figures/pca_tree_data.png figures/ADABOOST_model_confusion.txt figures/ADABOOST_model.txt
	touch report.Rmd

report.html: report.Rmd
	#R -e "Sys.setenv(RSTUDIO_PANDOC=dirname(Sys.getenv('RSTUDIO_PANDOC'))); rmarkdown::render('report.Rmd', output_format = 'html_document', output_dir = '.')"
	R -e "rmarkdown::render('report.Rmd')"
	