from PIL import Image, ImageDraw
import os

# Create 1024x1024 icon
size = 1024
img = Image.new('RGB', (size, size), color='#1a1a2e')
draw = ImageDraw.Draw(img)

# Modern gradient background (Purple to Blue - matching app theme)
for y in range(size):
    # Deep purple (#6A11CB) to bright blue (#2575FC)
    r = int(106 + (37 - 106) * (y / size))
    g = int(17 + (117 - 17) * (y / size))
    b = int(203 + (252 - 203) * (y / size))
    draw.rectangle([(0, y), (size, y+1)], fill=(r, g, b))

# Add subtle shine/glow effect at top
for y in range(int(size * 0.3)):
    alpha = (1 - y / (size * 0.3)) * 0.15
    overlay_color = (255, 255, 255, int(alpha * 255))
    # Can't use alpha directly in RGB mode, so we'll skip this for now

# Draw modern minimalist icon in center
center_x = size // 2
center_y = size // 2

# White rounded square background
bg_size = int(size * 0.55)
bg_margin = (size - bg_size) // 2
draw.rounded_rectangle(
    [bg_margin, bg_margin, bg_margin + bg_size, bg_margin + bg_size],
    radius=bg_size // 6,
    fill='white'
)

# Draw stylized checkmark + document icon
icon_margin = bg_margin + int(bg_size * 0.15)
icon_size = bg_size - int(bg_size * 0.3)

# Document outline (simplified)
doc_width = int(icon_size * 0.6)
doc_height = int(icon_size * 0.75)
doc_x = icon_margin + (icon_size - doc_width) // 2
doc_y = icon_margin + (icon_size - doc_height) // 2

# Draw document with folded corner
doc_corner_size = int(doc_width * 0.2)
doc_points = [
    (doc_x, doc_y),
    (doc_x + doc_width - doc_corner_size, doc_y),
    (doc_x + doc_width, doc_y + doc_corner_size),
    (doc_x + doc_width, doc_y + doc_height),
    (doc_x, doc_y + doc_height)
]
draw.polygon(doc_points, fill='#6A11CB', outline='#6A11CB')

# Folded corner
corner_points = [
    (doc_x + doc_width - doc_corner_size, doc_y),
    (doc_x + doc_width, doc_y + doc_corner_size),
    (doc_x + doc_width - doc_corner_size, doc_y + doc_corner_size)
]
draw.polygon(corner_points, fill='#2575FC')

# Draw MCQ lines (3 horizontal lines)
line_width = int(doc_width * 0.5)
line_height = 6
line_x = doc_x + int(doc_width * 0.25)
line_spacing = int(doc_height * 0.2)
first_line_y = doc_y + int(doc_height * 0.3)

for i in range(3):
    y_pos = first_line_y + (i * line_spacing)
    draw.rounded_rectangle(
        [line_x, y_pos, line_x + line_width, y_pos + line_height],
        radius=3,
        fill='white'
    )

# Draw large checkmark overlay
check_size = int(icon_size * 0.45)
check_x = icon_margin + icon_size - check_size - int(icon_size * 0.05)
check_y = icon_margin + icon_size - check_size - int(icon_size * 0.05)

# Checkmark circle background
check_circle_size = int(check_size * 1.1)
draw.ellipse(
    [check_x - int(check_size * 0.05), check_y - int(check_size * 0.05), 
     check_x + check_circle_size, check_y + check_circle_size],
    fill='#00D9A3'
)

# Draw checkmark
check_thickness = int(check_size * 0.15)
check_points_1 = [
    (check_x + int(check_size * 0.25), check_y + int(check_size * 0.5)),
    (check_x + int(check_size * 0.45), check_y + int(check_size * 0.7)),
]
check_points_2 = [
    (check_x + int(check_size * 0.45), check_y + int(check_size * 0.7)),
    (check_x + int(check_size * 0.85), check_y + int(check_size * 0.25)),
]
draw.line(check_points_1, fill='white', width=check_thickness, joint='curve')
draw.line(check_points_2, fill='white', width=check_thickness, joint='curve')

# Save main icon
output_dir = os.path.dirname(os.path.abspath(__file__))
img.save(os.path.join(output_dir, 'app_icon.png'))

# Create foreground version (transparent background for adaptive icon)
img_fg = Image.new('RGBA', (size, size), color=(0, 0, 0, 0))
draw_fg = ImageDraw.Draw(img_fg)

# White rounded square
draw_fg.rounded_rectangle(
    [bg_margin, bg_margin, bg_margin + bg_size, bg_margin + bg_size],
    radius=bg_size // 6,
    fill=(255, 255, 255, 255)
)

# Document
draw_fg.polygon(doc_points, fill=(106, 17, 203, 255))
draw_fg.polygon(corner_points, fill=(37, 117, 252, 255))

# Lines
for i in range(3):
    y_pos = first_line_y + (i * line_spacing)
    draw_fg.rounded_rectangle(
        [line_x, y_pos, line_x + line_width, y_pos + line_height],
        radius=3,
        fill=(255, 255, 255, 255)
    )

# Checkmark circle
draw_fg.ellipse(
    [check_x - int(check_size * 0.05), check_y - int(check_size * 0.05), 
     check_x + check_circle_size, check_y + check_circle_size],
    fill=(0, 217, 163, 255)
)

# Checkmark
draw_fg.line(check_points_1, fill=(255, 255, 255, 255), width=check_thickness, joint='curve')
draw_fg.line(check_points_2, fill=(255, 255, 255, 255), width=check_thickness, joint='curve')

img_fg.save(os.path.join(output_dir, 'app_icon_foreground.png'))

print("App icons generated successfully!")
print(f"Saved to: {output_dir}")
