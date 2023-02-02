#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#include <thrust/device_vector.h>
#include <thrust/inner_product.h>

#define N_ROUND 100

#define CHECK(cond, errmsg) \
  if (!(cond)) { \
    fprintf(stderr, "(%s:%d) %s\n", __FILE__, __LINE__, errmsg); \
    exit(1); \
  }

double dot_product(long n, double *x, double *y) {
  thrust::device_vector<double> d_x(x, x + n);
  thrust::device_vector<double> d_y(y, y + n);
  return thrust::inner_product(d_x.begin(), d_x.end(), d_y.begin(), 0.0);
}

long get_elapsed_useconds(struct timeval start, struct timeval stop) {
  return (stop.tv_sec - start.tv_sec) * 1000000 + stop.tv_usec - start.tv_usec;
}

int main() {
  long n_elems, n_ranks;
  double *arr_x, *arr_y;

  // Read data from file
  FILE *f = fopen("input.0.bin", "r");
  CHECK(f != NULL, "Failed to open file.");

  CHECK(fread(&n_elems, sizeof(n_elems), 1, f) != sizeof(n_elems), "Failed to read n_elems.");
  CHECK(fread(&n_ranks, sizeof(n_ranks), 1, f) != sizeof(n_ranks), "Failed to read n_ranks.");
  CHECK(n_ranks == 1, "Input file is partitioned. This program cannot process partitioned input.");

  size_t arr_size = sizeof(double) * n_elems;
  arr_x = (double*)malloc(arr_size); // Dynamically allocate memory
  arr_y = (double*)malloc(arr_size);
  CHECK(fread(arr_x, arr_size, 1, f) != arr_size, "Failed to read array X.");
  CHECK(fread(arr_y, arr_size, 1, f) != arr_size, "Failed to read array Y.");

  // Compute
  long elapsed_time = 0;
  double res;
  for (int i = 1; i <= N_ROUND; i++) {
    struct timeval start, stop;
    gettimeofday(&start, NULL);
    res = dot_product(n_elems, arr_x, arr_y); // Compute Kernel
    gettimeofday(&stop, NULL);
    elapsed_time += get_elapsed_useconds(start, stop);
    printf("Round: %d, Result: %lf, Average Elapsed Time: %ldus\n", i, res, elapsed_time / i);
  }
  
  printf("\n\nResult: %lf, Average Elapsed Time: %ldus\n", res, elapsed_time / N_ROUND);

  // Finalize & Clean up
  fclose(f);
  free(arr_x);
  free(arr_y);
  return 0;
}