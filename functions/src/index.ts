/* eslint-disable max-len */
/* eslint-disable object-curly-spacing */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { GoogleGenAI } from "@google/genai";
import { CallableContext } from "firebase-functions/v1/https"; 

admin.initializeApp();

// Fonksiyonumuzun isteği beklediği veri yapısının yeni, BASİT tanımı
interface VideoRequest {
  // image: string; <-- KALDIRILDI
  prompt: string; // Kullanıcı isteği
}

// Global scope'ta API anahtarı ayarı
const geminiApiKey = process.env.GEMINI_API_KEY; 
const ai = new GoogleGenAI({apiKey: geminiApiKey});


export const generateVideoFromImage = functions.https.onCall(async (data, context) => {
  
  // 1. Anahtarın varlığını Kontrol et
  if (!geminiApiKey) {
      throw new functions.https.HttpsError("internal", "Sunucu konfigürasyonu eksik: API anahtarı yok.");
  }
  
  // 2. Data'dan SADECE prompt'u oku
  const requestData = data as unknown as VideoRequest;
  const { prompt } = requestData;

  if (!prompt) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "Prompt (istek) alanı boş bırakılamaz."
    );
  }

  try {
    // 3. Gemini'a isteği gönderme (GÖRÜNTÜSÜZ VERSİYON)
    const response = await ai.models.generateContent({
      model: "gemini-2.5-flash", // Daha basit bir model de kullanabiliriz
      contents: [
        { text: `Sadece metin olarak verilen bu isteğe göre kısa bir film senaryosu yaz: "${prompt}". Yalnızca senaryoyu ve videonun ana temasını özetleyen kısa bir başlığı JSON formatında döndür. Senaryo en az 50 kelime olmalıdır.` },
      ],
    });

    return {
      success: true,
      message: "Senaryo başarıyla oluşturuldu.",
      result: response.text,
    };
  } catch (error) {
    console.error("Gemini API çağrısı başarısız oldu:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Yapay zeka servisinde bir hata oluştu."
    );
  }
});