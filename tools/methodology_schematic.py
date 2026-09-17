#!/usr/bin/env python3
"""Generate METHODOLOGY_SCHEMATIC.html (+ .svg) for paleo-RF.

A draw.io-style flowchart of the whole methodology: data sources, external
steps, the scripted pipeline in its two flavours (interp / non-interp), side
branches and outputs, colour-coded by status and badged by where each step is
described (draft manuscript = MS, EGU talk = Talk).

Every box carries a stable id and data-stage attribute so a later version can
attach the questions in METHODOLOGY_QUESTIONS.md as tooltips.

Run from the repo root:  python3 tools/methodology_schematic.py
"""
from pathlib import Path

W, H = 1560, 1010
COL = lambda i: 40 + i * 190          # column x for sources and stages (w = 176, gap 14)
BW = 176

# ----------------------------------------------------------------------------
# box definitions: (id, kind, status, x, y, w, h, badges, lines)
#   kind: 'doc' (data source / output), 'proc' (processing step), 'note'
#   status: 'runs' | 'blocked' | 'missing' | 'archive' | 'none'
#   lines: list of (text, style) where style in 'h' (header) 'b' (body) 'i' (italic)
# ----------------------------------------------------------------------------
BH = 98
SRC_Y = 96
EXT_Y = SRC_Y + BH + 52          # 246
L1_Y = EXT_Y + BH + 96           # 440
L2_Y = L1_Y + BH + 56            # 594
E_Y = L2_Y + BH + 66             # 758

