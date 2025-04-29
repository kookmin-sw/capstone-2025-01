// 반응형 ui를 위한 Stimulus 컨트롤러

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.checkScreenSize();
    window.addEventListener('resize', this.checkScreenSize.bind(this));
  }
  
  checkScreenSize() {
    const width = window.innerWidth;
    
    if (width < 768) {
      // 모바일 ui
      document.body.dataset.device = 'mobile';
    } else if (width < 1024) {
      // 태블릿 ui
      document.body.dataset.device = 'tablet';
    } else {
      // 데스크탑 ui
      document.body.dataset.device = 'desktop';
    }
  }
}
