import paho.mqtt.client as mqtt
import cv2
import json
import ssl
import threading
import time
import base64

broker_aws = "ag20q59pra3c4-ats.iot.us-east-1.amazonaws.com"
broker_local = "192.168.1.26"

topic = "AWS/comand"
port = 8883


ca_path = "/home/briang/Plataformas Emergentes/proyecto/AmazonRootCA1.pem"  
cert_path = "/home/briang/Plataformas Emergentes/proyecto/795cf3afe108d470fa7ec122970d65fdd5efb0370920cd0ceb92032f5b6aecee-certificate.pem.crt"  # Cambia esto con la ruta de tu archivo de certificado
key_path = "/home/briang/Plataformas Emergentes/proyecto/795cf3afe108d470fa7ec122970d65fdd5efb0370920cd0ceb92032f5b6aecee-private.pem.key"


client_esp = mqtt.Client()
client_esp.connect(broker_local, 1883, 60)

client_esp32 = mqtt.Client()
client_esp32.connect(broker_local, 1883, 60)



def image_to_base64(image_path):
    with open(image_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode("utf-8")
    return encoded_string

def on_messageFromAws(client, userdata, message):
    payload_variable = message.payload.decode('utf-8')
    client_esp.publish("ESP/inTopic", payload_variable)
    print(f"Mensaje recibido de AWS en el tema {message.topic}: {message.payload.decode('utf-8')}")


client_aws = mqtt.Client(protocol=mqtt.MQTTv5)
client_aws.tls_set(ca_path, certfile=cert_path, keyfile=key_path, cert_reqs=ssl.CERT_REQUIRED, tls_version=ssl.PROTOCOL_TLSv1_2)
client_aws.on_message = on_messageFromAws
client_aws.connect(broker_aws, port, 60)
client_aws.subscribe(topic)


json_stringESP =  json.dumps({})
def on_messageFromESP(client, userdata, message):
    payload_variable = message.payload.decode('utf-8')
    data = json.loads(payload_variable)
    global json_stringESP
    try :
        datos_json = {
            "value_sensor": data.get("value"),
            "unit": data.get("unit"),
            "description": data.get("notes"),
            "code": "ldr",
        }
        json_stringESP = json.dumps(datos_json)
        
    except :
        datos_json = {}
        json_stringESP =  json.dumps(datos_json)
    print(f"Mensaje recibido del ESP8266 en el tema {message.topic}: {message.payload.decode('utf-8')}")



def on_messageFromEsp32(client, userdata, message):
    payload_variable = message.payload.decode('utf-8')
    data = json.loads(payload_variable)
    try :
        datos_json = {
            "value_sensor": data.get("distancia"),
            "unit": "cm",
            "description": data.get("server"),
            "code": "camera",
        }
        url = "http://"+data.get("server")+"/capture"
        vid = cv2.VideoCapture(url)


        retval, image = vid.read()
        retval, buffer = cv2.imencode('.jpg', image)
        jpg_as_text = base64.b64encode(buffer)
        datos_json["description"] = str(jpg_as_text)[2:-1]
        json_stringESP = json.dumps(datos_json)
        client_aws.publish("device/2/data", str(json_stringESP))
        print("Imagen guardada en dynamo")

    except :
        datos_json = {}
        json_stringESP =  json.dumps(datos_json)
        print("Imagen no guardada en dynamo")

    print(f"Mensaje recibido de ESP32 en el tema {message.topic}: {message.payload.decode('utf-8')}")


client_esp.on_message = on_messageFromESP
client_esp.subscribe("ESP/data")


client_esp32.on_message = on_messageFromEsp32
client_esp32.subscribe("esp32/outTopic")


def loop_forever1():
    client_esp.loop_forever()

def loop_forever2():
    client_aws.loop_forever()

def loop_forever3():
    client_esp32.loop_forever()

thread1 = threading.Thread(target=loop_forever1)
thread2 = threading.Thread(target=loop_forever2)
thread3 = threading.Thread(target=loop_forever3)


# Iniciar los hilos
thread2.start()
thread1.start()
thread3.start()

while True:
    print("Funcion que se ejecuta cada 20 segundos (Publish y guarda datos en dynamo): ")
    if json_stringESP != "{}":
        client_aws.publish("device/1/data", json_stringESP)
        print(json_stringESP)
        json_stringESP = "{}"
    time.sleep(10)
