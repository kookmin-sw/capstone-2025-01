import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "dot", "pageCounter", "playPauseIcon"]

  connect() {
    this.detectDevice()
    this.cloneEdgeCards()

    const card = this.containerTarget.querySelector(".hot-issue-card")
    const gap = 30
    this.cardWidth = card ? card.offsetWidth + gap : 460

    this.totalSlides = this.containerTarget.children.length - 2 // 복제 카드 제외
    this.currentIndex = 0
    this.scrolling = false
    this.scrollAnimationId = null
    this.isAutoPlaying = false
    this.autoPlayInterval = null

    // 초기 위치: 첫 번째 진짜 카드
    this.containerTarget.scrollLeft = this.cardWidth

    this.updatePagination()
    this.addEventListeners()
  }

  disconnect() {
    this.removeEventListeners()
    this.stopAutoPlay()
  }

  detectDevice() {
    this.isMobile = window.innerWidth <= 768
  }

  addEventListeners() {
    this.boundOnScroll = this.onScroll.bind(this)
    this.boundOnResize = this.onResize.bind(this)
    this.boundOnKeydown = this.onKeydown.bind(this)
    this.boundWindowKeydown = (e) => {
      if (["ArrowLeft", "ArrowRight"].includes(e.key) &&
        document.activeElement !== this.containerTarget) {
        this.containerTarget.focus({ preventScroll: true })
      }
    }

    this.containerTarget.addEventListener("scroll", this.boundOnScroll)
    this.containerTarget.addEventListener("keydown", this.boundOnKeydown)
    window.addEventListener("keydown", this.boundWindowKeydown)
    window.addEventListener("resize", this.boundOnResize)
  }

  removeEventListeners() {
    this.containerTarget.removeEventListener("scroll", this.boundOnScroll)
    this.containerTarget.removeEventListener("keydown", this.boundOnKeydown)
    window.removeEventListener("keydown", this.boundWindowKeydown)
    window.removeEventListener("resize", this.boundOnResize)
  }

  onResize() {
    this.detectDevice()
    const card = this.containerTarget.querySelector(".hot-issue-card")
    this.cardWidth = card ? card.offsetWidth + (this.isMobile ? 0 : 30) : 460
    this.containerTarget.scrollLeft = (this.currentIndex + 1) * this.cardWidth
    this.updatePagination()
  }

  onScroll() {
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

  updatePagination() {
    if (this.hasDotTarget) {
      this.dotTargets.forEach((dot, index) => {
        const active = index === this.currentIndex
        dot.classList.toggle("active", active)
        dot.setAttribute("aria-current", active ? "true" : "false")
      })
    }

    if (this.hasPageCounterTarget) {
      this.pageCounterTarget.textContent = `${this.currentIndex + 1} / ${this.totalSlides}`
    }
  }

  onKeydown(event) {
    if (this.scrolling) return
    const direction = event.key === "ArrowRight" ? 1 : event.key === "ArrowLeft" ? -1 : 0
    if (direction !== 0) this.scrollToCard(direction)
  }

  startScrollLeft() {
    requestAnimationFrame(() => this.scrollToCard(-1))
  }

  startScrollRight() {
    requestAnimationFrame(() => this.scrollToCard(1))
  }

  scrollToCard(direction, duration = 500) {
    if (this.scrolling) return

    const targetIndex = Math.round(this.containerTarget.scrollLeft / this.cardWidth) + direction
    const targetScroll = targetIndex * this.cardWidth

    this.animateScroll(this.containerTarget.scrollLeft, targetScroll, duration)
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
      const ease = progress < 0.5
        ? 2 * progress * progress
        : -1 + (4 - 2 * progress) * progress

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

  cloneEdgeCards() {
    const children = this.containerTarget.children
    if (children.length < 1) return

    const firstCard = children[0].cloneNode(true)
    const lastCard = children[children.length - 1].cloneNode(true)

    firstCard.classList.add("hot-issue-card-clone")
    lastCard.classList.add("hot-issue-card-clone")

    this.containerTarget.insertBefore(lastCard, children[0])
    this.containerTarget.appendChild(firstCard)
  }

  toggleAutoPlay() {
    if (this.isAutoPlaying) {
      this.stopAutoPlay()
    } else {
      this.startAutoPlay()
    }
  }

  startAutoPlay() {
    this.isAutoPlaying = true
    this.autoPlayInterval = setInterval(() => {
      this.scrollToCard(1)
    }, 3500)

    if (this.hasPlayPauseIconTarget) {
      this.playPauseIconTarget.classList.add("playing")
    }
  }

  stopAutoPlay() {
    this.isAutoPlaying = false
    clearInterval(this.autoPlayInterval)

    if (this.hasPlayPauseIconTarget) {
      this.playPauseIconTarget.classList.remove("playing")
    }
  }

  stopScroll() {
    this.scrolling = false
  }
}
