*Fable, second look at 84b8689 and the working tree after it, 3 November 2026; condensed.*

**Verdict.** The fixes hold: every code finding from both first reviews is addressed; the selection score and choice
unchanged (point score asserted against the pre-fix table); pairing, weight-share arithmetic and the in-range
"incomplete" rule check out by hand. Hand check of the weight share: rows in groups g1, g1, g2 with weights 3 and 1 and
bands A, B, B give row weights 1.5, 1.5, 1 of 4, so band A 0.375 and band B 0.625, exactly the selection score's row
weights.

**Left:** a verification record at the head commit running both test files; the changelog entry and these reviews
filed; a test pinning the 0.375 / 0.625 case; compare the choice and its standard errors, not only the scores, with the
old code. Nits not acted on: reshape cost with continuous ids (measure first; the stand-in run's score stage took
seconds); a misleading message if an in-range predictions file exists for a month a rerun marks infeasible (rare).
