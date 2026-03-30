#include <stdio.h>

int main(void)
{
    char buffer[32];

    printf("Enter some text:\n");
    gets(buffer);  /* unsafe: no length check */

    printf("You entered: %s\n", buffer);
    return 0;
}
