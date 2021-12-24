const print = @import("std").debug.print;
const Interface = @import("interface.zig");

pub const Top__declare_once_mem = struct {
   v: bool,
 };
 
pub const Top__declare_once_out = struct {
  out: isize,
};

pub fn Top__declare_once_reset(self: *Top__declare_once_mem) void { 
 
  self.*.v = true; 
}

pub fn Top__declare_once_step(port: isize, direction: isize,
                              _out: *Top__declare_once_out,
                              self: *Top__declare_once_mem) void {
  var Interface__declare_io_out_st: Interface.declare_io_out = undefined; 
 
  Interface.declare_io_step(port, direction, self.*.v,
                            &Interface__declare_io_out_st);
  _out.*.out = Interface__declare_io_out_st.b;
  self.*.v = false; 
}

pub const Top__count_true_mem = struct {
  v: isize,
};

pub const Top__count_true_out = struct {
  y: isize,
};

pub fn Top__count_true_reset(self: *Top__count_true_mem) void { 
 
  self.*.v = 0; 
}

pub fn Top__count_true_step(_out: *Top__count_true_out,
                            self: *Top__count_true_mem) void { 
 
  _out.*.y = (self.*.v+1);
  self.*.v = _out.*.y; 
}

pub const Top__counter_mem = struct {
  v_4: isize,
  v_3: bool,
  v_1: isize,
  v: bool,
};

pub const Top__counter_out = struct {
  c: bool,
};

pub fn Top__counter_reset(self: *Top__counter_mem) void { 
 
  self.*.v_3 = true;
  self.*.v = true; 
}

pub fn Top__counter_step(period: isize, _out: *Top__counter_out,
                         self: *Top__counter_mem) void { 
 
  
  var v_6: isize = undefined;
  var v_5: isize = undefined;
  var v_2: bool = undefined;
  var y: isize = undefined;
  var do_tick: bool = undefined; 
 
  v_5 = (self.*.v_4+1);
  v_2 = (self.*.v_1>=period);
  if (self.*.v) {
    do_tick = false;
  } else {
    do_tick = v_2;
  }
  _out.*.c = do_tick;
  if (do_tick) {
    v_6 = 0;
  } else {
    v_6 = v_5;
  }
  if (self.*.v_3) {
    y = 0;
  } else {
    y = v_6;
  }
  self.*.v_4 = y;
  self.*.v_3 = false;
  self.*.v_1 = y;
  self.*.v = false; 
}

pub const Top__led_mem = struct {
  v_17: bool,
  v_15: bool,
  v_12: bool,
  v_9: bool,
  v_7: bool,
  v: bool,
  declare_once: Top__declare_once_mem,
  counter: Top__counter_mem,
};

pub const Top__led_out = struct {
  out: bool,
};

pub fn Top__led_reset(self: *Top__led_mem) void { 
 
  Top__counter_reset(&self.*.counter);
  Top__declare_once_reset(&self.*.declare_once);
  self.*.v_17 = false;
  self.*.v_15 = false;
  self.*.v_12 = true;
  self.*.v = true; 
}

pub fn Top__led_step(period: isize, pin: isize, toggle: bool,
                     _out: *Top__led_out, self: *Top__led_mem) void {
  var Interface__change_pin_state_out_st: Interface.change_pin_state_out = undefined;
  var Top__counter_out_st: Top__counter_out = undefined;
  var Top__declare_once_out_st: Top__declare_once_out = undefined; 
 
  
  var v_16: bool = undefined;
  var v_14: isize = undefined;
  var v_13: isize = undefined;
  var v_11: bool = undefined;
  var v_10: bool = undefined;
  var v_8: bool = undefined;
  var i: isize = undefined;
  var statee: bool = undefined;
  var change: bool = undefined;
  var s: isize = undefined; 
 
  v_16 = !(self.*.v_15);
  v_8 = !(self.*.v_7);
  Top__counter_step(period, &Top__counter_out_st, &self.*.counter);
  change = Top__counter_out_st.c;
  if (change) {
    _out.*.out = v_16;
    v_10 = v_8;
  } else {
    _out.*.out = self.*.v_17;
    v_10 = self.*.v_9;
  }
  if (toggle) {
    v_11 = v_10;
  } else {
    v_11 = false;
  }
  if (self.*.v) {
    statee = true;
  } else {
    statee = v_11;
  }
  Interface.change_pin_state_step(pin, statee,
                                  &Interface__change_pin_state_out_st);
  v_13 = Interface__change_pin_state_out_st.b;
  if (change) {
    v_14 = v_13;
  } else {
    v_14 = 0;
  }
  Top__declare_once_step(pin, 1, &Top__declare_once_out_st,
                         &self.*.declare_once);
  s = Top__declare_once_out_st.out;
  if (self.*.v_12) {
    i = s;
  } else {
    i = v_14;
  }
  self.*.v_17 = _out.*.out;
  self.*.v_15 = _out.*.out;
  self.*.v_12 = false;
  self.*.v_9 = statee;
  self.*.v_7 = statee;
  self.*.v = false; 
}

