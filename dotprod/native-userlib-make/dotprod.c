#include "dotprod.h"

double dot_product(long n, double *x, double *y) {
  double res = 0.0;
  for (long i = 0; i < n; i++) {
    res += x[i] * y[i];
  }
  return res;
}