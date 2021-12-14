const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  safelist: [
    {
      pattern: /.+/,
      variants: [
        'sm', 'md', 'lg', 'xl', '2xl',
        'group-hover',
        'hover',
        'focus-within',
        'focus',
        'dark',
      ]
    }
  ],
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
}