boxes = [
    # ---- data sources -------------------------------------------------------
    ("src-pollen", "doc", "missing", COL(0), SRC_Y, BW, BH, ["MS", "Talk"],
     [("Neotoma fossil pollen", "h"), ("sediment-core pollen counts", "b"),
      ("for North America", "b"), ("raw records not in repo", "i")]),
    ("src-agemodels", "doc", "missing", COL(1), SRC_Y, BW, BH, ["MS"],
     [("Bayesian age-depth models", "h"), ("refitted per site", "b"),
      ("Tunski et al. (in prep)", "b"), ("external", "i")]),
    ("src-reveals-params", "doc", "missing", COL(2), SRC_Y, BW, BH, ["MS", "Talk"],
     [("REVEALS inputs", "h"), ("pollen productivity, fall", "b"),
      ("speeds, lake sizes; taxon-to-", "b"), ("cover table (csv) is in repo", "i")]),
    ("src-modis", "doc", "missing", COL(3), SRC_Y, BW, BH, ["MS"],
     [("MODIS MCD43A3 v061 + ERA5", "h"), ("black/white-sky albedo", "b"),
      ("2000–09; diffuse fraction", "b"), ("external", "i")]),
    ("src-grid", "doc", "runs", COL(4), SRC_Y, BW, BH, ["MS"],
     [("1° grid, map, elevation", "h"), ("grid.RDS, pbs*.RDS in repo;", "b"),
      ("elevation fetched per run", "b"), ("by elevatr from AWS (network)", "i")]),
    ("src-ice", "doc", "missing", COL(5), SRC_Y, BW, BH, ["MS", "Talk"],
     [("Ice sheets", "h"), ("Dalton 2020 ice fraction;", "b"),
      ("shapefiles 21–1 ka; glacier", "b"), ("albedo table (source unknown)", "i")]),
    ("src-kernels", "doc", "missing", COL(6), SRC_Y, BW, BH, ["MS", "Talk"],
     [("Radiative kernels", "h"), ("HadGEM3 (used);", "b"),
      ("CAM5, CACKv1.0 (tested)", "b"), ("NetCDF files not in repo", "i")]),
    ("src-ccsm3", "doc", "archive", COL(7), SRC_Y, BW, BH, [],
     [("CCSM3 paleoclimate", "h"), ("temp, precip, GDD NetCDFs", "b"),
      ("22–0 ka transient run", "b"), ("only for the abandoned branch", "i")]),

    # ---- external steps (code not in repo) -----------------------------------
    ("ext-reveals", "proc", "missing", COL(0), EXT_Y, 360, BH, ["MS", "Talk"],
     [("REVEALS run (Sugita 2007)", "h"),
      ("pollen → taxon fractions per 1° cell and time slice, with posterior draws", "b"),
      ("→ veg_pred_LGM_8.0.RDS  (file and code not in repo)", "i")]),
    ("ext-interp", "proc", "missing", COL(2), EXT_Y, BW, BH, ["MS?", "Talk"],
     [("Bayesian spatial interpolation", "h"), ("+ ice mask; fills cells without", "b"),
      ("a pollen site (Pirzamanbein 2018)", "b"), ("→ veg_posts_interp_ice.RDS", "i")]),
    ("ext-bluesky", "proc", "missing", COL(3), EXT_Y, BW, BH, ["MS"],
     [("Building blue-sky albedo", "h"), ("blue = f·white + (1−f)·black,", "b"),
      ("monthly mean over 2000–09", "b"), ("→ GeoTIFF (in repo; code not)", "i")]),
    ("ext-snow", "proc", "archive", COL(7), EXT_Y, BW, BH, [],
     [("Abandoned snow branch", "h"), ("ClimateNA, Thornthwaite water", "b"),
      ("balance, GCM snow probability", "b"), ("scripts/archive; not used", "i")]),

    # ---- lane 1: interp path -------------------------------------------------
    ("stage-1-interp", "proc", "blocked", COL(0), L1_Y, BW, BH, ["MS", "Talk"],
     [("1_veg_lct_prep.R", "h"), ("taxa → ET / ST / OL fractions;", "b"),
      ("project, add elevation, clip", "b"), ("full grid, ice-masked", "i")]),
    ("stage-2-interp", "proc", "blocked", COL(1), L1_Y, BW, BH, ["MS"],
     [("2_calibration_lct_bluesky.R", "h"), ("extract monthly blue-sky", "b"),
      ("albedo at modern cells", "b"), ("all interpolated cells", "i")]),
    ("stage-4-interp", "proc", "blocked", COL(2), L1_Y, BW, BH, ["MS", "Talk"],
     [("4_calibration_model.R", "h"), ("beta GAM ladder mod1–8:", "b"),
      ("space + elevation + cover", "b"), ("12 monthly models", "i")]),
    ("stage-5-interp", "proc", "blocked", COL(3), L1_Y, BW, BH, ["MS"],
     [("5_calibration_eval.R", "h"), ("fit diagnostics, AIC table;", "b"),
      ("mod8 hardcoded as selected", "b"), ("per month", "i")]),
    ("stage-6-interp", "proc", "blocked", COL(4), L1_Y, BW, BH, ["MS", "Talk"],
     [("6_prediction_model.R", "h"), ("apply selected model to each", "b"),
      ("Holocene slice; 100 draws", "b"), ("(manuscript says 1,000)", "i")]),
    ("stage-7-interp", "proc", "blocked", COL(5), L1_Y, BW, BH, ["Talk"],
     [("7_plot_preds.R", "h"), ("albedo, sd, CV and difference", "b"),
      ("maps with ice-sheet overlays", "b"), ("12 months × slices", "i")]),
    ("stage-7a", "proc", "blocked", COL(6), L1_Y, BW, BH, ["MS"],
     [("7a_alb_diff_full.R", "h"), ("slice-to-slice Δalbedo split", "b"),
      ("into vegetation and ice parts", "b"), ("interp only", "i")]),
    ("stage-8", "proc", "blocked", COL(7), L1_Y, BW, BH, ["MS", "Talk"],
     [("8_radiative.R", "h"), ("forcing = Δalbedo × kernel", "b"),
      ("HadGEM3, CAM5, CACK; 27–74°N", "b"), ("interp only", "i")]),

    # ---- lane 2: non-interp path ---------------------------------------------
    ("stage-1-nointerp", "proc", "blocked", COL(0), L2_Y, BW, BH, ["MS", "Talk"],
     [("1_veg_lct_prep.R", "h"), ("same script, REVEALS half", "b"),
      ("input missing; its outputs", "b"), ("(lct_*_reveals.RDS) in repo", "i")]),
    ("stage-2-nointerp", "proc", "runs", COL(1), L2_Y, BW, BH, ["MS"],
     [("2_calibration_lct_bluesky.R", "h"), ("extract albedo at the", "b"),
      ("505 pollen-bearing cells", "b"), ("reproduces committed table", "i")]),
    ("stage-4-nointerp", "proc", "runs", COL(2), L2_Y, BW, BH, ["MS", "Talk"],
     [("4_calibration_model.R", "h"), ("same ladder, March only", "b"),
      ("(505 cells, ~90 min)", "b"), ("AIC favoured mod2, no cover", "i")]),
    ("stage-5-nointerp", "proc", "runs", COL(3), L2_Y, BW, BH, ["MS"],
     [("5_calibration_eval.R", "h"), ("model vs data, r = 0.95;", "b"),
      ("mod8 selected", "b"), ("March", "i")]),
    ("stage-6-nointerp", "proc", "runs", COL(4), L2_Y, BW, BH, ["MS", "Talk"],
     [("6_prediction_model.R", "h"), ("March albedo per slice;", "b"),
      ("matches committed predictions", "b"), ("(corr 0.999)", "i")]),
    ("stage-7-nointerp", "proc", "runs", COL(5), L2_Y, BW, BH, ["Talk"],
     [("7_plot_preds.R", "h"), ("March maps and differences;", "b"),
      ("no ice overlay (shapefiles", "b"), ("missing)", "i")]),

    # ---- row E: side branches, snow note, outputs ----------------------------
    ("stage-3", "proc", "runs", COL(1), E_Y, BW, 84, [],
     [("3_plot_cal_lct_albedo.R", "h"), ("calibration-data diagnostics:", "b"),
      ("LCT maps, albedo vs covariates", "b")]),
    ("note-snow", "note", "none", COL(2), E_Y, 366, 84, [],
     [("Assumption, stated nowhere: snow is not modelled", "h"),
      ("The 2000–09 snow climatology sits inside the spatial and elevation", "b"),
      ("terms and is held fixed for every slice; only cover changes through", "b"),
      ("time. Ice sheets are handled separately in 7a.", "b")]),
    ("stage-6s", "proc", "blocked", COL(4), E_Y, BW, 84, ["MS"],
     [("6_prediction_model_", "h"), ("spatial_eval.R", "h"), ("7 nested models: does the", "b"),
      ("modern spatial term bias", "b"), ("the hindcasts?", "b")]),
    ("out-albedo", "doc", "none", COL(5), E_Y, BW, 84, ["MS", "Talk"],
     [("Albedo maps", "h"), ("per slice and month,", "b"), ("with sd and CV", "b")]),
    ("out-diff", "doc", "none", COL(6), E_Y, BW, 84, ["MS"],
     [("Albedo differences", "h"), ("between consecutive slices,", "b"),
      ("vegetation vs ice parts", "b")]),
    ("out-forcing", "doc", "none", COL(7), E_Y, BW, 84, ["MS", "Talk"],
     [("Radiative forcing (W/m²)", "h"), ("maps, continental time series,", "b"),
      ("comparison to modern agents", "b")]),
]

