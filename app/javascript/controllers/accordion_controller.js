// 법안 상세페이지 더보기 기능을 위한 아코디언 Stimulus 컨트롤러

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]

  connect() {
    // 초기 상태는 닫혀있음
    this.isOpen = false
    this.contentTarget.style.maxHeight = "0"
    this.contentTarget.style.overflow = "hidden"
  }

  toggle() {
    this.isOpen = !this.isOpen
    
    if (this.isOpen) {
      // 열기
      this.contentTarget.style.maxHeight = `${this.contentTarget.scrollHeight}px`
      this.contentTarget.style.overflow = "visible" 
      this.iconTarget.classList.add("rotate-270")
    } else {
      // 닫기
      this.contentTarget.style.maxHeight = "0"
      this.contentTarget.style.overflow = "hidden" 
      this.iconTarget.classList.remove("rotate-270")
    }
  }
}
