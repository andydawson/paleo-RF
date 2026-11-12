#!/usr/bin/env python3
"""Fill the numbers into the case-study report.

The report's prose is in report_template.md; every table and number block is made here from
the CSV files the R scripts wrote, so that no number is copied by hand. A placeholder
{{name}} in the template is replaced by the block of that name.

Usage: 13_report_tables.py   (reads and writes in its own folder)
"""
import csv
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
RUNS = ['mod8', 'loc100_linear', 'mod8_coarse_loc']
RUN_NAMES = {'mod8': 'model 8 (original)', 'loc100_linear': 'chosen model', 'mod8_coarse_loc': 'coarse-location model'}
MONTHS = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']
SEASONS = [('Dec-Feb', ['dec', 'jan', 'feb']), ('Mar-May', ['mar', 'apr', 'may']), ('Jun-Aug', ['jun', 'jul', 'aug']), ('Sep-Nov', ['sep', 'oct', 'nov'])]


def read(name):
    with open(os.path.join(HERE, name), newline='') as handle:
        return list(csv.DictReader(handle))


regions = {row['candidate']: row for row in read('candidate_regions.csv')}
monthly = read('candidate_monthly.csv')
expectation = read('candidate_expectation.csv')
judgements = read('candidate_judgements.csv')
per_unit = read('candidate_response_per_unit_cover.csv')
sensitivity = read('candidate_sensitivity.csv')
by_region = read('forcing_by_region.csv')


def number(row, column):
    return float(row[column])


def month_values(key, run, column):
    rows = {row['month']: row for row in monthly if row['key'] == key and row['run'] == run}
    return [float(rows[month][column]) if rows[month][column] not in ('NA', '') else None for month in MONTHS]


def mean(values):
    values = [v for v in values if v is not None]
    return sum(values) / len(values)


def season_mean(key, run, months):
    values = dict(zip(MONTHS, month_values(key, run, 'albedo_change')))
    return mean([values[m] for m in months])


def box_text(row):
    return '%g to %g W, %g to %g N' % (-number(row, 'lon_min'), -number(row, 'lon_max'), number(row, 'lat_min'), number(row, 'lat_max'))


def ka(row):
    return '%g to %g' % (number(row, 'older_slice_bp') / 1000, number(row, 'younger_slice_bp') / 1000)


def three(row, stem, form='%+.3f'):
    return ' / '.join(form % number(row, stem + run) for run in RUNS)


def summary_table():
    lines = ['| Rank | Candidate | Box | Slices (thousand years BP) | Cells (with pollen, older / younger end) | Cover change: open land, evergreen, summergreen | Expected albedo change | Three runs, 12-month mean albedo change (model 8 / chosen / coarse-location) | Three runs, vegetation forcing, W/m2 over the box | Quality as a test |',
             '|---|---|---|---|---|---|---|---|---|---|']
    for j in judgements:
        row = regions[j['key']]
        lines.append('| %s | %s | %s | %s | %d (%d / %d) | %+.3f, %+.3f, %+.3f | %s | %s | %s | %s |' % (
            j['rank'] or '-', j['short_name'], box_text(row), ka(row), number(row, 'cells'), number(row, 'pollen_cells_near_older'), number(row, 'pollen_cells_near_younger'),
            number(row, 'OL_change'), number(row, 'ET_change'), number(row, 'ST_change'), j['expected'],
            three(row, 'albedo_change_annual_', '%+.4f'), three(row, 'forcing_hadgem_', '%+.2f'), j['quality']))
    return '\n'.join(lines)


