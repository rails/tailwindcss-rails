const defaultTheme = require('tailwindcss/defaultTheme')
const plugin = require('tailwindcss/plugin')
const path = require("path")
const fs = require("fs");

const usePlugin = (pluginName) => plugin(({ addUtilities, postcss }) => {
  const pluginPath = path.join(__dirname, "../tmp/tailwindcss-plugin/", pluginName + ".css")
  const css = fs.readFileSync(pluginPath, 'utf8')
  addUtilities(postcss.parse(css).nodes)
})


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
