import { Controller } from "@hotwired/stimulus"

export class NoRedirectStrategy {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
  }
  onCategoryToggle(controller, event) {
    // 필터 UI만 갱신, URL 이동 없음
    controller.updateTagsDisplay();
    controller.updatePlaceholder();
    controller.updateURL(this.baseUrl);
    // URL 이동 없음
  }
}

export class RedirectStrategy {
  constructor(baseUrl) {
    this.baseUrl = baseUrl;
  }
  onCategoryToggle(controller, event) {
    // 필터 변경 시 URL 이동
    controller.updateTagsDisplay();
    controller.updatePlaceholder();
    controller.updateURL(this.baseUrl);
    controller.debouncedGoToSearch(event);
  }
}

export default class extends Controller {
  static targets = ["selectedCategory", "input"]

  connect() {
    // 카테고리 필터를 위한 디바운싱 타임아웃 오브젝트 설정
    this.debounceTimeout = null;
    // 디바운싱된 검색 메서드
    this.debouncedGoToSearch = this.debounce(this.goToSearch.bind(this), 500)

    // 전략 결정: 루트(/)면 NoRedirect, /bills면 Redirect
    let baseUrl = "/bills";
    if (window.location.pathname === "/") {
      baseUrl = "/";
      this.categoryStrategy = new NoRedirectStrategy(baseUrl);
    } else if (window.location.pathname.startsWith("/bills")) {
      this.categoryStrategy = new RedirectStrategy(baseUrl);
    } else {
      this.categoryStrategy = new NoRedirectStrategy(baseUrl); // 기본값
    }

    // 선택된 탭을 Set으로 관리
    this.selectedTabs = new Set()

    // URL에서 탭 파라미터를 가져옴
    const urlParams = new URLSearchParams(window.location.search)
    const tabsFromUrl = urlParams.getAll("tab[]") || []

    // 검색바가 없는 경우 종료
    if (!this.hasSelectedCategoryTarget) return

    // URL에 있는 탭 중 "all" 또는 "starred"는 제외하고 태그로 추가
    tabsFromUrl.forEach(tab => {
      if (["all", "starred"].includes(tab)) return
      this.selectedTabs.add(tab)
    })
    
    // 태그 표시 업데이트
    this.updateTagsDisplay()
    // placeholder 업데이트
    this.updatePlaceholder()
  }

  // Debounce utility
  debounce(func, wait) {
    // This method will now use `this.debounceTimeout` to store the timeout ID.
    // This makes the timeout ID accessible to other methods like disconnect().
    // Note: This assumes this specific `debounceTimeout` property is dedicated
    // to the single debounced function created in this controller.
    return (...args) => {
      clearTimeout(this.debounceTimeout)
      this.debounceTimeout = setTimeout(() => {
        func.apply(this, args)
      }, wait)
    }
  }

  disconnect() {
    if (this.debounceTimeout) {
      clearTimeout(this.debounceTimeout);
      this.debounceTimeout = null;
    }
  }

