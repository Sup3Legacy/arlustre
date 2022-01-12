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

## (Embedded) Zig for the win

- Free cross-compilation (thx to LLVM AVR support [^1]) :

```cpp
obj.setTarget(std.zig.CrossTarget{
        .cpu_arch = .avr,
        .cpu_model = .{ 
            .explicit = &std.Target.avr.cpu.atmega328p 
        },
        .os_tag = .freestanding,
        .abi = .none,
    });
```



[^1]: Currently, the upstream LLVM AVR target is broken and does not support certain intrinsics

qsd