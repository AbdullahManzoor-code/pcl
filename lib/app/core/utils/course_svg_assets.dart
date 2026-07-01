class CourseSvgAssets {
  static const String python = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <defs>
    <linearGradient id="pyGrad1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#3776AB" />
      <stop offset="100%" stop-color="#1E3F5F" />
    </linearGradient>
    <linearGradient id="pyGrad2" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FFD343" />
      <stop offset="100%" stop-color="#D9A71E" />
    </linearGradient>
  </defs>
  <rect width="100" height="100" rx="16" fill="#111827"/>
  <path d="M50 15c-15.5 0-16 6.8-16 11v8h16v4H26c-9.2 0-11 5.8-11 15s1.8 15 11 15h9v-9c0-6.2 4.8-11 11-11h14v-17c0-11.2-5.5-16-20-16z" fill="url(#pyGrad1)"/>
  <path d="M50 85c15.5 0 16-6.8 16-11v-8H50v-4h24c9.2 0 11-5.8 11-15s-1.8-15-11-15h-9v9c0 6.2-4.8 11-11 11H40v17c0 11.2 5.5 16 20 16z" fill="url(#pyGrad2)"/>
  <circle cx="34" cy="24" r="2.5" fill="#FFF"/>
  <circle cx="66" cy="76" r="2.5" fill="#FFF"/>
</svg>
''';

  static const String javascript = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <defs>
    <linearGradient id="jsGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#F7DF1E" />
      <stop offset="100%" stop-color="#D4AF37" />
    </linearGradient>
  </defs>
  <rect width="100" height="100" rx="16" fill="#111827"/>
  <rect x="25" y="25" width="50" height="50" rx="8" fill="url(#jsGrad)"/>
  <text x="36" y="66" font-family="'Outfit', 'Inter', sans-serif" font-weight="900" font-size="36" fill="#111827">JS</text>
</svg>
''';

  static const String cpp = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <defs>
    <linearGradient id="cppGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#00599C" />
      <stop offset="100%" stop-color="#003366" />
    </linearGradient>
  </defs>
  <rect width="100" height="100" rx="16" fill="#111827"/>
  <circle cx="45" cy="50" r="25" fill="none" stroke="url(#cppGrad)" stroke-width="8"/>
  <path d="M48 37h-8v8h-8v10h8v8h8v-8h8V45h-8z" fill="#FFF"/>
  <path d="M72 45h-6v-6h-4v6h-6v4h6v6h4v-6h6z" fill="url(#cppGrad)"/>
  <path d="M85 45h-6v-6h-4v6h-6v4h6v6h4v-6h6z" fill="url(#cppGrad)"/>
</svg>
''';

  static const String java = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <defs>
    <linearGradient id="javaGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#EA2D42" />
      <stop offset="100%" stop-color="#5382A1" />
    </linearGradient>
  </defs>
  <rect width="100" height="100" rx="16" fill="#111827"/>
  <path d="M50 20c-5 8 2 12-2 20M42 22c-3 6 1 9-2 15M58 24c-3 6 1 9-2 15" fill="none" stroke="#EA2D42" stroke-width="4" stroke-linecap="round"/>
  <path d="M30 55c0 0 10 8 20 8s20-8 20-8v6c0 5-9 8-20 8s-20-3-20-8z" fill="url(#javaGrad)"/>
  <path d="M26 50c0 0 12 10 24 10s24-10 24-10c4 0 6 3 6 5s-2 5-6 5H32c-4 0-6-3-6-5s2-5 6-5z" fill="#5382A1"/>
</svg>
''';

  static const String typescript = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <defs>
    <linearGradient id="tsGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#3178C6" />
      <stop offset="100%" stop-color="#1E4E8C" />
    </linearGradient>
  </defs>
  <rect width="100" height="100" rx="16" fill="#111827"/>
  <rect x="25" y="25" width="50" height="50" rx="8" fill="url(#tsGrad)"/>
  <text x="35" y="66" font-family="'Outfit', 'Inter', sans-serif" font-weight="900" font-size="36" fill="#FFF">TS</text>
</svg>
''';

  static const String go = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <defs>
    <linearGradient id="goGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#00ADD8" />
      <stop offset="100%" stop-color="#007D9C" />
    </linearGradient>
  </defs>
  <rect width="100" height="100" rx="16" fill="#111827"/>
  <rect x="25" y="25" width="50" height="50" rx="8" fill="url(#goGrad)"/>
  <text x="30" y="66" font-family="'Outfit', 'Inter', sans-serif" font-weight="900" font-size="38" fill="#FFF">Go</text>
</svg>
''';

  static String getSvgForLanguage(String languageName) {
    final name = languageName.toLowerCase();
    if (name.contains('python')) return python;
    if (name.contains('javascript')) return javascript;
    if (name.contains('c++') || name.contains('cpp')) return cpp;
    if (name.contains('java')) return java;
    if (name.contains('typescript')) return typescript;
    if (name.contains('go')) return go;
    return '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <rect width="100" height="100" rx="16" fill="#111827"/>
  <path d="M35 35 L20 50 L35 65 M65 35 L80 50 L65 65" fill="none" stroke="#6366F1" stroke-width="8" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';
  }
}
