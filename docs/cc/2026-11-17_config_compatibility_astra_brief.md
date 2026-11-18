# Brief for Astra (ultra effort): a simple, general way to load saved configurations that lack newer settings

*Chris McWilliams, 17 November 2026. Design only, read-only.*

## The problem
The ice build (branch `ice-nadi1`, worktree `/home/expert/Documents/contracting/Andria/paleo-RF-wt/ice`) adds a
required setting, `analysis$ice$fraction_source`. Every `config_used.R` saved by a run before it lacks that key, so
`load_config()` now refuses them, and tools that reload old runs stop (`tools/compare_cv_hindcasts.R`,
`tools/explore_cover_contrasts.R`, `tools/check_cv_separation.R`, `tools/cross_validate_albedo.R`, and the verification
checks that point at old run folders). Your review of the build (`docs/cc/2026-11-17_ice_build_review_codex_gpt6astra.md`,
finding 2) proposed a fallback for that one key in `load_config()`.

Chris's answer: **"We shouldn't have to bodge this every time we add a new config setting. Find an elegant fix - like
fail with a warning, and then pass an argument (or a legacy flag) to override missing config errors. Astra to design
and keep it simple."**

## What the design must give
1. One general mechanism, in `R/config.R` and `R/config_schema.R` (read both; also `R/run_manifest.R`, the tools above,
   `tools/verify_change.R`, and the existing config tests): by default a saved configuration missing settings fails
   with a clear message naming each missing setting and saying how to override; an explicit argument or flag lets a
   caller load it anyway. Say what the missing settings then become, and why that is right for old runs. For example,
   each setting could declare in the schema the value that reproduces the behaviour before it existed, used only
   under the override, with a warning listing what was filled. Choose the simplest form that stays correct when more
   settings are added later.
2. Which callers pass the override (the tools that reload old runs; command-line flag or code), and which must not
   (the pipeline's own runs, which must always have every setting).
3. How it interacts with field order (some tools compare settings with `identical()`), with explicit `NULL` or invalid
   values (still refused), and with the run manifest's record of settings.
4. Tests, and the smallest change to existing code; no migration framework, no rewriting of saved files.
5. An implementation plan for an Opus agent, in order.

## Rules
Change no file; do not commit. R may not start in your sandbox; Python is available. Plain words, summary first.
Simplicity is a requirement. Precedent from software practice is welcome but brief. The repository is public.
