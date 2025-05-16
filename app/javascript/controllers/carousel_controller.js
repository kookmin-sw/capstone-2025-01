import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "dot", "pageCounter", "playPauseIcon"]

  connect() {
    this.isMobile = window.innerWidth <= 768
    this.cardWidth = 0
    this.totalSlides = 0
    this.currentIndex = 0
    this.scrolling = false
    this.scrollAnimationId = null
    this.isAutoPlaying = false
    this.autoPlayInterval = null

    this.updateCardMetrics()
    this.containerTarget.scrollLeft = 0  // 첫 카드로 고정
    this.updatePagination()
    this.addEventListeners()

    if (this.isMobile) {
      this.startAutoPlay()
      this.addSwipeListeners()
    } else {
      this.updatePlayPauseIcon(false)
      this.containerTarget.setAttribute("tabindex", "0")
      setTimeout(() => {
        this.containerTarget.focus({ preventScroll: true })
      }, 100)
    }
  }

  updateCardMetrics() {
    const card = this.containerTarget.querySelector(".hot-issue-card")
    if (!card) return;

    const style = window.getComputedStyle(card)
    const marginRight = parseInt(style.marginRight || 0, 10)
    const marginLeft = parseInt(style.marginLeft || 0, 10)
    const gap = marginRight + marginLeft

    this.cardWidth = card.offsetWidth + gap
    this.totalSlides = this.containerTarget.querySelectorAll(".hot-issue-card").length
  }

  addEventListeners() {
    this.containerTarget.addEventListener("scroll", this.onScroll.bind(this))
    this.containerTarget.addEventListener("keydown", this.onKeydown.bind(this))
    this.containerTarget.addEventListener("mousedown", () => {
      this.containerTarget.focus({ preventScroll: true })
    })
  }

  onScroll() {
    if (this.scrolling) return

    const index = Math.round(this.containerTarget.scrollLeft / this.cardWidth)
    this.currentIndex = Math.min(index, this.totalSlides - 1)
    this.updatePagination()
  }

  scrollToIndex(index, duration = 500) {
    if (this.scrolling) return
    index = Math.max(0, Math.min(index, this.totalSlides - 1))  // 범위 제한

    const targetScroll = index * this.cardWidth
    this.animateScroll(this.containerTarget.scrollLeft, targetScroll, duration)
  }

  animateScroll(start, end, duration) {
    if (this.scrollAnimationId) cancelAnimationFrame(this.scrollAnimationId)
    this.scrolling = true
    const startTime = performance.now()

    const animate = (time) => {
      const progress = Math.min((time - startTime) / duration, 1)
      const ease = progress < 0.5 ? 2 * progress * progress : -1 + (4 - 2 * progress) * progress
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

  startScrollLeft() {
    this.scrollToIndex(this.currentIndex - 1)
  }

  startScrollRight() {
    this.scrollToIndex(this.currentIndex + 1)
  }

  onKeydown(e) {
    if (e.key === "ArrowLeft") this.startScrollLeft()
    if (e.key === "ArrowRight") this.startScrollRight()
  }

  updatePagination() {
    if (this.hasDotTarget && !this.isMobile) {
      this.dotTargets.forEach((dot, i) => {
        const active = i === this.currentIndex
        dot.classList.toggle("active", active)
        dot.setAttribute("aria-current", active ? "true" : "false")
      })
    }

    if (this.hasPageCounterTarget) {
      const current = Math.min(this.currentIndex + 1, this.totalSlides)
      this.pageCounterTarget.textContent = `${current} / ${this.totalSlides}`
    }
  }

  toggleAutoPlay() {
    this.isAutoPlaying ? this.stopAutoPlay() : this.startAutoPlay()
  }

  startAutoPlay() {
    this.isAutoPlaying = true
    this.autoPlayInterval = setInterval(() => {
      this.scrollToIndex(this.currentIndex + 1)
    }, 3000)
    this.updatePlayPauseIcon(true)
  }

  stopAutoPlay() {
    this.isAutoPlaying = false
    clearInterval(this.autoPlayInterval)
    this.updatePlayPauseIcon(false)
  }

  updatePlayPauseIcon(isPlaying) {
    const playIcon = this.playPauseIconTarget?.querySelector(".play-icon")
    const pauseIcon = this.playPauseIconTarget?.querySelector(".pause-icon")

    if (!playIcon || !pauseIcon) return

    playIcon.style.display = isPlaying ? "none" : "inline"
    pauseIcon.style.display = isPlaying ? "inline" : "none"
  }

  addSwipeListeners() {
    let startX = 0
    this.containerTarget.addEventListener("touchstart", (e) => {
      startX = e.touches[0].clientX
    })
    this.containerTarget.addEventListener("touchend", (e) => {
      const endX = e.changedTouches[0].clientX
      const diff = endX - startX

      if (Math.abs(diff) > 50 && !this.scrolling) {
        diff > 0 ? this.startScrollLeft() : this.startScrollRight()
      }
    })
  }

  focusContainer() {
    this.containerTarget.focus({ preventScroll: true })
  }
}
