# EDOLAB (MATLAB): project guide (DRAFT for approval, not yet in the project root)

EDOLAB is a MATLAB platform for evolutionary dynamic optimization: 27 EDOAs, 4 benchmark generators (MPB, GMPB, GDBG, FPs), and 2 indicators (offline error `E_o`, best-before-change error `E_bbc`). The reference article is Peng et al., ACM TOMS 52(1) Art. 4, 2026 (doi 10.1145/3785134). The code (v2.10, Nov 2025) is **newer than the article**. See `review/traceability.md` for known differences.

## Layout
- `CodeMode.m`: script entry point. Set `AlgorithmName`, `BenchmarkName`, `RunNumber`, and overrides on `Configurable*Parameters.<p>.value`.
- `GUIMode.m`: 6.5k-line App Designer-style class (batch runs, parfeval, stats panel).
- `Algorithm/<Alg>/`: `main_<Alg>`, `SubPopulationGenerator_<Alg>`, `IterativeComponents_<Alg>`, `ChangeReaction_<Alg>`, `getAlgConfigurableParameters_<Alg>`.
- `Benchmark/<B>/`: `BenchmarkGenerator_<B>` (pre-generates ALL environments), `fitness_<B>`, `getProConfigurableParameters_<B>`.
- `Benchmark/fitness.m`: the ONLY evaluation entry point. It counts FEs, triggers changes when `FE mod ChangeFrequency == 0`, and records `CurrentError`/`Ebbc`/indicator traces.
- `Indicators/Indicators.json`: indicator registry, read via a relative path.
- `OctaveVersion/`: a full duplicate tree for Octave. **Changes must be mirrored there by hand.**

## Conventions
- State lives in two structs passed by value: `Problem` and `Optimizer`. Any function that evaluates must return `Problem` (`[..., Problem] = f(..., Problem)`), otherwise FE counts are lost.
- Maximization everywhere. Error = `OptimumValue(env) - f`.
- After every `fitness(...)` call inside an algorithm: `if Problem.RecentChange == 1, return; end`. `fitness.m` returns NaN for every row after the change and for every row after `MaxEvals`.
- `Optimizer` fields are copied from `ConfigurableAlgParameters.<p>.value` in `main_<Alg>`. Constants assigned *after* that copy silently override user settings (this already happens in TMIPSO and DynDE, and the same pattern in the FPs generator overrides benchmark settings).
- Seeds: `rng(RunCounter)` before generating the benchmark (paired instances across algorithms), then `rng('shuffle')` before the optimizer, so **optimizer runs are not reproducible**.
- PSO constriction factor is the parameter `x` (0.729843788). Its description wrongly says "inertia weight".

## How to run (Code Mode)
1. Start MATLAB in the project root. The generators do `fileread('Indicators/Indicators.json')`, which resolves through the MATLAB path, so the project must be on the path (`CodeMode.m` adds it).
2. Requires the Statistics and Machine Learning Toolbox (`pdist2`, `friedman`, `signrank`, `ranksum`). GUI mode also needs the Parallel Computing Toolbox.
3. Edit `CodeMode.m` (algorithm, benchmark, `RunNumber`, overrides), then `run CodeMode.m`.
4. For a quick smoke run use `ChangeFrequency=500`, `EnvironmentNumber=3-5`, `RunNumber=1-2`, `GeneratingExcelFile=0`, `OutputFig=0`.
5. Full article protocol: D=5, CF=5000, ShiftSeverity=1, EnvironmentNumber=100, RunNumber=31. That is 500k FEs per run, which takes minutes to hours per algorithm.
- `CodeMode.m` builds paths with `'\'`, so it is Windows-only as written. FPs needs `Utility/Kdtree/ConstructKDTree.mexw64` (Windows x64 prebuilt). Other platforms must compile it with `mex`.

## Pitfalls (see review/concerns.md for evidence)
- FPs ignores the user's `SpaceChange`, `FunctionChange` and `Lambda`: they are hardcoded to 0/0/1 in `BenchmarkGenerator_FPs.m:62-65`.
- `E_bbc` is sampled at FE ≡ CF−1 (`fitness.m:55`), while the GUI trend plot uses FE ≡ 0. The two differ by one evaluation.
- Several algorithms read `Problem.PeakNumber` (true number of peaks), contrary to the article's black-box rule: CDE, SPSO_AP_AD, psfNBC, DPCPSO.
- psfNBC's change reaction calls `fitness` without taking back `Problem`, so it gets uncounted evaluations. mDE does not return `CurrentError` (its plots are empty).
- Never call `fitness` as `[f,~] = fitness(...)` or `f = fitness(...)` inside an algorithm: the evaluation is then not counted.
- `review/stage5_scripts` sits under the project, and `CodeMode` adds all subfolders to the path. Keep `.m` files there uniquely named and never name one `fitness.m`.
- Many algorithms evaluate points outside the box (quantum/re-diversification samples), contrary to the article's "absorb in all EDOAs".
- Algorithm-specific confirmed bugs exist (mjDE F rule, HmSO exclusion distance, mCMAES dead shift estimate, DynDE CR/F flag, ...). Check `review/concerns.md` before trusting results from a given algorithm.
- `GUIMode` Nemenyi letters can label significantly different algorithms with the same letter.
- `Results/` contains committed sample outputs even though `.gitignore` lists those folders.

## Working rules for future sessions
- Do not edit the project for review/verification work. Copy it (`git archive HEAD | tar -x -C <scratch>`) and run there.
- Run MATLAB non-interactively: `matlab -batch "cd('<copy>'); addpath(genpath(pwd)); ..."`.
- When changing shared logic (`fitness.m`, generators, a `main_*` pattern), apply it to all 27 `main_*` copies and to `OctaveVersion/`.
