# Print speech regions (start-end, seconds) in a vocals stem window, by RMS over 50ms frames.
import sys, numpy as np, soundfile as sf
path, start, end = sys.argv[1], float(sys.argv[2]), float(sys.argv[3])
thr_db = float(sys.argv[4]) if len(sys.argv) > 4 else -35
info = sf.info(path); sr = info.samplerate
x, _ = sf.read(path, start=int(start*sr), stop=int(end*sr))
x = x.mean(axis=1) if x.ndim > 1 else x
hop = int(0.05*sr); n = len(x)//hop
db = 20*np.log10(np.sqrt((x[:n*hop].reshape(n, hop)**2).mean(axis=1)) + 1e-9)
on = db > thr_db; regions = []; i = 0
while i < n:
    if on[i]:
        j = i
        while j < n and (on[j] or (j+4 < n and on[j:j+5].any())): j += 1  # bridge gaps <250ms
        regions.append((start+i*0.05, start+j*0.05, db[i:j].max())); i = j
    else: i += 1
for s, e, p in regions:
    if e - s >= 0.15: print(f"{s:7.2f}-{e:7.2f}  peak {p:5.1f}dB")
