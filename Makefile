analysis: wac2wav file-conversion

file-conversion:
	Rscript src/0-get-files.R $(DIR)
	Rscript src/01-convert-files.R

wac2wav: includes/wac2wav/wac2wav.c
	gcc -o src/functions/wac2wav includes/wac2wav/wac2wav.c

clean-all: clean-wav clean-wac
	rm src/functions/wac2wav

clean-wav:
	rm data/generated/filenames_wav.csv

clean-wac:
	rm data/generated/filenames_wac.csv

.FORCE:
	
