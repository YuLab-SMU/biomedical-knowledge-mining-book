book:
	quarto render
	# Rscript -e 'quarto::quarto_render()'

fresh:
	quarto render --cache-refresh 

nocache:
	quarto render example.qmd --no-cache 	


pdfbook:
	quarto render --to pdf

publish:
	cd gh-pages;\
	git add .;\
	git commit -m 'update';\
	git push -u origin gh-pages
	
