from flask import Flask, render_template_string, request, make_response
import os

app = Flask(__name__)

# Get email from environment variable, default to placeholder
CONTACT_EMAIL = os.environ.get('CONTACT_EMAIL', 'your-email@example.com')

# Translations
TRANSLATIONS = {
    'en': {
        'badge': 'Premium Domain',
        'title': 'This Domain is For Sale',
        'subtitle': 'This domain name is available for purchase',
        'contact_label': 'Contact',
        'footer': 'Serious inquiries only',
        'page_title': 'Premium Domain For Sale'
    },
    'zh': {
        'badge': '精品域名',
        'title': '此域名出售',
        'subtitle': '该域名正在出售中',
        'contact_label': '联系方式',
        'footer': '非诚勿扰',
        'page_title': '域名出售'
    },
    'ja': {
        'badge': 'プレミアムドメイン',
        'title': 'このドメインは売り出し中です',
        'subtitle': 'このドメイン名は購入可能です',
        'contact_label': 'お問い合わせ',
        'footer': '真剣なお問い合わせのみ',
        'page_title': 'ドメイン売り出し中'
    },
    'ko': {
        'badge': '프리미엄 도메인',
        'title': '이 도메인은 판매 중입니다',
        'subtitle': '이 도메인 이름을 구매하실 수 있습니다',
        'contact_label': '문의하기',
        'footer': '진지한 문의만 부탁드립니다',
        'page_title': '도메인 판매'
    },
    'de': {
        'badge': 'Premium-Domäne',
        'title': 'Diese Domain steht zum Verkauf',
        'subtitle': 'Diese Domain ist verfügbar',
        'contact_label': 'Kontakt',
        'footer': 'Nur ernste Anfragen',
        'page_title': 'Domain zu verkaufen'
    },
    'fr': {
        'badge': 'Domaine Premium',
        'title': 'Ce domaine est à vendre',
        'subtitle': 'Ce nom de domaine est disponible à l\'achat',
        'contact_label': 'Contact',
        'footer': 'Demandes sérieuses uniquement',
        'page_title': 'Domaine à vendre'
    },
    'es': {
        'badge': 'Dominio Premium',
        'title': 'Este dominio está en venta',
        'subtitle': 'Este nombre de dominio está disponible para comprar',
        'contact_label': 'Contacto',
        'footer': 'Solo consultas serias',
        'page_title': 'Dominio en venta'
    }
}

