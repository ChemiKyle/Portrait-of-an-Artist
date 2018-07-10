def main():
    quotes = import_from_txt('all_kindle_notes.txt')
    dic = scrape_info(quotes, True)


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

def scrape_info(quotes, use_dict = False):
    if use_dict:
        dic = {}
        use_json = True
    i = 0
    for quote_block in quotes[1:-1]:
        i += 1
        print(i)
        print(quote_block)
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
