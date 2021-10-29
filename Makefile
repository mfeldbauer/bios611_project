PHONY: clean
#PHONY: shiny_heatmap

clean:
	rm -f derived_data/*
	rm -f figures/*

#shiny_heatmap: derived_data/patient_and_clinical_data.csv derived_data/expression_data.csv expression_heatmap.R
#	Rscript expression_heatmap.R

derived_data/patient_and_clinical_data.csv: source_data/METABRIC_RNA_Mutation.csv separate_data.R
	mkdir -p derived_data
	Rscript separate_data.R

derived_data/expression_data.csv: source_data/METABRIC_RNA_Mutation.csv separate_data.R
	mkdir -p derived_data
	Rscript separate_data.R

derived_data/mutation_data.csv: source_data/METABRIC_RNA_Mutation.csv separate_data.R
	mkdir -p derived_data
	Rscript separate_data.R
