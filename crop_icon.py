from PIL import Image

def crop_white_padding(img_path, out_path, padding=0):
    img = Image.open(img_path).convert("RGBA")
    
    bg = Image.new(img.mode, img.size, (255,255,255,255))
    diff = Image.new("RGBA", img.size)
    
    # Calculate difference from white
    img_data = list(img.getdata())
    diff_data = []
    for pixel in img_data:
        r, g, b, a = pixel
        # if almost white
        if r > 240 and g > 240 and b > 240 and a > 240:
            diff_data.append((0,0,0,0))
        else:
            diff_data.append((255,255,255,255))
    diff.putdata(diff_data)
    
    bbox = diff.getbbox()
    if bbox:
        # Add some padding if desired
        left, upper, right, lower = bbox
        left = max(0, left - padding)
        upper = max(0, upper - padding)
        right = min(img.width, right + padding)
        lower = min(img.height, lower + padding)
        cropped = img.crop((left, upper, right, lower))
        cropped.save(out_path)
        print(f"Cropped successfully. Original size: {img.size}. New size: {cropped.size}")
    else:
        print("Could not find bounding box.")

crop_white_padding("image.png", "icon_cropped.png")
