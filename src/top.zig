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

pub fn Top__declare_once_step(port: isize, direction: bool,
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
  Top__declare_once_step(pin, true, &Top__declare_once_out_st,
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
  Top__declare_once_step(pin, true, &Top__declare_once_out_st,
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
  Top__declare_once_step(pin, true, &Top__declare_once_out_st,
                         &self.*.declare_once);
  s = Top__declare_once_out_st.out;
  self.*.v_29 = statee;
  self.*.v_28 = false;
  self.*.v = false; 
}

pub const Top__print_distance_mem = struct {
  counter: Top__counter_mem,
};

pub const Top__print_distance_out = struct {
  o: bool,
};

pub fn Top__print_distance_reset(self: *Top__print_distance_mem) void { 
 
  Top__counter_reset(&self.*.counter); 
}

pub fn Top__print_distance_step(_out: *Top__print_distance_out,
                                self: *Top__print_distance_mem) void {
  var Top__counter_out_st: Top__counter_out = undefined;
  var Interface__print_int_out_st: Interface.print_int_out = undefined;
  var Interface__float_of_int_out_st: Interface.float_of_int_out = undefined;
  var Interface__int_of_float_out_st: Interface.int_of_float_out = undefined;
  var Interface__time_pulse_out_st: Interface.time_pulse_out = undefined; 
 
  
  var v_35: isize = undefined;
  var v_34: f32 = undefined;
  var v_33: f32 = undefined;
  var v_32: f32 = undefined;
  var v: f32 = undefined;
  var cloc: bool = undefined;
  var received: bool = undefined;
  var l: isize = undefined;
  var h: isize = undefined;
  var print_n: bool = undefined;
  var distance: f32 = undefined; 
 
  Top__counter_step(16, &Top__counter_out_st, &self.*.counter);
  cloc = Top__counter_out_st.c;
  Interface.time_pulse_step(7, 9, 4, 1, cloc, &Interface__time_pulse_out_st);
  received = Interface__time_pulse_out_st.b;
  l = Interface__time_pulse_out_st.l;
  h = Interface__time_pulse_out_st.h;
  Interface.float_of_int_step(h, &Interface__float_of_int_out_st);
  v_32 = Interface__float_of_int_out_st.f;
  v_33 = (v_32*256.000000);
  Interface.float_of_int_step(l, &Interface__float_of_int_out_st);
  v = Interface__float_of_int_out_st.f;
  v_34 = (v+v_33);
  distance = (v_34*0.017000);
  Interface.int_of_float_step(distance, &Interface__int_of_float_out_st);
  v_35 = Interface__int_of_float_out_st.i;
  Interface.print_int_step(v_35, received, true, &Interface__print_int_out_st);
  print_n = Interface__print_int_out_st.b;
  _out.*.o = received; 
}

pub const Top__distance_mem = struct {
  counter: Top__counter_mem,
};

pub const Top__distance_out = struct {
  received: bool,
  dist: isize,
};

pub fn Top__distance_reset(self: *Top__distance_mem) void { 
 
  Top__counter_reset(&self.*.counter); 
}

pub fn Top__distance_step(_out: *Top__distance_out, self: *Top__distance_mem) void {
  var Top__counter_out_st: Top__counter_out = undefined;
  var Interface__float_of_int_out_st: Interface.float_of_int_out = undefined;
  var Interface__int_of_float_out_st: Interface.int_of_float_out = undefined;
  var Interface__time_pulse_out_st: Interface.time_pulse_out = undefined; 
 
  
  var v_36: f32 = undefined;
  var v: f32 = undefined;
  var cloc: bool = undefined;
  var l: isize = undefined;
  var h: isize = undefined; 
 
  Top__counter_step(16, &Top__counter_out_st, &self.*.counter);
  cloc = Top__counter_out_st.c;
  Interface.time_pulse_step(7, 9, 10, 1, cloc, &Interface__time_pulse_out_st);
  _out.*.received = Interface__time_pulse_out_st.b;
  l = Interface__time_pulse_out_st.l;
  h = Interface__time_pulse_out_st.h;
  Interface.float_of_int_step(l, &Interface__float_of_int_out_st);
  v = Interface__float_of_int_out_st.f;
  v_36 = (v*0.017000);
  Interface.int_of_float_step(v_36, &Interface__int_of_float_out_st);
  _out.*.dist = Interface__int_of_float_out_st.i; 
}

pub const Top__once_mem = struct {
  v_37: bool,
  v: bool,
};

pub const Top__once_out = struct {
  o: bool,
};

pub fn Top__once_reset(self: *Top__once_mem) void { 
 
  self.*.v = true; 
}

pub fn Top__once_step(i: bool, _out: *Top__once_out, self: *Top__once_mem) void { 
 
  
  var v_39: bool = undefined;
  var v_38: bool = undefined; 
 
  if (self.*.v) {
    v_38 = false;
  } else {
    v_38 = self.*.v_37;
  }
  v_39 = !(v_38);
  _out.*.o = (i and v_39);
  self.*.v_37 = i;
  self.*.v = false; 
}

pub const Top__joystick_mem = struct {
  v_55: isize,
  v_54: bool,
  v_50: isize,
  v_49: bool,
  v_47: isize,
  v_46: bool,
  v_44: isize,
  v_43: bool,
};

pub const Top__joystick_out = struct {
  o: bool,
};

pub fn Top__joystick_reset(self: *Top__joystick_mem) void { 
 
  self.*.v_54 = true;
  self.*.v_49 = true;
  self.*.v_46 = true;
  self.*.v_43 = true; 
}

pub fn Top__joystick_step(_out: *Top__joystick_out, self: *Top__joystick_mem) void {
  var Interface__map_int_out_st: Interface.map_int_out = undefined;
  var Interface__toggle_pixel_out_st: Interface.toggle_pixel_out = undefined;
  var Interface__read_analog_out_st: Interface.read_analog_out = undefined; 
 
  
  var v_60: bool = undefined;
  var v_59: bool = undefined;
  var v_58: bool = undefined;
  var v_57: bool = undefined;
  var v_56: isize = undefined;
  var v_53: bool = undefined;
  var v_52: bool = undefined;
  var v_51: isize = undefined;
  var v_48: isize = undefined;
  var v_45: isize = undefined;
  var v_42: bool = undefined;
  var v_41: isize = undefined;
  var v_40: isize = undefined;
  var v: isize = undefined;
  var x: isize = undefined;
  var y: isize = undefined; 
 
  if (self.*.v_54) {
    v_56 = 0;
  } else {
    v_56 = self.*.v_55;
  }
  if (self.*.v_49) {
    v_51 = 0;
  } else {
    v_51 = self.*.v_50;
  }
  if (self.*.v_46) {
    v_48 = 0;
  } else {
    v_48 = self.*.v_47;
  }
  if (self.*.v_43) {
    v_45 = 0;
  } else {
    v_45 = self.*.v_44;
  }
  Interface.read_analog_step(16, &Interface__read_analog_out_st);
  v_41 = Interface__read_analog_out_st.i;
  Interface.map_int_step(v_41, 0, 1000, 0, 7, &Interface__map_int_out_st);
  x = Interface__map_int_out_st.i;
  v_52 = (x==v_51);
  v_53 = !(v_52);
  Interface.read_analog_step(15, &Interface__read_analog_out_st);
  v = Interface__read_analog_out_st.i;
  v_40 = (1023-v);
  Interface.map_int_step(v_40, 0, 1000, 0, 7, &Interface__map_int_out_st);
  y = Interface__map_int_out_st.i;
  v_57 = (y==v_56);
  v_58 = !(v_57);
  v_59 = (v_53 or v_58);
  Interface.toggle_pixel_step(v_45, v_48, false, v_59,
                              &Interface__toggle_pixel_out_st);
  v_60 = Interface__toggle_pixel_out_st.b;
  Interface.toggle_pixel_step(x, y, true, true,
                              &Interface__toggle_pixel_out_st);
  v_42 = Interface__toggle_pixel_out_st.b;
  _out.*.o = (v_42 or v_60);
  self.*.v_55 = y;
  self.*.v_54 = false;
  self.*.v_50 = x;
  self.*.v_49 = false;
  self.*.v_47 = y;
  self.*.v_46 = false;
  self.*.v_44 = x;
  self.*.v_43 = false; 
}

pub const Top__joystick_toggle_mem = struct {
  v_110: isize,
  v_109: bool,
  v_105: isize,
  v_104: bool,
  v_102: isize,
  v_101: bool,
  v_99: isize,
  v_98: bool,
  v_95: isize,
  v_94: bool,
  v_92: isize,
  v_91: bool,
  v_86: isize,
  v_85: bool,
  v_79: isize,
  v_78: bool,
  v_71: isize,
  v_70: bool,
  v_64: isize,
  v_63: bool,
  once_2: Top__once_mem,
  once_3: Top__once_mem,
  once: Top__once_mem,
  once_1: Top__once_mem,
};

pub const Top__joystick_toggle_out = struct {
  o: bool,
};

pub fn Top__joystick_toggle_reset(self: *Top__joystick_toggle_mem) void { 
 
  Top__once_reset(&self.*.once_1);
  Top__once_reset(&self.*.once);
  Top__once_reset(&self.*.once_3);
  Top__once_reset(&self.*.once_2);
  self.*.v_109 = true;
  self.*.v_104 = true;
  self.*.v_101 = true;
  self.*.v_98 = true;
  self.*.v_94 = true;
  self.*.v_91 = true;
  self.*.v_85 = true;
  self.*.v_78 = true;
  self.*.v_70 = true;
  self.*.v_63 = true; 
}

pub fn Top__joystick_toggle_step(_out: *Top__joystick_toggle_out,
                                 self: *Top__joystick_toggle_mem) void {
  var Interface__toggle_pixel_out_st: Interface.toggle_pixel_out = undefined;
  var Interface__read_analog_out_st: Interface.read_analog_out = undefined;
  var Top__once_out_st: Top__once_out = undefined; 
 
  
  var v_115: bool = undefined;
  var v_114: bool = undefined;
  var v_113: bool = undefined;
  var v_112: bool = undefined;
  var v_111: isize = undefined;
  var v_108: bool = undefined;
  var v_107: bool = undefined;
  var v_106: isize = undefined;
  var v_103: isize = undefined;
  var v_100: isize = undefined;
  var v_97: bool = undefined;
  var v_96: isize = undefined;
  var v_93: isize = undefined;
  var v_90: isize = undefined;
  var v_89: isize = undefined;
  var v_88: bool = undefined;
  var v_87: isize = undefined;
  var v_84: bool = undefined;
  var v_83: bool = undefined;
  var v_82: isize = undefined;
  var v_81: bool = undefined;
  var v_80: isize = undefined;
  var v_77: bool = undefined;
  var v_76: bool = undefined;
  var v_75: isize = undefined;
  var v_74: isize = undefined;
  var v_73: bool = undefined;
  var v_72: isize = undefined;
  var v_69: bool = undefined;
  var v_68: bool = undefined;
  var v_67: isize = undefined;
  var v_66: bool = undefined;
  var v_65: isize = undefined;
  var v_62: bool = undefined;
  var v_61: bool = undefined;
  var v: isize = undefined;
  var x: isize = undefined;
  var y: isize = undefined;
  var updown: isize = undefined;
  var leftright: isize = undefined;
  var mx: isize = undefined;
  var my: isize = undefined; 
 
  if (self.*.v_109) {
    v_111 = 0;
  } else {
    v_111 = self.*.v_110;
  }
  if (self.*.v_104) {
    v_106 = 0;
  } else {
    v_106 = self.*.v_105;
  }
  if (self.*.v_101) {
    v_103 = 0;
  } else {
    v_103 = self.*.v_102;
  }
  if (self.*.v_98) {
    v_100 = 0;
  } else {
    v_100 = self.*.v_99;
  }
  if (self.*.v_94) {
    v_96 = 4;
  } else {
    v_96 = self.*.v_95;
  }
  if (self.*.v_91) {
    v_93 = 4;
  } else {
    v_93 = self.*.v_92;
  }
  if (self.*.v_85) {
    v_87 = 4;
  } else {
    v_87 = self.*.v_86;
  }
  v_88 = (v_87==0);
  if (v_88) {
    v_89 = 0;
  } else {
    v_89 = -1;
  }
  if (self.*.v_78) {
    v_80 = 4;
  } else {
    v_80 = self.*.v_79;
  }
  v_81 = (v_80==7);
  if (v_81) {
    v_82 = 0;
  } else {
    v_82 = 1;
  }
  if (self.*.v_70) {
    v_72 = 4;
  } else {
    v_72 = self.*.v_71;
  }
  v_73 = (v_72==0);
  if (v_73) {
    v_74 = 0;
  } else {
    v_74 = -1;
  }
  if (self.*.v_63) {
    v_65 = 4;
  } else {
    v_65 = self.*.v_64;
  }
  v_66 = (v_65==7);
  if (v_66) {
    v_67 = 0;
  } else {
    v_67 = 1;
  }
  Interface.read_analog_step(16, &Interface__read_analog_out_st);
  mx = Interface__read_analog_out_st.i;
  v_68 = (mx<=200);
  Top__once_step(v_68, &Top__once_out_st, &self.*.once_1);
  v_69 = Top__once_out_st.o;
  if (v_69) {
    v_75 = v_74;
  } else {
    v_75 = 0;
  }
  v_61 = (mx>=800);
  Top__once_step(v_61, &Top__once_out_st, &self.*.once);
  v_62 = Top__once_out_st.o;
  if (v_62) {
    updown = v_67;
  } else {
    updown = v_75;
  }
  x = (v_93+updown);
  v_107 = (x==v_106);
  v_108 = !(v_107);
  Interface.read_analog_step(15, &Interface__read_analog_out_st);
  v = Interface__read_analog_out_st.i;
  my = (1023-v);
  v_83 = (my<=200);
  Top__once_step(v_83, &Top__once_out_st, &self.*.once_3);
  v_84 = Top__once_out_st.o;
  if (v_84) {
    v_90 = v_89;
  } else {
    v_90 = 0;
  }
  v_76 = (my>=800);
  Top__once_step(v_76, &Top__once_out_st, &self.*.once_2);
  v_77 = Top__once_out_st.o;
  if (v_77) {
    leftright = v_82;
  } else {
    leftright = v_90;
  }
  y = (v_96+leftright);
  v_112 = (y==v_111);
  v_113 = !(v_112);
  v_114 = (v_108 or v_113);
  Interface.toggle_pixel_step(v_100, v_103, false, v_114,
                              &Interface__toggle_pixel_out_st);
  v_115 = Interface__toggle_pixel_out_st.b;
  Interface.toggle_pixel_step(x, y, true, true,
                              &Interface__toggle_pixel_out_st);
  v_97 = Interface__toggle_pixel_out_st.b;
  _out.*.o = (v_97 or v_115);
  self.*.v_110 = y;
  self.*.v_109 = false;
  self.*.v_105 = x;
  self.*.v_104 = false;
  self.*.v_102 = y;
  self.*.v_101 = false;
  self.*.v_99 = x;
  self.*.v_98 = false;
  self.*.v_95 = y;
  self.*.v_94 = false;
  self.*.v_92 = x;
  self.*.v_91 = false;
  self.*.v_86 = y;
  self.*.v_85 = false;
  self.*.v_79 = y;
  self.*.v_78 = false;
  self.*.v_71 = x;
  self.*.v_70 = false;
  self.*.v_64 = x;
  self.*.v_63 = false; 
}

pub const Top__fifo_mem = struct {
  v_138: isize,
  v_136: bool,
  v_135: isize,
  v_133: bool,
  v_132: isize,
  v_130: bool,
  v_129: isize,
  v_127: bool,
  v_126: isize,
  v_124: bool,
  v_123: isize,
  v_121: bool,
  v_120: isize,
  v_118: bool,
  v_117: isize,
  v: bool,
};

pub const Top__fifo_out = struct {
  o0: isize,
  o1: isize,
  o2: isize,
  o3: isize,
  o4: isize,
  o5: isize,
  o6: isize,
  o7: isize,
};

pub fn Top__fifo_reset(self: *Top__fifo_mem) void { 
 
  self.*.v_136 = true;
  self.*.v_133 = true;
  self.*.v_130 = true;
  self.*.v_127 = true;
  self.*.v_124 = true;
  self.*.v_121 = true;
  self.*.v_118 = true;
  self.*.v = true; 
}

pub fn Top__fifo_step(step: bool, i: isize, _out: *Top__fifo_out,
                      self: *Top__fifo_mem) void { 
 
  
  var v_137: isize = undefined;
  var v_134: isize = undefined;
  var v_131: isize = undefined;
  var v_128: isize = undefined;
  var v_125: isize = undefined;
  var v_122: isize = undefined;
  var v_119: isize = undefined;
  var v_116: isize = undefined; 
 
  if (self.*.v_136) {
    _out.*.o7 = 0;
  } else {
    _out.*.o7 = self.*.v_138;
  }
  if (self.*.v_133) {
    _out.*.o6 = 0;
  } else {
    _out.*.o6 = self.*.v_135;
  }
  if (step) {
    v_137 = _out.*.o6;
  } else {
    v_137 = _out.*.o7;
  }
  if (self.*.v_130) {
    _out.*.o5 = 0;
  } else {
    _out.*.o5 = self.*.v_132;
  }
  if (step) {
    v_134 = _out.*.o5;
  } else {
    v_134 = _out.*.o6;
  }
  if (self.*.v_127) {
    _out.*.o4 = 0;
  } else {
    _out.*.o4 = self.*.v_129;
  }
  if (step) {
    v_131 = _out.*.o4;
  } else {
    v_131 = _out.*.o5;
  }
  if (self.*.v_124) {
    _out.*.o3 = 0;
  } else {
    _out.*.o3 = self.*.v_126;
  }
  if (step) {
    v_128 = _out.*.o3;
  } else {
    v_128 = _out.*.o4;
  }
  if (self.*.v_121) {
    _out.*.o2 = 0;
  } else {
    _out.*.o2 = self.*.v_123;
  }
  if (step) {
    v_125 = _out.*.o2;
  } else {
    v_125 = _out.*.o3;
  }
  if (self.*.v_118) {
    _out.*.o1 = 0;
  } else {
    _out.*.o1 = self.*.v_120;
  }
  if (step) {
    v_122 = _out.*.o1;
  } else {
    v_122 = _out.*.o2;
  }
  if (self.*.v) {
    _out.*.o0 = 0;
  } else {
    _out.*.o0 = self.*.v_117;
  }
  if (step) {
    v_119 = _out.*.o0;
    v_116 = i;
  } else {
    v_119 = _out.*.o1;
    v_116 = _out.*.o0;
  }
  self.*.v_138 = v_137;
  self.*.v_136 = false;
  self.*.v_135 = v_134;
  self.*.v_133 = false;
  self.*.v_132 = v_131;
  self.*.v_130 = false;
  self.*.v_129 = v_128;
  self.*.v_127 = false;
  self.*.v_126 = v_125;
  self.*.v_124 = false;
  self.*.v_123 = v_122;
  self.*.v_121 = false;
  self.*.v_120 = v_119;
  self.*.v_118 = false;
  self.*.v_117 = v_116;
  self.*.v = false; 
}

pub const Top__graph_mem = struct {
  m0: isize,
  m1: isize,
  m2: isize,
  m3: isize,
  m4: isize,
  m5: isize,
  m6: isize,
  m7: isize,
  fifo: Top__fifo_mem,
};

pub const Top__graph_out = struct {
  o: bool,
};

pub fn Top__graph_reset(self: *Top__graph_mem) void { 
 
  Top__fifo_reset(&self.*.fifo);
  self.*.m7 = 0;
  self.*.m6 = 0;
  self.*.m5 = 0;
  self.*.m4 = 0;
  self.*.m3 = 0;
  self.*.m2 = 0;
  self.*.m1 = 0;
  self.*.m0 = 0; 
}

pub fn Top__graph_step(step: bool, i: isize, _out: *Top__graph_out,
                       self: *Top__graph_mem) void {
  var Top__fifo_out_st: Top__fifo_out = undefined;
  var Interface__toggle_pixel_out_st: Interface.toggle_pixel_out = undefined; 
 
  
  var v_169: bool = undefined;
  var v_168: bool = undefined;
  var v_167: bool = undefined;
  var v_166: bool = undefined;
  var v_165: bool = undefined;
  var v_164: bool = undefined;
  var v_163: bool = undefined;
  var v_162: bool = undefined;
  var v_161: bool = undefined;
  var v_160: bool = undefined;
  var v_159: bool = undefined;
  var v_158: bool = undefined;
  var v_157: bool = undefined;
  var v_156: bool = undefined;
  var v_155: bool = undefined;
  var v_154: bool = undefined;
  var v_153: bool = undefined;
  var v_152: bool = undefined;
  var v_151: bool = undefined;
  var v_150: bool = undefined;
  var v_149: bool = undefined;
  var v_148: bool = undefined;
  var v_147: bool = undefined;
  var v_146: bool = undefined;
  var v_145: bool = undefined;
  var v_144: bool = undefined;
  var v_143: bool = undefined;
  var v_142: bool = undefined;
  var v_141: bool = undefined;
  var v_140: bool = undefined;
  var v_139: bool = undefined;
  var v: bool = undefined;
  var i_0: isize = undefined;
  var i_1: isize = undefined;
  var i_2: isize = undefined;
  var i_3: isize = undefined;
  var i_4: isize = undefined;
  var i_5: isize = undefined;
  var i_6: isize = undefined;
  var i_7: isize = undefined;
  var l0: bool = undefined;
  var l1: bool = undefined;
  var l2: bool = undefined;
  var l3: bool = undefined;
  var l4: bool = undefined;
  var l5: bool = undefined;
  var l6: bool = undefined;
  var l7: bool = undefined; 
 
  _out.*.o = true;
  Top__fifo_step(step, i, &Top__fifo_out_st, &self.*.fifo);
  i_0 = Top__fifo_out_st.o0;
  i_1 = Top__fifo_out_st.o1;
  i_2 = Top__fifo_out_st.o2;
  i_3 = Top__fifo_out_st.o3;
  i_4 = Top__fifo_out_st.o4;
  i_5 = Top__fifo_out_st.o5;
  i_6 = Top__fifo_out_st.o6;
  i_7 = Top__fifo_out_st.o7;
  v_167 = (i_7==self.*.m7);
  v_168 = !(v_167);
  Interface.toggle_pixel_step(7, self.*.m7, false, v_168,
                              &Interface__toggle_pixel_out_st);
  v_169 = Interface__toggle_pixel_out_st.b;
  Interface.toggle_pixel_step(7, i_7, true, true,
                              &Interface__toggle_pixel_out_st);
  v_166 = Interface__toggle_pixel_out_st.b;
  l7 = (v_166 or v_169);
  v_163 = (i_6==self.*.m6);
  v_164 = !(v_163);
  Interface.toggle_pixel_step(6, self.*.m6, false, v_164,
                              &Interface__toggle_pixel_out_st);
  v_165 = Interface__toggle_pixel_out_st.b;
  Interface.toggle_pixel_step(6, i_6, true, true,
                              &Interface__toggle_pixel_out_st);
  v_162 = Interface__toggle_pixel_out_st.b;
  l6 = (v_162 or v_165);
  v_159 = (i_5==self.*.m5);
  v_160 = !(v_159);
  Interface.toggle_pixel_step(5, self.*.m5, false, v_160,
                              &Interface__toggle_pixel_out_st);
  v_161 = Interface__toggle_pixel_out_st.b;
  Interface.toggle_pixel_step(5, i_5, true, true,
                              &Interface__toggle_pixel_out_st);
  v_158 = Interface__toggle_pixel_out_st.b;
  l5 = (v_158 or v_161);
  v_155 = (i_4==self.*.m4);
  v_156 = !(v_155);
  Interface.toggle_pixel_step(4, self.*.m4, false, v_156,
                              &Interface__toggle_pixel_out_st);
  v_157 = Interface__toggle_pixel_out_st.b;
  Interface.toggle_pixel_step(4, i_4, true, true,
                              &Interface__toggle_pixel_out_st);
  v_154 = Interface__toggle_pixel_out_st.b;
  l4 = (v_154 or v_157);
  v_151 = (i_3==self.*.m3);
  v_152 = !(v_151);
  Interface.toggle_pixel_step(3, self.*.m3, false, v_152,
                              &Interface__toggle_pixel_out_st);
  v_153 = Interface__toggle_pixel_out_st.b;
  Interface.toggle_pixel_step(3, i_3, true, true,
                              &Interface__toggle_pixel_out_st);
  v_150 = Interface__toggle_pixel_out_st.b;
  l3 = (v_150 or v_153);
  v_147 = (i_2==self.*.m2);
  v_148 = !(v_147);
  Interface.toggle_pixel_step(2, self.*.m2, false, v_148,
                              &Interface__toggle_pixel_out_st);
  v_149 = Interface__toggle_pixel_out_st.b;
  Interface.toggle_pixel_step(2, i_2, true, true,
                              &Interface__toggle_pixel_out_st);
  v_146 = Interface__toggle_pixel_out_st.b;
  l2 = (v_146 or v_149);
  v_143 = (i_1==self.*.m1);
  v_144 = !(v_143);
  Interface.toggle_pixel_step(1, self.*.m1, false, v_144,
                              &Interface__toggle_pixel_out_st);
  v_145 = Interface__toggle_pixel_out_st.b;
  Interface.toggle_pixel_step(1, i_1, true, true,
                              &Interface__toggle_pixel_out_st);
  v_142 = Interface__toggle_pixel_out_st.b;
  l1 = (v_142 or v_145);
  v_139 = (i_0==self.*.m0);
  v_140 = !(v_139);
  Interface.toggle_pixel_step(0, self.*.m0, false, v_140,
                              &Interface__toggle_pixel_out_st);
  v_141 = Interface__toggle_pixel_out_st.b;
  Interface.toggle_pixel_step(0, i_0, true, true,
                              &Interface__toggle_pixel_out_st);
  v = Interface__toggle_pixel_out_st.b;
  l0 = (v or v_141);
  self.*.m7 = i_7;
  self.*.m6 = i_6;
  self.*.m5 = i_5;
  self.*.m4 = i_4;
  self.*.m3 = i_3;
  self.*.m2 = i_2;
  self.*.m1 = i_1;
  self.*.m0 = i_0; 
}

pub const Top__main_mem = struct {
  led_1: Top__led_mem,
  declare_once: Top__declare_once_mem,
  led: Top__led_mem,
  led_control: Top__led_control_mem,
  toggle_node: Top__toggle_node_mem,
  led_control_1: Top__led_control_mem,
  graph: Top__graph_mem,
  distance_1: Top__distance_mem,
};

pub const Top__main_out = struct {
  o: bool,
};

pub fn Top__main_reset(self: *Top__main_mem) void { 
 
  Top__distance_reset(&self.*.distance_1);
  Top__graph_reset(&self.*.graph);
  Top__led_control_reset(&self.*.led_control_1);
  Top__toggle_node_reset(&self.*.toggle_node);
  Top__led_control_reset(&self.*.led_control);
  Top__led_reset(&self.*.led);
  Top__declare_once_reset(&self.*.declare_once);
  Top__led_reset(&self.*.led_1); 
}

pub fn Top__main_step(_out: *Top__main_out, self: *Top__main_mem) void {
  var Interface__div_out_st: Interface.div_out = undefined;
  var Top__graph_out_st: Top__graph_out = undefined;
  var Interface__map_int_out_st: Interface.map_int_out = undefined;
  var Interface__print_int_out_st: Interface.print_int_out = undefined;
  var Top__distance_out_st: Top__distance_out = undefined;
  var Interface__read_analog_out_st: Interface.read_analog_out = undefined;
  var Top__toggle_node_out_st: Top__toggle_node_out = undefined;
  var Top__declare_once_out_st: Top__declare_once_out = undefined;
  var Top__led_out_st: Top__led_out = undefined;
  var Top__led_control_out_st: Top__led_control_out = undefined;
  var Interface__read_pin_state_out_st: Interface.read_pin_state_out = undefined; 
 
  
  var v_182: isize = undefined;
  var v_181: isize = undefined;
  var v_180: isize = undefined;
  var v_179: bool = undefined;
  var v_178: bool = undefined;
  var v_177: bool = undefined;
  var v_176: bool = undefined;
  var v_175: bool = undefined;
  var v_174: bool = undefined;
  var v_173: bool = undefined;
  var v_172: bool = undefined;
  var v_171: bool = undefined;
  var v_170: isize = undefined;
  var v: isize = undefined;
  var i: bool = undefined;
  var j: isize = undefined;
  var k: bool = undefined;
  var m: bool = undefined;
  var n: bool = undefined;
  var p: bool = undefined;
  var on_off: bool = undefined;
  var period: isize = undefined;
  var distance: bool = undefined;
  var joy: bool = undefined;
  var received: bool = undefined;
  var dist: isize = undefined; 
 
  Top__distance_step(&Top__distance_out_st, &self.*.distance_1);
  received = Top__distance_out_st.received;
  dist = Top__distance_out_st.dist;
  v_179 = (dist<100);
  if (v_179) {
    v_180 = dist;
  } else {
    v_180 = 100;
  }
  v_178 = (dist<0);
  if (v_178) {
    v_181 = 0;
  } else {
    v_181 = v_180;
  }
  Interface.map_int_step(v_181, 0, 100, 0, 7, &Interface__map_int_out_st);
  v_182 = Interface__map_int_out_st.i;
  v_174 = (dist>100);
  v_173 = (dist<0);
  v_175 = (v_173 or v_174);
  v_176 = !(v_175);
  v_177 = (received and v_176);
  Top__graph_step(v_177, v_182, &Top__graph_out_st, &self.*.graph);
  joy = Top__graph_out_st.o;
  Interface.print_int_step(dist, received, true, &Interface__print_int_out_st);
  p = Interface__print_int_out_st.b;
  distance = true;
  Interface.read_pin_state_step(5, &Interface__read_pin_state_out_st);
  v_172 = Interface__read_pin_state_out_st.b;
  Top__led_control_step(4, v_172, &Top__led_control_out_st,
                        &self.*.led_control_1);
  _out.*.o = Top__led_control_out_st.out;
  Interface.read_pin_state_step(5, &Interface__read_pin_state_out_st);
  v_171 = Interface__read_pin_state_out_st.b;
  Top__toggle_node_step(v_171, &Top__toggle_node_out_st, &self.*.toggle_node);
  on_off = Top__toggle_node_out_st.outp;
  Top__led_control_step(6, on_off, &Top__led_control_out_st,
                        &self.*.led_control);
  m = Top__led_control_out_st.out;
  Top__led_step(32, 2, on_off, &Top__led_out_st, &self.*.led);
  i = Top__led_out_st.out;
  Top__declare_once_step(5, false, &Top__declare_once_out_st,
                         &self.*.declare_once);
  j = Top__declare_once_out_st.out;
  Interface.read_analog_step(14, &Interface__read_analog_out_st);
  v = Interface__read_analog_out_st.i;
  Interface.div_step(v, 16, &Interface__div_out_st);
  v_170 = Interface__div_out_st.c;
  period = (v_170+1);
  Interface.print_int_step(period, false, true, &Interface__print_int_out_st);
  n = Interface__print_int_out_st.b;
  Top__led_step(period, 3, true, &Top__led_out_st, &self.*.led_1);
  k = Top__led_out_st.out; 
}