# Language display names for selector
LANGUAGE_NAMES = {
    'en': 'English',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
    'de': 'Deutsch',
    'fr': 'Français',
    'es': 'Español'
}

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="{{ lang }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ t.page_title }}</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;600;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background: linear-gradient(135deg, #0f0f23 0%, #1a1a3e 50%, #0d0d1f 100%);
            position: relative;
            overflow: hidden;
        }

        body::before {
            content: '';
            position: absolute;
            width: 150%;
            height: 150%;
            background: radial-gradient(circle at 20% 80%, rgba(120, 119, 198, 0.15) 0%, transparent 50%),
                        radial-gradient(circle at 80% 20%, rgba(255, 119, 198, 0.1) 0%, transparent 50%),
                        radial-gradient(circle at 40% 40%, rgba(120, 219, 255, 0.08) 0%, transparent 40%);
            animation: float 20s ease-in-out infinite;
        }

        @keyframes float {
            0%, 100% { transform: translate(0, 0) rotate(0deg); }
            33% { transform: translate(-30px, -30px) rotate(5deg); }
            66% { transform: translate(30px, -20px) rotate(-5deg); }
        }

        .language-selector {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 100;
        }

        .lang-dropdown {
            position: relative;
        }

        .lang-btn {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 10px 16px;
            background: rgba(255, 255, 255, 0.08);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 12px;
            color: rgba(255, 255, 255, 0.9);
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            backdrop-filter: blur(10px);
            transition: all 0.3s ease;
        }

        .lang-btn:hover {
            background: rgba(255, 255, 255, 0.12);
            border-color: rgba(255, 255, 255, 0.25);
        }

        .lang-btn svg {
            width: 18px;
            height: 18px;
            transition: transform 0.3s ease;
        }

        .lang-dropdown.open .lang-btn svg {
            transform: rotate(180deg);
        }

        .lang-menu {
            position: absolute;
            top: calc(100% + 8px);
            right: 0;
            min-width: 180px;
            background: rgba(15, 15, 35, 0.95);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 16px;
            padding: 8px;
            backdrop-filter: blur(20px);
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
            opacity: 0;
            visibility: hidden;
            transform: translateY(-10px);
            transition: all 0.3s ease;
        }

        .lang-dropdown.open .lang-menu {
            opacity: 1;
            visibility: visible;
            transform: translateY(0);
        }

        .lang-option {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 14px;
            border-radius: 10px;
            color: rgba(255, 255, 255, 0.8);
            font-size: 14px;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .lang-option:hover {
            background: rgba(255, 255, 255, 0.08);
            color: #ffffff;
        }

        .lang-option.active {
            background: rgba(99, 102, 241, 0.3);
            color: #ffffff;
        }

        .lang-option .check {
            width: 16px;
            height: 16px;
            opacity: 0;
            flex-shrink: 0;
        }

        .lang-option.active .check {
            opacity: 1;
        }

        .lang-option span {
            flex: 1;
        }

        .container {
            position: relative;
            z-index: 1;
            text-align: center;
            padding: 80px 100px;
            background: rgba(255, 255, 255, 0.03);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 32px;
            box-shadow: 0 30px 80px rgba(0, 0, 0, 0.5),
                        inset 0 1px 0 rgba(255, 255, 255, 0.1);
            max-width: 650px;
            margin: 20px;
        }

        .badge {
            display: inline-block;
            padding: 8px 20px;
            background: linear-gradient(135deg, rgba(120, 119, 198, 0.3), rgba(255, 119, 198, 0.2));
            border-radius: 100px;
            font-size: 13px;
            font-weight: 500;
            letter-spacing: 2px;
            text-transform: uppercase;
            color: rgba(255, 255, 255, 0.8);
            margin-bottom: 32px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        h1 {
            font-family: 'Playfair Display', serif;
            font-size: 56px;
            font-weight: 600;
            color: #ffffff;
            margin-bottom: 16px;
            letter-spacing: -1px;
            line-height: 1.2;
        }

        .subtitle {
            font-size: 18px;
            color: rgba(255, 255, 255, 0.6);
            font-weight: 300;
            margin-bottom: 48px;
            letter-spacing: 0.5px;
        }

        .divider {
            width: 60px;
            height: 2px;
            background: linear-gradient(90deg, transparent, rgba(120, 119, 198, 0.8), transparent);
            margin: 0 auto 48px;
        }

        .contact-section {
            margin-top: 20px;
        }

        .contact-label {
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 2px;
            color: rgba(255, 255, 255, 0.5);
            margin-bottom: 16px;
            font-weight: 500;
        }

        .email-link {
            display: inline-flex;
            align-items: center;
            gap: 12px;
            font-size: 22px;
            color: #ffffff;
            text-decoration: none;
            padding: 18px 36px;
            background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
            border-radius: 16px;
            font-weight: 500;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 10px 30px rgba(99, 102, 241, 0.4);
        }

        .email-link:hover {
            transform: translateY(-3px);
            box-shadow: 0 20px 40px rgba(99, 102, 241, 0.5);
        }

        .email-link:active {
            transform: translateY(-1px);
        }

        .icon {
            width: 24px;
            height: 24px;
            stroke: currentColor;
            stroke-width: 2;
            fill: none;
        }

        .footer {
            margin-top: 48px;
            padding-top: 32px;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
        }

        .footer-text {
            font-size: 13px;
            color: rgba(255, 255, 255, 0.3);
        }

        @media (max-width: 768px) {
            .language-selector {
                top: 12px;
                right: 12px;
            }

            .lang-btn {
                padding: 8px 12px;
                font-size: 13px;
            }

            .container {
                padding: 50px 32px;
                border-radius: 24px;
            }

            h1 {
                font-size: 40px;
            }

            .email-link {
                font-size: 18px;
                padding: 16px 28px;
            }
        }
    </style>
</head>
<body>
    <div class="language-selector">
        <div class="lang-dropdown" id="langDropdown">
            <button class="lang-btn" type="button" onclick="toggleDropdown()">
                <span id="currentLangName">{{ lang_names[lang] }}</span>
                <svg viewBox="0 0 24 24" fill="none">
                    <path d="M6 9l6 6 6-6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
            </button>
            <div class="lang-menu">
                {% for code, name in lang_names.items() %}
                <div class="lang-option {{ 'active' if code == lang else '' }}" onclick="setLanguage('{{ code }}')">
                    <svg class="check" viewBox="0 0 24 24" fill="none">
                        <path d="M20 6L9 17l-5-5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                    <span>{{ name }}</span>
                </div>
                {% endfor %}
            </div>
        </div>
    </div>

    <div class="container">
        <div class="badge">{{ t.badge }}</div>
        <h1>{{ t.title }}</h1>
        <p class="subtitle">{{ t.subtitle }}</p>
        <div class="divider"></div>

        <div class="contact-section">
            <p class="contact-label">{{ t.contact_label }}</p>
            <a href="mailto:{{ email }}" class="email-link">
                <svg class="icon" viewBox="0 0 24 24">
                    <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
                    <polyline points="22,6 12,13 2,6"></polyline>
                </svg>
                {{ email }}
            </a>
        </div>

        <div class="footer">
            <p class="footer-text">{{ t.footer }}</p>
        </div>
    </div>

    <script>
        function toggleDropdown() {
            const dropdown = document.getElementById('langDropdown');
            dropdown.classList.toggle('open');
        }

        function setLanguage(lang) {
            document.cookie = 'lang=' + lang + ';path=/;max-age=31536000';
            location.reload();
        }

        // Close dropdown when clicking outside
        document.addEventListener('click', function(e) {
            const dropdown = document.getElementById('langDropdown');
            if (!dropdown.contains(e.target)) {
                dropdown.classList.remove('open');
            }
        });
    </script>
</body>
</html>
"""

def get_preferred_language():
    """Get preferred language from cookie, query param, or Accept-Language header"""
    # Check URL parameter first
    if 'lang' in request.args:
        lang = request.args['lang']
        if lang in TRANSLATIONS:
            return lang

    # Check cookie next
    if 'lang' in request.cookies:
        lang = request.cookies['lang']
        if lang in TRANSLATIONS:
            return lang

    # Parse Accept-Language header
    accept_language = request.headers.get('Accept-Language', '')
    if accept_language:
        # Parse: "zh-CN,zh;q=0.9,en;q=0.8"
        for part in accept_language.split(','):
            part = part.strip()
            if ';' in part:
                lang_part = part.split(';')[0]
            else:
                lang_part = part

            # Extract base language (zh-CN -> zh, en-US -> en)
            base_lang = lang_part.split('-')[0].lower()

            if base_lang in TRANSLATIONS:
                return base_lang

    # Default to English
    return 'en'

@app.route('/')
def index():
    lang = get_preferred_language()
    t = TRANSLATIONS[lang]

    response = make_response(
        render_template_string(
            HTML_TEMPLATE,
            t=t,
            lang=lang,
            lang_names=LANGUAGE_NAMES,
            email=CONTACT_EMAIL
        )
    )

    # Set cookie if not present or different
    if request.cookies.get('lang') != lang:
        response.set_cookie('lang', lang, max_age=31536000, path='/')

    return response

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 80))
    app.run(host='0.0.0.0', port=port, debug=False)
