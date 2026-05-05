import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["question", "answerSection", "timerDisplay", "timerRing", "pauseBtn", "form", "outcomeField"]
  static values = {
    audio:       Boolean,
    timed:       Boolean,
    seconds:     Number,
    autoAdvance: Boolean
  }

  connect() {
    this.timeLeft = this.secondsValue
    this.paused   = false
    this.revealed = false

    if (this.audioValue) {
      // Small delay so Turbo has finished painting before we speak
      setTimeout(() => this.speak(this.questionTarget.textContent.trim()), 400)
    }

    if (this.timedValue) {
      this.updateRing()
      this.startTimer()
    }
  }

  disconnect() {
    this.stopTimer()
    this.cancelSpeech()
  }

  // ── Speech ────────────────────────────────────────────────────────────────

  speak(text) {
    if (!("speechSynthesis" in window)) return
    this.cancelSpeech()
    const utter = new SpeechSynthesisUtterance(text)
    utter.rate  = 0.92
    utter.pitch = 1.0
    const voice = this.bestVoice()
    if (voice) utter.voice = voice
    window.speechSynthesis.speak(utter)
  }

  cancelSpeech() {
    if ("speechSynthesis" in window) window.speechSynthesis.cancel()
  }

  bestVoice() {
    const voices = window.speechSynthesis.getVoices()
    return (
      voices.find(v => v.lang === "en-GB" && !v.localService === false) ||
      voices.find(v => v.lang === "en-GB") ||
      voices.find(v => v.lang.startsWith("en")) ||
      null
    )
  }

  // ── Timer ─────────────────────────────────────────────────────────────────

  startTimer() {
    this.interval = setInterval(() => {
      if (this.paused) return
      this.timeLeft = Math.max(0, this.timeLeft - 1)
      this.updateRing()
      if (this.timeLeft === 0) {
        this.stopTimer()
        if (this.autoAdvanceValue) this.advance()
      }
    }, 1000)
  }

  stopTimer() {
    if (this.interval) {
      clearInterval(this.interval)
      this.interval = null
    }
  }

  updateRing() {
    if (this.hasTimerDisplayTarget) {
      this.timerDisplayTarget.textContent = this.timeLeft
    }
    if (this.hasTimerRingTarget) {
      const pct = this.secondsValue > 0 ? this.timeLeft / this.secondsValue : 0
      // stroke-dasharray="100", sweep from full (offset 0) to empty (offset 100)
      this.timerRingTarget.style.strokeDashoffset = ((1 - pct) * 100).toFixed(2)
    }
  }

  togglePause() {
    this.paused = !this.paused
    if (this.hasPauseBtnTarget) {
      this.pauseBtnTarget.textContent = this.paused ? "Resume" : "Pause"
    }
  }

  // ── Reveal ────────────────────────────────────────────────────────────────

  reveal() {
    if (this.revealed) return
    this.revealed = true

    this.answerSectionTarget.classList.remove("hidden")
    this.answerSectionTarget.classList.add("flex")

    // Pause the timer while the answer is on screen
    if (this.timedValue && !this.paused) {
      this.paused = true
      if (this.hasPauseBtnTarget) this.pauseBtnTarget.textContent = "Resume"
    }

    if (this.audioValue) {
      this.speak(this.answerSectionTarget.dataset.answer)
    }
  }

  // ── Advance ───────────────────────────────────────────────────────────────

  next(event) {
    event.preventDefault()
    this.advance()
  }

  advance() {
    this.stopTimer()
    this.cancelSpeech()
    if (this.hasOutcomeFieldTarget) {
      this.outcomeFieldTarget.value = this.revealed ? "revealed" : "skipped"
    }
    this.formTarget.requestSubmit()
  }
}
