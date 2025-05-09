// 법안 상세페이지 더보기 기능을 위한 아코디언 Stimulus 컨트롤러

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]

  connect() {
    // 초기 상태는 닫혀있음
    this.isOpen = false
    const style = getComputedStyle(this.contentTarget)
    const previewHeightValue = style.getPropertyValue("--preview-height").trim()
    this.previewHeight = previewHeightValue || "0px" // Fallback to "0px" if --preview-height is not defined
  }

  toggle() {
    this.isOpen = !this.isOpen
    this.element.classList.toggle('is-open', this.isOpen)
    if (this.isOpen) {
      // 열기
      this.contentTarget.style.maxHeight = `${this.contentTarget.scrollHeight}px`
      this.contentTarget.style.overflow = "visible" 
      this.iconTarget.classList.add("rotate-270")
    } else {
      // 닫기: 미리보기 높이로 설정
      this.contentTarget.style.maxHeight = this.previewHeight
      this.contentTarget.style.overflow = "hidden" 
      this.iconTarget.classList.remove("rotate-270")
    }
  }
}