# ----------------------------------------------------------------------------
# connectors: list of (points, style, label, label_pos)
#   style: 'flow' solid, 'dash' dashed (side branch / missing input)
# ----------------------------------------------------------------------------
def cx(i): return COL(i) + BW / 2

edges = []
def E(pts, style="flow", label=None, at=None):
    edges.append((pts, style, label, at))

# sources -> external steps
E([(cx(0), SRC_Y + BH), (cx(0), EXT_Y)])
E([(cx(1), SRC_Y + BH), (cx(1), EXT_Y)])
E([(cx(2), SRC_Y + BH), (cx(2), SRC_Y + BH + 26), (COL(0) + 300, SRC_Y + BH + 26), (COL(0) + 300, EXT_Y)])
E([(cx(3), SRC_Y + BH), (cx(3), EXT_Y)])
E([(cx(7), SRC_Y + BH), (cx(7), EXT_Y)], "dash")
# ice -> interpolation (ice mask)
E([(cx(5), SRC_Y + BH), (cx(5), SRC_Y + BH + 36), (COL(2) + 150, SRC_Y + BH + 36), (COL(2) + 150, EXT_Y)],
  "dash", "ice mask", (COL(2) + 158, SRC_Y + BH + 31))
# REVEALS run -> interpolation
E([(COL(0) + 360, EXT_Y + BH / 2), (COL(2), EXT_Y + BH / 2)], "flow", "posterior draws", (COL(0) + 380, EXT_Y + BH + 14))
# REVEALS run -> stage 1 non-interp via left margin
E([(COL(0) + 12, EXT_Y + BH), (COL(0) + 12, EXT_Y + BH + 14), (24, EXT_Y + BH + 14), (24, L2_Y + BH / 2), (COL(0), L2_Y + BH / 2)],
  "flow", "cells with sites", None)
