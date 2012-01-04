#include <stdio.h>
#include <stdlib.h>

int main(void) {

	unsigned int i;

	for (i = 0 ; i < 1024 ; ++i)
		printf("%d\n", i % 256);

	return EXIT_SUCCESS;
}
