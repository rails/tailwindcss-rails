const defaultTheme = require('tailwindcss/defaultTheme')

const cssVar = (name, defaultValue) => `var(--tw-${name}, ${defaultValue})`

module.exports = {
  darkMode: 'media',
  theme: {
    extend: {
      fontFamily: {
        sans: cssVar('font-family-sans', ['"Inter var"', ...defaultTheme.fontFamily.sans]),
        serif: cssVar('font-family-serif', defaultTheme.fontFamily.serif),
        mono: cssVar('font-family-mono', defaultTheme.fontFamily.mono),
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
}
