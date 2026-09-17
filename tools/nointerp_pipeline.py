#!/usr/bin/env python3
"""Generate docs/nointerp_pipeline.svg: a simplified, linear flowchart of the
non-interp (March, 505 pollen cells) pipeline run on 2026-09-16.

A subset of tools/methodology_schematic.py: one box per script that ran, with
its inputs (in repo / missing) and outputs, plus greyed boxes for the scripts
that did not run. Badges mark steps shown in the EGU slides. No reference to
the manuscript by design.

Run from the repo root:  python3 tools/nointerp_pipeline.py
then:  uv run --with cairosvg python -c "import cairosvg; cairosvg.svg2png(url='docs/nointerp_pipeline.svg', write_to='docs/nointerp_pipeline.png', scale=2)"
"""
from pathlib import Path

W, H = 1580, 660
BW, BH = 196, 104            # script box
DW, DH = 196, 60             # data (document) box
GAP = 18
X0 = 40
COL = lambda i: X0 + i * (BW + GAP)   # 7 columns: 1,2,4,5,6,7,7a/8
Y_IN = 92                    # inputs row
Y_MISS = Y_IN + DH + 14      # missing inputs row
Y_PROC = Y_MISS + DH + 46    # script row
Y_OUT = Y_PROC + BH + 46     # outputs row