# interpolation -> stage 1 interp
E([(cx(2), EXT_Y + BH), (cx(2), EXT_Y + BH + 34), (cx(0) - 20, EXT_Y + BH + 34), (cx(0) - 20, L1_Y)],
  "flow", "full grid", (cx(0) - 16, L1_Y - 18))
# grid/elevation -> stage 1 (both lanes share; draw to interp lane)
E([(cx(4), SRC_Y + BH), (cx(4), EXT_Y + BH + 24), (cx(0) + 20, EXT_Y + BH + 24), (cx(0) + 20, L1_Y)],
  "flow", "grid, elevation", (cx(4) + 6, EXT_Y + 40))
# blue-sky -> stage 2 both lanes
E([(cx(3), EXT_Y + BH), (cx(3), EXT_Y + BH + 44), (cx(1), EXT_Y + BH + 44), (cx(1), L1_Y)],
  "flow", "blue-sky GeoTIFF", (cx(1) + 8, EXT_Y + BH + 36))
E([(cx(1), EXT_Y + BH + 44), (COL(1) - 10, EXT_Y + BH + 44), (COL(1) - 10, L2_Y + BH / 2), (COL(1), L2_Y + BH / 2)])
# ice -> 7a
E([(cx(5), SRC_Y + BH + 36), (cx(5), EXT_Y + BH + 54), (cx(6), EXT_Y + BH + 54), (cx(6), L1_Y)],
  "dash", "ice fraction, glacier albedo", (cx(5) + 6, EXT_Y + BH + 50))
# kernels -> 8
E([(cx(6), SRC_Y + BH), (cx(6), EXT_Y + BH + 10), (cx(7), EXT_Y + BH + 10), (cx(7), L1_Y)],
  "dash", "kernels", (cx(6) + 6, EXT_Y + BH + 6))
# lane 1 chain
for i in range(7):
    E([(COL(i) + BW, L1_Y + BH / 2), (COL(i + 1), L1_Y + BH / 2)])
# lane 2 chain
for i in range(5):
    E([(COL(i) + BW, L2_Y + BH / 2), (COL(i + 1), L2_Y + BH / 2)])
# side branches and outputs
E([(cx(1), L2_Y + BH), (cx(1), E_Y)], "dash")                                   # 2 -> 3
E([(cx(2), L2_Y + BH), (cx(2), E_Y)], "dash")                                   # 4 -> snow note
E([(COL(4) + BW, L1_Y + BH - 14), (COL(4) + BW + 10, L1_Y + BH - 14), (COL(4) + BW + 10, E_Y + 42), (COL(4) + BW, E_Y + 42)], "dash")  # 6 interp -> 6s
E([(cx(5), L2_Y + BH), (cx(5), E_Y)])                                           # 7 -> albedo maps
E([(cx(6), L1_Y + BH), (cx(6), E_Y)])                                           # 7a -> differences
E([(cx(7), L1_Y + BH), (cx(7), E_Y)])                                           # 8 -> forcing

