SRC = main.s
OBJ = main.o
OUT = out

DIR_BUILD = build
DIR_BIN = bin

all: $(DIR_BIN)/$(OUT)

$(DIR_BUILD)/$(OBJ): $(SRC) $(DIR_BUILD)
	nasm -f elf64 -o $(DIR_BUILD)/$(OBJ) $(SRC)

$(DIR_BIN)/$(OUT): $(DIR_BUILD)/$(OBJ) $(DIR_BIN)
	ld -o $(DIR_BIN)/$(OUT) $(DIR_BUILD)/$(OBJ)

$(DIR_BUILD):
	mkdir $(DIR_BUILD)

$(DIR_BIN):
	mkdir $(DIR_BIN)

clean:
	rm -rdf $(DIR_BUILD) $(DIR_BIN)

.PHONY: all clean
