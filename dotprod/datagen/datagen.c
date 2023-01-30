#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#define CHECK(cond, errmsg) \
  if (!(cond)) { \
    fprintf(stderr, "(%s:%d) %s\n", __FILE__, __LINE__, errmsg); \
    exit(1); \
  }

unsigned int random_seed = 0; // Set to a non-zero value to fix random seed

void generate_array(FILE *f, long n_elems_per_rank) {
  double *array = (double*)malloc(sizeof(double) * n_elems_per_rank);
  for (long i = 0; i < n_elems_per_rank; i++) {
    array[i] = (double)rand() / (double)(RAND_MAX) * 2.0 - 1.0; // Range of random values: [-1, 1]
  }
  fwrite(array, sizeof(double) * n_elems_per_rank, 1, f);
  free(array);
}

int main() {
  srand(random_seed == 0 ? time(NULL) : random_seed);

  long n_elems, n_ranks;
  printf("Input number of elements and partitions to generate (e.g. 10 2)\n");
  CHECK(scanf("%ld %ld", &n_elems, &n_ranks) == 2, "Invalid inputs.");
  CHECK(n_elems % n_ranks == 0, "Number of elements should be multiple of number of partitions.");

  long n_elems_per_rank = n_elems / n_ranks;

  for (long i = 0; i < n_ranks; i++) {
    char f_name[1024];
    sprintf(f_name, "input.%ld.bin", i);

    FILE *f = fopen(f_name, "wb"); // Output is a binary file (not a readable string)
    CHECK(f != NULL, "Failed to create file.");

    fwrite(&n_elems_per_rank, sizeof(n_elems_per_rank), 1, f); // Write n_elems to file
    fwrite(&n_ranks, sizeof(n_ranks), 1, f);

    generate_array(f, n_elems_per_rank); // Write array X
    generate_array(f, n_elems_per_rank); // Write array Y

    fclose(f);
  }

  return 0;
}