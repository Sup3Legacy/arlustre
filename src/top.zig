const print = @import("std").debug.print;
const Interface = @import("interface.zig");

const Top__count_true_mem = struct {
    v: isize,
};

const Top__count_true_out = struct {
    y: isize,
};

pub fn Top__count_true_reset(self: *Top__count_true_mem) void {
    self.*.v = 0;
}

pub fn Top__count_true_step(_out: *Top__count_true_out, self: *Top__count_true_mem) void {
    _out.*.y = (self.*.v + 1);
    self.*.v = _out.*.y;
}

const Top__led_mem = struct {
    v_12: bool,
    v_10: bool,
    v_7: bool,
    v_5: bool,
    v_3: bool,
    v_2: bool,
    count_true: Top__count_true_mem,
};

const Top__led_out = struct {
    out: bool,
};

pub fn Top__led_reset(self: *Top__led_mem) void {
    Top__count_true_reset(&self.*.count_true);
    self.*.v_12 = false;
    self.*.v_10 = false;
    self.*.v_7 = true;
    self.*.v_2 = true;
}

pub fn Top__led_step(period: isize, pin: isize, _out: *Top__led_out, self: *Top__led_mem) void {
    var Interface__change_pin_state_out_st: Interface.change_pin_state_out = undefined;
    var Top__count_true_out_st: Top__count_true_out = undefined;
    var Interface__modulo_out_st: Interface.modulo_out = undefined;
    var Interface__declare_io_out_st: Interface.declare_io_out = undefined;

    var v_11: bool = undefined;
    var v_9: isize = undefined;
    var v_8: isize = undefined;
    var v_6: bool = undefined;
    var v_4: bool = undefined;
    var v_1: isize = undefined;
    var v: isize = undefined;
    var i: isize = undefined;
    var statee: bool = undefined;
    var change: bool = undefined;
    var s: isize = undefined;

    v_11 = !(self.*.v_10);
    v_4 = !(self.*.v_3);
    Top__count_true_step(&Top__count_true_out_st, &self.*.count_true);
    v = Top__count_true_out_st.y;
    Interface.modulo_step(v, period, &Interface__modulo_out_st);
    v_1 = Interface__modulo_out_st.c;
    change = (v_1 == 0);
    if (change) {
        _out.*.out = v_11;
        v_6 = v_4;
    } else {
        _out.*.out = self.*.v_12;
        v_6 = self.*.v_5;
    }
    if (self.*.v_2) {
        statee = true;
    } else {
        statee = v_6;
    }
    Interface.change_pin_state_step(pin, statee, &Interface__change_pin_state_out_st);
    v_8 = Interface__change_pin_state_out_st.b;
    if (change) {
        v_9 = v_8;
    } else {
        v_9 = 0;
    }
    Interface.declare_io_step(pin, 1, &Interface__declare_io_out_st);
    s = Interface__declare_io_out_st.b;
    if (self.*.v_7) {
        i = s;
    } else {
        i = v_9;
    }
    self.*.v_12 = _out.*.out;
    self.*.v_10 = _out.*.out;
    self.*.v_7 = false;
    self.*.v_5 = statee;
    self.*.v_3 = statee;
    self.*.v_2 = false;
}

pub const Top__main_mem = struct {
    led: Top__led_mem,
    led_1: Top__led_mem,
};

pub const Top__main_out = struct {
    o: bool,
};

pub fn Top__main_reset(self: *Top__main_mem) void {
    Top__led_reset(&self.*.led_1);
    Top__led_reset(&self.*.led);
}

pub fn Top__main_step(_out: *Top__main_out, self: *Top__main_mem) void {
    var Top__led_out_st: Top__led_out = undefined;

    var i: bool = undefined;

    Top__led_step(4, 3, &Top__led_out_st, &self.*.led_1);
    _out.*.o = Top__led_out_st.out;
    Top__led_step(3, 2, &Top__led_out_st, &self.*.led);
    i = Top__led_out_st.out;
}
