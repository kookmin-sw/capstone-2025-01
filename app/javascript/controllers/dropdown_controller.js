import { Controller } from "@hotwired/stimulus"

// 배너 버튼(알림, 프로필) 드롭다운 컨트롤러
export default class extends Controller {
  static targets = ["button", "notificationMenu", "profileMenu", "settingsSubmenu", "settingsItem"]
  
  connect() {
    this.clickOutsideHandler = this.clickOutside.bind(this)
    document.addEventListener("click", this.clickOutsideHandler)
  }
  
  disconnect() {
    document.removeEventListener("click", this.clickOutsideHandler)
  }
  
  // 드롭다운 메뉴 토글 로직
  toggleMenu(currentMenu, otherMenu) {
    otherMenu.classList.remove("show")
    currentMenu.classList.toggle("show")
    // 설정 서브메뉴 닫기
    this.closeAllSubmenus()
  }
  
  toggleNotification(event) {
    event.stopPropagation()
    this.toggleMenu(this.notificationMenuTarget, this.profileMenuTarget)
  }
  
  toggleProfile(event) {
    event.stopPropagation()
    this.toggleMenu(this.profileMenuTarget, this.notificationMenuTarget)
  }

  // 설정 아이템 클릭 시 하위 드롭다운 토글
  toggleSettings(event) {
    event.stopPropagation(); 
    this.settingsSubmenuTarget.classList.toggle("show");
  }

  // 모든 하위 드롭다운 닫기
  closeAllSubmenus() {
    this.settingsSubmenuTarget.classList.remove("show");
  }

  // 드롭다운 메뉴 닫기
  closeAllMenus() {
    this.closeAllSubmenus();
    this.notificationMenuTarget.classList.remove("show")
    this.profileMenuTarget.classList.remove("show")
  }
    
  // 드롭다운 밖 영역 클릭 시
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.closeAllMenus()
    }
  }
  
  // 알림 설정 토글 스위치 처리
  toggleNotificationSetting(event) {
    event.stopPropagation(); 
  }
}