  toggleCategory(e) {
    e.preventDefault()
    const button = e.currentTarget
    const tab = button.dataset.tab

    if (button.classList.contains("active")) {
      // 이미 선택된 상태면 해제
      button.classList.remove("active")
      this.selectedTabs.delete(tab)
    } else {
      // "전체"나 "내 관심법안"이 선택된 상태라면 해제
      document.querySelectorAll(".law-category-button.active").forEach(btn => {
        const key = btn.dataset.tab
        if (["all", "starred"].includes(key)) {
          btn.classList.remove("active")
          this.selectedTabs.delete(key)
        }
      })

      // 선택된 탭 추가
      button.classList.add("active")
      this.selectedTabs.add(tab)
    }
    
    // 전략에 따라 동작 위임
    this.categoryStrategy.onCategoryToggle(this, e);
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

  // 모든 태그 표시 업데이트
  updateTagsDisplay() {
    if (!this.hasSelectedCategoryTarget) return
    
    // 기존 태그와 더보기 태그 모두 제거
    this.clearAllTags()
    
    // 선택된 탭이 없으면 종료 및 placeholder 업데이트
    if (this.selectedTabs.size === 0) return
    
    const tabsArray = Array.from(this.selectedTabs)
    
    // 지정된 개수만큼 태그 표시
    for (let i = 0; i < Math.min(1, tabsArray.length); i++) {
      const tab = tabsArray[i]
      const label = this.findLabelForTab(tab)
      if (label) this.createTagElement(tab, label)
    }
    
    // 더 보기 태그 추가 (남은 태그가 있는 경우)
    const remainingCount = tabsArray.length - 1
    if (remainingCount > 0) {
      this.addMoreTag(remainingCount)
    }

    // placeholder 업데이트
    this.updatePlaceholder()
  }
  
  // placeholder 업데이트
  updatePlaceholder() {
    if (this.selectedTabs.size > 0) {
      this.inputTarget.placeholder = ""
    } else {
      this.inputTarget.placeholder = "검색어를 입력해주세요"
    }
  }
  
  // 태그 요소 생성
  createTagElement(tab, label) {
    const tag = document.createElement("div")
    tag.className = "selected-category-tag"
    tag.dataset.tab = tab
    tag.innerHTML = `
      <span class="remove-button" data-action="click->category-search#removeCategory" data-tab="${tab}">&times;</span>
      <span>${label}</span>
    `
    this.selectedCategoryTarget.insertBefore(tag, this.inputTarget)
    return tag
  }
  
  // +N 태그 추가
  addMoreTag(count) {
    const moreTag = document.createElement("div")
    moreTag.className = "selected-category-tag more-count-tag"
    moreTag.innerHTML = `<span>+ ${count}</span>`
    moreTag.addEventListener('click', () => this.showAllTags())
    this.selectedCategoryTarget.insertBefore(moreTag, this.inputTarget)
  }
  
  // 모든 태그 보여주기
  showAllTags() {
    this.clearAllTags()
    
    // 모든 선택된 탭을 태그로 표시
    this.selectedTabs.forEach(tab => {
      const label = this.findLabelForTab(tab)
      if (label) this.createTagElement(tab, label)
    })
  }
  
  // 모든 태그 제거
  clearAllTags() {
    const existingTags = this.selectedCategoryTarget.querySelectorAll('.selected-category-tag')
    existingTags.forEach(tag => tag.remove())
  }

  // 태그 X 버튼을 눌렀을 때 해당 항목 제거
  removeCategory(e) {
    const tab = e.target.dataset.tab
    
    // 현재 컨트롤러 요소의 스코프 내에서만 버튼 찾기
    const container = this.element.closest('.mobile-only, .desktop-only, .home-category-search')
    const button = container.querySelector(`.law-category-button[data-tab="${tab}"]`)

    if (button) button.classList.remove("active")
    this.selectedTabs.delete(tab)
    
    this.categoryStrategy.onCategoryToggle(this, e);
  }

  // URL 업데이트 메서드
  updateURL(baseUrl) {
    const params = new URLSearchParams(window.location.search)
    
    // 기존 tab[] 파라미터 모두 제거
    params.delete("tab[]")
    
    // 배열로 전송
    if (this.selectedTabs.size >= 1) {
      this.selectedTabs.forEach(tab => params.append("tab[]", tab))
    }
    
    // 현재 페이지 유지하면서 URL만 업데이트
    const newUrl = `${baseUrl}?${params.toString()}`
    window.history.pushState({ path: newUrl }, '', newUrl)
  }

  goToSearch(e) {
    // 검색 버튼 클릭 시 선택된 탭과 검색어를 URL 파라미터로 설정하여 이동
    e.preventDefault()
    const query = this.inputTarget.value.trim()
    const baseUrl = "/bills"
    const params = new URLSearchParams()

    // 배열로 전송
    if (this.selectedTabs.size >= 1) {
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
