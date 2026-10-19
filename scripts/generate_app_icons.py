import os
from PIL import Image

def main():
    src_path = r"C:\Users\Dinusha\.gemini\antigravity-ide\brain\7eeaa6a4-4b29-484a-ac75-d1a718bdc140\traverza_app_icon_1792450659037.jpg"
    if not os.path.exists(src_path):
        print(f"Error: {src_path} not found")
        return

    img = Image.open(src_path).convert("RGBA")
    print(f"Loaded master image: {img.size}")

    # 1. Android Mipmap Icons
    android_res = {
        "mipmap-mdpi": (48, 48),
        "mipmap-hdpi": (72, 72),
        "mipmap-xhdpi": (96, 96),
        "mipmap-xxhdpi": (144, 144),
        "mipmap-xxxhdpi": (192, 192),
    }

    for folder, size in android_res.items():
        dest_dir = os.path.join("apps", "mobile", "android", "app", "src", "main", "res", folder)
        os.makedirs(dest_dir, exist_ok=True)
        dest_path = os.path.join(dest_dir, "ic_launcher.png")
        resized = img.resize(size, Image.Resampling.LANCZOS)
        resized.save(dest_path, "PNG")
        print(f"Updated Android {folder}/ic_launcher.png -> {size}")

    # 2. iOS AppIcon set
    ios_icons = {
        "Icon-App-1024x1024@1x.png": (1024, 1024),
        "Icon-App-20x20@1x.png": (20, 20),
        "Icon-App-20x20@2x.png": (40, 40),
        "Icon-App-20x20@3x.png": (60, 60),
        "Icon-App-29x29@1x.png": (29, 29),
        "Icon-App-29x29@2x.png": (58, 58),
        "Icon-App-29x29@3x.png": (87, 87),
        "Icon-App-40x40@1x.png": (40, 40),
        "Icon-App-40x40@2x.png": (80, 80),
        "Icon-App-40x40@3x.png": (120, 120),
        "Icon-App-60x60@2x.png": (120, 120),
        "Icon-App-60x60@3x.png": (180, 180),
        "Icon-App-76x76@1x.png": (76, 76),
        "Icon-App-76x76@2x.png": (152, 152),
        "Icon-App-83.5x83.5@2x.png": (167, 167),
    }

    ios_dir = os.path.join("apps", "mobile", "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    for fname, size in ios_icons.items():
        dest_path = os.path.join(ios_dir, fname)
        resized = img.resize(size, Image.Resampling.LANCZOS)
        # iOS AppStore icon requires no alpha transparency
        if "1024x1024" in fname:
            rgb_img = Image.new("RGB", size, (7, 15, 26))
            rgb_img.paste(resized, mask=resized.split()[3])
            rgb_img.save(dest_path, "PNG")
        else:
            resized.save(dest_path, "PNG")
        print(f"Updated iOS {fname} -> {size}")

    # 3. Mobile Asset
    assets_dir = os.path.join("apps", "mobile", "assets")
    os.makedirs(assets_dir, exist_ok=True)
    img.resize((512, 512), Image.Resampling.LANCZOS).save(os.path.join(assets_dir, "app_icon.png"), "PNG")
    print("Saved apps/mobile/assets/app_icon.png")

    # 4. Web Public & App Icons
    web_public = os.path.join("apps", "web", "public")
    web_app = os.path.join("apps", "web", "app")
    os.makedirs(web_public, exist_ok=True)
    os.makedirs(web_app, exist_ok=True)

    img.resize((512, 512), Image.Resampling.LANCZOS).save(os.path.join(web_public, "app-icon.png"), "PNG")
    img.resize((512, 512), Image.Resampling.LANCZOS).save(os.path.join(web_app, "icon.png"), "PNG")
    img.resize((32, 32), Image.Resampling.LANCZOS).save(os.path.join(web_public, "favicon.ico"), "ICO")
    print("Saved Web favicons and app icons!")

if __name__ == "__main__":
    main()
