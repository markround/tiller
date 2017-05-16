# Supported Ruby versions
Currently, Tiller will run on any Ruby version greater than 1.9.x. 

However, as of Tiller v1.2.0, official support for any Ruby version less than 2.2.0 is deprecated. This means that going forward, new features may not be available for older Ruby versions if they require extensive hacks or conditional logic to support.

My general policy is that I'll aim to target currently supported Ruby versions, which at the time of writing are 2.2.0 and up. I won't deliberately disable Tiller running on older versions, and will do my best to write code that still works on older versions but going forward I won't consider it a bug if a feature doesn't work on an older Ruby.
 
If you need a way of getting a newer Ruby version on an older system, I highly recommend [rbenv](https://github.com/rbenv/rbenv).