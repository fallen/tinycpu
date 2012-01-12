#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/stat.h>

int ram0, ram1, ram2, ram3;
unsigned int max_temp = 1024;

void write_to_ram(const char *op) {
	write(ram3, op, sizeof(const char)*2);
	write(ram3, "\n", sizeof(char));

	write(ram2, op + sizeof(const char) * 2, sizeof(const char)*2);
	write(ram2, "\n", sizeof(char));

	write(ram1, op + sizeof(const char) * 4, sizeof(const char)*2);
	write(ram1, "\n", sizeof(char));

	write(ram0, op + sizeof(const char) * 6, sizeof(const char)*2);
	write(ram0, "\n", sizeof(char));
	max_temp--;
}

int main(void) {

	unsigned int i = 0;
	unsigned int max;
	mode_t mode = S_IWGRP | S_IWOTH;
	umask(mode);

	ram0 = open("ram0.data", O_WRONLY | O_CREAT);
	ram1 = open("ram1.data", O_WRONLY | O_CREAT);
	ram2 = open("ram2.data", O_WRONLY | O_CREAT);
	ram3 = open("ram3.data", O_WRONLY | O_CREAT);

	write_to_ram("00430820");
	write_to_ram("00431020");
	write_to_ram("00221820");
	write_to_ram("8C050014");
	write_to_ram("AAAAAAAA");
	write_to_ram("BBBBBBBB");

	max = max_temp;
	for (i = 0 ; i < max ; ++i)
		write_to_ram("00000000");

	close(ram0);
	close(ram1);
	close(ram2);
	close(ram3);

	return EXIT_SUCCESS;
}