# (id, kind, status, col, row_y, w, h, badges, lines)
boxes = [
    # ---------- inputs used (in repo) ----------
    ("in-1", "doc", "runs", COL(0), Y_IN, DW, DH, [],
     [("grid.RDS, taxon-to-cover csv", "h"), ("in repo", "i")]),
    ("in-2", "doc", "runs", COL(1), Y_IN, DW, DH, [],
     [("blue-sky albedo GeoTIFF", "h"), ("2000–09 monthly; lct_paleo_reveals", "b"),
      ("(age-50 slice); pbs map polygons", "b")]),
    ("in-3", "doc", "runs", COL(2), Y_IN, DW, DH, [],
     [("calibration table", "h"), ("505 cells × 12 months (from 2)", "b")]),
    ("in-4", "doc", "runs", COL(3), Y_IN, DW, DH, [],
     [("calibration table (March)", "h"), ("505 cells, 496 with albedo", "b")]),
    ("in-5", "doc", "runs", COL(4), Y_IN, DW, DH, [],
     [("mod1–mod8 March fits", "h"), ("from 4; calibration table", "b")]),
    ("in-6", "doc", "runs", COL(5), Y_IN, DW, DH, [],
     [("selected model (mod8)", "h"), ("lct_paleo_reveals.RDS: 12 slices,", "b"),
      ("4,453 cell-slices", "b")]),
    ("in-7", "doc", "runs", COL(6), Y_IN, DW, DH, [],
     [("March predictions (from 6)", "h"), ("grid.RDS, pbs map polygons", "b")]),

    # ---------- inputs missing ----------
    ("miss-1", "doc", "missing", COL(0), Y_MISS, DW, DH, [],
     [("veg_pred_LGM_8.0.RDS", "h"), ("REVEALS output: MISSING", "i")]),
    ("miss-2", "doc", "missing", COL(1), Y_MISS, DW, DH, [],
     [("lct_modern_reveals_point.RDS", "h"), ("point-scale table: MISSING;", "i"),
      ("lct_modern_reveals.RDS stale", "i")]),
    ("miss-3", "doc", "missing", COL(2), Y_MISS, DW, DH, [],
     [("scripts/make_grid.R", "h"), ("MISSING (reconstructed);", "i"),
      ("_coarse/_point tables MISSING", "i")]),
    ("miss-4", "doc", "missing", COL(3), Y_MISS, DW, DH, [],
     [("interp calibration table", "h"), ("MISSING (interp half skipped)", "i")]),
    ("miss-5", "doc", "missing", COL(4), Y_MISS, DW, DH, [],
     [("interp fits; brms fits", "h"), ("MISSING (those blocks skipped)", "i")]),
    ("miss-6", "doc", "missing", COL(5), Y_MISS, DW, DH, [],
     [("lct_paleo_reveals_interp.RDS", "h"), ("MISSING (interp half skipped)", "i")]),
    ("miss-7", "doc", "missing", COL(6), Y_MISS, DW, DH, [],
     [("ice-sheet shapefiles 21–1 ka", "h"), ("MISSING: no ice overlay drawn", "i")]),

    # ---------- scripts ----------
    ("stage-1", "proc", "skipped", COL(0), Y_PROC, BW, BH, ["Talk"],
     [("1_veg_lct_prep.R", "h"), ("DID NOT RUN", "h"),
      ("taxa → ET / ST / OL fractions", "b"), ("its outputs are committed, so", "i"),
      ("the rest could start from them", "i")]),
    ("stage-2", "proc", "runs", COL(1), Y_PROC, BW, BH, [],
     [("2_calibration_lct_bluesky.R", "h"), ("extract monthly albedo at the", "b"),
      ("505 pollen-bearing cells", "b"), ("~3 min; reproduces the", "i"), ("committed table exactly", "i")]),
    ("stage-3", "proc", "runs", COL(2), Y_PROC, BW, BH, [],
     [("3_plot_cal_lct_albedo.R", "h"), ("side branch: calibration-data", "b"),
      ("diagnostics (LCT maps, albedo", "b"), ("vs covariates)", "b"), ("~1 min", "i")]),
    ("stage-4", "proc", "runs", COL(3), Y_PROC, BW, BH, ["Talk"],
     [("4_calibration_model.R", "h"), ("beta GAM ladder mod1–8 for", "b"),
      ("March: space + elevation + cover", "b"), ("~90 min on 8 threads", "i")]),
    ("stage-5", "proc", "runs", COL(4), Y_PROC, BW, BH, ["Talk"],
     [("5_calibration_eval.R", "h"), ("AIC / deviance table; model vs", "b"),
      ("data (r = 0.95); mod8 selected", "b"), ("by the script", "b"), ("seconds", "i")]),
    ("stage-6", "proc", "runs", COL(5), Y_PROC, BW, BH, ["Talk"],
     [("6_prediction_model.R", "h"), ("apply mod8 to each Holocene", "b"),
      ("slice; 100 draws per cell", "b"), ("seconds; matches committed", "i"), ("predictions (r = 0.999)", "i")]),
    ("stage-7", "proc", "runs", COL(6), Y_PROC, BW, BH, ["Talk"],
     [("7_plot_preds.R", "h"), ("March albedo, sd, CV and", "b"),
      ("slice-to-slice difference maps", "b"), ("~6 min", "i")]),

    # ---------- outputs ----------
    ("out-1", "doc", "none", COL(0), Y_OUT, DW, DH, [],
     [("lct_modern_reveals.RDS", "h"), ("lct_paleo_reveals.RDS (committed)", "b")]),
    ("out-2", "doc", "none", COL(1), Y_OUT, DW, DH, [],
     [("calibration_modern_lct_bluesky", "h"), ("+ _coarse; 26 albedo maps", "b")]),
    ("out-3", "doc", "none", COL(2), Y_OUT, DW, DH, [],
     [("LCT pie, tricolore and", "h"), ("gridded calibration maps", "b")]),
    ("out-4", "doc", "none", COL(3), Y_OUT, DW, DH, [],
     [("calibration_mod1–8_bluesky.RDS", "h"), ("(+ mod7_free); March fits", "b")]),
    ("out-5", "doc", "none", COL(4), Y_OUT, DW, DH, [],
     [("calibration_model_selected", "h"), ("model-vs-data figures", "b")]),
    ("out-6", "doc", "none", COL(5), Y_OUT, DW, DH, [],
     [("paleo_predict_gam[_summary|", "h"), ("_samps]_bluesky.RDS", "b")]),
    ("out-7", "doc", "none", COL(6), Y_OUT, DW, DH, [],
     [("13 alb_preds_* figures;", "h"), ("alb_preds_diffs_bluesky.RDS", "b")]),
]

# blocked tail (7a, 8) drawn to the right of the outputs row as one grey box
BLOCKED = ("stage-7a8", "proc", "blocked", COL(5), Y_OUT + DH + 26, BW * 2 + GAP, 56, [],
           [("7a_alb_diff_full.R, 8_radiative.R", "h"), ("not run: need the interp predictions,", "i"),
            ("Dalton ice raster, glacier albedo, kernels", "i")])
boxes.append(BLOCKED)

def cx(i): return COL(i) + BW / 2

edges = []
def E(pts, style="flow"):
    edges.append((pts, style))

for i in range(7):
    E([(cx(i), Y_IN + DH), (cx(i), Y_MISS)], "none")          # placeholder (no arrow)
    E([(cx(i) - 40, Y_IN + DH - 8), (cx(i) - 40, Y_PROC)])                       # inputs -> script (down the left)
    E([(cx(i) + 40, Y_MISS + DH - 8), (cx(i) + 40, Y_PROC)], "dash")             # missing -> script
    E([(cx(i), Y_PROC + BH), (cx(i), Y_OUT)])                                    # script -> output
