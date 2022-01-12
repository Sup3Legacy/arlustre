---
title: Arlustre
author:
- name: Constantin \textsc{Gierczak-Galle}
  affiliation: ENS Paris
numbersections: true
header-includes:
    - \usepackage{tikz}
    - \usetikzlibrary{chains, decorations.pathreplacing}
toc: True
abstract: When programming an embedded platform such as the Arduino Uno, a common obstacle to the easy development of complex, parallel programs is the lack of any simple-to-use, batteries-included, no-hidden-cost synchronous programming framework. This obstacle arises e.g. as soon as one intends to make two LEDs blink simultaneously on a different frequency. This is caused by the single-threaded nature of the MCU and the relatively constraining Flash and RAM capacities. this project aims at providing a proof-of-concept solution to this problem through a high-level interface between the synchronous Lustre language and the Arduino hardware.
---

# Introduction

Arlustre is a project centered around the development of a high-level Lustre interface for the Arduino Uno device.

## Motivation

No need to present the well-known and allmighty Arduino platform. It allows anyone to program minimalistic embedded software and get some fun with LED, dials, buttons, etc. Anyone who has some experience with Arduino has begun with something like this

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

Seeing the LED that blinks as isntructed by own-written code is at first so delightful, but it rapidly gets boring and one wants to add another LED, blinking at half the frequency.

So one writes the following code 

```cpp
int LED1 = 13;
int LED2 = 12;

void setup()   {                
  pinMode(LED1, OUTPUT); 
  pinMode(LED2, OUTPUT);         
}

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

And... This doesn't work. Obviously. But how to do this?

```cpp
int LED1 = 13;
int LED2 = 12;

void setup()   {                
  pinMode(LED1, OUTPUT); 
  pinMode(LED2, OUTPUT);         
}

