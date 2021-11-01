.PHONY: clean
.PHONY: shiny_app
.PHONY: shiny_heatmap

clean:
	rm -rf derived_data
	rm -rf figures

shiny_heatmap: derived_data/patient_and_clinical_data.csv derived_data/expression_data.csv expression_heatmap_interactive.R
	Rscript expression_heatmap_interactive.R

shiny_app: derived_data/patient_and_clinical_data.csv interactive_plots.R
	Rscript interactive_plots.R

figures/mrna_expression_heatmap_most_mutated_genes.png: derived_data/expression_data.csv derived_data/patient_and_clinical_data.csv derived_data/mutation_data.csv heatmap_most_mutated_genes.R
	mkdir -p figures
	Rscript heatmap_most_mutated_genes.R

derived_data/patient_and_clinical_data.csv: source_data/METABRIC_RNA_Mutation.csv separate_data.R
	mkdir -p derived_data
	Rscript separate_data.R

derived_data/expression_data.csv: source_data/METABRIC_RNA_Mutation.csv separate_data.R
	mkdir -p derived_data
	Rscript separate_data.R

derived_data/mutation_data.csv: source_data/METABRIC_RNA_Mutation.csv separate_data.R
	mkdir -p derived_data
	Rscript separate_data.R