pub const Top__xor_node_out = struct {
  o: bool,
};

pub fn Top__xor_node_step(i_1: bool, i_2: bool, _out: *Top__xor_node_out) void { 
 
  
  var v_20: bool = undefined;
  var v_19: bool = undefined;
  var v_18: bool = undefined;
  var v: bool = undefined; 
 
  v_19 = !(i_1);
  v_20 = (i_2 and v_19);
  v = !(i_2);
  v_18 = (i_1 and v);
  _out.*.o = (v_18 or v_20); 
}

pub const Top__toggle_node_mem = struct {
  v_23: bool,
  v_22: bool,
  v_21: bool,
  v: bool,
};

pub const Top__toggle_node_out = struct {
  outp: bool,
};

pub fn Top__toggle_node_reset(self: *Top__toggle_node_mem) void { 
 
  self.*.v_22 = true;
  self.*.v = true; 
}

pub fn Top__toggle_node_step(inp: bool, _out: *Top__toggle_node_out,
                             self: *Top__toggle_node_mem) void {
  var Top__xor_node_out_st: Top__xor_node_out = undefined; 
 
  
  var v_26: bool = undefined;
  var v_25: bool = undefined;
  var v_24: bool = undefined;
  var last_val: bool = undefined; 
 
  if (self.*.v) {
    last_val = false;
  } else {
    last_val = self.*.v_21;
  }
  v_24 = !(last_val);
  v_25 = (inp and v_24);
  Top__xor_node_step(self.*.v_23, v_25, &Top__xor_node_out_st);
  v_26 = Top__xor_node_out_st.o;
  if (self.*.v_22) {
    _out.*.outp = false;
  } else {
    _out.*.outp = v_26;
  }
  self.*.v_23 = _out.*.outp;
  self.*.v_22 = false;
  self.*.v_21 = inp;
  self.*.v = false; 
}

pub const Top__led_control_mem = struct {
  declare_once: Top__declare_once_mem,
};

pub const Top__led_control_out = struct {
  out: bool,
};

pub fn Top__led_control_reset(self: *Top__led_control_mem) void { 
 
  Top__declare_once_reset(&self.*.declare_once); 
}

pub fn Top__led_control_step(pin: isize, statee: bool,
                             _out: *Top__led_control_out,
                             self: *Top__led_control_mem) void {
  var Interface__change_pin_state_out_st: Interface.change_pin_state_out = undefined;
  var Top__declare_once_out_st: Top__declare_once_out = undefined; 
 
  
  var i: isize = undefined;
  var s: isize = undefined; 
 
  _out.*.out = true;
  Interface.change_pin_state_step(pin, statee,
                                  &Interface__change_pin_state_out_st);
  i = Interface__change_pin_state_out_st.b;
  Top__declare_once_step(pin, 1, &Top__declare_once_out_st,
                         &self.*.declare_once);
  s = Top__declare_once_out_st.out; 
}

pub const Top__led_control_print_mem = struct {
  v_29: bool,
  v_28: bool,
  v: bool,
  declare_once: Top__declare_once_mem,
};

pub const Top__led_control_print_out = struct {
  out: bool,
};

pub fn Top__led_control_print_reset(self: *Top__led_control_print_mem) void { 
 
  Top__declare_once_reset(&self.*.declare_once);
  self.*.v_28 = true;
  self.*.v = true; 
}

