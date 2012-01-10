#include <stdio.h>
#include <stdlib.h>

int main(void) {

	unsigned int i;

	printf("00430820\n");
	printf("00431020\n");
	printf("00221820\n");
	printf("8C050014\n");

	for (i = 4 ; i < 1024 ; ++i)
		printf("%08X\n", i % 1024);

	return EXIT_SUCCESS;
}
