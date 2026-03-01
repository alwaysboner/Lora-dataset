export type ColorGradeStyle = "original" | "realistic" | "anime" | "cinematic" | "vintage";

export async function applyColorGrade(blob: Blob, style: ColorGradeStyle): Promise<Blob> {
  if (style === "original") return blob;

  return new Promise((resolve, reject) => {
    const img = new Image();
    const url = URL.createObjectURL(blob);
    
    img.onload = () => {
      const canvas = document.createElement("canvas");
      canvas.width = img.width;
      canvas.height = img.height;
      const ctx = canvas.getContext("2d");
      
      if (!ctx) {
        reject(new Error("Could not get canvas context"));
        return;
      }

      // Apply CSS filters based on style
      switch (style) {
        case "realistic":
          // Slightly warmer, natural contrast
          ctx.filter = "contrast(1.05) saturate(1.1) sepia(0.05)";
          break;
        case "anime":
          // High vibrancy, slightly brighter
          ctx.filter = "contrast(1.15) saturate(1.4) brightness(1.05)";
          break;
        case "cinematic":
          // High contrast, teal/orange tint (approximated with hue-rotate and sepia)
          ctx.filter = "contrast(1.2) saturate(0.9) sepia(0.2) hue-rotate(-10deg)";
          break;
        case "vintage":
          // Faded contrast, warm tint
          ctx.filter = "contrast(0.9) sepia(0.4) brightness(1.1)";
          break;
      }

      ctx.drawImage(img, 0, 0);

      canvas.toBlob((newBlob) => {
        if (newBlob) {
          resolve(newBlob);
        } else {
          reject(new Error("Failed to create blob"));
        }
      }, blob.type);
      
      URL.revokeObjectURL(url);
    };
    
    img.onerror = () => {
      URL.revokeObjectURL(url);
      reject(new Error("Failed to load image for color grading"));
    };
    
    img.src = url;
  });
}
