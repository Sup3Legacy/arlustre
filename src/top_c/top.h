/* --- Generated the 3/12/2021 at 18:13 --- */
/* --- heptagon compiler, version 1.05.00 (compiled sat. nov. 27 22:35:24 CET 2021) --- */
/* --- Command line: /usr/local/bin/heptc -target c -s main top.lus --- */

#ifndef TOP_H
#define TOP_H

#include "top_types.h"
#include "interface.h"
typedef struct Top__count_true_mem {
  int v;
} Top__count_true_mem;

typedef struct Top__count_true_out {
  int y;
} Top__count_true_out;

void Top__count_true_reset(Top__count_true_mem* self);

void Top__count_true_step(Top__count_true_out* _out,
                          Top__count_true_mem* self);

typedef struct Top__led_mem {
  int v_12;
  int v_10;
  int v_7;
  int v_5;
  int v_3;
  int v_2;
  Top__count_true_mem count_true;
} Top__led_mem;

typedef struct Top__led_out {
  int out;
} Top__led_out;

void Top__led_reset(Top__led_mem* self);

void Top__led_step(int period, int pin, Top__led_out* _out,
                   Top__led_mem* self);

typedef struct Top__main_mem {
  Top__led_mem led;
  Top__led_mem led_1;
} Top__main_mem;

typedef struct Top__main_out {
  int o;
} Top__main_out;

void Top__main_reset(Top__main_mem* self);

void Top__main_step(Top__main_out* _out, Top__main_mem* self);

#endif // TOP_H
