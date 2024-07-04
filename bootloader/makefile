all: bootstarch

CC = nasm

NAME = bootstarch.bin

FLAGS = -f bin

OBJECTS = 

SRC_FILE = bootstarch.asm

bootstarch: bootstarch.asm
	$(CC) $(FLAGS) $(SRC_FILE) -o $(NAME) && ./start.sh


