// Minimal topbar vendor shim used by Phoenix LiveView page loading events.
export default {
  config() {},
  show() {
    document.documentElement.classList.add("is-loading")
  },
  hide() {
    document.documentElement.classList.remove("is-loading")
  }
}
