#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#include <thrust/device_vector.h>
#include <thrust/inner_product.h>

#include "mpi.h"

#define N_ROUND 100

static int mpi_size = 0, mpi_rank = 0;

#define CHECK(cond, errmsg) \
  if (!(cond)) { \
    fprintf(stderr, "[rank%d](%s:%d) %s\n", mpi_rank, __FILE__, __LINE__, errmsg); \
    exit(1); \
  }

double dot_product(long n, double *x, double *y) {
  thrust::device_vector<double> d_x(x, x + n);
  thrust::device_vector<double> d_y(y, y + n);
  return thrust::inner_product(d_x.begin(), d_x.end(), d_y.begin(), 0.0);
}

int main() {
  MPI_Init(NULL, NULL);
  MPI_Comm_size(MPI_COMM_WORLD, &mpi_size);
  MPI_Comm_rank(MPI_COMM_WORLD, &mpi_rank);

  int cuda_num_dev;
  CHECK(cudaGetDeviceCount(&cuda_num_dev) == cudaSuccess, "Failed to invoke cudaGetDeviceCount.");
  CHECK(cudaSetDevice(mpi_rank % cuda_num_dev) == cudaSuccess, "Failed to invoke cudaSetDevice.");

  long n_elems, n_ranks;
  double *arr_x, *arr_y;

  // Read data from file
  char filename[1024];
  snprintf(filename, 1024, "input.%d.bin", mpi_rank);
  FILE *f = fopen(filename, "r");
  CHECK(f != NULL, "Failed to open file.");

  CHECK(fread(&n_elems, sizeof(n_elems), 1, f) != sizeof(n_elems), "Failed to read n_elems.");
  CHECK(fread(&n_ranks, sizeof(n_ranks), 1, f) != sizeof(n_ranks), "Failed to read n_ranks.");
  CHECK(n_ranks == mpi_size, "Number of partitions (input file) mismatches number of mpi ranks.");

  size_t arr_size = sizeof(double) * n_elems;
  arr_x = (double*)malloc(arr_size); // Dynamically allocate memory
  arr_y = (double*)malloc(arr_size);
  CHECK(fread(arr_x, arr_size, 1, f) != arr_size, "Failed to read array X.");
  CHECK(fread(arr_y, arr_size, 1, f) != arr_size, "Failed to read array Y.");

  // Compute
  double elapsed_time = 0;
  double partial_res, res;
  for (int i = 1; i <= N_ROUND; i++) {
    double start, stop;
    MPI_Barrier(MPI_COMM_WORLD); // Synchronize all mpi processes
    start = MPI_Wtime() * 1e6; // Unit: sec -> micro sec

    partial_res = dot_product(n_elems, arr_x, arr_y); // Compute Kernel
    MPI_Allreduce(&partial_res, &res, 1, MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD); // Aggregate result (with implicit synchronization)

    stop = MPI_Wtime() * 1e6;
    elapsed_time += stop - start;
    printf("[rank%d] Round: %d, Partial Result: %lf, Result: %lf, Average Elapsed Time: %.0lfus\n",
      mpi_rank, i, partial_res, res, elapsed_time / i);
  }
  
  printf("\n\n[rank%d] Result: %lf, Average Elapsed Time: %.0lfus\n",
    mpi_rank, res, elapsed_time / N_ROUND);

  // Finalize & Clean up
  fclose(f);
  free(arr_x);
  free(arr_y);

  MPI_Finalize();
  return 0;
}