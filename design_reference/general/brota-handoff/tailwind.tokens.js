// Fragmento para tailwind.config.js
module.exports = {
  darkMode: ['class', '[data-theme="dark"]'],
  theme: {
    extend: {
      colors: {
        brota: {
          50: '#f0fdf4',
          100: '#dcfce7',
          200: '#bbf7d0',
          400: '#4ade80',
          600: '#16a34a',
          700: '#15803d',
          950: '#052e16',
          cream: '#f2efea',
          ink: '#060d07',
          surface: '#1a1d24',
          surfaceUp: '#2c3140',
          authDark: '#0d110e',
        },
      },
      backgroundImage: {
        'brota-dashboard': 'linear-gradient(#f0fdf4,#dcfce7)',
        'brota-dashboard-dark': 'linear-gradient(#0a1a0a,#060d07)',
        'brota-hero': 'linear-gradient(135deg,#16a34a,#15803d)',
        'brota-hero-dark': 'linear-gradient(135deg,#15803d,#14532d)',
        'brota-placeholder': 'repeating-linear-gradient(135deg,#dcfce7 0 8px,#f0fdf4 8px 16px)',
      },
      boxShadow: {
        'brota-cta': '0 6px 16px rgba(22,163,74,.28)',
        'brota-sheet': '0 -12px 40px rgba(5,46,22,.25)',
        'brota-focus': '0 0 0 3px rgba(22,163,74,.12)',
      },
      borderRadius: { sheet: '28px', card: '18px', cardLg: '22px', field: '14px' },
      fontFamily: { sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'] },
    },
  },
};
