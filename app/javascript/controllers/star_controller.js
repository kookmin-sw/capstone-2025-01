import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { billId: String }

  connect() {
    const starred = this.loadStarredBills()
    const id = this.element.dataset.billId
    if (starred.includes(id)) {
      this.element.classList.add("active")
    }
  }

  toggle(e) {
    e.preventDefault()
    e.stopPropagation()

    const id = this.element.dataset.billId
    let starred = this.loadStarredBills()

    if (starred.includes(id)) {
      starred = starred.filter(i => i !== id)
      this.element.classList.remove("active")

      if (window.location.search.includes("starred=true")) {
        const card = this.element.closest(".bill-card")
        if (card) card.remove()
      }
    } else {
      starred.push(id)
      this.element.classList.add("active")
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
