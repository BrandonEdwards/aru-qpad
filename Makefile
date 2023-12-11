OBJ = obj/main.o
DIR="/home/brandon/Documents/chapter-3/aru-qpad/data/raw/aru"
CORES=15
CC = gcc

all: localize

localize: $(OBJ)
	$(CC) $(OBJ) -o localize

obj/main.o: src/main.c
	$(CC) -c -o obj/main.o src/main.c








analysis: wac2wav file-conversion

file-conversion: get-files convert-files

get-files:
	Rscript src/0-get-files.R $(DIR)

convert-files:
	Rscript src/01-convert-files.R

spectrograms: data/generated/filenames_wav.csv data/generated/tags.csv
	Rscript src/03-generate-spectrograms.R $(CORES)

wac2wav: includes/wac2wav/wac2wav.c
	gcc -o src/functions/wac2wav.exe includes/wac2wav/wac2wav.c

clean-all: clean-exe clean-wac clean-wav

clean-exe:
	rm src/functions/wac2wav.exe

clean-wav:
	rm data/generated/filenames_wav.csv

clean-wac:
	rm data/generated/filenames_wac.csv

aru-data:
	sudo mount $(DIR)

.FORCE:
	