# ----------------------------------------------------------------------------
def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

def doc_path(x, y, w, h):
    """draw.io 'document' shape: rectangle with a gentle wave along the bottom."""
    d = 10
    return (f"M{x},{y} H{x + w} V{y + h - d} "
            f"C{x + w * 0.83},{y + h + d * 0.9} {x + w * 0.66},{y + h - 2 * d} {x + w * 0.5},{y + h - d} "
            f"C{x + w * 0.34},{y + h} {x + w * 0.17},{y + h + d * 0.2} {x},{y + h - d} Z")

def badge_svg(x_right, y_bottom, badges):
    out, x = [], x_right - 8
    for b in reversed(badges):
        w = 22 if len(b) <= 2 else 30
        x -= w
        cls = "badge-ms" if b.startswith("MS") else "badge-talk"
        out.append(f'<rect class="{cls}" x="{x}" y="{y_bottom - 19}" width="{w}" height="13" rx="3"/>'
                   f'<text class="badge-t" x="{x + w / 2}" y="{y_bottom - 9.4}" text-anchor="middle">{b}</text>')
        x -= 4
    return "".join(out)

def box_svg(bid, kind, status, x, y, w, h, badges, lines):
    cls = f"box st-{status} k-{kind}"
    if kind == "doc":
        shape = f'<path class="{cls}" d="{doc_path(x, y, w, h)}"/>'
    elif kind == "note":
        shape = f'<rect class="{cls}" x="{x}" y="{y}" width="{w}" height="{h}" rx="3"/>'
    else:
        shape = f'<rect class="{cls}" x="{x}" y="{y}" width="{w}" height="{h}" rx="7"/>'
    ty = y + 19
    texts = []
    for i, (t, style) in enumerate(lines):
        texts.append(f'<text class="t-{style}" x="{x + 9}" y="{ty}">{esc(t)}</text>')
        ty += 15 if style == "h" else 13.5
    return (f'<g id="{bid}" data-stage="{bid}" class="node">{shape}{badge_svg(x + w, y + h - (12 if kind == "doc" else 0), badges)}'
            f'{"".join(texts)}</g>')

def edge_svg(pts, style, label, at):
    d = "M" + " L".join(f"{px},{py}" for px, py in pts)
    s = f'<path class="edge e-{style}" d="{d}" marker-end="url(#arrow)"/>'
    if label and at is None:   # rotated label along the left-margin route
        s += f'<text class="t-edge" transform="translate(20,{L2_Y - 30}) rotate(-90)">{esc(label)}</text>'
    elif label:
        anchor = ' text-anchor="middle"' if label == "posterior draws" else ""
        s += f'<text class="t-edge" x="{at[0]}" y="{at[1]}"{anchor}>{esc(label)}</text>'
    return s

def lane_svg(y, h, title, sub, cls, title_y):
    return (f'<rect class="lane {cls}" x="32" y="{y}" width="{W - 46}" height="{h}" rx="6"/>'
            f'<text class="t-lane" x="48" y="{title_y}">{esc(title)}</text>'
            f'<text class="t-lanesub" x="{48 + 7.4 * len(title) + 10}" y="{title_y}">{esc(sub)}</text>')

def band_label(y, text):
    return f'<text class="t-band" x="40" y="{y}">{esc(text)}</text>'

