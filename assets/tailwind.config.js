const plugin = require("tailwindcss/plugin")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/tasker_web.ex",
    "../lib/tasker_web/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        ink: "#17211f",
        moss: "#2f6b4f",
        mint: "#e9f7ef",
        coral: "#e66f51",
        amber: "#f5b84b"
      },
      fontFamily: {
        sans: ["Inter", "ui-sans-serif", "system-ui", "sans-serif"]
      }
    }
  },
  plugins: [
    plugin(({ addVariant }) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"]))
  ]
}