pub fn Top__led_control_print_step(pin: isize, statee: bool,
                                   _out: *Top__led_control_print_out,
                                   self: *Top__led_control_print_mem) void {
  var Interface__change_pin_state_out_st: Interface.change_pin_state_out = undefined;
  var Interface__print_int_out_st: Interface.print_int_out = undefined;
  var Top__xor_node_out_st: Top__xor_node_out = undefined;
  var Top__declare_once_out_st: Top__declare_once_out = undefined; 
 
  
  var v_31: bool = undefined;
  var v_30: bool = undefined;
  var v_27: isize = undefined;
  var i: isize = undefined;
  var s: isize = undefined;
  var p: bool = undefined;
  var d: bool = undefined; 
 
  _out.*.out = true;
  if (self.*.v_28) {
    v_30 = false;
  } else {
    v_30 = self.*.v_29;
  }
  Top__xor_node_step(statee, v_30, &Top__xor_node_out_st);
  v_31 = Top__xor_node_out_st.o;
  if (statee) {
    v_27 = 105;
  } else {
    v_27 = 66;
  }
  Interface.print_int_step(v_27, v_31, true, &Interface__print_int_out_st);
  p = Interface__print_int_out_st.b;
  if (self.*.v) {
    d = true;
  } else {
    d = false;
  }
  Interface.change_pin_state_step(pin, statee,
                                  &Interface__change_pin_state_out_st);
  i = Interface__change_pin_state_out_st.b;
  Top__declare_once_step(pin, 1, &Top__declare_once_out_st,
                         &self.*.declare_once);
  s = Top__declare_once_out_st.out;
  self.*.v_29 = statee;
  self.*.v_28 = false;
  self.*.v = false; 
}

pub const Top__main_mem = struct {
  led_1: Top__led_mem,
  declare_once: Top__declare_once_mem,
  led: Top__led_mem,
  led_control: Top__led_control_mem,
  toggle_node: Top__toggle_node_mem,
  led_control_1: Top__led_control_mem,
};

pub const Top__main_out = struct {
  o: bool,
};

pub fn Top__main_reset(self: *Top__main_mem) void { 
 
  Top__led_control_reset(&self.*.led_control_1);
  Top__toggle_node_reset(&self.*.toggle_node);
  Top__led_control_reset(&self.*.led_control);
  Top__led_reset(&self.*.led);
  Top__declare_once_reset(&self.*.declare_once);
  Top__led_reset(&self.*.led_1); 
}

pub fn Top__main_step(_out: *Top__main_out, self: *Top__main_mem) void {
  var Interface__div_out_st: Interface.div_out = undefined;
  var Interface__print_int_out_st: Interface.print_int_out = undefined;
  var Interface__random_out_st: Interface.random_out = undefined;
  var Interface__read_analog_out_st: Interface.read_analog_out = undefined;
  var Top__toggle_node_out_st: Top__toggle_node_out = undefined;
  var Top__declare_once_out_st: Top__declare_once_out = undefined;
  var Top__led_out_st: Top__led_out = undefined;
  var Top__led_control_out_st: Top__led_control_out = undefined;
  var Interface__read_pin_state_out_st: Interface.read_pin_state_out = undefined; 
 
  
  var v_35: bool = undefined;
  var v_34: isize = undefined;
  var v_33: bool = undefined;
  var v_32: isize = undefined;
  var v: isize = undefined;
  var i: bool = undefined;
  var j: isize = undefined;
  var k: bool = undefined;
  var m: bool = undefined;
  var n: bool = undefined;
  var on_off: bool = undefined;
  var period: isize = undefined; 
 
  Interface.read_pin_state_step(5, &Interface__read_pin_state_out_st);
  v_35 = Interface__read_pin_state_out_st.b;
  Top__led_control_step(4, v_35, &Top__led_control_out_st,
                        &self.*.led_control_1);
  _out.*.o = Top__led_control_out_st.out;
  Interface.random_step(8, 512, &Interface__random_out_st);
  v_34 = Interface__random_out_st.i;
  Interface.read_pin_state_step(5, &Interface__read_pin_state_out_st);
  v_33 = Interface__read_pin_state_out_st.b;
  Top__toggle_node_step(v_33, &Top__toggle_node_out_st, &self.*.toggle_node);
  on_off = Top__toggle_node_out_st.outp;
  Top__led_control_step(6, on_off, &Top__led_control_out_st,
                        &self.*.led_control);
  m = Top__led_control_out_st.out;
  Top__led_step(v_34, 2, on_off, &Top__led_out_st, &self.*.led);
  i = Top__led_out_st.out;
  Top__declare_once_step(5, 0, &Top__declare_once_out_st,
                         &self.*.declare_once);
  j = Top__declare_once_out_st.out;
  Interface.read_analog_step(14, &Interface__read_analog_out_st);
  v = Interface__read_analog_out_st.i;
  Interface.div_step(v, 64, &Interface__div_out_st);
  v_32 = Interface__div_out_st.c;
  period = (v_32+1);
  Interface.print_int_step(period, false, true, &Interface__print_int_out_st);
  n = Interface__print_int_out_st.b;
  Top__led_step(period, 3, true, &Top__led_out_st, &self.*.led_1);
  k = Top__led_out_st.out; 
}

