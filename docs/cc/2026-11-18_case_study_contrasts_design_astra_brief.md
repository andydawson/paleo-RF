# Brief for Astra (ultra effort): design the cover-contrast summaries for the case-study boxes

*Chris McWilliams, 18 November 2026. Design only, read-only. Chris approved this "after the ice work"; the ice work is
now merged.*

## Why
The cover-contrast exploration (`tools/explore_cover_contrasts.R` on the trunk, worktree
`/home/expert/Documents/contracting/Andria/paleo-RF-wt/feature`) summarises the fitted response to a 10-point exchange of
cover by month for the study area and the six boxes of `R/regions.R`. Chris chose three main case studies (the hemlock
decline in the northeast; the spruce rise in Quebec and Labrador, 6 to 2.5 ka; the prairie advance and return at the
prairie-forest border) with the eastern land clearance as a secondary check (500 to 200 BP on the Atlantic seaboard).
Your summary of the full results (`/tmp/claude-1000/-home-expert-Documents-contracting-Andria-paleo-RF/912627b7-1f54-4406-9a56-dc38e8ab3d9e/scratchpad/2026-11-17_contrast_results_codex_gpt6astra.md`)
noted that Quebec-Labrador has no box and the Upper Midwest box only overlaps the prairie-border box. The case-study
boxes are defined in the search report `docs/cc/2026-11-10_case_study_candidates.md` and its folder, and your check
`docs/cc/2026-11-16_case_studies_check_codex_gpt6astra.md`. Chris's goals for the model
(`docs/cc/questions_for_andria_scientific_from_2026-10-20.md` and the agenda): the best models' cover response should
move closer to the published contrasts, and the final model should give the right vegetation forcing for the hemlock
decline.

## What the design must give
The smallest way to produce the same summaries (contrast by month, version and exchange, with support, beside the
published guide; and the Duveiller comparison if it is cheap to include) for the exact case-study boxes, reusing the
saved fits of the full run (`/home/expert/Documents/contracting/Andria/paleo-RF-verify/7c12534/.rundirs/cover-contrasts-full/`),
with no refitting. Say where the boxes are defined (whether adding them to `R/regions.R` would change other tools'
outputs, or a separate list is simpler), what new command or option the tool needs, outputs, tests, a verification
spec, and an implementation plan for an Opus agent. No pass or fail; an exploration. Questions for Chris only where the
choice is his.

## Rules
Change no file; do not commit. R may not start in your sandbox; Python is available. Plain words, summary first.
Simplicity is a requirement: as simple and parsimonious as possible; no duplicated code. Precedent for method
choices, or say it is a project choice. The repository is public. Never open `data/modis_albedo/requests/`.
