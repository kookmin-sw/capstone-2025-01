import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["selectedCategory", "input"]

  connect() {
    this.selectedTabs = new Set()
    this.categoryButtons = this.element.querySelectorAll(".law-category-button")

    const urlParams = new URLSearchParams(window.location.search)
    const tabsFromUrl = urlParams.getAll("tab")

    if (!this.hasSelectedCategoryTarget) return

    tabsFromUrl.forEach(tab => {
      const button = Array.from(this.categoryButtons).find(btn => btn.dataset.tab === tab)
      if (button && !button.classList.contains("active")) {
        button.classList.add("active")
        this.selectedTabs.add(tab)

        const label = button.dataset.label?.trim() || button.textContent.trim()
        this.addTag(tab, label)
      }
    })

    this.categoryButtons.forEach(button => {
      button.addEventListener("click", this.toggleCategory.bind(this))
    })
  }

  toggleCategory(e) {
    e.preventDefault()
    const button = e.currentTarget
    const tab = button.dataset.tab
    const label = button.dataset.label?.trim() || button.textContent.trim()

    if (button.classList.contains("active")) {
      button.classList.remove("active")
      this.selectedTabs.delete(tab)
      this.removeTag(tab)
      return
    }

    button.classList.add("active")
    this.selectedTabs.add(tab)
    this.addTag(tab, label)
  }

  addTag(tab, label) {
    if (!this.hasSelectedCategoryTarget) return
    if (this.selectedCategoryTarget.querySelector(`[data-tab="${tab}"]`)) return

    const tag = document.createElement("div")
    tag.className = "selected-category-tag"
    tag.dataset.tab = tab
    tag.innerHTML = `
      <span class="remove-button" data-action="click->category-search#removeCategory" data-tab="${tab}">&times;</span>
      <span>${label}</span>
    `
    this.selectedCategoryTarget.insertBefore(tag, this.inputTarget)
  }

  removeTag(tab) {
    const tag = this.selectedCategoryTarget.querySelector(`.selected-category-tag[data-tab="${tab}"]`)
    if (tag) tag.remove()
  }

  removeCategory(e) {
    const tab = e.target.dataset.tab
    const button = Array.from(this.categoryButtons).find(btn => btn.dataset.tab === tab)
    if (button) button.classList.remove("active")
    this.removeTag(tab)
    this.selectedTabs.delete(tab)
  }

  goToSearch(e) {
    e.preventDefault()
    const query = this.inputTarget.value.trim()
    const baseUrl = "/bills"
    const params = new URLSearchParams()

    if (query) params.set("q", query)

    // Rails에서 배열로 인식되게 하기 위해 "tab[]" 사용
    this.selectedTabs.forEach(tab => {
      params.append("tab[]", tab)
    })

    // 디버깅용: 콘솔에서 확인하고 싶다면 이 줄 유지
    // console.log(params.toString())

    window.location.href = `${baseUrl}?${params.toString()}`
  }
}
