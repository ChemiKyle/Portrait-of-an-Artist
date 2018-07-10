import epd7in5b
import Image
import ImageDraw
import ImageFont
#import imagedata
import random
#import pickle
import textwrap
import os
import sys

EPD_WIDTH = 640
EPD_HEIGHT = 384

def main():
    os.chdir((sys.path[0]))
    author, title, quote = select_quote_from_dict()
#    print(quote)
    draw(author, title, quote)

def select_quote_from_dict(file = '../data/quotes.json', use_json=True):
    if use_json:
        import json
        with open(file, 'r') as fp:
            dic = json.load(fp)
    else:
        import pickle
        with open(file, 'rb') as fp:
            dic = pickle.load(fp)
    author, book_quotes = random.choice(list(dic.items()))
    book = random.choice(list(book_quotes.items()))
    title = book[0]
    quote = random.choice(list(book[1].values()))

    return author, title, quote

def draw(author = "Albert Camus", title = "The Myth of Sisyphus",
        quote = "The struggle itself towards the heights is enough to fill a man's heart. One must imagine Sisyphus happy."):
    epd = epd7in5b.EPD()
    epd.init()

    image = Image.new('1', (EPD_WIDTH, EPD_HEIGHT), 1)
    draw = ImageDraw.Draw(image)
    font = ImageFont.truetype('/usr/share/fonts/truetype/freefont/FreeMonoBold.ttf', 20)
    
    #draw.rectangle((5, 5, 240, 384), fill = 0)

    def wrap_text(text, width, margin, offset, fill=0):
        for line in textwrap.wrap(text, width = 53):
            draw.text((margin, offset), line, font=font, fill=fill) # quote
            offset += font.getsize(line)[1]
    wrap_text(quote, 53, 5, 5)
    wrap_text('-{} "{}"'.format(author, title), 48, 30, 270)

    image = image.rotate(180)
    epd.display_frame(epd.get_frame_buffer(image))

if __name__ == '__main__':
    main()
