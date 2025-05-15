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
    this.forceScroll = false

    this.cloneEdgeCards()
    this.updateCardMetrics()
    this.containerTarget.scrollLeft = this.cardWidth
    this.updatePagination()
    this.addEventListeners()

    if (this.isMobile) {
      this.startAutoPlay()
      this.addSwipeListeners()
    } else {
      this.updatePlayPauseIcon(false)
      this.containerTarget.setAttribute("tabindex", "0")
      setTimeout(() => {
        this.containerTarget.focus({ preventScroll: true })  // ✅ 키보드 ← → 조작용
      }, 100)
    }
  }

  cloneEdgeCards() {
    const cards = [...this.containerTarget.children]
    if (cards.length === 0) return

    const first = cards[0].cloneNode(true)
    const last = cards[cards.length - 1].cloneNode(true)
    first.classList.add("hot-issue-card-clone")
    last.classList.add("hot-issue-card-clone")
    this.containerTarget.insertBefore(last, cards[0])
    this.containerTarget.appendChild(first)
  }

  updateCardMetrics() {
    const card = this.containerTarget.querySelector(".hot-issue-card:not(.hot-issue-card-clone)")
    const gap = this.isMobile ? 0 : 30
    this.cardWidth = card ? card.offsetWidth + gap : 460
    this.totalSlides = [...this.containerTarget.children].filter(el => !el.classList.contains("hot-issue-card-clone")).length
  }

  addEventListeners() {
    this.containerTarget.addEventListener("scroll", this.onScroll.bind(this))
    this.containerTarget.addEventListener("keydown", this.onKeydown.bind(this))

    // 마우스로 조작 시 포커스 다시 잡기
    this.containerTarget.addEventListener("mousedown", () => {
      this.containerTarget.focus({ preventScroll: true })
    })
  }

  onScroll() {
    if (this.scrolling) return

    const index = Math.round(this.containerTarget.scrollLeft / this.cardWidth)

    if (index === 0) {
      this.containerTarget.scrollLeft = this.totalSlides * this.cardWidth
      this.currentIndex = this.totalSlides - 1
    } else if (index === this.totalSlides + 1) {
      this.containerTarget.scrollLeft = this.cardWidth
      this.currentIndex = 0
    } else {
      this.currentIndex = index - 1
    }

    this.updatePagination()
  }

  scrollToIndex(index, duration = 500) {
    if (this.scrolling) return 

    const targetScroll = (index + 1) * this.cardWidth
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
    this.scrollToIndex((this.currentIndex - 1 + this.totalSlides) % this.totalSlides)
  }

  startScrollRight() {
    this.scrollToIndex((this.currentIndex + 1) % this.totalSlides)
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
      this.scrollToIndex((this.currentIndex + 1) % this.totalSlides)
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
