# 1 "src/pipeline/compute.c"
# 1 "<built-in>" 1
# 1 "<built-in>" 3
# 361 "<built-in>" 3
# 1 "<command line>" 1
# 1 "<built-in>" 2
# 1 "src/pipeline/compute.c" 2
# 1 "src/pipeline/constants.h" 1



int factorial_ref(int n);
# 2 "src/pipeline/compute.c" 2
int factorial_ref(int n) {
    if (n < 0 || n > 12) return -1;
    int product = 1;
    for (int i = 2; i <= n; ++i) product *= i;
    return product;
}
