# Written by tools/verify_change.R for "run1-main-fit-jul-sep": config.R with the spec's settings.
list(analysis = list(months = c("jul", "aug", "sep"), ages = c(50, 
200, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 
5500, 6000, 6500, 7000, 7500, 8000, 8500, 9000, 9500, 10000, 
10500, 11000, 11500), land_cover = list(reduction = "mean"), 
    elevation = list(method = "land_mean"), albedo = list(source = "modis_cells", 
        statistic = "all_days", version = "full_75"), calibration = list(
        model_id = "mod8", comparison_method = "ML", ice_mask = "centre_in_1ka_polygon"), 
    draws = list(evaluation = 100, prediction = 100, seed = 1549466984), 
    coarse = list(ages = c(50, 500, 2000, 4000, 6000, 8000, 10000, 
    12000), slice_alias = c(11500, 12000)), domain = list(lon_min = -170, 
        lat_min = 27, lat_max = 74, lon_max_coarse = -60), ice = list(
        threshold = 0.5, difference_method = "endpoint", albedo_coarse = "ice_albedo", 
        albedo_fixed = "ice_albedo_fixed", albedo_scaled = "ice_albedo_sc"), 
    kernels = list(hadgem_variable = "albedo_sw", cam5_variable = "FSNT", 
        cack_variable = "CACK CM", cack_year = 2003), forcing = list(
        earth_area_m2 = 5.101e+14, variant = "veg_ice_parts", 
        report_kernels = c("hadgem", "cam5", "cack"), sensitivity_variants = c("veg_thresh", 
        "ice_thresh", "veg_ice_thresh", "veg_part", "ice_part", 
        "veg_ice_parts", "veg_icesc_thresh", "veg_icesc_parts"
        ), latitude_band_width = 10)), presentation = list(map_windows = list(
    calibration = list(x = c(-172, -50), y = c(15, 80)), tail = list(
        x = c(-166, -50), y = c(12, 82)), diagnostics = list(
        x = c(-172, -50), y = c(17, 79)))), run = list(dir = ".rundirs/run1-main-fit-jul-sep", 
    allow_stale = FALSE, diagnostic = FALSE))
