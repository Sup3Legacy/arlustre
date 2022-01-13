---
title: Arlustre
author: Constantin \textsc{Gierczak-Galle} \newline Systèmes réactifs 2021/2022
abstract : Arduino
numbersections: True
advanced-maths: True
advanced-cs: True
theme: metropolis
header-includes:
    - \usepackage{setspace}
---

# Motivation

```cpp
int LED = 13;

void setup()   {                
  pinMode(LED, OUTPUT);         
}

void loop()                     
{
  digitalWrite(LED, HIGH);
  delay(1000);
  digitalWrite(LED, LOW);
  delay(1000);
}
```

---

```cpp
void loop()                     
{
  digitalWrite(LED1, HIGH);
  delay(1000);
  digitalWrite(LED1, LOW);
  delay(1000);

  digitalWrite(LED2, HIGH);
  delay(500);
  digitalWrite(LED2, LOW);
  delay(500);
}
```

. . .

... Nope!

## Lustre

Lustre nodes

```lustre
node counter(period: int) returns (c: bool);
var y: int;
let
   c = false -> (pre y) >= period;
   y = 0 -> (if do_tick then 0 else (pre y) + 1);
tel;
```
. . .

```lustre
node led_control(pin: int; statee: bool) returns ()
var i : int;
   s : int;
let
   i = change_pin_state(pin, statee);
tel;
```

# C? No thanks

> But why would you want to use Zig instead of the all-mighty C? Zig's "safeness" comes with a great amount of limitations and those who give up their freedom for the sake of winning some temporary safety get neith#(IAç]/l5Q¦Bmçtl¿(Fxǐ **Segmentation fault (core dumped)**

---

![](./slides/imgs/segfault.png){ width=100% }

## (Embedded) Zig for the win

> - Free cross-compilation (thanks to LLVM AVR support*) :

```cpp
obj.setTarget(std.zig.CrossTarget{
        .cpu_arch = .avr,
        .cpu_model = .{ 
            .explicit = &std.Target.avr.cpu.atmega328p 
        },
        .os_tag = .freestanding,
    });
```
> - Harder to cause a bootloop thanks to stricter type safety

> - Nice build system: "one tool to build them all"™️

> - Everything OS/platform-independant in the std freely usable

> - Nice auto-generated docs

## Shortcomings

> - No real Zig library for Arduino -> made my own

> - Certain intrinsics (`mul`, `div_mod`) not shipped by LLVM -> custom build sequence + avr-gcc linker

## Zig backend for Heptagon

Simple copy and adaptation of the C one

Working things:

- Nodes
- Arithmetic (int, float) and boolean operations
- External nodes/functions
- All control flow operation from Lustre

. . .

Non-working things:

- Everything array-based

# Arlustre itself

## Quick recap

Arduino Uno : 

- $8$-bit MCU, single core/thread, $16$MHz
- $32$kB Flash, $2$kB RAM 
- $14$ ($20$) digital I/O, $6$ analog, with pin change interrupt
- $3$ timers with interrupts on OVF and two counters

. . . 

Small target but a lot of room for small Lustre projects

## Libz

Custom core library for Arduino Uno, in Zig. Offers:

- Bootstrap functions (RAM copying from Flash)
- System initialization
- Digital I/O read and write
- Analog I/O read through the ADC (no PWM write, there's a reason)
- Serial output
- LED matrix via SPI
- Full on-the-fly ISR allocation, interrupt (en/dis)abling, nesting on/off
- Software-backed pinChangeInterrupt with pin-level precision

. . .

All that in a human-(readable, maintenable) form (~ $2$k Zig LOC)!

## How it works

Lustre's `step` called by a timer ISR with adjustable period \rightarrow well-suited for time-critical applications, regular intervals.

ISRs allocated on-the-fly: Lustre program can change itself it's behaviour.

Interrupts: control from software for arbitrary non-blocking operators.

One timer reserved for keeping track of time (as in C lib).

# Operators

Enable control of the hardware from Lustre. All functions sould last than ~5ms (target : Lustre program running at 100sps)

. . .

Some operators were copied over the C library but some were blocking, e.g.

```python
# pulseIn, Python rewrite
def pulseIn(pin, state):
    while read(pin) != state:
        nop()
    fst_time = microseconds()
    while read(pin) == state:
        nop()
    snd_time = microseconds()
    return snd_time - fst_time
```

---

The `pulseIn` operator blocks on the signal.

Usecase : acquire distance information from ultrasound sensor

. . .

Typical width of echo: ~$1$-$10$ms \rightarrow  too much.

General usecase: theoretically up to ~$70$mn, until timer overflow.