#include <stdlib.h>
#include <stdio.h>

int main(void)
{
    int x = 3;
    int y = 4;
    ptr<int> x2 = &x;
    ptr<int> y2 = &y;
    x2 = &y;
    printf("x2 deref:%d\n", *x2);
    return 0;
}
