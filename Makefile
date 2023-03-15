analysis: wac2wav file-conversion

file-conversion: data/generated/filenames_wac.csv
	Rscript src/0-get-files.R $(DIR)
	Rscript src/01-convert-files.R

wac2wav: includes/wac2wav/wac2wav.c
	gcc -o src/functions/wac2wav includes/wac2wav/wac2wav.c

.FORCE:
	
