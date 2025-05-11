import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["selectedCategory", "input"]

  connect() {
    // 선택된 탭을 Set으로 관리
    this.selectedTabs = new Set()

    // URL에서 탭 파라미터를 가져옴
    const urlParams = new URLSearchParams(window.location.search)
    const tabsFromUrl = urlParams.getAll("tab") || []

    // 검색바가 없는 경우 종료
    if (!this.hasSelectedCategoryTarget) return

    // URL에 있는 탭 중 "all" 또는 "starred"는 제외하고 태그로 추가
    tabsFromUrl.forEach(tab => {
      if (["all", "starred"].includes(tab)) return
      this.selectedTabs.add(tab)
      const label = this.findLabelForTab(tab)
      if (label) this.addTag(tab, label)
    })
  }

  toggleCategory(e) {
    e.preventDefault()
    const button = e.currentTarget
    const tab = button.dataset.tab
    const label = button.dataset.label?.trim() || button.textContent.trim()

    if (button.classList.contains("active")) {
      // 이미 선택된 상태면 해제
      button.classList.remove("active")
      this.selectedTabs.delete(tab)
      this.removeTag(tab)
    } else {
      // "전체"나 "내 관심법안"이 선택된 상태라면 해제
      document.querySelectorAll(".law-category-button.active").forEach(btn => {
        const key = btn.dataset.tab
        if (["all", "starred"].includes(key)) {
          btn.classList.remove("active")
          this.selectedTabs.delete(key)
          this.removeTag(key)
        }
      })

      // 선택된 탭 추가 및 태그 표시
      button.classList.add("active")
      this.selectedTabs.add(tab)
      this.addTag(tab, label)
    }
  }

  submitSingleTab(e) {
    e.preventDefault()
    const tab = e.currentTarget.dataset.tab
  
    this.selectedTabs.clear()
  
    const baseUrl = "/bills"
  
    // 전체 탭일 경우 쿼리스트링 없이 이동
    if (tab === "all") {
      window.location.href = baseUrl
      return
    }
  
    // 관심법안은 별도 처리
    if (tab === "starred") {
      window.location.href = `${baseUrl}?starred=true`
      return
    }
  
    const params = new URLSearchParams()
    params.set("tab", tab)
    window.location.href = `${baseUrl}?${params.toString()}`
  }  

  addTag(tab, label) {
    if (!this.hasSelectedCategoryTarget) return

    // 이미 해당 태그가 표시되어 있다면 중복 추가하지 않음
    if (this.selectedCategoryTarget.querySelector(`[data-tab="${tab}"]`)) return

    // 태그 요소 생성 및 검색바에 추가
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
    // 특정 탭에 해당하는 태그를 검색바에서 제거
    const tag = this.selectedCategoryTarget.querySelector(`.selected-category-tag[data-tab="${tab}"]`)
    if (tag) tag.remove()
  }

  removeCategory(e) {
    // 태그에 있는 X 버튼을 눌렀을 때 해당 항목 제거
    const tab = e.target.dataset.tab
    const button = document.querySelector(`.law-category-button[data-tab="${tab}"]`)
    if (button) button.classList.remove("active")
    this.removeTag(tab)
    this.selectedTabs.delete(tab)
  }

  goToSearch(e) {
    // 검색 버튼 클릭 시 선택된 탭과 검색어를 URL 파라미터로 설정하여 이동
    e.preventDefault()
    const query = this.inputTarget.value.trim()
    const baseUrl = "/bills"
    const params = new URLSearchParams()

    // 선택된 탭이 1개면 단일 값으로 전송
    if (this.selectedTabs.size === 1) {
      const only = Array.from(this.selectedTabs)[0]
      params.set("tab", only)
    } 
    // 2개 이상이면 배열로 전송
    else if (this.selectedTabs.size > 1) {
      this.selectedTabs.forEach(tab => params.append("tab[]", tab))
    }

    // 검색어가 있다면 함께 전송
    if (query) params.set("q", query)

    // 최종 URL로 이동
    window.location.href = `${baseUrl}?${params.toString()}`
  }

  findLabelForTab(tab) {
    // 탭에 해당하는 버튼을 찾아 라벨 텍스트를 반환
    const button = document.querySelector(`.law-category-button[data-tab="${tab}"]`)
    return button?.dataset.label?.trim() || button?.textContent.trim()
  }
}
