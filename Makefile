DIR="../../../../media/bedwards144/phd-data/aru-data/"

analysis: wac2wav file-conversion

file-conversion: get-files convert-files

get-files:
	Rscript src/0-get-files.R $(DIR)

convert-files:
	Rscript src/01-convert-files.R

wac2wav: includes/wac2wav/wac2wav.c
	gcc -o src/functions/wac2wav.exe includes/wac2wav/wac2wav.c

clean-all: clean-exe clean-wac clean-wav

clean-exe:
	rm src/functions/wac2wav.exe

clean-wav:
	rm data/generated/filenames_wav.csv

clean-wac:
	rm data/generated/filenames_wac.csv

.FORCE:
	
