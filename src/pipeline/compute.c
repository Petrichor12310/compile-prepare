#include "constants.h"
int factorial_ref(int n) {
    if (n < 0 || n > FACTORIAL_LIMIT) return -1;
    int product = 1;
    for (int i = 2; i <= n; ++i) product *= i;
    return product;
}
