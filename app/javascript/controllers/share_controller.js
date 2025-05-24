import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu" , "linkText"]

  connect() {
    this.clickOutsideHandler = this.clickOutside.bind(this)
    document.addEventListener("click", this.clickOutsideHandler)
    // 컨트롤러가 연결되면 현재 URL 표시
    this.linkTextTarget.textContent = window.location.href
  }

  disconnect() {
    document.removeEventListener("click", this.clickOutsideHandler)
  }

  // 드롭다운 밖 영역 클릭 시
  clickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.remove("show")
    }
  }

  // 공유 메뉴 닫기
  closeMenu() {
    this.menuTarget.classList.remove("show")
  }

  // 공유 메뉴 토글
  toggleMenu() {
    this.menuTarget.classList.toggle("show")
  }

  // 현재 URL 복사
  copy() {
    navigator.clipboard.writeText(window.location.href)
      .then(() => this.showToast("링크를 클립보드에 복사했습니다."))
      .catch(() => this.showToast("링크를 복사할 수 없습니다."))
  }

  // 복사 후 토스트 메시지 표시
  showToast(message) {
    const toast = document.createElement('div');
    toast.textContent = message;
    
    Object.assign(toast.style, {
        position: 'fixed',
        bottom: '20px',
        left: '20px',
        background: '#000000',
        color: 'white',
        padding: '10px 24px',
        borderRadius: '8px',
        boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
        zIndex: '10000',
        fontSize: '18px',
        transform: 'translateY(100%)',
        transition: 'transform 0.3s ease-in-out',
    });
    
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.style.transform = 'translateY(0)';
    }, 5);
    
    setTimeout(() => {
        toast.style.transform = 'translateY(100%)';
        setTimeout(() => {
            if (document.body.contains(toast)) {
                document.body.removeChild(toast);
            }
        }, 300);
    }, 3000);
  }

  // 네이티브 공유
  nativeShare() {
    if (navigator.share) {
      navigator.share({
        title: document.title,
        url: window.location.href
      }).catch(() => alert("공유가 취소되었습니다."))
    } else {
      alert("이 브라우저는 공유 기능을 지원하지 않습니다.")
    }
  }

  // 소셜 미디어 공유
  shareToX() {
    const url = encodeURIComponent(window.location.href)
    window.open(`https://x.com/intent/tweet?url=${url}`, "_blank")
  }

  shareToFacebook() {
    const url = encodeURIComponent(window.location.href)
    window.open(`https://www.facebook.com/sharer/sharer.php?u=${url}`, "_blank")
  }

  shareToKakao() {
    if (!window.Kakao || !Kakao.isInitialized()) {
      alert("카카오 SDK가 초기화되지 않았습니다.")
      return
    }

   // TODO: 카카오톡 공유 기능 구현
    // Kakao.Share.sendDefault({
    //   objectType: 'feed',
    //   content: {
    //     title: document.title,
    //     description: "법안 공유",
    //     imageUrl: "https://yourdomain.com/share-thumbnail.png",
    //     link: {
    //       mobileWebUrl: window.location.href,
    //       webUrl: window.location.href
    //     }
    //   },
    //   buttons: [
    //     {
    //       title: "보러 가기",
    //       link: {
    //         mobileWebUrl: window.location.href,
    //         webUrl: window.location.href
    //       }
    //     }
    //   ]
    // })
  }
}
