PHONY: clean

clean:
	rm derived_data/*

derived_data/patient_and_clinical_data.csv: source_data/METABRIC_RNA_Mutation.csv separate_data.R
	Rscript separate_data.R

derived_data/expression_data.csv: source_data/METABRIC_RNA_Mutation.csv separate_data.R
	Rscript separate_data.R

derived_data/mutation_data.csv: source_data/METABRIC_RNA_Mutation.csv separate_data.R
	Rscript separate_data.R
