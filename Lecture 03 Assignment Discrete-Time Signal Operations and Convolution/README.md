# Lecture 03 Assignment: Discrete-Time Signal Operations and Convolution
 
**Student:** Md Anwar Hossen

### Q1. Which operation changed the signal amplitude?

**Amplitude scaling** changed the signal amplitude. The operation `scaled = 2*measured` doubled every value, as shown by the red and gray curves in Task 1. The signal's frequency stayed the same.

### Q2. How did the five-sample delay change the signal?

The delayed signal shifted **five sample positions to the right**. The original waveform shape and sample amplitudes stayed the same, but five zeros were inserted at the start.

### Q3. What does the impulse response `h5[n]` represent?

`h5[n]` represents a five-point moving-average filter. Its five coefficients are each 1/5, so the filter averages five consecutive input samples. The impulse response describes the filter's output to a single unit impulse and determines its convolution behaviour.

### Q4. How did convolution change the noisy signal?

Convolution with `h5` made the noisy signal smoother by averaging neighboring samples. The green waveform in Task 3 has fewer rapid fluctuations than the gray waveform. Filtering also causes some distortion, so it does not recover the clean sine exactly.

### Q5. What differences did you observe between the 5-point and 15-point filters?

The **five-point filter** reduced noise while keeping the general shape and amplitude of the clean sine more closely. The **fifteen-point filter** produced a much flatter waveform and significantly reduced the useful sine amplitude. The difference is visible in Task 4.

### Q6. Which filter removed more noise?

The fifteen-point filter showed **stronger smoothing of rapid variations**, because it averages more samples. However, its flatter output should not be interpreted as better overall recovery: it also removes a large portion of the useful sine wave. Without the numerical noise-only comparison, the figure alone cannot quantify how much random-noise power each filter removed.

### Q7. Did the longer filter remove or distort useful signal information?

**Yes.** The fifteen-point filter reduced the desired sine-wave amplitude substantially. Its theoretical steady-state gain at the signal frequency is about 0.301, compared with about 0.904 for the five-point filter. The magenta line in Task 4 clearly shows that useful oscillation has been weakened.

### Q8. Which filter would you recommend for this signal? Explain your decision.

I recommend the **five-point moving-average filter** for the specific signal used here. It provides noticeable noise smoothing and preserves far more of the useful sine wave. The fifteen-point filter smooths more strongly, but its large amplitude reduction makes it unsuitable when the 20-sample-period sine wave must be retained accurately.

### Q9. Give one real engineering application for moving-average filtering.

Moving-average filtering can smooth readings from a **temperature sensor**. It helps reduce small, fast fluctuations so the underlying temperature trend is easier to see. The window should not be too long, because excessive averaging could hide important sudden temperature changes.