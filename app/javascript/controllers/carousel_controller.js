import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "dot"]

  connect() {
    // 스크롤 이동 속도 설정
    this.scrollSpeed = 8

    // 현재 선택된 인디케이터 인덱스 (0~2)
    this.currentIndex = 0

    // Stimulus가 초기화된 직후 dot 표시 업데이트
    setTimeout(() => this.updateDots(), 50)

    // 스크롤 이벤트 리스너 등록
    this.containerTarget.addEventListener("scroll", this.onScroll.bind(this))
  }

  // 스크롤 시 인디케이터 위치 업데이트
  onScroll() {
    const container = this.containerTarget
    const scrollLeft = container.scrollLeft
    const maxScroll = container.scrollWidth - container.clientWidth

    // 스크롤 가능한 영역이 없으면 종료
    if (maxScroll <= 0) return

    // 전체 너비에서 현재 스크롤 비율 계산 (0~1)
    const ratio = scrollLeft / maxScroll

    // 비율을 기준으로 현재 인디케이터 인덱스 계산 (최대 2)
    this.currentIndex = Math.min(2, Math.floor(ratio * 3))

    // 인디케이터 상태 갱신
    this.updateDots()
  }

  // 왼쪽 방향으로 자동 스크롤 시작
  startScrollLeft() {
    this.stopScroll()
    this.scrollInterval = setInterval(() => {
      this.containerTarget.scrollBy({ left: -this.scrollSpeed, behavior: "auto" })
      this.onScroll()
    }, 10)
  }

  // 오른쪽 방향으로 자동 스크롤 시작
  startScrollRight() {
    this.stopScroll()
    this.scrollInterval = setInterval(() => {
      this.containerTarget.scrollBy({ left: this.scrollSpeed, behavior: "auto" })
      this.onScroll()
    }, 10)
  }

  // 자동 스크롤 중단
  stopScroll() {
    clearInterval(this.scrollInterval)
    this.onScroll()
  }

  // 인디케이터 상태를 현재 인덱스에 따라 갱신
  updateDots() {
    this.dotTargets.forEach((dot, index) => {
      dot.classList.toggle("active", index === this.currentIndex)
    })
  }
}
