#include <WiFi.h>
#include <PubSubClient.h>
/* Recommend changing PubSubClient.h to support larger payloads
 * beyond original, which severely limits quote length
 * add the following line in PubSubClient.h
 */
//#define MQTT_MAX_PACKET_SIZE = 1024


#define MQTT_TOPIC "epaper/desk"

// Connect to the WiFi
const char* ssid = "";
const char* password = "";
const char* mqtt_server = "";

WiFiClient espClient;
PubSubClient client(espClient);

// Library: https://github.com/ZinggJM/GxEPD2
#define ENABLE_GxEPD2_GFX 0

#include <GxEPD2_3C.h>
#include <Fonts/FreeMonoBold9pt7b.h>

#if defined(ESP32)
// ***** for mapping of Waveshare ESP32 Driver Board *****
GxEPD2_3C<GxEPD2_750c, GxEPD2_750c::HEIGHT> display(GxEPD2_750c(/*CS=*/ 15, /*DC=*/ 27, /*RST=*/ 26, /*BUSY=*/ 25));
#endif

void setup() {

    WiFi.mode(WIFI_STA);
    WiFi.begin(ssid, password);
    WiFi.setHostname("ESPaper");
    while (WiFi.status() != WL_CONNECTED) { delay(500); }

    Serial.begin(115200);
    Serial.println("Connected to wifi");
    Serial.println(WiFi.localIP());

    Serial.println();
    display.init(115200); // uses standard SPI pins, e.g. SCK(18), MISO(19), MOSI(23), SS(5)
    // *** special handling for Waveshare ESP32 Driver board *** //
    // ********************************************************* //
    SPI.end(); // release standard SPI pins, e.g. SCK(18), MISO(19), MOSI(23), SS(5)
    //SPI: void begin(int8_t sck=-1, int8_t miso=-1, int8_t mosi=-1, int8_t ss=-1);
    SPI.begin(13, 12, 14, 15); // map and init SPI pins SCK(13), MISO(12), MOSI(14), SS(15)
    // *** end of special handling for Waveshare ESP32 Driver board *** //
    // **************************************************************** //
    // first update should be full refresh

    client.setServer(mqtt_server, 1883);
    client.setCallback(callback);
}

void loop()
{
 if (!client.connected()) {
  reconnect();
 }
 client.loop();
}


void callback(char* topic, byte* payload, unsigned int length) {
    // convert byte array to char and null terminate
    // https://forum.arduino.cc/index.php?topic=111180.0
    char message[length+1];
    memcpy(message, payload, length);
    message[length+1] = '\0';

    writeText(message);
}

void reconnect() {
    // Loop until we're reconnected
    while (!client.connected()) {
        Serial.print("Attempting MQTT connection...");
        // Attempt to connect
        // assign random client ID to avoid collisions
        // https://github.com/knolleary/pubsubclient/blob/master/examples/mqtt_esp8266/mqtt_esp8266.ino
        String clientID = "ESP32_client-";
        clientID += String(random(0xffff), HEX);

        if (client.connect(clientID.c_str())) {
            Serial.println("connected");
            // ... and subscribe to topic
            client.subscribe(MQTT_TOPIC);
        } else {
            Serial.print("failed, rc=");
            Serial.print(client.state());
            Serial.println(" try again in 5 seconds");
            delay(5000);
        }
    }
}


void writeText(char text[]) {
    // set to landscape mode, with 180 rotation
    display.setRotation(2);
    // select a suitable font in Adafruit_GFX
    display.setFont(&FreeMonoBold9pt7b);
    display.setTextColor(GxEPD_BLACK);

    int16_t tbx, tby; uint16_t tbw, tbh; // boundary box window
    display.getTextBounds(text, 0, 0, &tbx, &tby, &tbw, &tbh);

    // set text to begin in top left corner
    uint16_t x = display.width() - tbx;
    uint16_t y = 0;

    display.setFullWindow();

    display.firstPage();
    do
    {
        // TODO: cache old text, use partial update to erase and redraw
        display.fillScreen(GxEPD_WHITE);
        display.setCursor(x, y);
        display.print(text);
    }

    while (display.nextPage());
}
