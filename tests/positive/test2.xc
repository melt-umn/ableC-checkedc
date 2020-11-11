#include <stdlib.h>
#include <stdio.h>

int main(void)
{
    int x = 3;
    ptr<int> x2 = &x;
    printf("pointer dereferenced: %i\n", *x2);
    return 0;
}
