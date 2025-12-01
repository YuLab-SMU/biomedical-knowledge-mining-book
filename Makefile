book:
	quarto render
	# Rscript -e 'quarto::quarto_render()'

fresh:
	quarto render --cache-refresh 

nocache:
	quarto render example.qmd --no-cache 	


pdfbook:
	quarto render --to pdf

sync:
	# mv -f docs/* gh-pages/;\
	rsync -av --remove-source-files docs/ gh-pages/ ;\

publish: sync
	cd gh-pages;\
	git add .;\
	git commit -m 'update';\
	git push -u origin gh-pages
	