def legend_svg(x, y):
    items = [("st-runs k-proc", "in repo, runs today"),
             ("st-blocked k-proc", "in repo, blocked on a missing input"),
             ("st-missing k-proc", "not in repo: external step or missing data"),
             ("st-archive k-proc", "abandoned / archive"),
             ("st-none k-doc", "data source or output")]
    out = [f'<text class="t-band" x="{x}" y="{y}">LEGEND</text>']
    yy = y + 12
    for cls, lab in items:
        if "k-doc" in cls:
            out.append(f'<path class="box {cls}" d="{doc_path(x, yy, 26, 16)}"/>')
        else:
            out.append(f'<rect class="box {cls}" x="{x}" y="{yy}" width="26" height="16" rx="4"/>')
        out.append(f'<text class="t-b" x="{x + 34}" y="{yy + 12}">{esc(lab)}</text>')
        yy += 22
    bx = x + 330
    out.append(f'<rect class="badge-ms" x="{bx}" y="{y + 14}" width="22" height="13" rx="3"/>'
               f'<text class="badge-t" x="{bx + 11}" y="{y + 23.6}" text-anchor="middle">MS</text>'
               f'<text class="t-b" x="{bx + 30}" y="{y + 24}">described in the draft manuscript (MS? = hinted only)</text>')
    out.append(f'<rect class="badge-talk" x="{bx}" y="{y + 36}" width="30" height="13" rx="3"/>'
               f'<text class="badge-t" x="{bx + 15}" y="{y + 45.6}" text-anchor="middle">Talk</text>'
               f'<text class="t-b" x="{bx + 38}" y="{y + 46}">shown in the EGU slides</text>')
    out.append(f'<path class="edge e-flow" d="M{bx},{y + 66} L{bx + 30},{y + 66}" marker-end="url(#arrow)"/>'
               f'<text class="t-b" x="{bx + 38}" y="{y + 70}">data flow</text>')
    out.append(f'<path class="edge e-dash" d="M{bx},{y + 88} L{bx + 30},{y + 88}" marker-end="url(#arrow)"/>'
               f'<text class="t-b" x="{bx + 38}" y="{y + 92}">side branch, or input that is missing</text>')
    return "".join(out)

def build_svg():
    parts = [f'<svg id="schematic" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" role="img" '
             f'aria-label="Flowchart of the paleo-RF methodology from fossil pollen to radiative forcing, '
             f'showing data sources, external steps, the scripted pipeline in interp and non-interp flavours, and outputs, '
             f'colour-coded by whether each part is in the repository and runs.">',
             '<defs><marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto-start-reverse">'
             '<path d="M0,0 L10,5 L0,10 z" class="arrowhead"/></marker>'
             f'<pattern id="grid" width="20" height="20" patternUnits="userSpaceOnUse"><path d="M20,0 H0 V20" class="gridline"/></pattern></defs>',
             f'<rect class="paper" x="0" y="0" width="{W}" height="{H}"/>',
             f'<rect x="0" y="0" width="{W}" height="{H}" fill="url(#grid)"/>',
             f'<text class="t-title" x="40" y="40">paleo-RF methodology</text>',
             f'<text class="t-sub" x="40" y="62">Fossil pollen → land cover → modern albedo calibration → Holocene albedo → radiative forcing.  '
             f'Colour = status in the repository; badges = where the step is described.</text>',
             band_label(SRC_Y - 10, "DATA SOURCES"),
             band_label(EXT_Y - 10, "STEPS OUTSIDE THE REPOSITORY  (no code here)"),
             lane_svg(L1_Y - 12, BH + 36, "INTERP PATH", "full grid, ice-masked, all 12 months: the paper's path. Blocked on veg_posts_interp_ice.RDS. (scripts/ in the repo; one script serves both flavours)", "lane-interp", L1_Y + BH + 17),
             lane_svg(L2_Y - 30, BH + 42, "NON-INTERP PATH", "505 pollen-bearing cells, March only: runs today on branch run-nointerp", "lane-nointerp", L2_Y - 12),
             f'<text class="t-i" x="{cx(6) + 12}" y="{L2_Y + 22}">7a and 8 have no non-interp</text>',
             f'<text class="t-i" x="{cx(6) + 12}" y="{L2_Y + 36}">version: 7a reads only the</text>',
             f'<text class="t-i" x="{cx(6) + 12}" y="{L2_Y + 50}">interp predictions, and both</text>',
             f'<text class="t-i" x="{cx(6) + 12}" y="{L2_Y + 64}">need the missing ice and</text>',
             f'<text class="t-i" x="{cx(6) + 12}" y="{L2_Y + 78}">kernel files.</text>',
             band_label(E_Y - 10, "SIDE BRANCHES, ASSUMPTIONS AND OUTPUTS"),
             ]
    parts += [edge_svg(*e) for e in edges]
    parts += [box_svg(*b) for b in boxes]
    parts.append(legend_svg(40, E_Y + 112))
    parts.append(f'<text class="t-foot" x="{W - 20}" y="{H - 14}" text-anchor="end">paleo-RF, branch chris-dev · 2026-09-17 · generated by tools/methodology_schematic.py</text>')
    parts.append("</svg>")
    return "\n".join(parts)