def numbers_block(key):
    row = regions[key]
    out = []
    out.append('Box %s; slices %s thousand years BP; %d cells, of which %d have a pollen-based estimate near the older end and %d near the younger (pollen table slices %d and %d BP). Cells with any ice at either end: %d (mean ice fraction %.2f, then %.2f).' % (
        box_text(row), ka(row), number(row, 'cells'), number(row, 'pollen_cells_near_older'), number(row, 'pollen_cells_near_younger'),
        number(row, 'pollen_slice_near_older'), number(row, 'pollen_slice_near_younger'), number(row, 'cells_with_ice_at_either_end'),
        number(row, 'mean_ice_fraction_older'), number(row, 'mean_ice_fraction_younger')))
    out.append('')
    out.append('| Area-weighted mean cover | open land | evergreen | summergreen |')
    out.append('|---|---|---|---|')
    out.append('| older slice | %.3f | %.3f | %.3f |' % (number(row, 'OL_older'), number(row, 'ET_older'), number(row, 'ST_older')))
    out.append('| younger slice | %.3f | %.3f | %.3f |' % (number(row, 'OL_younger'), number(row, 'ET_younger'), number(row, 'ST_younger')))
    out.append('| change | %+.3f | %+.3f | %+.3f |' % (number(row, 'OL_change'), number(row, 'ET_change'), number(row, 'ST_change')))
    out.append('| standard deviation of the change (posterior draws) | %.3f | %.3f | %.3f |' % (number(row, 'OL_change_sd'), number(row, 'ET_change_sd'), number(row, 'ST_change_sd')))
    out.append('| 95 %% interval of the change | %+.3f to %+.3f | %+.3f to %+.3f | %+.3f to %+.3f |' % (
        number(row, 'OL_change_lo95'), number(row, 'OL_change_hi95'), number(row, 'ET_change_lo95'), number(row, 'ET_change_hi95'), number(row, 'ST_change_lo95'), number(row, 'ST_change_hi95')))
    out.append('| step-to-step standard deviation outside the window | %.3f | %.3f | %.3f |' % (number(row, 'OL_step_sd'), number(row, 'ET_step_sd'), number(row, 'ST_step_sd')))
    out.append('')
    out.append('Kind of change: %s (cleanness %.2f, where 1 is a pure two-class exchange). Share of the area whose mix is outside the range of modern mixes: %.0f %% at the older slice (farthest %.3f outside), %.0f %% at the younger (farthest %.3f).' % (
        row['exchange'], number(row, 'exchange_purity'), 100 * number(row, 'outside_modern_mixes_older'), number(row, 'farthest_outside_older'),
        100 * number(row, 'outside_modern_mixes_younger'), number(row, 'farthest_outside_younger')))
    out.append('')
    out.append('Expected albedo change by straight mixing of published class albedos with this cover change:')
    out.append('')
    for e in expectation:
        if e['key'] == key:
            out.append('- %+.4f: %s (%s)' % (float(e['expected_change']), e['state'], e['source']))
    out.append('')
    observed = month_values(key, 'mod8', 'observed_albedo_today'); share = month_values(key, 'mod8', 'cells_observed_share')
    out.append('| | ' + ' | '.join(month.capitalize() for month in MONTHS) + ' |')
    out.append('|---|' + '---|' * 12)
    out.append('| observed albedo today (box mean) | ' + ' | '.join('%.2f' % v if v is not None else 'none' for v in observed) + ' |')
    out.append('| share of cells observed that month | ' + ' | '.join('%.2f' % v for v in share) + ' |')
    for run in RUNS:
        out.append('| albedo change, %s | ' % RUN_NAMES[run] + ' | '.join('%+.3f' % v for v in month_values(key, run, 'albedo_change')) + ' |')
    out.append('')
    out.append('| Run | Dec-Feb | Mar-May | Jun-Aug | Sep-Nov | 12-month mean | vegetation forcing, W/m2 over the box, HadGEM3 kernel (CACK kernel) | global equivalent, mW/m2 |')
    out.append('|---|---|---|---|---|---|---|---|')
    for run in RUNS:
        out.append('| %s | %s | %+.4f | %+.2f (%+.2f) | %+.2f |' % (
            RUN_NAMES[run], ' | '.join('%+.4f' % season_mean(key, run, months) for _, months in SEASONS), number(row, 'albedo_change_annual_' + run),
            number(row, 'forcing_hadgem_' + run), number(row, 'forcing_cack_' + run), number(row, 'global_equivalent_mwm2_' + run)))
    sens = {s['run']: s for s in sensitivity if s['candidate'] == key}
    out.append('')
    out.append('Moving the box two degrees each way and each end of the window one slice each way (%s variants), the forcing ranges over: %s; its sign is the same as here in %s of the variants.' % (
        sens['mod8']['variants'],
        '; '.join('%s %+.2f to %+.2f' % (RUN_NAMES[run], float(sens[run]['forcing_lowest']), float(sens[run]['forcing_highest'])) for run in RUNS),
        ', '.join('%.0f %%' % (100 * float(sens[run]['same_sign_share'])) for run in RUNS)))
    return '\n'.join(out)


