**Verdict.** Revise before fold fitting: the exclusion logic is sound, but the buffer’s evidential basis and the interpretation of incomplete coverage need tightening.

**Benefit.** Protocol 3 can choose among the existing albedo models using unfamiliar cover mixtures without nearby training observations, while showing which historical conditions remain untested.

**Hand check.**

The two exclusions work together correctly. A tested cell exceeds the directional cover cut; every retained training cell lies below that cut. Removing additional neighbours cannot put the tested cell back inside the training hull. Separately excluding every training cell within h enforces the geographic gap. This requires the proposed separate test and training-exclusion masks; the current single-mask implementation at [tools/cross_validate_albedo.R:114](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/tools/cross_validate_albedo.R:114) cannot express it.

The score arithmetic also agrees with the stated method. Consider one month, two represented cover groups with frozen weights ¾ and ¼:

| Group | Observed albedo | Model A prediction | Model B prediction |
|---|---:|---:|---:|
| Shallow | 0.20 | 0.30 | 0.40 |
| Deeper | 0.50 | 0.80 | 0.60 |

All albedos are physical. Squared errors give:

- A: ¾ × 0.01 + ¼ × 0.09 = **0.0300**.
- B: ¾ × 0.04 + ¼ × 0.01 = **0.0325**.

A wins. If the shallow group becomes unrepresented, the existing code renormalizes over the deeper group: A scores **0.09**, B **0.01**, and represented weight is **¼**. That is exactly [R/cross_validation.R:222](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/R/cross_validation.R:222). Frozen weights do not mean an unchanged selection target when coverage disappears.

A second distinction matters: if two clusters supply errors 0.01 and 0.09 **within the same group**, its mean is 0.05. Losing the second cluster leaves 0.01, while represented group weight remains **100%**.

I also checked the downstream sign convention. For two ice-free cells with areas 2 and 1, older-to-younger albedo changes −0.02 and +0.02 give regional change **−0.006667**. An illustrative HadGEM3/CAM5 kernel of −1 W m⁻² per 0.01 albedo gives **+0.6667 W m⁻²**, warming; CACK at +100 W m⁻² per unit albedo gives the same after its explicit minus sign. The formulas agree. CV itself contains neither kernels nor a score of consecutive albedo changes.

**Findings.**

Useful deletion first: retain the proposed removal of the protocol-1 membership comparison, approximately **+0/−23 = −23 lines**, including its argument/output plumbing. The relevant block starts at `tools/cross_validate_albedo.R:222`. Retain the in-range diagnostic and monthly depth evidence: tail-only tests cannot replace either. No further substantial deletion was justified.

