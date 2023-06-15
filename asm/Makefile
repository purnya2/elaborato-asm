AS_FLAGS = --march=i386 --32
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin

SRCS = $(SRC_DIR)/main.s $(SRC_DIR)/onoffmenu.s $(SRC_DIR)/clear.s $(SRC_DIR)/freccedirezione.s $(SRC_DIR)/pressionegomme.s

OBJS = $(patsubst $(SRC_DIR)/%.s, $(OBJ_DIR)/%.o, $(SRCS))

TARGET = $(BIN_DIR)/cruscotto


all: $(TARGET)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s
	as $(AS_FLAGS) $(DEBUG) -o $@ $<

$(TARGET): $(OBJS)
	ld $(LD_FLAGS) -o $@ $^

clean:
	rm -f obj/*.o bin/cruscotto