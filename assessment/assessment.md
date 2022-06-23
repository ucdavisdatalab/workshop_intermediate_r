# 
Possible questions for the assesment of the 'R: beyond basics'
We wouldn't include all of them, but 
+ just a subset, or
+ answer any k of them 


1. Is the following a syntax error or an evaluation error?
```
foo(x, y)
Error in foo(x, y) : could not find function "foo"
```

1. Is the following a syntax error or an evaluation error?
```
a = list(other = "oil", xy2 = "Population")
plot(x[[1]], y[[i], main = "GDP versus Population', xlab = a$2xy)
```
+ How do you determine this? 
+ How do you correct this call?


1. In the following code, 

```
f = function(x)
         sin(2 * x * pi)
```
where is `pi` found in the call `f(20)`?

If we then issue the commands
```
attach(list(pi = 1, z = 2))
pi = 3
```
where is `pi` found in the call `f(20)`?


1. Is the following call legitimate? a syntax error? an evaluation error?
```r
matplot(data, col = "red", ce = 3, lt = 2, lwd = 3, pch = "x", ce = 3,  ylim = c(0, 100), verb = TRUE)
```
What is needed to correct it?


1. In the following function call  to 
what will the value of each of the parameters, including ..., be
in the call frame:
```r
matplot(data, col = "red", verb = TRUE, lt = 2, lw = 3, pch = "x", ce = 3,  ylim = c(0, 100), verbose = TRUE,
           main = "Title for the plot", ylab = "Percent")
```

1. Where will R find the value of a and x in the
and what are their values in this call?
```
gen = 
function(x)
{
   function(a) 
      x + a
}
f = gen(1:10)

w = 101
f(w)
```


1. The body of the function `lm` calls `model.response` and `NROW`.
Where does R find these when evaluating the body of the call to `lm`?


1. With 
```
x = 10:1
```
what are the results and lengths for:
 1. `x[3]`
 1. `x[c(3, 3)]`
 1. `x[23]`
 1. `x[c(3, NA)]`
 1. `x[NA]`
What rule governs the last of these?
 

1. 
We have a list with 20 vectors in `y`
```
set.seed(11658313)
y = replicate(20, rpois(10, 1), simplify = FALSE)
```
I want to get the element of y that has the largest
value and I find the index with 
```
x = sapply(y, max)
i = which(x == max(x))
```
Why does 
```
y[[i]]
```
not give me the vector I intended?
What was my incorrect assumption?


1. The base package contains a variable named `version`.
This is used in the function `is.R`
```r
function () 
exists("version") && !is.null(vl <- version$language) && vl == 
    "R"
<bytecode: 0x7fc3799ee958>
<environment: namespace:base>
```
Suppose we create a variable in our R session (global environment)
named `version`, e.g., 
```
version = "1.3-0"
```
and then call `is.R()`.
Where will `is.R` find the variable `version` when it evaluates
`version$language`?


1. [An alternative version(!) of the previous question] 
The `gaussian()` function is defined in stats package. It is used to define a gaussian family in a
  generalized linear model (see the help `?gaussian`).
  It uses the variable  `pi`.
  When we redefine `pi` as we did above,  will `gaussian()` behave differently?
Is this good or bad? 
If we wanted the opposite to occur, how could we do this?

<!--
1. The function as.data.frame.table in the base
package uses the non-local variable LETTERS.
Suppose we wanted our own version of LETTERS, such as, 
```
LETTERS = c("Ͱ", "Ͳ", "Ͷ", "Ϳ", "Ά", "Έ", "Ή", "Ί", "Ό", "Ύ", 
"Ώ", "Α", "Β", "Γ", "Δ", "Ε", "Ζ", "Η", "Θ", "Ι", "Κ", 
"Λ", "Μ", "Ν", "Ξ", "Ο", "Π", "Ρ", "Σ", "Τ", "Υ", "Φ", 
"Χ", "Ψ", "Ω", "Ϊ", "Ϋ", "Ϗ", "Ϣ", "Ϥ", "Ϧ", "Ϩ", "Ϫ", 
"Ϭ", "Ϯ", "ϴ", "Ϸ", "Ϲ", "Ϻ", "Ͻ", "Ͼ", "Ͽ")
```
Next we call
```
tb = table(sample(LETTERS, 200, replace = TRUE))
as.data.frame(tb)

```


Aside, here is how we got these letters.
```r
txt = RCurl::getURLContent("https://en.wikipedia.org/wiki/List_of_Unicode_characters#Greek_and_Coptic")
tt = XML::readHTMLTable(htmlParse(txt))
tbl = tt$Table_Greek_and_Coptic
tbl[[2]][ grepl("Capital", tbl[[4]]) ]
```
-->



1. Consider the function
```
f =
function(x, len = length(x))
{
  x = x[!is.na(x)]
  sum(x)/len
}
```
Now, 
```
a = rnorm(10)
a[c(3, 9)] = NA
f(a)
```
What is the value of `len` in `sum(x)/len`?

And in
```
f(a, 20)
```



1. Consider the function definition
```
f = 
function(x, y)
{
   if(is.numeric(x) && all(x < 0))
     return(sum(x))
	 
    x ^ y
}
```
Now we call this with 
```
set.seed(12312)
a = rnorm(100, - 20, 4)
f(a, z <- 3)
```
What is the value of `z` at the end of the call?
where is it found?

Next we evaluate
```
a = rnorm(100, 20, 4)
f(a, z <- 3)
```
What is the value of `z` and where is found?




1. We define a function as
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
Can the default value of renderer be a call that references outFile?
How will it find outFile?  And how will it find the api variable?  


1. In the function `toPDF()` above, explain the three uses of  `...`


1.
+ What are the similarities and difference between these three implementations
  of essentially the same thing:
```
lapply(x, function(x)
            identical(x, target))
```

```
check = function(x)
           identical(x, target)
lapply(x, check)
```

```
lapply(x, function(x, a)
            identical(x, a),
          target)
```
Where is target found in each of these calls?
