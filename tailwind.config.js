// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

let plugin = require('tailwindcss/plugin')

module.exports = {
  content: ['./src/**/*.{html,gleam}'],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Overpass', 'sans-serif']
      },
    },
  },
  plugins: [require('@tailwindcss/forms')],
}
