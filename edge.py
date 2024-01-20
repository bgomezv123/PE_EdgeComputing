import paho.mqtt.client as mqtt
import cv2
import json
import ssl
import threading

broker_aws = "ag20q59pra3c4-ats.iot.us-east-1.amazonaws.com"
broker_local = "192.168.1.26"

topic = "AWS/comand"
port = 8883


ca_path = "/home/briang/Plataformas Emergentes/proyecto/AmazonRootCA1.pem"  # Cambia esto con la ruta de tu archivo de CA
cert_path = "/home/briang/Plataformas Emergentes/proyecto/795cf3afe108d470fa7ec122970d65fdd5efb0370920cd0ceb92032f5b6aecee-certificate.pem.crt"  # Cambia esto con la ruta de tu archivo de certificado
key_path = "/home/briang/Plataformas Emergentes/proyecto/795cf3afe108d470fa7ec122970d65fdd5efb0370920cd0ceb92032f5b6aecee-private.pem.key"



client_esp = mqtt.Client()
client_esp.connect(broker_local, 1883, 60)


def on_messageFromAws(client, userdata, message):
    payload_variable = message.payload.decode('utf-8')
    client_esp.publish("inTopic", payload_variable)
    print(f"Mensaje recibido de AWS en el tema {message.topic}: {message.payload.decode('utf-8')}")


client_aws = mqtt.Client(protocol=mqtt.MQTTv5)
client_aws.tls_set(ca_path, certfile=cert_path, keyfile=key_path, cert_reqs=ssl.CERT_REQUIRED, tls_version=ssl.PROTOCOL_TLSv1_2)
client_aws.on_message = on_messageFromAws
client_aws.connect(broker_aws, port, 60)
client_aws.subscribe(topic)

def on_messageFromESP(client, userdata, message):
    payload_variable = message.payload.decode('utf-8')
    data = json.loads(payload_variable)
    try :
        datos_json = {
            "value_sensor": data.get("value"),
            "unit": data.get("unit"),
            "description": data.get("notes"),
            "code": "ldr",
        }
        json_string = json.dumps(datos_json)
        client_aws.publish("device/1/data", json_string)
    except :
        datos_json = {}
    print(f"Mensaje recibido del ESP8266 en el tema {message.topic}: {message.payload.decode('utf-8')}")


client_esp.on_message = on_messageFromESP
client_esp.subscribe("ESP/data")


client_esp.subscribe("outTopic")

def loop_forever1():
    client_esp.loop_forever()

def loop_forever2():
    client_aws.loop_forever()

thread1 = threading.Thread(target=loop_forever1)
thread2 = threading.Thread(target=loop_forever2)

# Iniciar los hilos
thread2.start()
thread1.start()

