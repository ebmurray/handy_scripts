import time
import qrcode
timestr = time.strftime("%Y%m%d-%H%M%S")
data = input("\nEnter the data to encode: ").strip()
img = qrcode.make(data)
img.save(timestr + ".QR.png")