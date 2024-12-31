SRC = main.s
OBJ = main.o
OUT = out

DIR_BUILD = build

all: $(OUT)
build: $(OUT)

$(DIR_BUILD)/$(OBJ): $(SRC)
	@mkdir -p build
	nasm -f elf64 -o $(DIR_BUILD)/$(OBJ) $(SRC)

$(OUT): $(DIR_BUILD)/$(OBJ)
	ld -o $(OUT) $(DIR_BUILD)/$(OBJ)

clean:
	rm -rdf $(DIR_BUILD)
	rm -f $(OUT)

.PHONY: all clean
