# Astra (GPT-6-Astra, ultra effort): which direction a withheld cell counts under, and leakage, 3 November 2026

**I recommend (b): count each error under the direction in which that cell actually leaves its fold’s training range, because that gives “direction” the same meaning for validation and the past.** Neither grouping rule inherently causes leakage. I agree with the main session’s conclusion, but its justification needs qualifications.

The information flow in the [driver](tools/cross_validate_albedo.R) is:

- **Past cover** determines departure directions, holdouts and target weights. It therefore **does influence which modern observations train each fold**, and ultimately the model chosen. That is deliberate use of known, unlabelled target conditions.
- **Withheld cover** helps define cuts and the full-modern hull. Under (b), its position relative to its own fold’s training hull determines its scoring group. Neither operation requires its albedo.
- **Training albedo** fits the model. **Withheld albedo** enters the squared error and hence model selection, but stays outside **its own fold’s fit**, including the retry. It can legitimately train another fold and the eventual full-data refit. Albedo *availability*, rather than its numerical value, affects complete rows, hulls and feasibility. The full-table coefficient-count calculation is setup without fitting.
- **Past albedo is unobserved. Hindcast predictions do not determine these folds or weights.** Although the driver reads an albedo-differences file, it extracts coordinates, ages, area and ice fractions. I traced those quantities upstream: area comes from geometry and adjusted ice from ice data, without using predicted albedo magnitudes or signs. Validation predictions, naturally, enter validation errors.

Thus “no past information reaches training” would be inaccurate; “no withheld response enters its own fold’s fit” is the relevant distinction. Knowing the cover conditions of this particular hindcast is legitimate. Changing (a) to (b) changes scoring, without requiring different fits.

The citations support that principle, **but do not establish this particular score as unbiased hindcast accuracy**:

- **Sugiyama, Krauledat and Müller (2007), *JMLR* 8:985–1005**, “Covariate Shift Adaptation by Importance Weighted Cross Validation”: uses unlabelled target inputs to estimate importance weights. However, its theory assumes an unchanged response relationship and suitable density ratios; its opening footnote explicitly limits “extrapolation” to regions with sparse training samples. Our grouped, reduced-hull comparison does not inherit that guarantee, particularly for genuinely unsupported historical mixes. [Paper](https://jmlr.org/papers/volume8/sugiyama07a/sugiyama07a.pdf). JMLR supplies no DOI; Krauledat’s university profile lists **10.5555/1314498.1390324**.
- **Milà, Mateu, Pebesma and Meyer (2022), *Methods in Ecology and Evolution* 13:1304–1316**, DOI [10.1111/2041-210X.13851](https://doi.org/10.1111/2041-210X.13851): constructs validation using prediction locations. Its discussion explicitly identifies large differences in predictor conditions as a limitation.
- **Linnenbrink, Milà, Ludwig and Meyer (2024), *Geoscientific Model Development* 17:5897–5912**, DOI [10.5194/gmd-17-5897-2024](https://doi.org/10.5194/gmd-17-5897-2024): likewise matches validation geography to prediction geography, while distinguishing this from matching predictor conditions. Neither spatial paper directly validates our cover-direction rule.

There are three subtler risks. First, tailoring folds to known cover before seeing errors does not automatically create optimism. **Choosing a winner using these errors and reporting its selection score as independent performance does.** The protocol intentionally has no separate assessment set. Choosing between (a) and (b) after seeing which favours a model or northeast sign would add further selection bias; the already-known sign should remain disclosed.

Second, target groups depend on the full-modern hull, whereas validation groups depend on smaller fold hulls. That is legitimate, common geometry, but transferring errors between those situations is an assumption: equal month, direction and distance band need not imply equal difficulty, geography or historical albedo behaviour. Weights cannot manufacture evidence for unrepresented conditions.

Third, (b) can change rankings by moving errors between groups. That is its intended effect, not model favouritism, provided **every candidate receives the same labels, rows and weights**, computed without its predictions. Overlapping holdouts can put multiple errors from one cell into one group; those remain dependent observations.

**My project-specific proposal** is to freeze (b) before examining scores, retain the holdout identifier separately, and report the label-change count and percentage by month and holdout, unique cells and blocks per scoring group, overlap counts, and represented target weight. I cannot supply the actual change count without computation. These diagnostics explain what the choice changes; they should not become another way to choose whichever result looks preferable.

Read-only review, including relevant concurrent edits; no R execution or writes.