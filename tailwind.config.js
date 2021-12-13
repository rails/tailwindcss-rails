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
        'responsive',
        'group-hover',
        'group-focus',
        'hover',
        'focus-within',
        'focus-visible',
        'focus',
        'active',
        'visited',
        'disabled',
        'checked',
      ]
    }
  ],
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
}
