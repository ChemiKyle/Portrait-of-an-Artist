#!/bin/python3

def main():
    quotes = import_from_txt('all_kindle_notes.txt')
    scrape_info(quotes)


def import_from_txt(quote_file):
    #, encoding='utf-8-sig'  # This throws an error but used to be important
    with open(quote_file, 'r') as f:
        f = '==========\n' + f.read()
        quotes = f.split('==========')
    return quotes


def split_quote(quote_block):
    splt = quote_block.split('\n')
    book, author = splt[1].split('(') # breaks if parentheses in title
    stamp_line = splt[2]
    quote = splt[4]
    return book, author, quote


def scrape_info(quotes, use_dict = False, use_json = False):
    dic = {}
    if not use_dict:
        import sqlite3
        conn = sqlite3.connect('data/quotes.db')
        conn.execute('CREATE TABLE IF NOT EXISTS quotes(author, book, quote, '
        'CONSTRAINT quote_unique UNIQUE (quote))')
        c = conn.cursor()
    for quote_block in quotes[1:-1]:
        book, author, quote = split_quote(quote_block)
        if use_dict:
            if author not in dic:
                dic[author] = {}
            if book not in dic[author]:
                dic[author][book] = {}
                dic[author][book].update({'quote 1': quote})
            else:
                q = {'quote ' + str(len(dic[author][book]) + 1): quote}
                dic[author][book].update(q)
        else:
            cmd =("INSERT INTO quotes(author,book,quote) "
                    "VALUES(?,?,?)")
            try:
                c.execute(cmd, [author, book, quote])
            except sqlite3.IntegrityError:
                print("Skipping duplicate quote: {}".format(quote))
    if not use_dict:
        conn.commit()
        conn.close()
    if use_json:
        import json
        with open('data/quotes.json', 'w') as fp:
              json.dump(dic, fp, sort_keys = True, indent = 4)
    else:
        import pickle
        with open('data/quotes.p', 'wb') as fp:
            pickle.dump(dic, fp, protocol=pickle.HIGHEST_PROTOCOL)


if __name__ in '__main__':
    main()

