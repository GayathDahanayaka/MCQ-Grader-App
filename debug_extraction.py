import cv2, sys, json, numpy as np
from backend.main import EnhancedOMRProcessor

image_path = sys.argv[1]
watch_qs = list(map(int, sys.argv[2].split(','))) if len(sys.argv) > 2 else list(range(1,11))

proc = EnhancedOMRProcessor(image_path)
proc.process()

all_circles = []
height, width = proc.warped.shape[:2]
answer_area = proc.warped[int(height * 0.20):int(height * 0.97), :]
img_height, img_width = answer_area.shape[:2]
gray = cv2.cvtColor(answer_area, cv2.COLOR_BGR2GRAY)
denoised = cv2.fastNlMeansDenoising(gray)
adaptive = cv2.adaptiveThreshold(denoised, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, 15, 3)
_, otsu = cv2.threshold(denoised, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)
combined = cv2.bitwise_or(adaptive, otsu)
kernel = np.ones((2,2), np.uint8)
cleaned = cv2.morphologyEx(cv2.morphologyEx(combined, cv2.MORPH_OPEN, kernel), cv2.MORPH_CLOSE, kernel)
contours, _ = cv2.findContours(cleaned, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
for cnt in contours:
    area = cv2.contourArea(cnt)
    if area < 80 or area > 5000: continue
    x, y, w, h = cv2.boundingRect(cnt)
    ar = w/float(h) if h else 0
    if ar < 0.5 or ar > 2.0: continue
    peri = cv2.arcLength(cnt, True)
    if peri == 0: continue
    if 4*np.pi*area/(peri*peri) < 0.3: continue
    is_m, strength = proc._is_marked_advanced(gray, cleaned, {'x':x,'y':y,'w':w,'h':h,'cx':x+w//2,'cy':y+h//2,'area':area,'circularity':0,'marked':False,'mark_strength':0})
    all_circles.append({'x':x,'y':y,'w':w,'h':h,'cx':x+w//2,'cy':y+h//2,'area':area,'marked':is_m,'mark_strength':strength})

all_areas = sorted([c['area'] for c in all_circles])
median_area = all_areas[len(all_areas)//2] if all_areas else 200
col_width = img_width / 4.0

for col_idx in range(4):
    x1 = int(col_idx*col_width) if col_idx<3 else int(col_idx*col_width - col_width*0.1)
    x2 = int((col_idx+1)*col_width) if col_idx<3 else img_width
    col_circles = [c for c in all_circles if x1 <= c['cx'] < x2]
    if not col_circles: continue
    col_circles_sorted = sorted(col_circles, key=lambda c: c['cy'])
    all_rows = proc._cluster_into_rows(col_circles_sorted, img_height)
    calibration_xs = []
    for r in all_rows:
        if len(r)==4:
            areas = [c['area'] for c in r]
            if max(areas)/max(min(areas),1) < 3.0:
                calibration_xs.append(sorted([c['cx'] for c in r]))
    if calibration_xs:
        slot_xs = [int(np.median([row[i] for row in calibration_xs])) for i in range(4)]
        slot_tol = (slot_xs[-1]-slot_xs[0])/6.0+10
    else:
        step = (x2-x1)/4.0
        slot_xs = [int(x1+step*(i+0.5)) for i in range(4)]
        slot_tol = step*0.6
    filtered = [c for c in col_circles if any(abs(c['cx']-sx)<slot_tol for sx in slot_xs)]
    if not filtered: filtered = col_circles
    filtered.sort(key=lambda c: c['cy'])
    rows = proc._cluster_into_rows(filtered, img_height)
    scored = sorted([{'circles':r,'count':len(r),'avg_cy':sum(c['cy'] for c in r)/len(r),'good_circles':sum(1 for c in r if abs(c['area']-median_area)<median_area*0.8),'size_var':np.std([c['area'] for c in r]) if len(r)>1 else 0} for r in rows], key=lambda x:(x['good_circles'],-x['size_var']), reverse=True)[:10]
    scored.sort(key=lambda x: x['avg_cy'])
    for row_idx, r_data in enumerate(scored):
        q = col_idx*10+row_idx+1
        if q not in watch_qs: continue
        r_circles = r_data['circles']
        slot_best = {}
        for c in r_circles:
            ns = min(range(4), key=lambda i: abs(c['cx']-slot_xs[i]))
            if ns not in slot_best or c['mark_strength'] > slot_best[ns]['mark_strength']:
                slot_best[ns] = c
        r_circles = sorted([slot_best[i] for i in range(4) if i in slot_best], key=lambda c: c['cx'])
        if len(r_circles)<2: continue
        strengths = [c['mark_strength'] for c in r_circles]
        mx = max(strengths)
        mn = sum(strengths)/len(strengths)
        rel = mx - mn
        winner = min(range(4), key=lambda i: abs(r_circles[strengths.index(mx)]['cx']-slot_xs[i]))+1 if rel>=0.065 else None
        print(f"Q{q}: strengths={[round(s,3) for s in strengths]}, max={mx:.3f}, mean={mn:.3f}, relative={rel:.3f}, -> {'BLANK' if winner is None else f'option {winner}'}")