def per_unit_table(kind):
    lines = ['| Candidate | cover exchanged | cleanness | Dec-Feb | Mar-May | Jun-Aug | Sep-Nov |', '|---|---|---|---|---|---|---|']
    keys = []
    for row in per_unit:
        if row['kind'] == kind and row['candidate'] not in keys:
            keys.append(row['candidate'])
    names = {j['key']: j['short_name'] for j in judgements}
    for key in keys:
        rows = {row['season']: row for row in per_unit if row['candidate'] == key}
        first = rows['Dec-Feb']
        cells = ['%+.2f / %+.2f / %+.2f' % tuple(float(rows[season]['albedo_per_unit_' + run]) for run in RUNS) for season, _ in SEASONS]
        lines.append('| %s | %+.3f | %.2f | %s |' % (names[key], float(first['cover_exchanged']), float(first['purity']), ' | '.join(cells)))
    return '\n'.join(lines)


def region_table():
    periods, names = [], []
    for row in by_region:
        if row['period'] not in periods:
            periods.append(row['period'])
        if row['region'] not in names:
            names.append(row['region'])
    periods = periods[::-1]
    value = {(row['run'], row['period'], row['region']): float(row['global_equivalent_mwm2']) for row in by_region}
    cells = {row['region']: row['cells'] for row in by_region}
    lines = ['| Region (cells) | ' + ' | '.join(p.replace(' ', '') for p in periods) + ' |', '|---|' + '---|' * len(periods)]
    for name in names + ['Whole study area']:
        entries = []
        for period in periods:
            v = [sum(value[(run, period, r)] for r in names) if name == 'Whole study area' else value[(run, period, name)] for run in RUNS]
            text = '%+.1f / %+.1f / %+.1f' % tuple(v)
            entries.append(text if (min(v) > 0 or max(v) < 0) else '*' + text + '*')
        lines.append('| %s%s | %s |' % (name, ' (%s)' % cells[name] if name in cells else '', ' | '.join(entries)))
    return '\n'.join(lines)


blocks = {'summary_table': summary_table(), 'per_unit_evergreen': per_unit_table('summergreen to evergreen'),
          'per_unit_open': per_unit_table('trees and shrubs to open land'), 'region_table': region_table()}
for key in regions:
    blocks['numbers:' + key] = numbers_block(key)

with open(os.path.join(HERE, 'report_template.md')) as handle:
    template = handle.read()
missing = [name for name in re.findall(r'\{\{([^}]+)\}\}', template) if name not in blocks]
if missing:
    raise SystemExit('the template asks for blocks that do not exist: ' + ', '.join(missing))
report = re.sub(r'\{\{([^}]+)\}\}', lambda match: blocks[match.group(1)], template)
with open(os.path.join(HERE, 'case_study_candidates.md'), 'w') as handle:
    handle.write(report)
print('written:', os.path.join(HERE, 'case_study_candidates.md'), '(%d lines)' % report.count('\n'))