# chain between scripts (skip 3, the side branch: 2 -> 4)
E([(COL(0) + BW, Y_PROC + BH / 2), (COL(1), Y_PROC + BH / 2)], "dash")
E([(COL(1) + BW, Y_PROC + BH / 2), (COL(2), Y_PROC + BH / 2)], "dash")
E([(COL(1) + BW, Y_PROC + BH - 16), (COL(1) + BW + GAP / 2, Y_PROC + BH - 16),
   (COL(1) + BW + GAP / 2, Y_PROC + BH + 18), (COL(2) + BW + GAP / 2, Y_PROC + BH + 18),
   (COL(2) + BW + GAP / 2, Y_PROC + BH / 2 + 12), (COL(3), Y_PROC + BH / 2 + 12)])
for i in range(3, 6):
    E([(COL(i) + BW, Y_PROC + BH / 2), (COL(i + 1), Y_PROC + BH / 2)])
E([(cx(6), Y_OUT + DH), (cx(6), Y_OUT + DH + 26)], "dash")                      # 7 outputs -> blocked tail

def esc(s):
    return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

def doc_path(x, y, w, h):
    d = 8
    return (f"M{x},{y} H{x + w} V{y + h - d} "
            f"C{x + w * 0.83},{y + h + d * 0.9} {x + w * 0.66},{y + h - 2 * d} {x + w * 0.5},{y + h - d} "
            f"C{x + w * 0.34},{y + h} {x + w * 0.17},{y + h + d * 0.2} {x},{y + h - d} Z")

def badge_svg(x_right, y_bottom, badges):
    out, x = [], x_right - 8
    for b in reversed(badges):
        w = 30
        x -= w
        out.append(f'<rect class="badge-talk" x="{x}" y="{y_bottom - 19}" width="{w}" height="13" rx="3"/>'
                   f'<text class="badge-t" x="{x + w / 2}" y="{y_bottom - 9.4}" text-anchor="middle">{b}</text>')
        x -= 4
    return "".join(out)

def box_svg(bid, kind, status, x, y, w, h, badges, lines):
    cls = f"box st-{status} k-{kind}"
    if kind == "doc":
        shape = f'<path class="{cls}" d="{doc_path(x, y, w, h)}"/>'
    else:
        shape = f'<rect class="{cls}" x="{x}" y="{y}" width="{w}" height="{h}" rx="7"/>'
    ty = y + 18
    texts = []
    for t, style in lines:
        texts.append(f'<text class="t-{style}" x="{x + 9}" y="{ty}">{esc(t)}</text>')
        ty += 15 if style == "h" else 13.5
    return (f'<g id="{bid}" data-stage="{bid}" class="node">{shape}'
            f'{badge_svg(x + w, y + h - (10 if kind == "doc" else 0), badges)}{"".join(texts)}</g>')

def edge_svg(pts, style):
    if style == "none":
        return ""
    d = "M" + " L".join(f"{px},{py}" for px, py in pts)
    return f'<path class="edge e-{style}" d="{d}" marker-end="url(#arrow)"/>'

def band(y, text):
    return f'<text class="t-band" x="{X0}" y="{y}">{esc(text)}</text>'

