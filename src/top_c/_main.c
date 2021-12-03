/* --- Generated the 3/12/2021 at 18:13 --- */
/* --- heptagon compiler, version 1.05.00 (compiled sat. nov. 27 22:35:24 CET 2021) --- */
/* --- Command line: /usr/local/bin/heptc -target c -s main top.lus --- */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "_main.h"

Top__main_mem mem;
int main(int argc, char** argv) {
  int step_c;
  int step_max;
  Top__main_out _res;
  step_c = 0;
  step_max = 0;
  if ((argc==2)) {
    step_max = atoi(argv[1]);
  };
  Top__main_reset(&mem);
  while ((!(step_max)||(step_c<step_max))) {
    step_c = (step_c+1);
    Top__main_step(&_res, &mem);
    printf("=> ");
    printf("%d ", _res.o);
    puts("");
    fflush(stdout);
  };
  return 0;
}

