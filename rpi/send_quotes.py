import random
import textwrap
import os
import sys
import paho.mqtt.client as mqtt

def main():
    client = mqtt_init()
    if KeyboardInterrupt:
        client.disconnect()
        client.loop_stop()


def send_quote():
    os.chdir((sys.path[0]))
    use_dict = False # TODO: re-evaluate the need for this
    if use_dict:
        author, book, quote = select_quote_from_dict()
    else:
        author, book, quote = select_quote_from_db()

    # TODO: accept as arg with destination in "epaper/send"
    line_limit = 21 # max capacity for 640x384 epaper display in portrait mode

    quote_lines = (textwrap.wrap(quote, width = 56))
    quote = '\n'.join(quote_lines)
    formatted_quote = f"{quote}\n{author} - {book}"
    cmd_formatted_quote = formatted_quote.replace('"', '\\"')
    print(formatted_quote)
    # TODO: why doesn't this work?
    #client.publish('epaper/desk', str(formatted_quote))
    os.system("mosquitto_pub -t epaper/desk -m \"" + cmd_formatted_quote + "\"")


def wrap_text(text, width, margin, offset, fill=0):
    for line in textwrap.wrap(text, width = 53):
        draw.text((margin, offset), line, font=font, fill=fill) # quote
        offset += font.getsize(line)[1]


def select_quote_from_db(db = '../data/quotes.db', uniformity = "quote"):
    """
    uniformity: equal probability of selection for any...
        quote
        book
        author
    """
    import sqlite3
    conn = sqlite3.connect(db)
    c = conn.cursor()
    cmd = ("SELECT ? FROM quotes ORDER BY Random() LIMIT 1")
    c.execute(cmd, [uniformity])
    result = c.fetchone()[0]
    cmd = ("SELECT author, book, quote FROM quotes WHERE ?=? ORDER BY Random() LIMIT 1")
    c.execute(cmd, [uniformity, result])
    res_list = []
    for i in c.fetchone():
        res_list.append(i)
    return res_list


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


def send_mqtt(msg):
    client.publish(msg['topic'], str(msg['cmd']))
    return(str(msg))


def on_connect(client, userdata, flags, rc):
    print("Connected with code: {}".format(str(rc)))
    sub_topics = ["epaper/send"]
    [client.subscribe(topic) for topic in sub_topics]


def on_message(client, userdata, msg):
    print("message received")
    print(str(msg.payload))
    send_quote()


def mqtt_init():
    client = mqtt.Client()
    client.on_connect = on_connect
    client.on_message = on_message
    client.connect("localhost", 1883, 60)
    #client.loop_start()
    client.loop_forever()
    return(client)

if __name__ == '__main__':
    main()
