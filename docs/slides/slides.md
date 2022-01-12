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