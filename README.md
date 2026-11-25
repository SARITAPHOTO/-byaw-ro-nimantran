# शाही ब्याव — राजस्थानी विवाह निमंत्रण

यह हिंदी-प्रथम, मोबाइल-अनुकूल विवाह निमंत्रण वेबसाइट है। इसमें शाही प्रवेश-द्वार, गणेश वंदना, वर-वधू परिचय, परिवार का निमंत्रण, वास्तविक touch/mouse scratch reveal कार्यक्रम, countdown, फोटो गैलरी, स्थल, RSVP, WhatsApp sharing और अलग प्रशासक प्रवेश शामिल हैं।

> **महत्वपूर्ण:** बिना Supabase credentials के यह केवल दृश्य डेमो है। डेमो में RSVP सेव नहीं होता, प्रशासक लॉगिन नहीं होगा और कोई नकली सफलता नहीं दिखाई जाती। असली उपयोग से पहले नीचे का Supabase सेटअप पूरा करें।

## 1. Supabase परियोजना तैयार करें

1. https://supabase.com पर नया प्रोजेक्ट बनाएँ।
2. परियोजना के **SQL Editor** में `supabase/schema.sql` की पूरी सामग्री चलाएँ।
3. **Authentication → Users** में अपना प्रशासक उपयोगकर्ता बनाएँ। ईमेल और मजबूत पासवर्ड रखें।
4. **Project Settings → API** से Project URL और anon/public key लें।
5. `index.html` में ये दो मान बदलें:
   - `YOUR_SUPABASE_URL` → आपका Project URL
   - `YOUR_SUPABASE_ANON_KEY` → आपकी anon/public key

Frontend में केवल anon/public key रखें। **service_role key कभी भी HTML, JavaScript, GitHub या browser में न डालें।**

## 2. प्रशासक प्रवेश

1. वेबसाइट के URL के अंत में `?admin=1` जोड़ें (उदाहरण: `https://आपका-डोमेन/?admin=1`)। इससे प्रशासक प्रवेश बटन दिखेगा। किसी विवाह के साथ खोलने के लिए `?wedding=rahul-priya&admin=1` जोड़ें।
2. Supabase Authentication में बनाए गए प्रशासक ईमेल/पासवर्ड से प्रवेश करें।
3. विवाह पहचान (slug), वर-वधू के नाम, माता-पिता, तिथि, मुहूर्त, स्थल, संदेश, कार्यक्रम, गैलरी और रंग भरें।
4. पहले विवाह को सेव करें। उसके बाद उसी slug के लिए चित्र और संगीत अपलोड करें।
5. प्रकाशित विकल्प को **प्रकाशित** करके सेव करें। ड्राफ़्ट सार्वजनिक मेहमानों को नहीं दिखता।

पहला विवाह उदाहरण slug: `rahul-priya`

## 3. अलग-अलग विवाह के URL

GitHub Pages पर सरल तरीका:

`https://आपका-डोमेन/?wedding=rahul-priya`

दूसरी शादी के लिए अलग slug रखें, जैसे `amit-neha`:

`https://आपका-डोमेन/?wedding=amit-neha`

Vercel पर `vercel.json` rewrite के कारण सुंदर URL भी उपलब्ध है:

`https://आपका-डोमेन/wedding/rahul-priya`

हर निमंत्रण का डेटा `weddings` तालिका में अलग slug और UUID से जुड़ा है। किसी एक शादी के कार्यक्रम या फोटो दूसरी शादी को नहीं बदलते।

## 4. फोटो और संगीत

- प्रशासक कक्ष में वर, वधू और संगीत की फ़ाइल चुनें।
- गैलरी में एक-एक सार्वजनिक image URL अलग पंक्ति में जोड़ें।
- Supabase Storage में `wedding-media` bucket SQL से बनता है।
- फ़ाइल आकार सीमा 12 MB है। समर्थित प्रकार: JPG, PNG, WebP, AVIF और MP3/MP4/AAC/OGG।
- सार्वजनिक निमंत्रण में प्रयुक्त मीडिया सार्वजनिक पढ़ने योग्य है; अपलोड/बदलाव/हटाने के लिए संबंधित विवाह का मालिक होना आवश्यक है।

## 5. कार्यक्रम Scratch कार्ड

