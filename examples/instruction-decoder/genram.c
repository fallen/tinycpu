#include <stdio.h>
#include <stdlib.h>

int main(void) {

	unsigned int i;

	printf("11820\n"); /* add $2,$0,$1 */

	for (i = 1 ; i < 1024 ; ++i)
		printf("%d\n", i % 1024);

	return EXIT_SUCCESS;
}
