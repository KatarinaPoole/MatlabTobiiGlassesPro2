'''
Code made for getting the livestream data and getting it to work with Matlab. Currently works by just printing out the data!!
'''

## imports
import time
import socket
import threading
import signal
import sys
#import win32api # to get mouse clicks everywhere

## variables
timeout = 1.0
running = True
GLASSES_IP = "fe80::76fe:48ff:fe19:fbaf"  # IPv6 address scope global
PORT = 49152
tobiiData = []
#clicks = 0
# Keep-alive message content used to request live data and live video streams
KA_DATA_STR = "{\"type\": \"live.data.unicast\", \"key\": \"some_GUID\", \"op\": \"start\"}"
KA_DATA_MSG = KA_DATA_STR.encode() #need to encode it to work with python 3.6
## Functions
# Create UDP socket
def mksock(peer):
	iptype = socket.AF_INET
	if ':' in peer[0]:
		iptype = socket.AF_INET6
	return socket.socket(iptype, socket.SOCK_DGRAM)

# Callback function
def send_keepalive_msg(socket, msg, peer):
	while running:
		#print("Sending " + msg + " to target " + peer[0] + " socket no: " + str(socket.fileno()) + "\n")
		socket.sendto(msg, peer)
		time.sleep(timeout)

def signal_handler(signal, frame):
	stop_sending_msg()
	sys.exit(0)

def stop_sending_msg():
	global running
	running = False

# Need to put in a way to double check that it is pulling data for the required time (hopefully not as it doesnt seem like its lossfull or laggy?
if __name__ == "__main__":
		signal.signal(signal.SIGINT, signal_handler)
		peer = (GLASSES_IP, PORT)
	# Create socket which will send a keep alive message for the live data stream
		data_socket = mksock(peer)
		data_socket.bind(('',PORT)) # Need this bind to get python to work with Windows
		td = threading.Timer(0, send_keepalive_msg, [data_socket, KA_DATA_MSG, peer])
		td.start()
		calibTime = time.time() +float(1)
		print(calibTime)
		print('not running')
		while running:
		# Read live data and add it to variable
			data, address = data_socket.recvfrom(1024)
			tobiiData.append(data)
			if time.time() > calibTime:
				running = False
		sys.stdout.write(str(tobiiData)) 
