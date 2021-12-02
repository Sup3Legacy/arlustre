const print = @import("std").debug.print;
const Top = @import("top.zig");

pub fn main(argc: isize, argv: **u8) isize {
   var step_zig: isize = undefined;
   var step_max_1: isize = undefined;
   var _res: Top.main_out = undefined; 
 
   step_zig = 0;
   step_max_1 = 0;
   if ((argc==2)) {
     step_max_1 = atoi(argv[1]);
   }
   while ((!(step_max_1)||(step_zig<step_max_1))) {
     step_zig = (step_zig+1);
     Top.main_step(&_res);
     printf("=> ", .{});
     printf("{d} ", .{_res.o});
     puts("");
     fflush(stdout);
   }
   return 0; 
 }
 
