# MATLAB Assignment — Z-transform and One-Sample Delay


## Answers to all six tasks

### Part 1

**1. Identify each sample represented by the terms in X(z).**

`X(z) = 1 + 2z^(-1) + z^(-2)`.

- `1` corresponds to `x[0] = 1`.
- `2z^(-1)` corresponds to `x[1] = 2`.
- `z^(-2)` corresponds to `x[2] = 1`.

**2. Write the Z-transform of the delayed signal.**

The one-sample delayed sequence is `[0 1 2 1]`, starting at `n = 0`.

`X_delayed(z) = z^(-1) + 2z^(-2) + z^(-3)`.

**3. Explain the multiplication by z^(-1).**

A one-sample delay shifts each original sample from index `n` to `n + 1`. In the Z-transform, the power of `z^(-1)` therefore increases by one, so `X_delayed(z) = z^(-1) X(z)`.

### Part 2

**4. Calculate y[0], y[1], y[2], y[3] by hand.**

For `y[n] = 0.5x[n] + 0.5x[n-1]`, with all unlisted input samples zero:

- `y[0] = 0.5(1) + 0.5(0) = 0.5`
- `y[1] = 0.5(2) + 0.5(1) = 1.5`
- `y[2] = 0.5(1) + 0.5(2) = 1.5`
- `y[3] = 0.5(0) + 0.5(1) = 0.5`

Expected MATLAB output: `[0.5 1.5 1.5 0.5]`. Compare against your actual run.

**5. Explain b = [0.5 0.5].**

`b(1) = 0.5` weights the current input `x[n]`, and `b(2) = 0.5` weights the previous input `x[n-1]`. Both inputs contribute equally. The denominator `a = 1` means this is a finite impulse response (FIR) filter.

**6. Change to H(z) = 0.8 + 0.2z^(-1) and explain.**

Set `bNew = [0.8 0.2]`. The formula becomes `yNew[n] = 0.8x[n] + 0.2x[n-1]`.

The expected output is `[0.8 1.8 1.2 0.2]`. The current input has more influence because its coefficient `0.8` is four times the previous input's coefficient `0.2`.

