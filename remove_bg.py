from PIL import Image
import os

images = [
    r"C:\Users\MF\.gemini\antigravity\brain\615c66e9-8e70-4b37-b774-0616c1a8be4c\onboarding1_square_1779266599584.png",
    r"C:\Users\MF\.gemini\antigravity\brain\615c66e9-8e70-4b37-b774-0616c1a8be4c\onboarding2_square_1779266614398.png",
    r"C:\Users\MF\.gemini\antigravity\brain\615c66e9-8e70-4b37-b774-0616c1a8be4c\onboarding3_square_1779266764894.png",
    r"C:\Users\MF\.gemini\antigravity\brain\615c66e9-8e70-4b37-b774-0616c1a8be4c\onboarding4_square_1779266794814.png",
    r"C:\Users\MF\.gemini\antigravity\brain\615c66e9-8e70-4b37-b774-0616c1a8be4c\onboarding5_square_1779266813508.png"
]

dest_dir = r"e:\Coding\serat\assets\onboarding"

for i, img_path in enumerate(images):
    img = Image.open(img_path)
    img = img.convert("RGBA")
    datas = img.getdata()
    
    newData = []
    # threshold for white
    for item in datas:
        if item[0] > 240 and item[1] > 240 and item[2] > 240:
            newData.append((255, 255, 255, 0))
        else:
            newData.append(item)
            
    img.putdata(newData)
    save_path = os.path.join(dest_dir, f"onboarding{i+1}.png")
    img.save(save_path, "PNG")
    print(f"Saved {save_path}")
