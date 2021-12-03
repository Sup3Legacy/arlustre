const print = @import("std").debug.print;
const Top = @import("top.zig");

var mem: Top.Top__main_mem = undefined;
var _res: Top.Top__main_out = undefined; 
pub fn main() isize {
  var step_zig: isize = undefined;
  
 
  step_zig = 0;
  Top.Top__main_reset(&mem);
  return 0; 
}

pub fn step() void {
  
  Top.Top__main_step(&_res, &mem);
}
