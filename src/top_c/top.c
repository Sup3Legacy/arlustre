/* --- Generated the 3/12/2021 at 18:13 --- */
/* --- heptagon compiler, version 1.05.00 (compiled sat. nov. 27 22:35:24 CET 2021) --- */
/* --- Command line: /usr/local/bin/heptc -target c -s main top.lus --- */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "top.h"

void Top__count_true_reset(Top__count_true_mem* self) {
  self->v = 0;
}

void Top__count_true_step(Top__count_true_out* _out,
                          Top__count_true_mem* self) {
  _out->y = (self->v+1);
  self->v = _out->y;
}

void Top__led_reset(Top__led_mem* self) {
  Top__count_true_reset(&self->count_true);
  self->v_12 = false;
  self->v_10 = false;
  self->v_7 = true;
  self->v_2 = true;
}

void Top__led_step(int period, int pin, Top__led_out* _out,
                   Top__led_mem* self) {
  Interface__change_pin_state_out Interface__change_pin_state_out_st;
  Top__count_true_out Top__count_true_out_st;
  Interface__declare_io_out Interface__declare_io_out_st;
  
  int v_11;
  int v_9;
  int v_8;
  int v_6;
  int v_4;
  int v_1;
  int v;
  int i;
  int statee;
  int change;
  int s;
  v_11 = !(self->v_10);
  v_4 = !(self->v_3);
  Top__count_true_step(&Top__count_true_out_st, &self->count_true);
  v = Top__count_true_out_st.y;
  v_1 = (v%period);
  change = (v_1==0);
  if (change) {
    _out->out = v_11;
    v_6 = v_4;
  } else {
    _out->out = self->v_12;
    v_6 = self->v_5;
  };
  if (self->v_2) {
    statee = true;
  } else {
    statee = v_6;
  };
  Interface__change_pin_state_step(pin, statee,
                                   &Interface__change_pin_state_out_st);
  v_8 = Interface__change_pin_state_out_st.b;
  if (change) {
    v_9 = v_8;
  } else {
    v_9 = 0;
  };
  Interface__declare_io_step(pin, 1, &Interface__declare_io_out_st);
  s = Interface__declare_io_out_st.b;
  if (self->v_7) {
    i = s;
  } else {
    i = v_9;
  };
  self->v_12 = _out->out;
  self->v_10 = _out->out;
  self->v_7 = false;
  self->v_5 = statee;
  self->v_3 = statee;
  self->v_2 = false;;
}

void Top__main_reset(Top__main_mem* self) {
  Top__led_reset(&self->led_1);
  Top__led_reset(&self->led);
}

void Top__main_step(Top__main_out* _out, Top__main_mem* self) {
  Top__led_out Top__led_out_st;
  
  int i;
  Top__led_step(4, 3, &Top__led_out_st, &self->led_1);
  _out->o = Top__led_out_st.out;
  Top__led_step(3, 2, &Top__led_out_st, &self->led);
  i = Top__led_out_st.out;;
}

