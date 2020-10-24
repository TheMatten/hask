# hask

*Funny little Haskell implementation.* The goal is a highly annotated and _simple_ compiler for [Haskell 98](https://www.haskell.org/onlinereport/index.html).

# Status (:construction:)

There isn't really anything usable right now, but we're working on it (see [#1], [#2] and [#3]).

# *W h y ?*

It's easy to treat ~Haskell compilers~ **GHC** as a *"magic"* - even if the language is often deemed "hard" of "complicated" unrightfully, it's not a trivial one, usually used with bunch of extensions, and thus it's implementation has to work with some interesting problems. But as a normal programmer, if you want to know how Haskell works, you can't really just open GHC repo and start reading - that compiler came through 30 years of iterations, contains dozens of extensions to the original specification and there's a lot of context, jargon and technicalities behind it's code. It's documentation often assumes that you know how language works and mostly covers tricky things / corner cases - instead, we would like to assume that you (and we) don't know, and explain things along the way.

Then, having relatively simple implementation written in modern Haskell allows anyone to play with the compiler, experimenting with new designs / features / targets - who knows, maybe such project could be ground for some fruitful development in Haskell community.

And at the end, languages are fun, why not implement one just for kicks? :smile:

# More info

See [`NOTES.md`](/NOTES.md)

[#1]: https://github.com/TheMatten/hask/issues/1
[#2]: https://github.com/TheMatten/hask/issues/2
[#3]: https://github.com/TheMatten/hask/issues/3
