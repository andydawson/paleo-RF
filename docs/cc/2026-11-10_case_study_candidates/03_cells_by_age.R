# Which reconstruction cells are present at which ages, and where the missing ones are (read-only).
r = '/home/expert/Documents/contracting/Andria/paleo-RF-verify/f05628d/.rundirs/cv-mod8'
p = readRDS(file.path(r, 'data/lct_paleo_reveals_interp.RDS'))
p$id = paste(p$x, p$y)
ages = sort(unique(p$ages))
all_ids = unique(p$id)
cat('cells ever present:', length(all_ids), '\n')
cat('sum check: range of OL+ET+ST:', range(p$OL + p$ET + p$ST), '\n')
cat('duplicated cell-age rows:', sum(duplicated(p[, c('id','ages')])), '\n')
n_ages = table(p$id)
cat('cells by number of ages present:\n'); print(table(n_ages))
for (a in ages) {
  miss = setdiff(all_ids, p$id[p$ages == a])
  xy = do.call(rbind, strsplit(miss, ' '))
  if (length(miss)) {
    x = as.numeric(xy[,1]); y = as.numeric(xy[,2])
    cat(sprintf('age %5d: present %4d, missing %3d; missing lon %.1f..%.1f lat %.1f..%.1f; in study lat band 27-74: %d\n',
                a, sum(p$ages == a), length(miss), min(x), max(x), min(y), max(y), sum(y > 27 & y < 74)))
  } else cat(sprintf('age %5d: present %4d, missing 0\n', a, sum(p$ages == a)))
}
# Where are the cells missing at 6000 but present at 6500 and 5500?
m6 = setdiff(intersect(p$id[p$ages == 6500], p$id[p$ages == 5000]), p$id[p$ages == 6000])
xy = do.call(rbind, strsplit(m6, ' ')); x = as.numeric(xy[,1]); y = as.numeric(xy[,2])
cat('\ncells present at 6500 and 5000 but missing at 6000:', length(m6), '\n'); print(table(lat = y)); print(table(lon10 = floor(x/10)*10))
m45 = setdiff(intersect(p$id[p$ages == 5000], p$id[p$ages == 4000]), p$id[p$ages == 4500])
xy = do.call(rbind, strsplit(m45, ' ')); x = as.numeric(xy[,1]); y = as.numeric(xy[,2])
cat('\ncells present at 5000 and 4000 but missing at 4500:', length(m45), '\n'); print(table(lat = y)); print(table(lon10 = floor(x/10)*10))
m200 = setdiff(intersect(p$id[p$ages == 50], p$id[p$ages == 500]), p$id[p$ages == 200])
xy = do.call(rbind, strsplit(m200, ' ')); x = as.numeric(xy[,1]); y = as.numeric(xy[,2])
cat('\ncells present at 50 and 500 but missing at 200:', length(m200), '\n'); print(table(lat = y)); print(table(lon10 = floor(x/10)*10))
# is elevation constant per cell over ages?
e = tapply(p$elev, p$id, function(v) diff(range(v)))
cat('\nmax elevation range within a cell over ages:', max(e), '\n')
# the modern file versus the 50 BP slice
m = readRDS(file.path(r, 'data/lct_modern_reveals_interp.RDS')); m$id = paste(m$x, m$y)
p50 = p[p$ages == 50, ]; mm = merge(m, p50, by = 'id', suffixes = c('.m', '.p'))
cat('modern file vs 50 BP slice: cells matched', nrow(mm), '; max abs diff ET/OL/ST:', max(abs(mm$ET.m - mm$ET.p)), max(abs(mm$OL.m - mm$OL.p)), max(abs(mm$ST.m - mm$ST.p)), '\n')
