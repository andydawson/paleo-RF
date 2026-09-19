# Radiative kernels

Albedo radiative kernels read by `scripts/8_radiative.R`. All three are
published, citable datasets, so the repository records their provenance
and a download script rather than the files themselves; run
`bash scripts/download_kernels.sh` to fetch them. The `.nc` files are
git-ignored (see the note on Git LFS below).

| File | Kernel | Flux level | Sky | Units | Read at | Source |
|---|---|---|---|---|---|---|
| `HadGEM3-GA7.1_TOA_kernel_L19.nc` (157 MB) | `albedo_sw_cs` (also holds all-sky `albedo_sw`) | top of atmosphere | clear-sky | W/m² per 1% albedo | `8:58` | Smith (2019), Zenodo, [10.5281/zenodo.3594673](https://doi.org/10.5281/zenodo.3594673), CC-BY-4.0. Paper: Smith et al., ESSD 12, 2157-2168, 2020 |
| `CAM5/alb.kernel.nc` (21 MB) | `FSNSC` (also `FSNS`, `FSNT`, `FSNTC`) | **surface** for `FSNSC`, top of model for `FSNTC` | clear-sky for the `*C` variables | W/m² per 1% albedo | `8:163` | Pendergrass (2017), Zenodo/NCAR, [10.5065/D6F47MT6](https://doi.org/10.5065/D6F47MT6), CC-BY-4.0. Paper: Pendergrass et al., ESSD 10, 317-324, 2018 |
| `CACKv1.0/CACKv1.0.nc` | `CACK`, band 3 | top of atmosphere | all-sky and clear-sky layers | see dataset | `8:197` | Bright and O'Halloran (2019), Environmental Data Initiative, [10.6073/pasta/d77b84b11be99ed4d5376d77fe0043d8](https://doi.org/10.6073/pasta/d77b84b11be99ed4d5376d77fe0043d8), package `edi.396.1`. Paper: Bright and O'Halloran, GMD 12, 3975-3990, 2019 |

Verified on 2026-09-19 by opening the downloaded files: the HadGEM3 file
carries `albedo_sw_cs` with units `W/m2/%` and long name "SW Surface
albedo clear-sky kernel" on a 12 x 19 x 144 x 192 (month, plev, lat, lon)
grid; the CAM5 file carries `FSNSC` "Clearsky net solar flux at surface"
on a 12 x 192 x 288 (time, lat, lon) grid. Pendergrass et al. (2018,
§2.1) define their albedo kernel as "the change in radiative flux for a
1 % change in surface albedo", so the `alb_diff * 100 * kernel`
convention in `8_radiative.R` is right for both.

**Flux levels are not like for like.** The HadGEM3 variable the script
reads is a top-of-atmosphere flux response; the CAM5 variable it reads,
`FSNSC`, is a *surface* flux response. The like-for-like CAM5 variable
would be `FSNTC` ("Clearsky net solar flux at top of model"), which is in
the same file. See `docs/cc/questions_for_andria_scientific.md` (C3).
Switching either kernel between clear-sky and all-sky needs no new
download: both variants are in each file.

**CACK is not downloadable without a browser.** The Environmental Data
Initiative portal serves `edi.396.1` behind a human-verification check
and its anonymous API returns 403, so the script cannot fetch it. Get it
by hand from
<https://portal.edirepository.org/nis/mapbrowse?packageid=edi.396.1> and
save it as `data/radiative-kernels/CACKv1.0/CACKv1.0.nc`.

**Git LFS.** These files are git-ignored. They are public and citable, so
the download script is the lighter option and it leaves the repository's
LFS quota (which belongs to the owner's GitHub account) for data that
exists nowhere else. If you would rather have them versioned, add
`data/radiative-kernels/**/*.nc` to `.gitattributes` for LFS and remove
the ignore lines.
