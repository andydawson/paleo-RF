# Expected 'data in credible interval' after script 5's denominator fix, from the seed-1 anchor:
# new = inside / observed = old * N / observed; old was rounded to 0.01, the new value will be too,
# so the new rounded value lies in [ (old - 0.005) r - 0.005, (old + 0.005) r + 0.005 ], r = N / observed.
ct = readRDS('tests/anchors/interp-allmonths-2026-09-20/calibration_modern_lct_interp_bluesky.RDS')
st = read.csv('tests/anchors/interp-seed1-2026-10-14/calibration_model_stats.csv', check.names = FALSE)
mo = st$month
N = nrow(ct); obs = sapply(mo, function(m) sum(!is.na(ct[[m]])))
r = N / obs; old = st[['data in credible interval']]
out = data.frame(month = mo, cells = N, observed = obs, old = old, expected = round(old * r, 3),
                 low = round((old - 0.005) * r - 0.005, 3), high = round(pmin(1, (old + 0.005) * r + 0.005), 3))
print(out, row.names = FALSE)
write.csv(out, commandArgs(TRUE)[1], row.names = FALSE)
