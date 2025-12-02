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
	# rsync -av --remove-source-files docs/ gh-pages/ ;\
	cd gh-pages;\
	find . -maxdepth 1 ! -name "CNAME" ! -name ".gitignore" ! -name ".git" ! -name . |xargs rm -r ;\
	mv -f ../docs/* ./

publish: sync
	cd gh-pages;\
	git add .;\
	git commit -m 'update';\
	git push -u origin gh-pages
	
