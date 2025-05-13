import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "dot"]

  connect() {
    const card = this.containerTarget.querySelector(".hot-issue-card")
    const gap = 30
    this.cardWidth = card ? card.offsetWidth + gap : 460

    this.totalSlides = this.containerTarget.children.length
    this.dotCount = Math.min(this.totalSlides, 5)
    this.currentIndex = 0
    this.scrolling = false
    this.scrollAnimationId = null

    this.updateDots()
    this.addEventListeners()
  }

  disconnect() {
    this.removeEventListeners()
  }

  addEventListeners() {
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

  removeEventListeners() {
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
    this.scrollToCard(-1)
  }

  startScrollRight() {
    this.scrollToCard(1)
  }

  scrollToCard(direction, duration = 700) {
    if (this.scrolling) return

    const currentIndex = Math.round(this.containerTarget.scrollLeft / this.cardWidth)
    const targetIndex = Math.max(0, Math.min(currentIndex + direction, this.totalSlides - 1))
    const targetScroll = targetIndex * this.cardWidth
    const currentScroll = this.containerTarget.scrollLeft

    if (Math.abs(currentScroll - targetScroll) < 2) return // 이동할 필요 없음

    this.animateScroll(currentScroll, targetScroll, duration)
  }

  animateScroll(start, end, duration) {
    if (this.scrollAnimationId) {
      cancelAnimationFrame(this.scrollAnimationId)
    }

    this.scrolling = true
    const startTime = performance.now()

    const animate = (time) => {
      const elapsed = time - startTime
      const progress = Math.min(elapsed / duration, 1)
      const ease = 0.5 - Math.cos(progress * Math.PI) / 2
      this.containerTarget.scrollLeft = start + (end - start) * ease

      if (progress < 1) {
        this.scrollAnimationId = requestAnimationFrame(animate)
      } else {
        this.scrolling = false
        this.scrollAnimationId = null
        this.onScroll()
      }
    }

    this.scrollAnimationId = requestAnimationFrame(animate)
  }
}
