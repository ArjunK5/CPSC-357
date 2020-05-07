#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>


#define LOWER_LIMIT  -95
#define UPPER_LIMIT  +95
#define INCREMENT    5
#define FILENAME     "input.bin"


int main()
{
  int value;
  int fd;
  double temp;

  /*  Open a file for writing  */
  fd = creat(FILENAME, 0666);

  /*  Error check file creation  */
  if (fd < 0) {
    fprintf(stderr, "Can't open file for writing.  Aborting.\n");
    exit(-1);
  }

  /*  Write negative double values to file  */
  for (value = LOWER_LIMIT; value <= UPPER_LIMIT; value += INCREMENT) {
    /*  Divide value by 100.0  */
    temp = (double)value / 100.0;
    
    /*  Write out a double to file  */
    int n_written = write(fd, (char *)&temp, sizeof(double));

    /*  Error check the write  */
    if (n_written != sizeof(double)) {
      fprintf(stderr, "Error writing file.  Aborting.\n");
      close(fd);
      exit(-1);
    }
  }

  /*  Close binary file  */
  close(fd);

  return 0;
}

  
