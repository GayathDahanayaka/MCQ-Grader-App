import cv2
import numpy as np

class OMRScanner:
    def __init__(self):
        self.questions = 50  # Dynamic: can be 40 or 50
        self.choices = 5    # Standard MCQ choices (1, 2, 3, 4, 5)

    def get_answers(self, img_path):
        # 1. Load and Pre-process
        img = cv2.imread(img_path)
        img = cv2.resize(img, (700, 1000))
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        # Invert colors: X marks become white, background becomes black
        thresh = cv2.threshold(gray, 150, 255, cv2.THRESH_BINARY_INV)[1]

        # 2. Divide the sheet into grids (Example for one column)
        # This part will loop through your 4-5 columns
        # For now, let's visualize the bubble detection
        bubbles = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)[0]
        
        detected_answers = []
        # Logical sorting and pixel counting goes here...
        # If pixels in a bubble > threshold, it's marked as "X"
        
        return thresh

    def process_master_key(self, img_path):
        # Logic to save the correct answers to marking_scheme.json
        print(f"Master Key processed from: {img_path}")
        return self.get_answers(img_path)

    def grade_student(self, student_img_path, master_answers):
        # Logic to compare student answers with master answers
        print(f"Grading student paper: {student_img_path}")
        score = 0
        # Simple comparison logic...
        return score

# --- TESTING THE FLOW ---
scanner = OMRScanner()

# Step 1: Teacher uploads the correct answer sheet first
master_thresh = scanner.process_master_key('backend/images/image2.jpeg')

# Step 2: Now we can check a student paper
student_score = scanner.grade_student('backend/images/image2.jpeg', master_thresh)

cv2.imshow("Detection Logic (Black & White)", master_thresh)
cv2.waitKey(0)