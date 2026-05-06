import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  show() {
    this.modalTarget.classList.remove("hidden")
  }

  // Close only when clicking the dim overlay itself, not the card
  dismissIfBackground(event) {
    if (event.target === this.modalTarget) this.hide()
  }

  hide() {
    this.modalTarget.classList.add("hidden")
  }
}
