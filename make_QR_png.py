import os
import time
import qrcode
from sys import platform

# vars
timestr = time.strftime("%Y%m%d-%H%M%S")
file_name = timestr + ".QR.png"

# OS detect
# So lnog as the Python module qrcode is installed it'll run on most OS
if platform == "linux" or platform == "linux2":
	OS_detected = str("Linux")
	save_dir = os.path.join(os.environ['HOME'], "Downloads/")
elif platform == "darwin":
	OS_detected = str("OS X")
	save_dir = os.path.join(os.environ['HOME'], "Downloads/")
elif platform == "win32" or platform == "cygwin":
	OS_detected = str("Windows")
	save_dir = os.path.join(os.environ['USERPROFILE'], "Downloads\\")

def generate_qr_code(data, file_name):
	qr = qrcode.QRCode(
		version=1,
		error_correction=qrcode.constants.ERROR_CORRECT_L,
		box_size=10,
		border=2
	)
	qr.add_data(data)
	qr.make(fit=True)
	img = qr.make_image(fill_color="black", back_color="white")
	img.save(file_name)
	print(f"QR code saved as .png in user's \"Downloads\" folder.\n")

def main():
	print("\nQR Code Generator running on " + OS_detected)
	data = input("Enter the data to encode (e.g., URL, text): ").strip()
	generate_qr_code(data, save_dir + file_name)

if __name__ == "__main__":
	main()
