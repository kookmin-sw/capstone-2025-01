import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]

  connect() {
    const starred = this.loadStarredBills()

    // 아이콘 초기 상태 적용
    this.iconTargets.forEach(icon => {
      const id = icon.dataset.billId
      if (starred.includes(id)) {
        icon.classList.add("active")
      }
    })

    // URL이 starred=true일 경우 → 쿠키 동기화
    const url = new URL(window.location.href)
    const isStarredView = url.searchParams.get("starred") === "true"

    if (isStarredView) {
      this.syncCookie(starred)
    }
  }

  toggle(e) {
    e.preventDefault()
    e.stopPropagation()

    const icon = e.currentTarget
    const id = icon.dataset.billId
    let starred = this.loadStarredBills()

    if (starred.includes(id)) {
      starred = starred.filter(i => i !== id)
      icon.classList.remove("active")

      // "내 관심 법안" 페이지에서는 바로 카드 제거
      if (window.location.search.includes("starred=true")) {
        const card = icon.closest(".bill-card")
        if (card) card.remove()
      }

    } else {
      starred.push(id)
      icon.classList.add("active")
    }

    localStorage.setItem("starredBills", JSON.stringify(starred))
    this.syncCookie(starred)
  }

  loadStarredBills() {
    return JSON.parse(localStorage.getItem("starredBills") || "[]").map(String)
  }

  syncCookie(starredList) {
    document.cookie = `starred_bill_ids=${JSON.stringify(starredList)}; path=/`
  }
}
