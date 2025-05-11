import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "dot"]

  connect() {
    this.cardWidth = 430
    this.totalSlides = this.containerTarget.children.length
    this.dotCount = Math.min(this.totalSlides, 5)
    this.currentIndex = 0
    this.scrolling = false

    this.updateDots()
    this.bindEvents()
  }

  // 이벤트 핸들러를 변수에 저장해서 remove 가능하도록
  bindEvents() {
    this.boundOnScroll = this.onScroll.bind(this)
    this.boundOnKeydown = this.onKeydown.bind(this)
    this.boundWindowKeydown = (e) => {
      if (
        ["ArrowLeft", "ArrowRight"].includes(e.key) &&
        document.activeElement !== this.containerTarget
      ) {
        this.containerTarget.focus({ preventScroll: true })
      }
    }

    this.containerTarget.addEventListener("scroll", this.boundOnScroll)
    this.containerTarget.addEventListener("keydown", this.boundOnKeydown)
    window.addEventListener("keydown", this.boundWindowKeydown)
  }

  // Stimulus가 DOM에서 제거될 때 clean-up
  disconnect() {
    this.containerTarget.removeEventListener("scroll", this.boundOnScroll)
    this.containerTarget.removeEventListener("keydown", this.boundOnKeydown)
    window.removeEventListener("keydown", this.boundWindowKeydown)
  }

  onScroll() {
    const scrollLeft = this.containerTarget.scrollLeft
    const maxScroll = this.containerTarget.scrollWidth - this.containerTarget.clientWidth
    const ratio = scrollLeft / maxScroll
    this.currentIndex = Math.min(this.dotCount - 1, Math.round(ratio * (this.dotCount - 1)))
    this.updateDots()
  }

  updateDots() {
    this.dotTargets.forEach((dot, index) => {
      const active = index === this.currentIndex
      dot.classList.toggle("active", active)
      dot.setAttribute("aria-current", active ? "true" : "false")
    })
  }

  onKeydown(event) {
    if (this.scrolling) return
    const direction = event.key === "ArrowRight" ? 1 : event.key === "ArrowLeft" ? -1 : 0
    if (direction !== 0) this.scrollToCard(direction)
  }

  startScrollLeft() {
    if (!this.scrolling) this.scrollToCard(-1)
  }

  startScrollRight() {
    if (!this.scrolling) this.scrollToCard(1)
  }

  scrollToCard(direction, duration = 700) {
    const start = this.containerTarget.scrollLeft
    const target = Math.max(
      0,
      Math.min(start + direction * this.cardWidth, this.containerTarget.scrollWidth)
    )
    this.animateScroll(start, target, duration)
  }

  animateScroll(start, end, duration) {
    this.scrolling = true
    const startTime = performance.now()

    const animate = (time) => {
      const elapsed = time - startTime
      const progress = Math.min(elapsed / duration, 1)
      const ease = 0.5 - Math.cos(progress * Math.PI) / 2
      this.containerTarget.scrollLeft = start + (end - start) * ease

      if (progress < 1) {
        requestAnimationFrame(animate)
      } else {
        this.scrolling = false
        this.onScroll()
      }
    }

    requestAnimationFrame(animate)
  }
}
