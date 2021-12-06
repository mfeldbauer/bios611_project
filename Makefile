.PHONY: clean
.PHONY: shiny_app
.PHONY: shiny_heatmap

clean:
	rm -rf derived_data
	rm -rf figures
	rm -f report.pdf

report.pdf:\
figures/highly_exp_and_variable_genes_large_dataset.pdf \
figures/large_set_pam50genes_heatmap.pdf \
figures/pca_plot_high_exp_and_var.pdf \
figures/multiplot_five_pcs.pdf \
figures/km_plot_overall_survival.pdf \
figures/km_plot_overall_recur.pdf \
build_report.R
	Rscript build_report.R

#Larger dataset
figures/km_plot_overall_survival.pdf figures/km_plot_overall_recur.pdf &:\
source_data/clinical_patient_info.txt \
derived_data/highly_exp_and_mut_genes_matrix_from_large_set.csv \ 
survival_plots.R
	mkdir -p figures
	Rscript survival_plots.R

figures/pca_plot_high_exp_and_var.pdf figures/multiplot_five_pcs.pdf &:\
derived_data/highly_exp_and_mut_genes_matrix_from_large_set.csv \
source_data/clinical_patient_info.txt \
pca_highly_exp_and_var.R
	mkdir -p figures
	Rscript pca_highly_exp_and_var.R

figures/large_set_highly_var_and_exp_heatmap.pdf: source_data/clinical_patient_info.txt \
source_data/clinical_sample_info.txt \
derived_data/highly_exp_and_mut_genes_matrix_from_large_set.csv \
large_dataset_heatmap.R
	mkdir -p figures
	Rscript large_dataset_heatmap.R

figures/highly_exp_and_variable_genes_large_dataset.pdf: source_data/data_mrna_expression.txt \
prepare_large_dataset.R
	mkdir -p figures
	Rscript prepare_large_dataset.R

derived_data/highly_exp_and_mut_genes_matrix_from_large_set.csv:\
source_data/data_mrna_expression.txt \
source_data/pam50_genes.csv \
prepare_large_dataset.R
	mkdir -p figures
	mkdir -p derived_data
	Rscript prepare_large_dataset.R

#Download the large dataset from cbioportal
source_data/data_mrna_expression.txt: 
	./obtain_large_dataset.sh


#Initial dataset
shiny_heatmap: derived_data/patient_and_clinical_data.csv \
derived_data/expression_data.csv \
expression_heatmap_interactive.R
	Rscript expression_heatmap_interactive.R

shiny_app: derived_data/patient_and_clinical_data.csv \
interactive_plots.R
	Rscript interactive_plots.R

figures/mrna_expression_heatmap_most_mutated_genes.png: derived_data/expression_data.csv \
derived_data/patient_and_clinical_data.csv \
derived_data/mutation_data.csv \
heatmap_most_mutated_genes.R
	mkdir -p figures
	Rscript heatmap_most_mutated_genes.R

derived_data/patient_and_clinical_data.csv \
derived_data/expression_data.csv \
derived_data/mutation_data.csv &:\
source_data/METABRIC_RNA_Mutation.csv \
separate_data.R
	mkdir -p derived_data
	Rscript separate_data.R
