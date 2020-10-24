# hask
Funny little Haskell implementation. The goal is a highly annotated and _simple_ compiler for [Haskell 98](https://www.haskell.org/onlinereport/index.html).

# Status (:construction:)

There isn't really anything usable right now, but we're working on it (see [#1], [#2] and [#3]).

# *W h y ?*
It's easy to treat ~Haskell compilers~ **GHC** as a *"magic"* - even if the language is often deemed "hard" of "complicated" unrightfully, it's not a trivial one, usually used with bunch of extensions, and thus it's implementation has to work with some interesting problems. But as a normal programmer, if you want to know how Haskell works, you can't really just open GHC repo and start reading - that compiler came through 30 years of iterations, contains dozens of extensions to the original specification and there's a lot of context, jargon and technicalities behind it's code. It's documentation often assumes that you know how language works and mostly covers tricky things / corner cases - instead, we would like to assume that you (and we) don't know, and explain things along the way.

Then, having relatively simple implementation written in modern Haskell allows anyone to play with the compiler, experimenting with new designs / features / targets - who knows, maybe such project could be ground for some fruitful development in Haskell community.

And at the end, languages are fun, why not implement one just for kicks? :smile:

# References
- [Typing Haskell in Haskell - Mark P. Jones](https://gist.github.com/chrisdone/0075a16b32bfd4f62b7b)
- [Haskell 98 Language and Libraries: The Revised Report](https://www.haskell.org/onlinereport/index.html)
- [The Implementation of Functional Programming Languages - Simon Peyton Jones](https://www.microsoft.com/en-us/research/publication/the-implementation-of-functional-programming-languages/)
- [Implementing Functional Languages: A Tutorial - Jones and Lester](https://www.microsoft.com/en-us/research/publication/implementing-functional-languages-a-tutorial/)
- [Implementing Lazy Functional Languages on Stock Hardware: The Spineless Tagless G-machine - Simon Peyton Jones](https://www.microsoft.com/en-us/research/publication/implementing-lazy-functional-languages-on-stock-hardware-the-spineless-tagless-g-machine/)
- [System FC As Implemented in GHC (2020)](https://gitlab.haskell.org/ghc/ghc/blob/master/docs/core-spec/core-spec.pdf)
- [System F with Type Equality Coercions - Sulzmann, Chakravarty, Jones, Donnelly](https://www.microsoft.com/en-us/research/wp-content/uploads/2007/01/tldi22-sulzmann-with-appendix.pdf)
- [The Glasgow Haskell Compiler - Simon Marlowe and Simon Peyton Jones](https://www.microsoft.com/en-us/research/wp-content/uploads/2012/01/aos.pdf)

[#1]: https://github.com/TheMatten/hask/issues/1
[#2]: https://github.com/TheMatten/hask/issues/2
[#3]: https://github.com/TheMatten/hask/issues/3
