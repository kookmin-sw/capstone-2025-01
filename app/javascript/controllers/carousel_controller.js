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

  bindEvents() {
    this.containerTarget.addEventListener("scroll", this.onScroll.bind(this))
    this.containerTarget.addEventListener("keydown", this.onKeydown.bind(this))

    window.addEventListener("keydown", (e) => {
      if (["ArrowLeft", "ArrowRight"].includes(e.key) &&
          document.activeElement !== this.containerTarget) {
        this.containerTarget.focus({ preventScroll: true })
      }
    })
  }

  onScroll() {
    const scrollLeft = this.containerTarget.scrollLeft
    const maxScroll = this.containerTarget.scrollWidth - this.containerTarget.clientWidth
    const ratio = scrollLeft / maxScroll
    this.currentIndex = Math.round(ratio * (this.dotCount - 1))
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
    const target = Math.max(
      0,
      Math.min(this.containerTarget.scrollLeft + direction * this.cardWidth,
               this.containerTarget.scrollWidth)
    )
    this.animateScroll(this.containerTarget.scrollLeft, target, duration)
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
