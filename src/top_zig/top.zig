const print = @import("std").debug.print;
const Interface = @import("interface.zig");

const Top__max_out = struct {
   c: isize,
 };
 
pub fn Top__max_step(a: isize, b: isize, _out: *Top__max_out) void { 
 
  
  var v: isize = undefined; 
 
  v = (a<b);
  if (v) {
    _out.*.c = b;
  } else {
    _out.*.c = a;
  } 
}

const Top__main_out = struct {
  o: isize,
};

pub fn Top__main_step(_out: *Top__main_out) void {
  var Top__max_out_st: Top__max_out = undefined;
  var Interface__identity_out_st: Interface.identity_out = undefined;
  var Interface__declare_io_out_st: Interface.declare_io_out = undefined; 
 
  
  var v: isize = undefined;
  var i: isize = undefined; 
 
  Interface.identity_step(1, &Interface__identity_out_st);
  v = Interface__identity_out_st.o;
  Top__max_step(v, 0, &Top__max_out_st);
  _out.*.o = Top__max_out_st.c;
  Interface.declare_io_step(12, 5, &Interface__declare_io_out_st);
  i = Interface__declare_io_out_st.b; 
}