कार्यक्रम JSON का उदाहरण:

```json
[
  {"name":"हल्दी समारोह","date":"२१ नवम्बर २०२६","time":"प्रातः १० बजे","venue":"परिवार निवास","description":"पीले रंग और मंगल गीतों के साथ","color":"#d5a64e"},
  {"name":"मेहंदी समारोह","date":"२१ नवम्बर २०२६","time":"सायं ५ बजे","venue":"आँगन","description":"मेहंदी और संगीत","color":"#a87935"},
  {"name":"शुभ विवाह","date":"२२ नवम्बर २०२६","time":"रात्रि ९ बजे","venue":"शाही गार्डन","description":"मंगल परिणय","color":"#8f2037"}
]
```

कार्यक्रम कार्ड की तारीख़, समय और स्थान Canvas scratch layer के नीचे रहते हैं। मेहमान को उंगली या माउस से वास्तविक scratching करनी होती है।

## 6. RSVP और सुरक्षा

- RSVP केवल प्रकाशित और सक्रिय विवाह के लिए स्वीकार होता है।
- RSVP तालिका पर Row Level Security चालू है। मेहमान RSVP केवल insert कर सकते हैं; उसे पढ़ नहीं सकते।
- केवल उसी विवाह का मालिक RSVP पढ़ सकता है।
- Wedding रिकॉर्ड केवल owner बना/बदल सकता है; सार्वजनिक उपयोगकर्ता केवल published और active निमंत्रण पढ़ सकता है।
- Admin account को Supabase Auth में बनाएँ। किसी भी स्थिति में service_role key साझा न करें।
- उत्पादन उपयोग से पहले Supabase Auth में ईमेल सत्यापन और मजबूत पासवर्ड लागू करें।

## 7. GitHub Pages पर प्रकाशित करना

यह प्रोजेक्ट बिना build step के एकल HTML पेज है:

1. GitHub repository में बदलाव push करें।
2. Repository → **Settings → Pages** खोलें।
3. Deploy from a branch चुनें, Branch `main`, Folder `/ (root)` रखें।
4. Save करें। प्रकाशित होने के बाद दिए गए URL पर जाएँ।
5. बदलाव न दिखें तो Ctrl+Shift+R करें।

GitHub Pages static hosting है। Supabase authentication/database अलग से काम करते हैं। सुंदर `/wedding/slug` URL के लिए Vercel/Netlify जैसी hosting बेहतर है; GitHub Pages पर `?wedding=slug` URL इस्तेमाल करें।

## 8. Vercel deployment

1. Vercel में GitHub repository import करें।
2. Framework preset **Other** चुनें; Build command खाली और Output directory `.` रखें।
3. `vercel.json` पहले से मौजूद है। Deploy करें।
4. Supabase URL और anon key HTML में सेट होना आवश्यक है।

## 9. Lovable के साथ

यह repository सामान्य HTML/CSS/JavaScript और Supabase SQL का उपयोग करती है। Lovable में GitHub repository import/connect करके इसे आगे React/Vite संरचना में बदला जा सकता है। Lovable sync से पहले repository का backup रखें।

## 10. अभी की सीमाएँ / आगे का सुधार

- वर्तमान Admin Dashboard एक ही विवाह का विवरण, कार्यक्रम JSON, गैलरी URL, थीम और RSVP सूची संपादित करता है। कई विवाहों का प्रबंधन slug बदलकर किया जा सकता है।
- संगीत browser autoplay policy के कारण केवल मेहमान के पहले interaction के बाद चलेगा।
- अभी gallery में URL सूची उपलब्ध है; बहु-फोटो bulk manager और delete UI अगला विकास चरण है।
- प्रकाशित विवाह में बदलावा सेव होते ही लाइव हो जाते हैं; अलग revision/draft preview workflow और audit history अभी शामिल नहीं है।
- उत्पादन में custom domain, Supabase backup, storage quota, CAPTCHA/rate limiting और admin MFA जोड़ने की सलाह है।

## Repository files

- `index.html` — मेहमान वेबसाइट, scratch canvas, countdown, RSVP और admin interface
- `supabase/schema.sql` — tables, storage bucket और RLS policies
- `vercel.json` — सुंदर विवाह URL rewrite
