#include <ESP8266WiFi.h>
#include <WiFiClient.h>

#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>
#include "DHT.h"
// http://esp8266.github.io/Arduino/versions/2.0.0/doc/filesystem.html
#define DHTPIN D7     // what digital pin we're connected to
#define DHTTYPE DHT22   // DHT 22  (AM2302), AM2321

DHT dht(DHTPIN, DHTTYPE);

const char* ssid = "N1";
const char* password = "Nodrog/221337";

ESP8266WebServer server(80);

#include <EEPROM.h>
#define CONFIG_SAVE_VERSION 0.1


extern "C" {
#define USE_US_TIMER 1
#include "user_interface.h"
}


os_timer_t weatherTimer;

void timerCallback( void * arg) 
{
 // (void) arg;
 // LogTempData();
}

int lastWriteAddr = 0;

struct weather_info
{
  weather_info( float hum, float temp, float heatidx)
  {
    humidity = hum;
    temperature_C = temp;
    heat_index_C = heatidx;
  }
  float humidity;
  float temperature_C;
  float heat_index_C;
};


// log temp data to eeprom
void LogTempData(float h, float t, float hic)
{ 

 /* weather_info *info = new weather_info(h,t,hic);
  EEPROM.put(lastWriteAddr,info);
  lastWriteAddr += sizeof(info); 
  EEPROM.commit();
  delete info;*/
}

const int led = 13;

void handleRoot() {
  String message = "<!DOCTYPE html><html><head><meta http-equiv='refresh' content='2'><title>Gordo's Web Weather Station</title></head><body>";

  
 // Reading temperature or humidity takes about 250 milliseconds!
  // Sensor readings may also be up to 2 seconds 'old' (its a very slow sensor)
  float h = dht.readHumidity();
  // Read temperature as Celsius (the default)
  float t = dht.readTemperature();
  // Read temperature as Fahrenheit (isFahrenheit = true)
  float f = dht.readTemperature(true);

  // Check if any reads failed and exit early (to try again).
  if (isnan(h) || isnan(t) || isnan(f)) {
    message += ("Failed to read from DHT sensor!");
    return;
  }
  float hif = dht.computeHeatIndex(f, h);
  // Compute heat index in Celsius (isFahreheit = false)
  float hic = dht.computeHeatIndex(t, h, false);
  //LogTempData(h,t,hic);

  message += ("<b>Humidity: </b><br>");
  message += (h);
  message += ("%\t<br>");
  message += ("<br><b>Temperature:</b><br>");
  message += (t);
  message += (" *C<br>");
  message += (f);
  message += (" *F\t<br>");
  message += ("<br><b>Heat index:</b><br>");
  message += (hic);
  message += (" *C <br>");
  message += (hif);
  message += (" *F<hr>");

  uint32_t free = system_get_free_heap_size();
  message += "<br><b>System Info:</b><br><i>heap size:</i> ";
  message += (free);
  message += " bytes<br>";
  message += "<b>Save version:</b> <br>";
  message += CONFIG_SAVE_VERSION;

  // output current log info
/*
  int infoSz = sizeof(weather_info);
  for(int i = 0; i < lastWriteAddr; i+=infoSz)
  {
    weather_info *info = new weather_info(-1,-1,-1);
    EEPROM.get(i,info);
    message += info->temperature_C;
    message += " *C<br>";
  }
*/

  message += "</body></html>";
  server.send(200, "text/plain", message);
}

class sensor_reading 
{
  public:
  sensor_reading()
  {
    
  }
  float humidity,temperature;
};

#include<vector>

std::vector<sensor_reading*>* collectHighSpeed( int reading_count = 10)
{
  std::vector<sensor_reading*> *readings = new std::vector<sensor_reading*>();
  for(int x=0;x<reading_count;x++)
  {
    sensor_reading * reading = new sensor_reading();
    reading->humidity = dht.readHumidity();
    reading->temperature = dht.readTemperature();
    readings->push_back(reading);
    delay(250);
  }

  return readings;
}

void handleNotFound(){
  EEPROM.begin(4096);
  digitalWrite(led, 1);
  String message = "File Not Found\n\n";
  message += "URI: ";
  message += server.uri();
  message += "\nMethod: ";
  message += (server.method() == HTTP_GET)?"GET":"POST";
  message += "\nArguments: ";
  message += server.args();
  message += "\n";
  for (uint8_t i=0; i<server.args(); i++){
    message += " " + server.argName(i) + ": " + server.arg(i) + "\n";
  }
  server.send(404, "text/plain", message);
  digitalWrite(led, 0);
}

void setup(void){
  pinMode(led, OUTPUT);
  digitalWrite(led, 0);
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  Serial.println("");

  if(WiFi.SSID() != "")
    Serial.print("SSID configured: " + WiFi.SSID());
    // resetting

  WiFi.mode(WIFI_STA);
  
  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.print("Connected to ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  if (MDNS.begin("esp8266")) {
    Serial.println("MDNS responder started");
  }

  server.on("/", handleRoot);

  server.on("/inline", [](){
    String reading = "";
    std::vector<sensor_reading*> * readings = collectHighSpeed();
    {
      std::vector<sensor_reading*>::iterator it;
      for(it = readings->begin(); it != readings->end(); ++it)
      {
        float temp = (*it)->temperature;
        reading += temp;
        reading += ", ";
      }
      
    }    
    readings->clear(); // call delete on individual objects;
    delete readings; // done with memory.
    server.send(200, "text/html", reading);
  });
  
  server.onNotFound(handleNotFound);

  server.begin();
  Serial.println("HTTP server started");
  
  dht.begin();


  // start weather update timer
  //os_timer_setfn(&weatherTimer, (os_timer_func_t*) &timerCallback, 0);
  //os_timer_arm(&weatherTimer, 2500, 1);
}


void loop(void){
  server.handleClient();
}
