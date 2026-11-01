# Input check before the refit runs (31 October 2026)

Code: branch `feature/single-config` at **837f2d3** (the refit code merged; legacy verification PASS).
Every run goes through `tools/verify_change.R` from its own worktree; the 331 frozen inputs are
checked before and after each run.

## The runs (your decisions of 29-30 October)

All start from `config.R`; only the settings shown differ.

| # | Run | albedo statistic | albedo version | months | other |
|---|---|---|---|---|---|
| 1 | Main | all days | full_75 | all 12 | |
| 2 | Snow-free | snow-free | full_75 | all 12 | |
| 3 | Any quality | all days | any_75 | all 12 | |
| 4 | Any quality, snow-free | snow-free | any_75 | all 12 | |
| 5 | Winter, no sun-angle rule | all days | full_nocut | Nov-Feb | report the four months only, beside run 1's |
| 6 | Winter, no sun-angle rule, snow-free | snow-free | full_nocut | Nov-Feb | as 5 |
| 7 | Snowy | snowy | full_75 | **you choose from the counts** | scripts 1-2 first |
| 8 | Raster control | (raster) | (raster) | all 12 | `source = "legacy_raster"`; its calibration table must have MD5 8119f506... (the 18 October table) |
| + | Model 7 at 2,000 steps | on run 1's table | | months that hit the 500-step limit, plus one converged month | |

Unchanged in every run (as evaluated from `config.R`): land cover = posterior mean; elevation = GMTED2010
land mean; ice mask = cells whose centre is under the 1 ka ice; prediction model = model 8 (REML); ladder
by ML; 100 evaluation and 100 prediction draws; 25 time slices 50 BP to 11.5 ka; domain 170 W-60 W,
27-74 N; ice threshold 0.5, endpoint differences; kernels HadGEM3 (albedo_sw), CAM5 (FSNT), CACK (CM, 2003);
headline variant vegetation plus partial ice; Earth area 5.101e14 m2; 10-degree latitude bands.

## How they run (your decision of 29 October: up to four jobs at once)

- Model fitting (script 4) split by month into four parts of three months, eight cores each, on four
  code-identical commits so they can run at once; then scripts 1-10 and the diagnostic figures once,
  from those fits. One run's fitting at a time. Measured on 18 October: about 4.5 hours per fitting
  part and about 3 hours for the rest.
- R's maths library at one thread (`THREADS=1`); the model fitting uses its own eight threads.
- Script 6 (the memory-heavy step) one run at a time; its memory measured on run 1 before any overlap.
- Each run writes about 9 GB (18 October: 7.8 GB plus 1.1 GB per fitting part); 954 GB free.

## Inputs (all present; MD5 first 12 characters)

| id | path | from | MB | MD5 |
|---|---|---|---|---|
| veg_posts | `data/veg_posts_interp_ice.RDS` | code commit | 334.1 | 7bb1d2daeac6 |
| elevation_cache | `data/elev_interp_cells.RDS` | code commit | 0.02 | 4b125b789cd8 |
| elevation_land_mean | `data/elev_land_mean_cells.csv` | code commit | 0.06 | d07cd1cb8ca5 |
| grid | `data/grid.RDS` | code commit | 0 | d384b716d1f3 |
| bluesky_raster | `data/blue_sky_monthly_2000-2009.tif` | code commit | 3.26 | 177283acc81b |
| albedo_modis_cells | `data/albedo_modis_cells.csv` | code commit | 7.79 | d73c54cca47b |
| albedo_modis_provenance | `data/albedo_modis_cells_provenance.txt` | code commit | 0 | 7cc93a23b55e |
| boundaries_ll | `data/map-data/geographic/pbs_ll.RDS` | code commit | 6.46 | eae024438c45 |
| boundaries | `data/map-data/geographic/pbs.RDS` | code commit | 7.17 | 496f295574ad |
| glacier_shapes | `data/map-data/ice/glacier_shapefiles_21-1k.RDS` | code commit | 8.14 | b2a222cb5d8e |
| glacier_albedo | `data/albedo_glacier_monthly.csv` | code commit | 0 | f59add22cbb7 |
| dalton_ice | `data/Dalton_QSR_2020_Ice/dalton_interpolated_LC6k.tif` | code commit | 0.06 | 9f381624b167 |
| kernel_hadgem | `data/radiative-kernels/HadGEM3-GA7.1_TOA_kernel_L19.nc` | code commit | 156.63 | 94a6253a156f |
| kernel_cam5 | `data/radiative-kernels/CAM5/alb.kernel.nc` | code commit | 21.24 | 1af28c1bcf55 |
| kernel_cack | `data/radiative-kernels/CACKv1.0/CACKv1.0.nc` | code commit | 126.5 | c25c4cc0ca1f |
| ipcc_erf | `data/ipcc-ar6/AR6_ERF_1750-2019.csv` | code commit | 0.1 | f64915777d29 |
| ipcc_erf_pc05 | `data/ipcc-ar6/AR6_ERF_1750-2019_pc05.csv` | code commit | 0.1 | 59901f800bbd |
| ipcc_erf_pc95 | `data/ipcc-ar6/AR6_ERF_1750-2019_pc95.csv` | code commit | 0.1 | 012bcceb6962 |
| lct_paleo_reveals | `data/lct_paleo_reveals.RDS` | code commit | 0.13 | 058dc974a8fb |

Missing: 0 

The cell table's MD5 is the one recorded when it was built (29 October) and committed (`d73c54cc...`).

## Settings as evaluated from config.R

```
{"analysis":{"months":["jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec"],"ages":[50,200,500,1000,1500,2000,2500,3000,3500,4000,4500,5000,5500,6000,6500,7000,7500,8000,8500,9000,9500,10000,10500,11000,11500],"land_cover":{"reduction":["mean"]},"elevation":{"method":["land_mean"]},"albedo":{"source":["modis_cells"],"statistic":["all_days"],"version":["full_75"]},"calibration":{"model_id":["mod8"],"comparison_method":["ML"],"ice_mask":["centre_in_1ka_polygon"]},"draws":{"evaluation":[100],"prediction":[100],"seed":["random"]},"coarse":{"ages":[50,500,2000,4000,6000,8000,10000,12000],"slice_alias":[11500,12000]},"domain":{"lon_min":[-170],"lat_min":[27],"lat_max":[74],"lon_max_coarse":[-60]},"ice":{"threshold":[0.5],"difference_method":["endpoint"],"albedo_coarse":["ice_albedo"],"albedo_fixed":["ice_albedo_fixed"],"albedo_scaled":["ice_albedo_sc"]},"kernels":{"hadgem_variable":["albedo_sw"],"cam5_variable":["FSNT"],"cack_variable":["CACK CM"],"cack_year":[2003]},"forcing":{"earth_area_m2":[510100000000000],"variant":["veg_ice_parts"],"report_kernels":["hadgem","cam5","cack"],"sensitivity_variants":["veg_thresh","ice_thresh","veg_ice_thresh","veg_part","ice_part","veg_ice_parts","veg_icesc_thresh","veg_icesc_parts"],"latitude_band_width":[10]}},"presentation":{"map_windows":{"calibration":{"x":[-172,-50],"y":[15,80]},"tail":{"x":[-166,-50],"y":[12,82]},"diagnostics":{"x":[-172,-50],"y":[17,79]}}},"run":{"dir":null,"allow_stale":[false],"diagnostic":[false]}} 
```
