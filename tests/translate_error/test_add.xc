#include <stdlib.h>
#include <stdio.h>

int main(void)
{
    int x = 0;
    ptr<int> x2 = &x;
    //Should fail, because arithmetic on checked pointers is not allowed
    return x2 + 2;
}
