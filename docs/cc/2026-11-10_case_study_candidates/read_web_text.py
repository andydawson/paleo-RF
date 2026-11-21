#!/usr/bin/env python3
"""Read a web page from standard input as plain text and print one part of it.

Nothing is saved: the page is piped in (curl ... | read_web_text.py ...), the tags are
stripped, and either the headings, a character range, or the passages around a search
term are printed. Used to read open-access papers and find the exact passage and section
that supports a statement.

Usage:
  ... | read_web_text.py headings
  ... | read_web_text.py range START END
  ... | read_web_text.py find 'regular expression' [CONTEXT_CHARS] [MAX_HITS]
"""
import html
import re
import sys


def page_text(raw):
    """The page as text, with headings marked '#### Hn:' so that sections can be located."""
    text = re.sub(r'(?s)<(script|style).*?</\1>', '', raw)
    text = re.sub(r'(?s)<h(\d)[^>]*>(.*?)</h\1>',
                  lambda m: '\n\n#### H' + m.group(1) + ': ' + re.sub('<[^>]+>', '', m.group(2)) + '\n', text)
    text = re.sub(r'(?s)<[^>]+>', '', text)
    text = html.unescape(text)
    text = re.sub(r'[ \t\r\f\v]+', ' ', text)
    return re.sub(r'\n\s*\n+', '\n\n', text)


def section_at(text, position):
    """The last heading before a position: the locator of a passage."""
    headings = [m for m in re.finditer(r'#### H\d: [^\n]*', text) if m.start() <= position]
    return headings[-1].group(0)[5:90] if headings else '(before the first heading)'


def main():
    text = page_text(sys.stdin.read())
    mode = sys.argv[1]
    if mode == 'headings':
        print('characters:', len(text))
        for m in re.finditer(r'#### H\d: [^\n]*', text):
            print(m.start(), m.group(0)[:110])
    elif mode == 'range':
        print(text[int(sys.argv[2]):int(sys.argv[3])])
    elif mode == 'find':
        context = int(sys.argv[3]) if len(sys.argv) > 3 else 300
        max_hits = int(sys.argv[4]) if len(sys.argv) > 4 else 8
        hits = list(re.finditer(sys.argv[2], text, flags=re.I))
        print(len(hits), 'hits')
        for m in hits[:max_hits]:
            start, end = max(0, m.start() - context), min(len(text), m.end() + context)
            print('\n--- at', m.start(), '| section:', section_at(text, m.start()))
            print(text[start:end].replace('\n', ' '))


if __name__ == '__main__':
    main()
