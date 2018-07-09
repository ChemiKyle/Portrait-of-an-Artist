def main():
    quotes = import_txt('all_kindle_notes.txt')
    dic = scrape_info(quotes)
    export_dict(dic)


def import_txt(quote_file):
    with open(quote_file, 'r', encoding='utf-8-sig') as f: # must correct for unicode error
        f = '==========\n' + f.read()
        quotes = f.split('==========')
    return quotes

def scrape_info_to_dict(quotes):
    dic = {}
    quotes = quotes[1:-257]
    for quote_block in quotes: # something fucky with [1:>-256]
        splt = quote_block.split('\n')
        book, author = splt[1].replace(')', '').split('(')
        stamp_line = splt[2]
        quote = splt[4]
        if author not in dic:
            dic[author] = {}
        if book not in dic[author]:
            dic[author][book] = {}
            dic[author][book].update({'quote 1': quote})
        else:
            q = {'quote ' + str(len(dic[author][book]) + 1): quote}
            dic[author][book].update(q)
    return dic

def export_dict(dic, use_json = False):
    if use_json:
        import json
        with open('quotes.json', 'w') as fp:
            json.dump(dic, fp, sort_keys = True, indent = 4)
    else:
        import pickle
        with open('quotes.p', 'wb') as fp:
            pickle.dump(dic, fp, protocol=pickle.HIGHEST_PROTOCOL)



if __name__ in '__main__':
    main()
