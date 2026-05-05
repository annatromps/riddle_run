import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["timedOptions", "secondsDisplay"]

  connect() {
    this.syncTimedOptions()
  }

  timedChanged() {
    this.syncTimedOptions()
  }

  secondsChanged(event) {
    this.secondsDisplayTarget.textContent = event.target.value
  }

  syncTimedOptions() {
    const timed = this.element.querySelector('[name="timed"]').checked
    this.timedOptionsTarget.classList.toggle("hidden", !timed)
  }
}
