import wave, os, array, struct
import os.path

IN_FOLDER = "wavNexusGyroY"


def sample_out_of_range(min, max, x, i, direction):
	ret = False
	if x[i] > max or x[i] < min:
		for j in range(1,10):
			if x[i+direction*j] > max or x[i+direction*j] < min:
				ret = True
				break
	return ret
	

files = os.listdir(IN_FOLDER)
wavfiles = list()
for f in files:
	if f.endswith('.wav'):
		wavfiles.append(f)

for f in wavfiles:
	print f
	w = wave.open(IN_FOLDER + '\\' + f, 'r')
	frame = w.readframes(w.getnframes())
	params = w.getparams()
	x = array.array('h', frame)
	w.close()
	max = -65000
	min = 65000
	for i in range(len(x)):
		if i <= 60:
			if x[i] < min:
				min = x[i]
			if x[i] > max:
				max = x[i]
		if not sample_out_of_range(min, max, x, i, 1):
			x[i] = 0
		else:
			break
	low_index = i
	for i in reversed(range(len(x))):
		if not sample_out_of_range(min, max, x, i, -1):
			x[i] = 0
		else:
			break
	high_index = i
	
	w = wave.open(os.path.join(IN_FOLDER, 'cleaned', f), 'wb')
	w.setparams(params)
	for i in range(len(x)):
		if i < low_index or i > high_index:
			w.writeframes(struct.pack('h', 0))
		else:
			w.writeframes(struct.pack('h', x[i]))
	w.close()
