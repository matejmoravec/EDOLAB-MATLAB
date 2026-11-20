# AMPPSO vs AMPPSO_GI vs AMPPSO_BC

Branch `comparison-v2`, working tree as of 2026-11-20. Files compared: `Algorithm/AMPPSO*/`, after normalising names, line endings and whitespace.
The variants were added in commit `e753ef2fdfb` ("Add CEC 2025 results ... GI-AMPPSO and AMPPSO-BC"). Their headers are copied verbatim from AMPPSO (AMP-PSO, Li et al. 2016). **GI** = "genetic improvement": Stanovov & Semenkin, *Genetic Improvement of Dynamic Optimization Algorithms using PushGP*, GECCO '25 Companion, doi 10.1145/3712255.3734281 (the paper is called GI-AMP/PSO there). I did not find what **BC** stands for, and the paper does not cover it (the competition page credits AMPPSO-BC to different authors).

## Where they differ

All three share the same parameter files, `SubPopulationGenerator_*` and run loop. The differences are in `IterativeComponents_*`, `ChangeReaction_*`, and a few lines of `main_*`.

| Aspect | AMPPSO (base) | AMPPSO_GI | AMPPSO_BC |
|---|---|---|---|
| Brownian move of a swarm's best particle | Gbest + N(0,1)·radius, 2 tries (`IterativeComponents_AMPPSO.m:77-97`) | Pbest of the best particle + N(0,1)·radius, then blended with the 2nd-best Pbest by factor `randn()`: `x = n1 + r·(p2 − n1)`, 2 tries (`..._GI.m:77-90`) | Gbest + N(0,1)·radius·(1+0.1·try), 2 tries; restores the original position after a failed first try; `break`s after the first improvement (`..._BC.m:76-111`) |
| Cauchy move (stagnated swarm) | t-distribution (ν=1), scale = range/10, once (`..._AMPPSO.m:99-117`) | No Cauchy draw. Same blend as above (best Pbest + N(0,1)·radius, blended with 2nd-best by `randn()`); wrapped in a `for tries = 1:1` loop; repaired when out of the box (`..._GI.m:106-125`) | Cauchy scale = clamp(`Environmentcounter`/20, 0.1, 0.5)·range, so it grows with the environment index (`..._BC.m:118-123`) |
| Change reaction | Re-evaluate swarm, reset Pbest/Gbest, reset velocity to U(−1,1), keep previous Gbest (`ChangeReaction_AMPPSO.m:24-32`) | Identical to base | Same, plus a "velocity range" `clamp(Environmentcounter/10, 0.5, 2)` applied **once, after the loop, to swarm `jj` only** (`ChangeReaction_AMPPSO_BC.m:15-17`) |
| Diversity threshold in activation test and non-stagnated radius check | `Optimizer.diversityFactor` (default 0.005) | Hardcoded 0.005 (`..._GI.m:161,238`) | Hardcoded 0.005 (`..._BC.m:181,258`) |
| `Optimizer.ShiftSeverity` initial value | 1 | 1 | `Problem.ShiftSeverity` (`main_AMPPSO_BC.m:61`) |
| Other (`main`) | Header "May 6, 2025", template comments for user indicators | Older `main` layout: `tic` placed after RNG setup, no template comments | Same older layout |
| SubPopulationGenerator, parameter file | — | identical to base | identical to base |
| Parameters (w, c1, c2, initPopulationSize, ConvergenceLimit, OverlapDegree, StepIndivs, diversityFactor) | 0.7298, 1.496, 1.496, 100, 1e-5, 0.1, 10, 0.005 | same values | same values |
| CEC 2025 GMPB rank (competition page) | not entered | 1st, score +43 | 3rd, score +22 |

## Concerns in the new variants (read from code; not run)

1. **BC ChangeReaction applies velocity range to one swarm only.** The two lines at `ChangeReaction_AMPPSO_BC.m:15-17` sit after the `for jj` loop, so `jj` is the last swarm; only that swarm's velocities are overwritten. Likely a misplaced `end`. If `SwarmNumber == 0`, `jj` is undefined there and the line errors (suspicious, needs verification).
2. **BC skips the change check after an improving Brownian try.** After `break` at `..._BC.m:101-105` control leaves the loop without testing `Problem.RecentChange`, so if that evaluation triggered the change, later code in the same iteration may call `fitness` on a finished environment and get NaN (suspicious, needs verification).
3. **GI needs at least two particles.** It reads `index(2)` of the sorted Pbest values (`..._GI.m:80,109`). A swarm of one particle would error (suspicious; I did not check whether swarms can shrink to one).
4. **Hardcoded 0.005 in GI and BC** ignores the `diversityFactor` parameter. The default matches, so results agree until a user changes it (same pattern as C6 in `concerns.md`).
5. **BC uses `Problem.Environmentcounter` as a tuning input** for Cauchy scale and velocity range. The article's black-box rule says algorithms are told only that a change happened, so this uses the environment index (inferred concern, not verified against the CEC rules).
6. **The CEC 2025 rank is not a performance statement about these exact files.** The rank comes from the competition submissions; I did not check that the committed code matches what was submitted.

## Open questions
- What does "BC" stand for, and are GI and BC the exact submitted CEC 2025 versions?
- Is the BC `ChangeReaction` placement of the velocity lines intentional?

## What the GI paper confirms (Stanovov & Semenkin 2025)
- PushGP evolved a local-search heuristic on mQSO. Its simplified form is four instructions: `vector.normrand vector.+ float.normrand vector.between` (Algorithm 3). That is: a Gaussian point next to the best, then a point on the line from it to the second-best, at a `N(0,1)`-distributed position.
- It was then inserted into AMP/PSO and **replaced both the Brownian and the Cauchy move**; "the Cauchy distribution was not used" (Sect. 4.3). This matches `IterativeComponents_AMPPSO_GI.m:77-125`.
- Results: lowest Friedman rank in the paper's comparison; always better than or similar to AMP/PSO; loses to AMP/DE on some instances (the paper names F9 and F10, smaller change frequency or larger dimension).
- On mQSO alone the gain was not significant overall (Mann-Whitney p = 0.0935, Table 2).
- The extracted equation (6) is garbled, so I could not check whether the code's scaling of the Gaussian noise by the swarm radius is stated there.
