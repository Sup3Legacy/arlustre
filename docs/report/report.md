---
title: Arlustre
author:
- name: Constantin \textsc{Gierczak-Galle}
  affiliation: ENS Paris
numbersections: true
header-includes:
    - \usepackage{tikz}
    - \usetikzlibrary{chains,decorations.pathreplacing}
toc: True
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

# Heptagon modification

As the stock `heptagon` compiler only output C or Java (and not Zig), I had to add a custom Zig code generation backend. It is greatly inspired by the C backend with some additional logic (e.g. in Zig we do need to remember the name of all struct's fields). Not everything is implemented as of writing, as everything memory-related (i.e. arrays) does not produce correct Zig code, but everything else should be functionnal.

The generated Zig code is very C-like for obvious reasons. I could have worked on improving the Zig backend to make the generated code more idiomatic but it didn't seem worth the time, as the heart of the project was around Lustre and not the codegen backend, and because the generated code is not supposed to be read outside deugging purposes anyway.

# Low-level interface

The base Arduino Zig ressource I had at my disposition was the Zig compiler, which has support for the `avr` architecture through LLVM, and everything in Zig's std that is OS- and platform-independent. I borrowed a linker script and part of a build script (see aknowledgments on the repo) from people in the community and was ready to start implementeing the (very light) HAL.

Here's a recap of the whole interface, used in my ode under the `Libz` namespace.

## MMIO and GPIO

As with any embedded system, the main thing I needed was some sort of Memory-Mapper I/O. It is implemented as compile-time determined types that expose volatile pointers

```zig
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

# High-level bindings