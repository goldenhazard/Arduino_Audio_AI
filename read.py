import serial
import serial.tools.list_ports
import pyaudio
import random
import queue
import time
import audioop
import wave

audio_q = b''

buff_size = 2048
rand_bytes = [None]*buff_size

ports = list(serial.tools.list_ports.comports())
print(ports);
for p in ports:
    print(p);
    if 'ttyACM0' in p[1]: 
        com_port = p[0]
        break;
    else: com_port = ''
try:
    port = serial.Serial(com_port,230400,timeout=None)
    millis = int(round(time.time() * 1000))
    while(int(round(time.time()*1000))-millis<=5000):
        rec_bytes = port.read(buff_size)
        print(len(rec_bytes))
        audio_q+=rec_bytes
#audio_bytes = rec_bytes
#audio_q.put(audio_bytes)
except:
    print("Connection Error: Can't find Arduino serial port")
#audiofile=audioop.lin2ulaw(audio_q,1);
#print(audiofile)
audio_q=audioop.mul(audio_q,1,3)
audio_q=audioop.lin2lin(audio_q,1,2)
noise_output = wave.open('noise.wav', 'w')
noise_output.setparams((1, 2, 20000, len(audio_q), 'NONE', 'not compressed'))
noise_output.writeframes(audio_q)
noise_output.close()
