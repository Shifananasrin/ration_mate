translations = {
    "user_exists": {
        "en": "User already exists. Redirecting to OTP page.",
        "ml": "ഉപയോക്താവ് ഇതിനകം നിലവിലുണ്ട്. OTP പേജിലേക്ക് പോകുന്നു.",
    },
    "user_not_found": {
        "en": "User not found. Redirecting to registration page.",
        "ml": "ഉപയോക്താവിനെ കണ്ടെത്തിയില്ല. രജിസ്ട്രേഷൻ പേജിലേക്ക് പോകുന്നു.",
    },
    "otp_sent": {
        "en": "OTP sent successfully.",
        "ml": "OTP വിജയകരമായി അയച്ചു.",
    },
    "otp_invalid": {
        "en": "Invalid OTP.",
        "ml": "OTP അസാധുവാണ്.",
    },
    "otp_verified": {
        "en": "Phone number verified successfully.",
        "ml": "ഫോൺ നമ്പർ വിജയകരമായി സ്ഥിരീകരിച്ചു.",
    }
}

def get_message(key, lang='en'):
    return translations.get(key, {}).get(lang, translations.get(key, {}).get('en', ''))
