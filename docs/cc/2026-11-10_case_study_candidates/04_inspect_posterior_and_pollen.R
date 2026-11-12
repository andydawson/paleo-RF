# Inspect the land-cover posterior draws (the pipeline's input) and the pollen-based cover
# before interpolation (read-only). Both are in the cv2 worktree's data folder.
wt = '/home/expert/Documents/contracting/Andria/paleo-RF-wt/cv2'
t0 = Sys.time()
posts = readRDS(file.path(wt, 'data/veg_posts_interp_ice.RDS'))
cat('read in', round(difftime(Sys.time(), t0, units = 'secs')), 's\n')
cat('class:', class(posts), ' dim:', dim(posts), '\n'); str(posts, vec.len = 4)
cat('object size GB:', round(as.numeric(object.size(posts)) / 1e9, 2), '\n')
for (n in names(posts)) { u = unique(posts[[n]]); cat(n, ': ', length(u), ' unique; first: ', paste(head(u, 8), collapse = ', '), '\n') }
pollen = readRDS(file.path(wt, 'data/lct_paleo_reveals.RDS'))
cat('\npollen-based cover: class', class(pollen), ' dim:', dim(pollen), '\n'); str(pollen, vec.len = 4)
cat('ages:'); print(table(pollen$ages))
print(head(as.data.frame(pollen), 6))
