#!/usr/bin/env python3
"""Look a paper up by DOI or by title words, and print its record and abstract.

Why: every source in the case-study report needs a DOI that is the paper it claims to be, and
a passage that was read. This prints, compactly, the registry record (Crossref for a DOI,
OpenAlex for a title search) with the abstract and any open-access address, so that the
abstract can be read and the open copy found. Nothing is saved, and no contact address is
sent with the request.

Usage:
  lookup_paper.py doi 10.xxxx/yyyy [more DOIs ...]
  lookup_paper.py title "words of the title" [number of results, default 3]
"""
import html
import json
import re
import sys
import urllib.parse
import urllib.request

AGENT = {'User-Agent': 'literature-lookup/1.0 (generic research client)'}
MAX_ABSTRACT = int(__import__('os').environ.get('MAX_ABSTRACT', '2600'))   # characters printed: an abstract field sometimes holds a whole page


def fetch_json(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=AGENT), timeout=40) as response:
        return json.load(response)


def plain(text):
    return re.sub(r'\s+', ' ', html.unescape(re.sub(r'<[^>]+>', ' ', text or ''))).strip()


def abstract_from_index(index):
    """OpenAlex stores an abstract as word -> positions; put the words back in order."""
    if not index:
        return ''
    words = sorted((position, word) for word, positions in index.items() for position in positions)
    return ' '.join(word for _, word in words)


def show_openalex(work):
    source = ((work.get('primary_location') or {}).get('source') or {}).get('display_name')
    biblio = work.get('biblio') or {}
    authors = [a['author']['display_name'] for a in work.get('authorships', [])]
    print('TITLE  :', work.get('title'))
    print('AUTHORS:', '; '.join(authors[:6]) + (' ...' if len(authors) > 6 else ''))
    print('WHERE  :', source, work.get('publication_year'), 'vol', biblio.get('volume'), 'pages', biblio.get('first_page'), '-', biblio.get('last_page'))
    print('DOI    :', work.get('doi'), '| type:', work.get('type'), '| retracted:', work.get('is_retracted'))
    access = work.get('open_access') or {}
    print('OPEN   :', access.get('is_oa'), access.get('oa_status'), access.get('oa_url'))
    print('ABSTRACT:', abstract_from_index(work.get('abstract_inverted_index')) or '(none in OpenAlex)')
    print()


def by_doi(doi):
    """The Crossref record of a DOI; the OpenAlex record adds the open-access address, and the
    abstract when Crossref has none (printed once, to keep the output short)."""
    print('=' * 100)
    crossref_abstract = ''
    try:
        record = fetch_json('https://api.crossref.org/works/' + urllib.parse.quote(doi))['message']
        authors = ['%s %s' % (a.get('given', ''), a.get('family', '')) for a in record.get('author', [])]
        issued = (record.get('issued', {}).get('date-parts') or [[None]])[0][0]
        crossref_abstract = plain(record.get('abstract'))
        print('CROSSREF', doi)
        print('TITLE  :', plain(' '.join(record.get('title', []))))
        print('AUTHORS:', '; '.join(authors[:6]) + (' ...' if len(authors) > 6 else ''))
        print('WHERE  :', plain(' '.join(record.get('container-title', []))), issued, 'vol', record.get('volume'), 'issue', record.get('issue'), 'pages', record.get('page'))
    except Exception as error:
        print('CROSSREF failed for', doi, ':', error)
    try:
        work = fetch_json('https://api.openalex.org/works/https://doi.org/' + urllib.parse.quote(doi))
        access = work.get('open_access') or {}
        print('OPEN   :', access.get('is_oa'), access.get('oa_status'), access.get('oa_url'), '| retracted:', work.get('is_retracted'))
        if not crossref_abstract:
            print('ABSTRACT (OpenAlex):', abstract_from_index(work.get('abstract_inverted_index'))[:MAX_ABSTRACT] or '(none)')
    except Exception as error:
        print('OPENALEX failed for', doi, ':', error)
    if crossref_abstract:
        print('ABSTRACT (Crossref):', crossref_abstract[:MAX_ABSTRACT])


def by_title(words, number):
    url = 'https://api.openalex.org/works?per-page=%d&search=%s' % (number, urllib.parse.quote(words))
    for work in fetch_json(url).get('results', []):
        print('=' * 100)
        show_openalex(work)


if __name__ == '__main__':
    if sys.argv[1] == 'doi':
        for doi in sys.argv[2:]:
            by_doi(doi)
    else:
        by_title(sys.argv[2], int(sys.argv[3]) if len(sys.argv) > 3 else 3)
