from PIL import Image
import os
import glob

dest_dir = r"e:\Coding\serat\assets\onboarding"
png_files = glob.glob(os.path.join(dest_dir, "*.png"))

for png_file in png_files:
    img = Image.open(png_file)
    webp_file = png_file.replace(".png", ".webp")
    # Convert and save as webp, using lossless to perfectly preserve the transparent background
    img.save(webp_file, "webp", lossless=True)
    print(f"Saved {webp_file}")
    
    img.close()
    os.remove(png_file)
    print(f"Removed {png_file}")
