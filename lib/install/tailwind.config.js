const defaultTheme = require('tailwindcss/defaultTheme')

// Uncomment this line if you want to add support for tailwind plugins
// const usePlugin = require('./tailwind.plugins')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    // usePlugin(pluginName) => plugin name is based on that defined in tailwind.plugins.yml
  ]
}