1. **Should-fix — no-location residuals do not, by themselves, establish a sufficient h.**  
   **Location:** [review brief:13](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-24_cv_spatial_folds_review_brief.md:13), also line 31; `R/model_registry.R:49`.

   The saved `cover_elev` model still contains a 200-basis cover smooth and a 50-basis elevation smooth. Those spatially patterned predictors can absorb dependence even without an explicit location term. A short residual range could therefore produce an insufficient buffer.

   The cited literature is more specific:

   - Telford, R. J. & Birks, H. J. B. (2009), *Evaluation of transfer functions in spatially structured environments*, **Quaternary Science Reviews 28**, 1309–1316, DOI **10.1016/j.quascirev.2008.12.020**, §5: residual-range estimation should use a method resistant to absorbing nuisance autocorrelation; their example uses detrended weighted-averaging residuals. [Published paper](https://quantpalaeo.wordpress.com/wp-content/uploads/2013/08/telford-and-birks-2009-qsr-evaluation.pdf).
   - Trachsel, M. & Telford, R. J. (2016), *Technical note: Estimating unbiased transfer-function performances in spatially structured environments*, **Climate of the Past 12**, 1215–1223, DOI **10.5194/cp-12-1215-2016**, §2: the implementation uses detrended **cross-validated** weighted-averaging residuals, with qualifications about the detrending. It does not validate arbitrary full-data GAM residuals. [Published paper](https://cp.copernicus.org/articles/12/1215/2016/cp-12-1215-2016.pdf).
   - Roberts et al. (2017), *Cross-validation strategies for data with temporal, spatial, hierarchical, or phylogenetic structure*, **Ecography 40**, 913–929, DOI **10.1111/ecog.02881**, pp. 920 and 924: predictors can conceal dependence in residuals; their guidance also examines raw-data dependence. [Published paper](https://www.biom.uni-freiburg.de/mitarbeiter/dormann/roberts-et-al-2017-ecography.pdf/at_download/file).

   **Consequence:** choosing 100, 250 or 500 km from these plots is a defensible project judgement, but cannot certify that spatial dependence has been removed.

   **Minimal correction:** name the saved model and residual definition, retain monthly results, and record the chosen h as a judgement with its limitations. Do not silently choose the largest offered radius if the plots remain correlated beyond it. No new estimator is required by this finding.

   **Check:** inspect whether the claimed range is visible and supported in each relevant month; distinguish absent residual correlation from established independence. No plots were available to settle this.

   **Estimated correction:** documentation **+8/−4 = +4 lines**. Additional raw-field plots would be a separate proposal, not an assumed requirement.

2. **Should-fix — interpreting location as climate does not make new-place validation the correct historical test.**  
   **Location:** [Fable design:96](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-23_cv_spatial_folds_design_fable.md:96), repeated at line 170; `scripts/6_prediction_model.R:45`.

   The statement that this is the right test *if location represents climate or snow* is unsupported. The pipeline carries the fitted modern location surface unchanged through time. Removing nearby modern observations does not reproduce changing historical climate or snow at that location.

   The saved `comparison.csv` shows March–September historical distance quantiles effectively zero in all directions. Conversely, December d1 has a median historical distance of **1,360 km**. One common geographic exclusion therefore represents neither situation directly.

   **Consequence:** the method can penalize useful local prediction and select a coarser location term because it transfers better geographically. That may be Chris’s preferred selection criterion; it does not establish superior hindcast accuracy or a more correct vegetation response. Nor is its RMSE necessarily an upper bound on historical error.

   Telford and Birks §6 provide a substantive argument for testing spatial transfer before trusting temporal reconstruction. Roberts et al. require matching validation to the prediction objective and acknowledge that blocking cannot resolve changing relationships through time. These support a transfer test, not the claimed equivalence. [Telford and Birks](https://quantpalaeo.wordpress.com/wp-content/uploads/2013/08/telford-and-birks-2009-qsr-evaluation.pdf), [Roberts et al.](https://www.biom.uni-freiburg.de/mitarbeiter/dormann/roberts-et-al-2017-ecography.pdf/at_download/file).

   **Minimal correction:** delete that equivalence and describe selection as a judgement favouring geographically separated modern transfer. Chris’s decision that this score chooses remains intact.

   **Check:** the recorded target-versus-test distances establish the mismatch; no modern holdout can prove historical stationarity.

   **Estimated correction:** documentation **+4/−2 = +2 lines**.

3. **Should-fix — per-split feasibility can remove geographic evidence without reducing reported target coverage.**  
   **Location:** [reconciliation:18](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-23_cv_spatial_folds_reconciliation_codex_gpt6astra.md:18); `R/cross_validation.R:44`, `:50`, `:238`.

   The hand check demonstrates the reporting limitation: “represented” measures occupied month–direction–depth groups, not representation of their geographic variation. An infeasible cluster can disappear while another cluster retains every group.

   There is substantial practical pressure on feasibility. Saved December counts are:

   | Direction | Training rows before buffering | Additional rows removable while retaining ≥748 |
   |---|---:|---:|
   | d1 | 1,087 | 339 |
   | d2 | 1,040 | 292 |
   | d3 | 914 | 166 |

   Thus **167 additional exclusions fail December d3’s row condition**. January d3/d2 and November d3/d2 are the next winter concerns, although actual losses remain unknown.

   The block condition also matters. Before buffering, positive-target observations across **all distances** occupy:

   | Month(s) | d1 blocks | d2 blocks | d3 blocks |
   |---|---:|---:|---:|
   | March–September | 53 | 48 | 35 |
   | November | 31 | 45 | 28 |
   | December | 24 | 29 | 28 |

   These must now supply four compact clusters with ten scored blocks **per split**. This makes summer d3 a concern too. These totals do not prove infeasibility: cluster boundaries can divide a physical block, and buffering can change departure directions and target-group membership.

   Cover support is also vulnerable. **58.36% of the outside target weight is below 0.02**, while d3 has target weight only below 0.05. Shrinking the training hull cannot decrease a tested cell’s cover distance; it can move observations out of the groups carrying those weights.

   **Consequence:** a successful score could describe surviving geographic subsets rather than the whole proposed tail experiment, even with apparently complete group coverage.

   **Minimal correction:** retain the approved per-split feasibility tables beside coverage and explicitly label coverage as *cover-group weight represented*. Do not add an all-four-clusters veto or silently pool the ten-block requirement across clusters.

   **Check:** use the existing holdouts stage to inspect actual split counts, achieved distances and group coverage. Add the small same-group/two-cluster example above to demonstrate what the coverage number does and does not mean.

   **Estimated correction:** existing report wording **+6/−0**, focused fixture **+12/−0**; total **+18/−0 = +18 lines**.

4. **Should-fix — the frozen clustering and buffer specification is incomplete.**  
   **Location:** [review brief:24](/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv-folds/docs/cc/2026-11-24_cv_spatial_folds_review_brief.md:24), lines 27–29.

   The coordinates are explicitly unresolved. Also unresolved is whether the buffer surrounds all cells in the frozen cluster or only cells with an observed response that month. Either can enforce separation of scored cells, but they remove different training observations and change winter feasibility.

   **Consequence:** two implementations could satisfy the prose yet produce different folds and winners.

   **Minimal correction:** specify one geographic metric, fixed clustering seed/settings, membership fixed across months, and the monthly buffer interpretation. Continue using `nearest_km()` for the actual geographic exclusion. This belongs in the existing method record and preparation code.

   **Check:** frozen membership reproduces; every scored cell meets h against actual monthly training rows; buffer-only cells are excluded without being scored.

   **Estimated clarification and focused check:** **+16/−2 = +14 lines**, within the already proposed clustering work.

The focused corrections above total approximately **+46/−8 = +38 lines**, including tests and records. These are planning estimates, partly within the existing allowance, not a measured patch or justification for expanding it.

**Clustering, uncertainty and numerical claims.**

I found no inherent defect in making clusters separately for each direction. They are fitting partitions, not twelve independent geographic replicates. A physical block must retain one bootstrap multiplicity across every month, direction and cluster appearance; `cv_score()` already implements that principle through its global block key.

The 5° bootstrap remains a **conditional selection heuristic**. It does not resample fitting or cluster construction, and neighbouring blocks need not be independent. At 70°N, five degrees of longitude span roughly 190 km, so choosing h = 500 km would not make those resampling units independent.

There is also an observed limitation: protocol 2’s `scores.csv` reports **135 of 1,000 bootstrap draws missing a group**. Those draws renormalize over different target subsets. The resulting paired standard error is not uncertainty for one perfectly fixed target. The reconciliation already acknowledges uncalibrated uncertainty; preserve that qualification.

The principal arithmetic claims check:

- Outside target: **12.815792%** of full historical weight.
- Main fits: **4 × 3 × 12 × 15 = 2,160**.
- Maximum with listed follow-ups: **2,736**, before retries.
- Recorded protocol-2 durations: **973.9 directional fit-minutes** and **71.6 in-range fit-minutes**, summed from rounded log entries.

The submitted **+1,200/−150 = +1,050 lines** is an allowance, not an auditable patch count.

**What the proposed verification misses.**

Use the existing tests and `tools/verify_change.R`; no additional testing framework is warranted.

- **Combined membership:** one tested tail cell, another tail cell outside its cluster, a buffer-only cell and a retained training cell. Only the first is scored; the first three are excluded from training.
- **Pooling:** with h = 0 and all splits feasible, partitioning a tail into clusters must reproduce its pooled **all-distance** score. It must not average unequal cluster means equally. Protocol 2’s nearby-only score is a different comparison.
- **Coverage loss:** check both an absent cover group and an absent cluster within a still-represented group.
- **Overlap and contributions:** repeated physical blocks stay together in resampling; additive block and direction–cluster contributions sum to the paired MSE difference.
- **Downstream meaning:** update the explicit `<250 km` consumer at `R/hindcast_comparison.R:148` and the associated comparison captions. Otherwise h ≥ 250 can leave the reported validation evidence empty or incorrectly described.

For stochastic behaviour, reuse `derive_seed()` and `withr_seed()`. Clustering must have its own recorded seed without shifting the existing in-range, bootstrap or recovery streams. Keep 1,000 bootstrap draws and 20 recovery replicates unless separately changed.

Seed-1 anchor identity demonstrates preservation of the seeded legacy path; historical tolerances concern unseeded simulation variability. Neither validates the new folds, h, coverage or scientific interpretation.

**Questions for Chris or Andria.**

1. **Chris:** If residual correlograms do not identify a convincing range within 100–500 km, should the selected radius remain an explicitly limited judgement, or should the evidence be reconsidered before choosing it? Meanwhile, no h is established; the approved plots can still be prepared.
2. **Chris:** If only some clusters survive the existing per-split requirements, should their score still choose with the missing geography stated, or should that particular result prompt reconsideration? Meanwhile, the proposed rule scores surviving splits; it contains no all-cluster requirement.
3. **Andria:** Is geographically separated modern predictive skill sufficient for retaining location as an empirical adjustment, with historical interpretation unresolved? The alternative is to retain the selected model while presenting the vegetation forcing as sensitive to model structure. Meanwhile, prediction holds the modern location relationship fixed.
4. **Chris:** Should monthly buffers use every frozen cluster cell or only that month’s observed test cells? The former freezes geographic exclusion across months; the latter retains more winter training data. The current single-mask code implements neither combined construction.

These questions remain here under the read-only instruction; I did not alter the living question files.

**Not worth doing.**

- Requiring identical clusters across directions, or averaging repeated appearances merely because they repeat. I dropped these two possible findings: neither fixes a demonstrated defect under the approved weighting and global block resampling.
- Replacing the bootstrap with four cluster labels and calling that calibrated uncertainty.
- A radius search, automatic instability veto, new fold framework, regional reweighting or candidate registry.
- Deleting the in-range holdout or monthly depth records.
- Claiming a cheaper equivalent has been established. Buffering the entire tail at once saves fits but excludes a superset of every cluster’s training exclusions; winter feasibility is unmeasured and already fragile. Re-scoring existing far cells changes the tested population and cannot supply missing shallow-cover evidence.

The present direct construction remains the simplest defensible implementation of the specifically chosen experiment.

**Not checked.**

No R, pipeline or tests were executed. No clusters, correlograms, new feasibility masks or new predictions were produced. Binary fitted objects and kernel-file metadata were not inspected. Exact geographic equality for every historical cell was not established from rounded distance quantiles. The literature identities and relevant primary passages were checked, but dedicated reference checkers were unavailable. No current parallel reviewer’s conclusions were consulted.

Files read: project rules/README, supplied designs/reconciliations/protocols/decisions/regression contract, relevant question-file sections, named CV/separation/comparison code and tests, configuration, model/seed/support/difference/kernel helpers, pipeline callers, saved CV tables and fit logs; tools used: read-only shell reads/searches, published-literature web calls, and two evidence-only delegates; no writes or execution of R.