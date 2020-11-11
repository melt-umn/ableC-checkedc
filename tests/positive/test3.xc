#include <stdlib.h>
#include <stdio.h>

int main(void)
{
    int x = 3;
    int y = 4;
    ptr<int> x2 = &x;
    ptr<int> y2 = &y;
    ptr<int> x3 = &x;
    printf("two equivalent ptrs compare: %d\ntwo different ptrs compare: %d\n", (x2 == x3),(x2 == y2));
    return 0;
}