def legend_svg(x, y):
    items = [("st-runs k-proc", "ran on 2026-09-16"),
             ("st-skipped k-proc", "did not run (input missing; outputs already committed)"),
             ("st-blocked k-proc", "not run: blocked on missing data"),
             ("st-runs k-doc", "input present in the repo"),
             ("st-missing k-doc", "input missing from the repo"),
             ("st-none k-doc", "output produced")]
    out = [f'<text class="t-band" x="{x}" y="{y}">LEGEND</text>']
    yy = y + 12
    for k, (cls, lab) in enumerate(items):
        xx = x + (k // 3) * 330
        y2 = yy + (k % 3) * 22
        if "k-doc" in cls:
            out.append(f'<path class="box {cls}" d="{doc_path(xx, y2, 26, 16)}"/>')
        else:
            out.append(f'<rect class="box {cls}" x="{xx}" y="{y2}" width="26" height="16" rx="4"/>')
        out.append(f'<text class="t-b" x="{xx + 34}" y="{y2 + 12}">{esc(lab)}</text>')
    bx = x + 680
    out.append(f'<rect class="badge-talk" x="{bx}" y="{y + 14}" width="30" height="13" rx="3"/>'
               f'<text class="badge-t" x="{bx + 15}" y="{y + 23.6}" text-anchor="middle">Talk</text>'
               f'<text class="t-b" x="{bx + 38}" y="{y + 24}">step shown in the EGU slides</text>')
    out.append(f'<path class="edge e-flow" d="M{bx},{y + 44} L{bx + 30},{y + 44}" marker-end="url(#arrow)"/>'
               f'<text class="t-b" x="{bx + 38}" y="{y + 48}">data flow</text>')
    out.append(f'<path class="edge e-dash" d="M{bx},{y + 66} L{bx + 30},{y + 66}" marker-end="url(#arrow)"/>'
               f'<text class="t-b" x="{bx + 38}" y="{y + 70}">missing input, or a step that did not run</text>')
    return "".join(out)

CSS = """
svg{font-family:'Liberation Sans','Helvetica Neue',Arial,sans-serif;}
.paper{fill:#fbfaf7;}
.gridline{fill:none;stroke:#e6e3dc;stroke-width:0.6;}
.box{stroke-width:1.2;}
.st-runs{fill:#dcefdc;stroke:#3f8a4d;}
.st-skipped{fill:#efefef;stroke:#a3a3a3;stroke-dasharray:2 3;}
.st-blocked{fill:#fbe8c4;stroke:#c5851a;}
.st-missing{fill:#fbe3e0;stroke:#b4443a;stroke-dasharray:5 3;}
.st-none{fill:#ffffff;stroke:#5b6873;}
.k-doc.st-runs{fill:#eef6ee;}
.edge{fill:none;stroke:#5b6873;stroke-width:1.3;}
.e-dash{stroke-dasharray:5 4;}
.arrowhead{fill:#5b6873;}
text{fill:#1f2a33;}
.t-title{font-size:22px;font-weight:700;}
.t-sub{font-size:12.5px;fill:#4b5a66;}
.t-band{font-size:10.5px;font-weight:700;letter-spacing:1px;fill:#7a8791;}
.t-h{font-size:11px;font-weight:700;}
.t-b{font-size:10.5px;fill:#4b5a66;}
.t-i{font-size:10px;font-style:italic;fill:#7a8791;}
.t-foot{font-size:10px;fill:#7a8791;}
.st-skipped ~ text{fill:#7d7d7d;}
.badge-talk{fill:#7b4ea3;}
.badge-t{font-size:8.5px;font-weight:700;fill:#ffffff;letter-spacing:0.3px;}
"""

def build_svg():
    parts = [f'<?xml version="1.0" encoding="UTF-8"?>\n<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" role="img" '
             f'aria-label="Linear flowchart of the non-interp paleo-RF pipeline run on 2026-09-16, with inputs, missing inputs and outputs per script.">',
             f'<style>{CSS}</style>',
             '<defs><marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="8" markerHeight="8" orient="auto-start-reverse">'
             '<path d="M0,0 L10,5 L0,10 z" class="arrowhead"/></marker>'
             '<pattern id="grid" width="20" height="20" patternUnits="userSpaceOnUse"><path d="M20,0 H0 V20" class="gridline"/></pattern></defs>',
             f'<rect class="paper" x="0" y="0" width="{W}" height="{H}"/>',
             f'<rect x="0" y="0" width="{W}" height="{H}" fill="url(#grid)"/>',
             '<text class="t-title" x="40" y="38">paleo-RF: the non-interp pipeline as run on 2026-09-16</text>',
             '<text class="t-sub" x="40" y="60">March albedo, 505 pollen-bearing 1° cells, vegetation only. One column per script; '
             'rows show the inputs it used, the inputs that were missing, and what it produced.</text>',
             band(Y_IN - 8, "INPUTS USED (IN REPO)"),
             band(Y_MISS - 8, "INPUTS MISSING FROM THE REPO"),
             band(Y_PROC - 8, "SCRIPTS"),
             band(Y_OUT - 8, "OUTPUTS PRODUCED")]
    parts += [edge_svg(*e) for e in edges]
    parts += [box_svg(*b) for b in boxes]
    parts.append(legend_svg(X0, Y_OUT + DH + 26))
    parts.append(f'<text class="t-foot" x="{W - 20}" y="{H - 12}" text-anchor="end">paleo-RF · 2026-09-17 · generated by tools/nointerp_pipeline.py</text>')
    parts.append("</svg>")
    return "\n".join(parts)

if __name__ == "__main__":
    root = Path(__file__).resolve().parent.parent
    out = root / "docs" / "nointerp_pipeline.svg"
    out.parent.mkdir(exist_ok=True)
    out.write_text(build_svg())
    print(f"wrote {out}")
