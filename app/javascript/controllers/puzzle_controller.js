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
    this.elapsed  = 0
    this.paused   = false
    this.revealed = false

    if (this.audioValue) {
      setTimeout(() => this.speak(this.questionTarget.textContent.trim()), 400)
    }

    if (this.timedValue) {
      this.updateRing()
      this.startTimer()
    }

    this.startListening()
  }

  disconnect() {
    this.stopTimer()
    this.cancelSpeech()
    this.stopListening()
  }

  // ── Speech ────────────────────────────────────────────────────────────────

  speak(text) {
    if (!("speechSynthesis" in window)) return
    this.cancelSpeech()
    this.pauseListening()
    const utter = new SpeechSynthesisUtterance(text)
    utter.rate  = 0.92
    utter.pitch = 1.0
    const voice = this.bestVoice()
    if (voice) utter.voice = voice
    utter.onend = () => this.resumeListening()
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

  // ── Voice commands ────────────────────────────────────────────────────────

  startListening() {
    const SR = window.SpeechRecognition || window.webkitSpeechRecognition
    if (!SR) return

    this.listeningActive = true
    this.speechActive    = false
    this.recognition     = new SR()
    this.recognition.continuous     = true
    this.recognition.interimResults = false
    this.recognition.lang           = "en-GB"

    this.recognition.onresult = (event) => {
      const last = event.results[event.results.length - 1]
      if (!last.isFinal) return
      const t = last[0].transcript.trim().toLowerCase()
      if (t.includes("next"))   this.advance()
      else if (t.includes("answer")) this.reveal()
    }

    this.recognition.onerror = (event) => {
      if (event.error === "not-allowed" || event.error === "service-not-allowed") {
        this.listeningActive = false
      }
    }

    // Continuous mode still ends on silence on some browsers — restart automatically
    this.recognition.onend = () => {
      if (this.listeningActive && !this.speechActive) {
        try { this.recognition.start() } catch (_) {}
      }
    }

    try { this.recognition.start() } catch (_) {}
  }

  pauseListening() {
    this.speechActive = true
    if (this.recognition) {
      try { this.recognition.abort() } catch (_) {}
    }
  }

  resumeListening() {
    this.speechActive = false
    if (this.listeningActive && this.recognition) {
      try { this.recognition.start() } catch (_) {}
    }
  }

  stopListening() {
    this.listeningActive = false
    this.speechActive    = false
    if (this.recognition) {
      try { this.recognition.abort() } catch (_) {}
      this.recognition = null
    }
  }

  // ── Timer ─────────────────────────────────────────────────────────────────

  startTimer() {
    this.interval = setInterval(() => {
      if (this.paused) return
      this.elapsed += 1
      this.updateRing()
      if (this.elapsed >= this.secondsValue) {
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
      this.timerDisplayTarget.textContent = this.elapsed
    }
    if (this.hasTimerRingTarget) {
      const pct = this.secondsValue > 0 ? Math.min(this.elapsed / this.secondsValue, 1) : 0
      // stroke-dasharray="100", starts empty (offset 100) and fills as time passes (offset → 0)
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

  // ── Replay ────────────────────────────────────────────────────────────────

  replayQuestion() {
    if (!this.audioValue) return
    this.speak(this.questionTarget.textContent.trim())
  }

  replayAnswer() {
    if (!this.audioValue || !this.revealed) return
    this.speak(this.answerSectionTarget.dataset.answer)
  }

  // ── Advance ───────────────────────────────────────────────────────────────

  next(event) {
    event.preventDefault()
    this.advance()
  }

  advance() {
    this.stopTimer()
    this.cancelSpeech()
    this.stopListening()
    if (this.hasOutcomeFieldTarget) {
      this.outcomeFieldTarget.value = this.revealed ? "revealed" : "skipped"
    }
    this.formTarget.requestSubmit()
  }
}