void loop()                     
{
  digitalWrite(LED1, HIGH);
  digitalWrite(LED2, HIGH);
  delay(500);
  digitalWrite(LED2, LOW);
  delay(500);

  digitalWrite(LED1, LOW);
  digitalWrite(LED2, HIGH);
  delay(500);
  digitalWrite(LED2, LOW);
  delay(500);
}
```

Now, this does work. But kind of a pain to write. A lot a redundant code, and we are even is the almost-optimal case with two frequencies, one being the double of the other.

A more clever implementation would be to use an universal runtime-based state machine running at a specific frequency with events occuring at some ticks. I have already done in Zig [such an implementation](https://github.com/Sup3Legacy/hd-mp3) to blink between 0 and ~15 LEDs on a USB music mixing device with arbitrary frequencies and temporal offsets. However, this would not really fit into a more general usecase on the Arduino platform (e.g. interraction with timers, interrupts, I/O, etc.).

This project was all about making the development of such synchronous and parallel tasks (easily) possible, and that with minimal (i.e. none) dependencies and a light HAL (hardware abstraction layer).

## Lustre and toolchain

The Lustre synchronous language is built to fit such a programming paradigm. In this project, I used (and modified) the [Heptagon](https://gitlab.inria.fr/synchrone/heptagon) compiler.

I wanted to avoid doing any programming in C for the simple reason I do not like to use this language. I wanted to use instead [Zig](ziglang.org) because it allows for a more modern programming style with error enums, optional types, compile-time execution and simple build scripting capabilities. That means I was not able to reuse the stock Arduino C library from the Arduino team (I'll call `libcore` here) and had to redo everything I needed entirely from scratch.

## Technical scope

As I never intended for my work to be really portable, it is only compatible with the Arduino Uno variant (although making a more general HAL should not be difficult, only a bit technical and time-consuming). So everything technical-related detail in this report or in my code implicitly only refers to the Arduino Uno (with Atmega328p MCU).

Although Zig is already several years old and hopefully nearing stability, it is susceptible to changes over different versions. I used Zig 0.9.* versions during my work.

# Heptagon modification

As the stock `heptagon` compiler only output C or Java (and not Zig), I had to add a custom Zig code generation backend. It is greatly inspired by the C backend with some additional logic (e.g. in Zig we do need to remember the name of all struct's fields). Not everything is implemented as of writing, as everything memory-related (i.e. arrays) does not produce correct Zig code, but everything else should be functionnal.

The generated Zig code is very C-like for obvious reasons. I could have worked on improving the Zig backend to make the generated code more idiomatic but it didn't seem worth the time, as the heart of the project was around Lustre and not the codegen backend, and because the generated code is not supposed to be read outside deugging purposes anyway.

Something that had consequences over the implementation of the hardware/Lustre interface is the unique `int` type. The C bakcend translates this type to the C type `int`, which is `32` bits on most modern platforms. This bit-width is generally speaking sufficient and barely implies any performance/memory penalty when compared to smaller integer sizes (e.g. in a some usecases, a `char` or a `short` would ne sufficient). However, this is simply not the case with the Arduino platform, or even with any 8-bit MCU-based platform. Here, we are dealing with very constrained memory capacities (even stripped-down, the executable of my testbench is approx. 9kB, so a significant chunk of the total 32kB of flash) and limited CPU performance. The standard `int` bit-width on Arduino is 16 bits. That means any arithmetic operation on these integers results in multiple 8-bit instructions and multiple registers, which contributes to slowing down the program execution as well as thicken up the binary and clogger the (limited) stack.

However, limiting the integers in the Lustre program to less than 16 bit width would be too much of a constrain, so I chose to convert the Lustre `int` to Zig's `isize`, i.e. signed 16-bit integers on the Arduino platform.

In some specific cases (e.g. the distance sensor, which returns a sort-of timestamp), a larger bit-width is needed. In that case, all the conversion logic is hidden behidn the interface and the Lustre program manipulates 32-bit integers as 2 `int`s.

If I had more time, maybe a nice addition to `Heptagon` would be some different-width intergers to be optionnaly used alongside the `int` type.

# Low-level interface

The base Arduino Zig ressource I had at my disposition was the Zig compiler, which has support for the `avr` architecture through LLVM, and everything in Zig's std that is OS- and platform-independent. I borrowed a linker script and part of a build script (see aknowledgments on the repo) from people in the community and was ready to start implementeing the (very light) HAL.

Here's a recap of the whole interface, used in my ode under the `Libz` namespace.

## MMIO and GPIO

As with any embedded system, the main thing I needed was some sort of Memory-Mapper I/O. It is implemented as compile-time determined types that expose an I/O interface through volatile pointers.

```rust
pub fn MMIO(comptime addr: usize, comptime IntType: type, comptime ReprType: type) type {
    return struct {
        pub fn ptr() *volatile IntType {
            return @intToPtr(*volatile IntType, addr);
        }
        pub fn read() ReprType {
            const intVal = ptr().*;
            return @bitCast(ReprType, intVal);
        }
        pub fn write(val: ReprType) void {
            const intVal = @bitCast(IntType, val);
            ptr().* = intVal;
        }
    };
}
```

The GPIO module is directly built on top of that and exposes a similar interface to the `libcore`'s one (w/ `DigitalMode`, `DigitalWrite`, etc.). 

## Interrupts

I chose to build the whole system making an extensive use of interrupts to make everything "time-accurate" and allow for multiple virtual threads. 

The `Libz`'s interrupt handling system is designed around a higher-stage interrupt vector that can be modified at runtime. This means that every interrupt can be reconfigured from the Lustre program or the Libz-runtime. 

### Timer interrupts

The Arduino Uno has three different built-in, independently controlled, timers.  

The first one is by default hooked up to a function in charge of keeping track of time (with precision in the order of the tens of microseconds, as I understand). 

The second timer is used to run the transpiled Lustre program. On each interrupt, the global `step` function is called. This means that the system steps at a very regular interval (assuming the run-time of `step` never exceeds the period of the interrupt; when testing, with my LED/button/potentiometer/joystick testbench, I used a period of 10'000µs=10ms, i.e. a frequency of 100Hz), compared to the infinite looping with `delay(period)`s that do not take the (possibly varying) run-time of `step` into account. Thanks to that, every node of the Lustre program steps very regularly, independently of the computing activity of the other nodes.

This approach does have a drawback : As almost everything is computed from an ISR, all further interrupts are disabled during this time, which can last sereval `ms`. This means that the software clock will run slower than normal time, possibly making any time-based measurement inaccurate. The other implication is that if ever the run-time of that ISR (even slightly) exceeds the period of the corresponding timer, the next step will be (at least) one timer cycle late). 

Thankfully, the microcontroller is able to schedule interrupts (when an interrupt request arrives, even if the global interrupt bit is disabled, the individual interrutp bits stays up. When the current ISR returns, the one that arrived is still in stand-by and the corresponding ISR is then executed), so a loss of accuracy is to be expected but we should not miss too much interrupts.

A further solution is to re-enable interrupts on a global basis when entering the `step`-bound ISR. This means that any external event (time-keeping timer, pin change interrupt, etc.) can be served directly with no additional delay. However, this leads the way to nesting interrupts that can become a nithgtmare to debug. Essentially, we trade reliability and stability for accuracy. This can be mitigated by increasing the `step` period to make sure we'll never have nesting `step` interrupts.

To futher help stabilize the behaviour around interrupts and avoid looping in nested interrupts, I implemented a software-side control of nesting detection, using some custom atomic (basically force-disabling interrupts on a global scale durign the critical operation) operations.

### Hardware interrupts

To allow for time-based Lustre operators, I implemented the support of `Pin Change Interrupt`s. On the Arduino Uno, there are 3 corresponding interrupt channels, each bound to a port (i.e. ~8 GPIO pins). This means that, chen such an interrupt is firing, some work is needed to determine which particular pin in the corresponding port did change. This is simply implemented using static arrays where the whole port's state is stored on each interrupt.


# High-level bindings

This is the heart of the project, consisting of an interface between Zig and Lustre. This interface is defined as a Lustre external interface (`interface.epi` file) with a corresponding code file (`interface.zig`). I defined these fucntions as "operators" that give the Lustre program access to the Arduino hardware in the most usable and sensible way to my knowledge.

As I am far from fluent in Lustre, I stumbled onto the following problem : some operators I want not to execute on each step, e.g. `declare_io`, used to declare the digital mode of a GPIO pin. I only want to execute it once.

However, the `res = if (true -> false) then declare_io(...) else false;` does not work as the `declare_io(...)` node steps on each cycle even after the first cycle, as Lustre, as it seems, uses a sort of greedy evaluation paradigm. So I had to add to all any side-effect-generating operator that shall not execute every cycle an additional boolean argument (often called `do_step`) that dictates whether the execution should or not take place.

Other things like signal delay measurments are interfaced by an operator that "packs everything in" because there is no way in Lustre to ensure constant known time between the execution of two nodes.

## Simple GPIO

Some operators are defined to enable simple actions like setting the mode of a GPIO pin or switching bewteen High and Low state.


This can also be used as a very simple-to-timplement PWM generator, in the case the desired frequency does not exceed the frequency of the `step` interrupt.

## Higher level GPIO

## Interrupt based operators

A non-trivial challenge emerged when trying to use the ultrasound-based range sensor. It has two data pin, one as input signal and one as output echo. The former shall receive a square signal of ~10ms width and some time after, the latter while emit a square signal with width proportional to the measured length. Here, we are talking of a width in the order ~1ms to ~10ms.

The `libcore` uses such approach : the signal is emitted with a call to `delayMicrosedond` (ASM-programmed delay accurate function) surrounded by two `DIGITAL_MODE` calls. The echo is measured using the `pulseIn` function, which "simply" polls the pin at a high rate to detect when changes occur.

This has the advantage of being accurate and "easy" to implement (although technical as these routines are partly programmed in ASM for accuracy sakes). However I was not able to follow the same approcha as the echo's width was too large (in the case of ultrasound echoes, around 1-10ms, which is already too long, but theoritically up to several dozens minutes!) to reasonably fit inside the `step` ISR : I would not have been able to just poll in a loop waiting for the change. This means that the `pulseIn` is a blocking operator, while the Lustre runtime needs a non-blocking operator. So I used pin change interrupts to make such an operator.

(I would advice looking at the `time_pulse_step` function in `itnerface.zig` to fully understand the following explaination)

The `time_pulse` operators takes in two pin ids : one for the emitted signal and one for the echo signal as well as a state signal (`do_step`). The sstate signal dictates, on each Lustre tick, whether the operator should start a measure or wait for/read the result.

When `do_step` is on, the output signal is fired up using a delay (here, the delay is a few µs so no need to use any interrupt-based method as this is a very short amount of time) and the echo signal pin's interrupt is setup and enabled.

When `do_step` is off, the operators poll the static vectors containing various data about the pin change interrupts (such as "did it fire since enabled", "how many times did it fire up", "what was the last time it fired up" "what is the last delay between two interrupts"), and outputs the results according to them.

Thanks to that implementation, we can have an accurate time-based measurement over a long period, possibly extending over multiple period of the Lustre program whithout any compromise over all the other nodes, essentially implementing an asynchronous pulse measurment.

After some tests, it seems that it is in fact working, as I get very reasonable data from the range sensor through this method.

# Possible extensions

## Lustre-space operators

A possible extension to my work would be to move some of the logic that currently sits inside the Zig runtime into Lustre, e.g. the logic behind `time_pulse`. It contains a state machine that could be implemented directly in Lustre, using some `merge` and `when` constructions.

## Implement array-based operations

The specificity of Heptagon versus stock Lustre is that it adds a whole lot around arrays of values. `Arlustre` *does not* support them, be it in the codegen backend or in the Zig runtime, and this for several reasons :

- Time. Simply time, as I had a lot to do with the core functionnalities of `Arlustre`
- Usecase. I did play around a bit with my testbench but did not really feel the need for array-based opetations myself (Not saying they're useless of cours, simply that my proof-of-concept examples are simple enough to not use large amount of values)
- Memory and compute time. It seems to me that these operations are implemented using some sort of dynamic memory alocation, which is not a typical usecase of the Arduino platform, with it's very very limited memory capacity. I could totally add a small allocator (Zig does provide a very handy and practical way of defining custom memory allocators), but this would not be very idiomatic of the Arduino platform. The allcoator would also consume some compute time, which we do not have so much of :).

## Improve the Zig codegen

As Heptagon's Zig backend is very primitive and "copied over" from the C one, the code is, as said, not idiomatic and would benefit from a rewrite.