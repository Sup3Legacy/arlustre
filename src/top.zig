const print = @import("std").debug.print;
const Interface = @import("interface.zig");

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

pub const Top__led_mem = struct {
  v_14: bool,
  v_12: bool,
  v_9: bool,
  v_7: bool,
  v_5: bool,
  v_3: bool,
  v_2: bool,
  count_true: Top__count_true_mem,
};

pub const Top__led_out = struct {
  out: bool,
};

pub fn Top__led_reset(self: *Top__led_mem) void { 
 
  Top__count_true_reset(&self.*.count_true);
  self.*.v_14 = false;
  self.*.v_12 = false;
  self.*.v_9 = true;
  self.*.v_2 = true; 
}

pub fn Top__led_step(period: isize, pin: isize, toggle: bool,
                     _out: *Top__led_out, self: *Top__led_mem) void {
  var Interface__change_pin_state_out_st: Interface.change_pin_state_out = undefined;
  var Top__count_true_out_st: Top__count_true_out = undefined;
  var Interface__modulo_out_st: Interface.modulo_out = undefined;
  var Interface__declare_io_out_st: Interface.declare_io_out = undefined; 
 
  
  var v_13: bool = undefined;
  var v_11: isize = undefined;
  var v_10: isize = undefined;
  var v_8: bool = undefined;
  var v_6: bool = undefined;
  var v_4: bool = undefined;
  var v_1: isize = undefined;
  var v: isize = undefined;
  var i: isize = undefined;
  var statee: bool = undefined;
  var change: bool = undefined;
  var s: isize = undefined; 
 
  v_13 = !(self.*.v_12);
  v_4 = !(self.*.v_3);
  Top__count_true_step(&Top__count_true_out_st, &self.*.count_true);
  v = Top__count_true_out_st.y;
  Interface.modulo_step(v, period, &Interface__modulo_out_st);
  v_1 = Interface__modulo_out_st.c;
  change = (v_1==0);
  if (change) {
    _out.*.out = v_13;
    v_6 = v_4;
  } else {
    _out.*.out = self.*.v_14;
    v_6 = self.*.v_5;
  }
  if (toggle) {
    v_8 = v_6;
  } else {
    v_8 = self.*.v_7;
  }
  if (self.*.v_2) {
    statee = true;
  } else {
    statee = v_8;
  }
  Interface.change_pin_state_step(pin, statee,
                                  &Interface__change_pin_state_out_st);
  v_10 = Interface__change_pin_state_out_st.b;
  if (change) {
    v_11 = v_10;
  } else {
    v_11 = 0;
  }
  Interface.declare_io_step(pin, 1, &Interface__declare_io_out_st);
  s = Interface__declare_io_out_st.b;
  if (self.*.v_9) {
    i = s;
  } else {
    i = v_11;
  }
  self.*.v_14 = _out.*.out;
  self.*.v_12 = _out.*.out;
  self.*.v_9 = false;
  self.*.v_7 = statee;
  self.*.v_5 = statee;
  self.*.v_3 = statee;
  self.*.v_2 = false; 
}

pub const Top__xor_node_out = struct {
  o: bool,
};

pub fn Top__xor_node_step(i_1: bool, i_2: bool, _out: *Top__xor_node_out) void { 
 
  
  var v_17: bool = undefined;
  var v_16: bool = undefined;
  var v_15: bool = undefined;
  var v: bool = undefined; 
 
  v_16 = !(i_1);
  v_17 = (i_2 and v_16);
  v = !(i_2);
  v_15 = (i_1 and v);
  _out.*.o = (v_15 or v_17); 
}

pub const Top__toggle_node_mem = struct {
  v_20: bool,
  v_19: bool,
  v_18: bool,
  v: bool,
};

pub const Top__toggle_node_out = struct {
  outp: bool,
};

