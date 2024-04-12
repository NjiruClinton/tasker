import "phoenix_html"
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

const KanbanDrop = {
  mounted() {
    this.bindDragEvents()
  },

  updated() {
    this.bindDragEvents()
  },

  bindDragEvents() {
    this.el.querySelectorAll("[data-card-id]").forEach((card) => {
      card.draggable = true
      card.ondragstart = (event) => {
        event.dataTransfer.effectAllowed = "move"
        event.dataTransfer.setData("text/plain", card.dataset.cardId)
      }
    })

    this.el.querySelectorAll("[data-list-id]").forEach((list) => {
      list.ondragover = (event) => event.preventDefault()
      list.ondrop = (event) => {
        event.preventDefault()
        const cardId = event.dataTransfer.getData("text/plain")
        const cards = Array.from(list.querySelectorAll("[data-card-id]"))
        const position = cards.findIndex((card) => event.clientY < card.getBoundingClientRect().top + card.offsetHeight / 2)

        this.pushEvent("move-card", {
          card_id: cardId,
          list_id: list.dataset.listId,
          position: position < 0 ? cards.length : position
        })
      }
    })
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: { KanbanDrop },
  params: { _csrf_token: csrfToken }
})

topbar.config({ barColors: { 0: "#2f6b4f" }, shadowColor: "rgba(0, 0, 0, .2)" })
window.addEventListener("phx:page-loading-start", () => topbar.show(300))
window.addEventListener("phx:page-loading-stop", () => topbar.hide())

liveSocket.connect()
window.liveSocket = liveSocket