CSS = """
:root{
  --bg:#f6f5f1; --paper:#fbfaf7; --ink:#1f2a33; --ink-2:#4b5a66; --ink-3:#7a8791;
  --grid:#e6e3dc; --edge:#5b6873; --lane-i:#e9eef8; --lane-n:#f3efe4; --lane-stroke:#cfd6e2;
  --runs:#dcefdc; --runs-s:#3f8a4d; --blocked:#fbe8c4; --blocked-s:#c5851a;
  --missing:#ebedf1; --missing-s:#6b7683; --archive:#efefef; --archive-s:#a3a3a3; --archive-t:#7d7d7d;
  --none:#ffffff; --none-s:#5b6873; --note:#fff8d6; --note-s:#c9a227;
  --ms:#2f5fa8; --talk:#7b4ea3; --badge-t:#ffffff;
}
@media (prefers-color-scheme: dark){ :root:not([data-theme="light"]){
  --bg:#171b20; --paper:#1d2228; --ink:#e6e9ec; --ink-2:#b6bec6; --ink-3:#8b959e;
  --grid:#262c33; --edge:#a6b1bb; --lane-i:#1f2a3c; --lane-n:#2b2820; --lane-stroke:#3a4652;
  --runs:#1f3b26; --runs-s:#6cc57c; --blocked:#3e2f12; --blocked-s:#e0a53a;
  --missing:#2a3038; --missing-s:#9aa5b1; --archive:#272727; --archive-s:#6d6d6d; --archive-t:#9a9a9a;
  --none:#20262d; --none-s:#a6b1bb; --note:#3a3413; --note-s:#d9b53a;
  --ms:#5b8ad6; --talk:#a67fd0; --badge-t:#0f1418;
}}
:root[data-theme="dark"]{
  --bg:#171b20; --paper:#1d2228; --ink:#e6e9ec; --ink-2:#b6bec6; --ink-3:#8b959e;
  --grid:#262c33; --edge:#a6b1bb; --lane-i:#1f2a3c; --lane-n:#2b2820; --lane-stroke:#3a4652;
  --runs:#1f3b26; --runs-s:#6cc57c; --blocked:#3e2f12; --blocked-s:#e0a53a;
  --missing:#2a3038; --missing-s:#9aa5b1; --archive:#272727; --archive-s:#6d6d6d; --archive-t:#9a9a9a;
  --none:#20262d; --none-s:#a6b1bb; --note:#3a3413; --note-s:#d9b53a;
  --ms:#5b8ad6; --talk:#a67fd0; --badge-t:#0f1418;
}
body{background:var(--bg);color:var(--ink);margin:0;padding:24px 16px;font-family:"IBM Plex Sans","Helvetica Neue",Arial,sans-serif;}
main{max-width:1600px;margin:0 auto;}
figure{margin:0;}
.scroller{overflow-x:auto;border:1px solid var(--grid);border-radius:8px;background:var(--paper);}
svg#schematic{display:block;min-width:1100px;width:100%;height:auto;font-family:"IBM Plex Sans","Helvetica Neue",Arial,sans-serif;}
figcaption{font-size:13px;color:var(--ink-2);margin-top:10px;max-width:70ch;line-height:1.45;}
figcaption code{font-family:"IBM Plex Mono",Menlo,Consolas,monospace;font-size:12px;}
.paper{fill:var(--paper);}
.gridline{fill:none;stroke:var(--grid);stroke-width:0.6;}
.lane{stroke:var(--lane-stroke);stroke-width:1;}
.lane-interp{fill:var(--lane-i);} .lane-nointerp{fill:var(--lane-n);}
.box{stroke-width:1.2;}
.st-runs{fill:var(--runs);stroke:var(--runs-s);}
.st-blocked{fill:var(--blocked);stroke:var(--blocked-s);}
.st-missing{fill:var(--missing);stroke:var(--missing-s);stroke-dasharray:5 3;}
.st-archive{fill:var(--archive);stroke:var(--archive-s);stroke-dasharray:2 3;}
.st-none{fill:var(--none);stroke:var(--none-s);}
.k-note.st-none,.k-note{fill:var(--note);stroke:var(--note-s);}
.edge{fill:none;stroke:var(--edge);stroke-width:1.3;}
.e-dash{stroke-dasharray:5 4;}
.arrowhead{fill:var(--edge);}
text{fill:var(--ink);}
.t-title{font-size:22px;font-weight:600;letter-spacing:-0.2px;}
.t-sub{font-size:12.5px;fill:var(--ink-2);}
.t-band{font-size:10.5px;font-weight:600;letter-spacing:1px;fill:var(--ink-3);}
.t-lane{font-size:11px;font-weight:700;letter-spacing:0.6px;}
.t-lanesub{font-size:11px;fill:var(--ink-2);}
.t-h{font-size:11px;font-weight:600;}
.t-b{font-size:10.5px;fill:var(--ink-2);}
.t-i{font-size:10px;font-style:italic;fill:var(--ink-3);}
.t-edge{font-size:9.5px;fill:var(--ink-3);}
.t-foot{font-size:10px;fill:var(--ink-3);}
.st-archive ~ text,.node:has(.st-archive) text{fill:var(--archive-t);}
.badge-ms{fill:var(--ms);} .badge-talk{fill:var(--talk);}
.badge-t{font-size:8.5px;font-weight:700;fill:var(--badge-t);letter-spacing:0.3px;}
"""

