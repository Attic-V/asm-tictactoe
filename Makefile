ROOT := $(notdir $(abspath $(dir $(lastword $(MAKEFILE_LIST)))))

.PHONY: all clean docker

SRC_DIR := src
SRC_DIR_SRCS := $(wildcard $(SRC_DIR)/*.s)

BUILD_DIR := build
BUILD_DIR_OBJS := $(patsubst $(SRC_DIR)/%.s,$(BUILD_DIR)/%.o,$(SRC_DIR_SRCS))

BIN_DIR := bin

OUT := out
TARGET := $(BIN_DIR)/$(OUT)

all: $(TARGET)

$(TARGET): $(BUILD_DIR_OBJS) | $(BIN_DIR)
	@echo "LD $@"
	@ld -o $@ $^

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s | $(BUILD_DIR)
	@echo "AS $<"
	@nasm -f elf64 -o $@ $<

$(BIN_DIR) $(BUILD_DIR):
	@mkdir -p $@

clean:
	@$(RM) -r $(BUILD_DIR) $(BIN_DIR)

DOCKER_TAG := $(ROOT)

docker:
	docker build -t $(DOCKER_TAG) .
	docker run --rm -it $(DOCKER_TAG)