pub fn Top__toggle_node_reset(self: *Top__toggle_node_mem) void { 
 
  self.*.v_19 = true;
  self.*.v = true; 
}

pub fn Top__toggle_node_step(inp: bool, _out: *Top__toggle_node_out,
                             self: *Top__toggle_node_mem) void {
  var Top__xor_node_out_st: Top__xor_node_out = undefined; 
 
  
  var v_23: bool = undefined;
  var v_22: bool = undefined;
  var v_21: bool = undefined;
  var last_val: bool = undefined; 
 
  if (self.*.v) {
    last_val = false;
  } else {
    last_val = self.*.v_18;
  }
  v_21 = !(last_val);
  v_22 = (inp and v_21);
  Top__xor_node_step(self.*.v_20, v_22, &Top__xor_node_out_st);
  v_23 = Top__xor_node_out_st.o;
  if (self.*.v_19) {
    _out.*.outp = false;
  } else {
    _out.*.outp = v_23;
  }
  self.*.v_20 = _out.*.outp;
  self.*.v_19 = false;
  self.*.v_18 = inp;
  self.*.v = false; 
}

pub const Top__led_control_out = struct {
  out: bool,
};

pub fn Top__led_control_step(pin: isize, statee: bool,
                             _out: *Top__led_control_out) void {
  var Interface__change_pin_state_out_st: Interface.change_pin_state_out = undefined;
  var Interface__declare_io_out_st: Interface.declare_io_out = undefined; 
 
  
  var i: isize = undefined;
  var s: isize = undefined; 
 
  _out.*.out = true;
  Interface.change_pin_state_step(pin, statee,
                                  &Interface__change_pin_state_out_st);
  i = Interface__change_pin_state_out_st.b;
  Interface.declare_io_step(pin, 1, &Interface__declare_io_out_st);
  s = Interface__declare_io_out_st.b; 
}

pub const Top__main_mem = struct {
  led: Top__led_mem,
  toggle_node: Top__toggle_node_mem,
  led_1: Top__led_mem,
};

pub const Top__main_out = struct {
  o: bool,
};

pub fn Top__main_reset(self: *Top__main_mem) void { 
 
  Top__led_reset(&self.*.led_1);
  Top__toggle_node_reset(&self.*.toggle_node);
  Top__led_reset(&self.*.led); 
}

pub fn Top__main_step(_out: *Top__main_out, self: *Top__main_mem) void {
  var Top__toggle_node_out_st: Top__toggle_node_out = undefined;
  var Top__led_out_st: Top__led_out = undefined;
  var Top__led_control_out_st: Top__led_control_out = undefined;
  var Interface__read_pin_state_out_st: Interface.read_pin_state_out = undefined;
  var Interface__declare_io_out_st: Interface.declare_io_out = undefined; 
 
  
  var v_24: bool = undefined;
  var v: bool = undefined;
  var i: bool = undefined;
  var j: isize = undefined;
  var k: bool = undefined;
  var on_off: bool = undefined; 
 
  Interface.read_pin_state_step(5, &Interface__read_pin_state_out_st);
  v_24 = Interface__read_pin_state_out_st.b;
  Top__led_control_step(4, v_24, &Top__led_control_out_st);
  _out.*.o = Top__led_control_out_st.out;
  Top__led_step(7, 3, true, &Top__led_out_st, &self.*.led_1);
  k = Top__led_out_st.out;
  Interface.read_pin_state_step(5, &Interface__read_pin_state_out_st);
  v = Interface__read_pin_state_out_st.b;
  Top__toggle_node_step(v, &Top__toggle_node_out_st, &self.*.toggle_node);
  on_off = Top__toggle_node_out_st.outp;
  Top__led_step(3, 2, on_off, &Top__led_out_st, &self.*.led);
  i = Top__led_out_st.out;
  Interface.declare_io_step(5, 0, &Interface__declare_io_out_st);
  j = Interface__declare_io_out_st.b; 
}

