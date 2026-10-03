#include "sylib.h"
#include "constants.h"
int main(void) {
    int n = getint();
    putint(factorial_ref(n));
    putch(10);
    return 0;
}
