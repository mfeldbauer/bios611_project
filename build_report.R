options(tinytex.tlmgr.path = '/opt/tinytex/bin/x86_64-linux/tlmgr');
rmarkdown::render('report.Rmd',output_format='pdf_document')

