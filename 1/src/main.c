#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {
  FILE* file = NULL;
  char* line = NULL;
  size_t len = 0;
  size_t read = 0;
  unsigned int sum = 0;
  unsigned int max = 0;
  
  if (argc != 2) {
    fprintf(stderr, "Expected one argument, for file path\n");
    return EXIT_FAILURE;
  }

  file = fopen(argv[1], "r");

  if (!file) {
    fprintf(stderr, "Unable to open file\n");
    return EXIT_FAILURE;
  }

  while ((read = getline(&line, &len, file)) != -1) {
    if (line[read - 1] == '\n') {
       line[read - 1] = '\0';
    }

    if (read > 1) {
      sum += atoi(line);
    } else {
      if (sum > max) {
        max = sum;
      }

      sum = 0;
    }
  }

  printf("Max: %d\n", max);
  free(line);
  fclose(file);
  return EXIT_SUCCESS;
}

