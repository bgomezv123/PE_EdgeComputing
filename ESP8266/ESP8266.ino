#include <ESP8266WiFi.h>
#include <PubSubClient.h>
 #include <ArduinoJson.h>
// Update these with values suitable for your network.
 
// Valores para la conexion WiFi
const char* ssid                = "GOMEZ 2,4G";
const char* password            = "holathiago123456789";
const char* mqtt_server = "192.168.1.26";
 
WiFiClient espClient;
PubSubClient client(espClient);
long lastMsg = 0;
char msg[50];
int value = 0;
bool onOff                      = true;
int MODE_LED                    = 1;
int R                           = 50;
int G                           = 50;
int B                           = 50;

void setup() {
  pinMode(BUILTIN_LED, OUTPUT); 
  digitalWrite(BUILTIN_LED, HIGH);    // Initialize the BUILTIN_LED pin as an output
  Serial.begin(115200);
  setup_wifi();
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
}
 
void setup_wifi() {
 
  delay(10);
  // We start by connecting to a WiFi network
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
 
  WiFi.begin(ssid, password);
 
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
 
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}
 
void callback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");
  for (int i = 0; i < length; i++) {
    Serial.print((char)payload[i]);
  }
  Serial.println();

  payload[length] = '\0';
  String jsonString = String((char*)payload);
  DynamicJsonDocument doc(512);
  deserializeJson(doc, jsonString);
  int value1 = doc["on_off"];
  int value2 = doc["mode_led"];
  int r = doc["r"];
  int g = doc["g"];
  int b = doc["b"];
 
    if (value1 == 1) {
        onOff = true;
    } else if(value1 == 0) {
        onOff = false;  
    } 

    if(value2 == 1){
        MODE_LED = 1;
    }else if(value2 == 2){
        MODE_LED = 2;
        R=r;
        G=g;
        B=b;
    }

  
}
 
void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Attempt to connect
    if (client.connect("ESP8266Client")) {
      Serial.println("connected");
      // Once connected, publish an announcement...
      client.publish("ESP/data", "0");
      // ... and resubscribe
      client.subscribe("ESP/inTopic");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}
 


int redpin                      = 13; // select the pin for the red LED
int greenpin                    = 12 ;// select the pin for the green LED
int bluepin                     = 14;

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
  int sensorValue = analogRead(A0);  
  // read the input on analog pin 0
	int voltage = sensorValue ;   // Convert the analog reading (which goes from 0 - 1023) to a voltage (0 - 5V)
  int voltageConvert = 255 - voltage*(1.536);
  char cadena[20]; // Ajusta el tamaño según tus necesidades
  if(onOff == 0){
    analogWrite(redpin, 0);
    analogWrite(greenpin, 0);
    analogWrite(bluepin, 0);
  }else if(MODE_LED == 1){
    analogWrite(redpin, voltageConvert);
    analogWrite(greenpin, voltageConvert);
    analogWrite(bluepin, voltageConvert);

  }else if(MODE_LED == 2){
    analogWrite(redpin, R);
    analogWrite(greenpin,G);
    analogWrite(bluepin,B);
  }
  StaticJsonDocument<128> jsonDoc;
  // Obtenemos la fecha y hora actual
  jsonDoc["value"] = voltage*(1.536);
  jsonDoc["unit"] = "lux";
  jsonDoc["notes"] = "Enviado desde Esp8266";
  String jsonString;
  serializeJson(jsonDoc, jsonString);

    // Utilizando sprintf para convertir float a string
  sprintf(cadena, "%i", voltageConvert);
  Serial.print("Publish message: ");
  Serial.println(jsonString);
  client.publish("ESP/data", jsonString.c_str());
  
  delay(1000);
}