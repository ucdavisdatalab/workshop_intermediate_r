R Beyond Basics Assessment
==========================

Complete this assessment to earn Microbadge: R Basics in the [GradPathways
Research Computing Pathway][pathway].

[pathway]: https://gradpathways.ucdavis.edu/research-computing-pathway

Complete any eight of the following exercises. Make sure to include the
exercise number and prompt with each answer.


## Exercise 1

Is the following a syntax error or an evaluation error?
```
foo(x, y)
Error in foo(x, y) : could not find function "foo"
```


## Exercise 2

1.  Does the following code cause a syntax error or an evaluation error?
    ```
    a = list(other = "oil", xy2 = "Population")
    plot(x[[1]], y[[i], main = "GDP versus Population', xlab = a$2xy)
    ```
2.  How did you reach your answer to part 1? 
3.  How do you correct this call?


## Exercise 3

Consider the following code:

```
f = function(x) sin(2 * x * pi)
```

1. Where is `pi` found in the call `f(20)`?

2.  If we then run:
    ```
    attach(list(pi = 1, z = 2))
    pi = 3
    ```
    Where is `pi` found in the call `f(20)`?


## Exercise 4

1.  Is the following call legitimate? A syntax error? An evaluation error?
    ```r
    matplot(data, col = "red", ce = 3, lt = 2, lwd = 3, pch = "x", ce = 3,
      ylim = c(0, 100), verb = TRUE)
    ```
2.  What is needed to correct it?


## Exercise 5

Consider the following function call:

```r
matplot(data, col = "red", verb = TRUE, lt = 2, lw = 3, pch = "x", ce = 3,
  ylim = c(0, 100), verbose = TRUE, main = "Title for the plot",
  ylab = "Percent")
```

What will the value of each of the parameters (including `...`) be in the call
frame?


## Exercise 6

Consider this code:
```
gen = function(x)
{
   function(a) x + a
}
f = gen(1:10)

w = 101
f(w)
```
In the call `f(w)`, where will R find the values of `a` and `x`, and what are
their values?


## Exercise 7

The body of the function `lm` calls `model.response` and `NROW`. Where does R
find these when evaluating the body of the call to `lm`?


## Exercise 8
With 
```
x = 10:1
```
what are the results and lengths for:

a. `x[3]`
b. `x[c(3, 3)]`
c. `x[23]`
d. `x[c(3, NA)]`
e. `x[NA]`

What rule governs the last of these?
 

## Exercise 9

We have a list with 20 vectors in `y`:
```
set.seed(11658313)
y = replicate(20, rpois(10, 1), simplify = FALSE)
```
I want to get the element of y that has the largest
value and I find the index with:
```
x = sapply(y, max)
i = which(x == max(x))
```

1. Why does `y[[i]]` not give me the vector I intended?
2. What was my incorrect assumption?


## Exercise 10

The base package contains a variable named `version`. This is used in the
function `is.R`:

```r
function () 
exists("version") && !is.null(vl <- version$language) && vl == 
    "R"
<bytecode: 0x7fc3799ee958>
<environment: namespace:base>
```

Suppose we create a variable in our R session (global environment)
named `version`, for example:

```
version = "1.3-0"
```

and then call `is.R()`. Where will `is.R` find the variable `version` when it
evaluates `version$language`?


## Exercise 11

_An alternative version(!) of the previous question._

The `gaussian()` function is defined in stats package. It is used to define a
gaussian family in a generalized linear model (see the help `?gaussian`). It
uses the variable  `pi`.

1.  When we redefine `pi` as we did above,  will `gaussian()` behave
    differently?
2.  Is this good or bad? 
3.  If we wanted the opposite to occur, how could we do this?


## Exercise 12

Consider the function:
```
f = function(x, len = length(x))
{
  x = x[!is.na(x)]
  sum(x) / len
}
```
Now, 
```
a = rnorm(10)
a[c(3, 9)] = NA
f(a)
```

1. What is the value of `len` in `sum(x) / len`?
2. What about for `f(a, 20)`?


## Exercise 13

Consider the function definition:

```
f = function(x, y)
{
   if(is.numeric(x) && all(x < 0))
     return(sum(x))
	 
    x ^ y
}
```

Now we call this with:
```
set.seed(12312)
a = rnorm(100, - 20, 4)
f(a, z <- 3)
```

1.  What is the value of `z` at the end of the call? Where is it found?
2.  Next we evaluate

    ```
    a = rnorm(100, 20, 4)
    f(a, z <- 3)
    ```

    What is the value of `z` and where is found?


## Exercise 14

We define a function as:
```
toPDF =
function(imgFile, outFile = removeExtension(imgFile), 
         renderer = PDFRenderer(outFile, GetDataPath(api), ...),
         api = tesseract(, PSM_AUTO), ...)
{
   args = list(...)
   args$x
}
```

1. Can the default value of renderer be a call that references `outFile`?
2. How will it find `outFile`? And how will it find the `api` variable?  


## Exercise 15

Explain the three uses of  `...` in the function `toPDF` in Exercise 14.


## Exercise 16

Consider these three code snippets:
```
lapply(x, function(x) identical(x, target))
```

```
check = function(x) identical(x, target)
lapply(x, check)
```

```
lapply(x, function(x, a) identical(x, a), target)
```

1. What are the similarities and differences between these three
   implementations of essentially the same thing?
2. Where is target found in each of these calls?
