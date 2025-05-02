import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    this.scrollSpeed = 8
  }

  startScrollLeft() {
    this.stopScroll()
    this.scrollInterval = setInterval(() => {
      this.containerTarget.scrollBy({ left: -this.scrollSpeed, behavior: "auto" })
    }, 10)
  }

  startScrollRight() {
    this.stopScroll()
    this.scrollInterval = setInterval(() => {
      this.containerTarget.scrollBy({ left: this.scrollSpeed, behavior: "auto" })
    }, 10)
  }

  stopScroll() {
    clearInterval(this.scrollInterval)
  }
}
