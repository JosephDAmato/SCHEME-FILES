## Scheme Helper File

- This is a list of files to operate specifically on data within Scheme
- Though some of this functionality probably already exists, it is an exercise
  on trying to understand the language and its versatility. My hope is to grow this and be able to extend functionality far beyond appending and mapping.

### Simply-Scheme.scm

- This files's main goal is having something to help with UC Berkeley–style SICP
  (Structure and Interpretation of Computer Programs) coursework.
- The most important thing I think I am learning with this undertaking is how
  with understanding your language you can create almost anything. I feel less
  BOXED in with how I view creating programs.

---

length

```scheme
(define (length list-arg)
(if (null? list-arg)
0
(+ 1 (length (cdr list-arg)))))
```

Description:
Recursively computes the number of elements in a list.

Example:

```scheme
(length '(1 2 3 4)) ; => 4
```

list-map

```scheme
(define (list-map list-arg func)
(if (null? list-arg)
'()
(cons (func (car list-arg))
(list-map (cdr list-arg) func))))
```

Description:
Applies a function func to each element of list-arg, returning a new list.

Example:

```scheme
(list-map '(1 2 3) (lambda (x) (\* x 2))) ; => (2 4 6)
```

list-filter

```scheme
(define (list-filter list-arg func)
(if (null? list-arg)
'()
(if (func (car list-arg))
(cons (car list-arg) (list-filter (cdr list-arg) func))
(list-filter (cdr list-arg) func))))
```

Description:
Returns a new list containing only the elements of list-arg for which func returns true.

Example:

```scheme
(list-filter '(1 2 3 4 5) even?) ; => (2 4)
```

list-append

```scheme
(define (list-append list-arg1 list-arg2)
(if (null? list-arg1)
list-arg2
(cons (car list-arg1)
(list-append (cdr list-arg1) list-arg2))))
```

Description:
Concatenates two lists without using the built-in append.

Example:

```scheme
(list-append '(1 2) '(3 4)) ; => (1 2 3 4)
```

list-reduce

```scheme
(define (list-reduce list-arg func)
(cond
((null? (cdr list-arg)) (car list-arg))
(else
(list-reduce
(cons (func (car list-arg) (cadr list-arg)) (cddr list-arg))
func))))
```

Description:
Performs a left-associative reduction on a list using binary function func.
Combines pairs recursively until one element remains.

Example:

```scheme
(list-reduce '(1 2 3 4) +) ; => 10
(list-reduce '(2 3 4) \*) ; => 24
```

String and Symbol Helpers
first

```scheme
(define (first s) (car s))
```

Returns the first element of a list or string (depending on context).

bf (“but first”)

```scheme
(define (bf s) (cdr s))
```

Returns all but the first element of a list or string.

every

```scheme
(define (every fn seq)
  (map fn seq))
```

Alias for map, included for readability and compatibility with some educational SICP-style examples.

word

```scheme
(define (word . args)
  (string->symbol
    (apply string-append
      (map (lambda (x)
             (cond ((string? x) x)
                   ((number? x) (number->string x))
                   ((symbol? x) (symbol->string x))
                   (else (error "Invalid argument to word"))))
           args)))))
```

Description:
Concatenates strings, symbols, or numbers into a single symbol.

Examples:

```scheme
(word 'hello 'world)       ; => 'helloworld
(word "foo" 42)            ; => 'foo42
(word 'A "B" 'C)           ; => 'ABC
```

⚙️ Notes
All recursive functions assume proper lists.
Avoid circular or dotted pairs unless you fully understand their behavior.
This file can be required into other SICP labs with (require "helpers.scm").

Author: Joseph D’Amato
Language: Scheme (Racket dialect)
License: MIT (recommended for educational distribution)
