const plugin = require('tailwindcss/plugin')
const { execSync } = require("child_process");
const root = execSync("npm root --location=global").toString().trim();
const path = require("path")
const fs = require("fs");
const postcss = require(path.join(root, "postcss"))

function usePlugin(pluginName) {
  return plugin(function({addUtilities}) {
    const pluginPath = path.join(__dirname, "../tmp/tailwindcss-plugin/", pluginName + ".css")

    const css = fs.readFileSync(pluginPath, 'utf8')

    addUtilities(postcss.parse(css).nodes)
  })
}

module.exports = usePlugin
