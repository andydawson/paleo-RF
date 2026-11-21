# Brief for Astra (ultra effort): review the ice build before its verification runs

*Chris McWilliams, 17 November 2026. Read-only. Chris's arrangement: Astra designs and reviews, an Opus agent
implements, then the verification tool. The five forcing runs (old-ice replay, legacy regression, NADI-1 optimal,
minimum and maximum) start only after this review.*

## Rules
- Change no file; do not commit; download nothing. You are in the worktree of branch `ice-nadi1` (tip 59a9a6f; the
  build is e951b2f..59a9a6f). R may not start in your sandbox; Python is available. The builder's tests, trial
  outputs, figures and check scripts are in
  `/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/ice_trial/`
  (`tests.log`, `compare_ice_headline/` with five PNG figures, tables, `record.txt`, `runtimes.txt`, and the check
  scripts with their logs). The inputs: NADI-1 in `/home/expert/Documents/contracting/Andria/paleo-RF/data/nadi1/`,
  the old raster and polygons in `data/`, the headline run `/home/expert/Documents/contracting/Andria/paleo-RF-verify/d5d5df5/.rundirs/run1-main`.
  Check numbers your own way.
- Plain words, verdict first, findings worst first with file and line, consequence, evidence and a proposed check.
  Simplicity is a requirement: say what can be cut. Precedent for method choices, or say it is a project choice. The
  repository is public. Never open `data/modis_albedo/requests/`.

## What was to be built
Your second design (`docs/cc/2026-11-16_ice_redesign_simpler_codex_gpt6astra.md`) and Chris's decisions
(`docs/cc/2026-11-17_ice_work_decisions.md`), including two the design predates: compute BOTH rules for splitting the
forcing into vegetation and ice parts (today's: vegetation change over land ice-free at the older slice; the
alternative: vegetation change only on land ice-free at both slices, the rest to ice), and label the oldest slice
11.5 ka (config.R only; legacy unchanged). Chris also chose to run NADI-1 optimal, minimum and maximum side by side,
and to defer a run with the readvance averaging switched off. The builder's account:
`docs/cc/2026-11-17_ice_implementation_note.md`.

## What to check
1. Each commit against the design and decisions; anything missing or added.
2. The split arithmetic in `R/differences.R` and its flow through scripts 8 and 9: existing columns unchanged, the
   two new ones right, signs and kernels, the legacy configuration untouched. The builder's evidence: 34,392
   cell-months rebuilt, the 12 existing columns identical, the two rules differing only on the 2,844 advancing rows.
3. The NADI-1 builder's geometry. The design asked for areas on the sphere (s2), as script 7a measures cells; the
   builder found s2 turns the 8.5 ka minimum inside out (long edges read as great circles), so it measures in an
   equal-area projection (EPSG:6931) after cutting edges every 0.01 degree; elsewhere the two agree within 0.0008. It
   closed 3 open rings and made 12 self-crossing polygons valid; minimum <= optimal <= maximum fails in 129
   cell-slices (largest 0.0099 at 6 ka on Baffin Island), reported not repaired. Is this sound, with precedent?
4. The relabel: forcing unchanged; but script 7, with no alias, now takes the 11 ka polygon for 11.5 ka (a tie, the
   first wins), so 780 instead of 1,004 cells are ice on the oldest map and in script 7's coarse differences, and
   the historical EGU comparison's oldest bar changes. Your view?
5. The new required setting makes every saved `config_used.R` made before this work fail `load_config()`, so tools
   that reload old runs (the hindcast comparison, the cover-contrast exploration, the cross-validation tools) would
   stop. The builder proposes filling `fraction_source = "dalton_ice"` when a saved configuration lacks it. Your view
   on the simplest correct fix.
6. `tools/compare_ice.R` and its check: the readvance inventory (186 raw, 228 after averaging, 75 created; NADI-1:
   142 optimal, 35 minimum, 231 maximum before averaging), ice areas, figures; no copied pipeline arithmetic.
7. The six specs: will the replay prove nothing else changed; is the legacy regression right; can the five runs go
   side by side on separate cores as the builder proposes; anything to change before launch.
8. Anything else wrong, most important first.

End with your verdict (ready to verify, ready after named changes, or not ready), the changes in order, each small
enough for Chris to say yes or no to, and any question for Chris, answerable without reading anything else.
