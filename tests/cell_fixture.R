# The hand-made cell of tests/test_differences.R and tests/test_forcing_components.R, as
# script 7a builds one: one month, slices in ascending age (row 1 is the youngest), glacier
# albedo 0.68 (fixed) and 0.73 (month by month); the *_thresh glacier albedo is NA where the
# slice counts as vegetation (ice fraction <= threshold).
cell <- function(ice_frac, alb_veg, threshold = 0.5) {
  is_veg <- !is.na(ice_frac) & ice_frac <= threshold
  data.frame(ice_frac = ice_frac, alb_veg = alb_veg, ice_albedo_fixed = 0.68, ice_albedo_sc = 0.73,
             alb_ice_thresh = ifelse(is_veg, NA, 0.68), alb_icesc_thresh = ifelse(is_veg, NA, 0.73))
}