HTML = """<title>paleo-RF Methodology</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:ital,wght@0,400;0,600;0,700;1,400&family=IBM+Plex+Mono&display=swap">
<style>{css}</style>
<main>
<figure>
<div class="scroller">
{svg}
</div>
<figcaption>One-page map of the method behind “Mapping Holocene Albedo from Fossil Pollen Inferred Land Cover Change”.
Rows read top to bottom: the data that feeds the method, the steps done outside this repository, the scripted
pipeline in its two flavours, then side branches and outputs. Green boxes run today; amber boxes are in the
repository but wait on an input that is not; dashed grey boxes have no code here. Each box has a stable
<code>id</code> so the open questions in <code>METHODOLOGY_QUESTIONS.md</code> can be attached later.</figcaption>
</figure>
</main>
"""

if __name__ == "__main__":
    root = Path(__file__).resolve().parent.parent
    svg = build_svg()
    (root / "METHODOLOGY_SCHEMATIC.html").write_text(HTML.format(css=CSS, svg=svg))
    # standalone SVG: light-theme literal values, no CSS variables
    light = {}
    block = CSS.split("}", 1)[0].split("{", 1)[1]
    for decl in block.split(";"):
        if ":" in decl:
            k, v = decl.split(":", 1)
            light[k.strip()] = v.strip()
    css_svg = CSS
    for k, v in light.items():
        css_svg = css_svg.replace(f"var({k})", v)
    # keep only the rules that matter inside an SVG
    css_svg = css_svg.split("body{", 1)[1].split("figcaption code{", 1)[1].split("}", 1)[1]
    css_svg = css_svg.replace("svg#schematic{", "svg{")
    standalone = svg.replace(">", f'><style>{css_svg}</style>', 1)
    standalone = standalone.replace('<svg id="schematic"', '<svg id="schematic" style="font-family:\'Liberation Sans\'"')
    (root / "METHODOLOGY_SCHEMATIC.svg").write_text('<?xml version="1.0" encoding="UTF-8"?>\n' + standalone)
    print("wrote METHODOLOGY_SCHEMATIC.html and .svg")
