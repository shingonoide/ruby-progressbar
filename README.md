# ruby/progressbar

Ruby/ProgressBar is a text progress bar library for Ruby.

It can indicate progress with percentage, a progress bar, and estimated remaining time.

## Limitations

Since the progress is calculated by the proportion to the 
total cost of processing, Ruby/ProgressBar cannot be used if
the total cost of processing is unknown in advance.
Moreover, the estimation of remaining time cannot be
accurately performed if the progress does not flow uniformly.

---

[Satoru Takabayashi](http://namazu.org/~satoru/)

Cleaned up by [Leonid Shevtsov](http://leonid.shevtsov.me)
