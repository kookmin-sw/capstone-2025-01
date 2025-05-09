import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggleMenu() {
    this.menuTarget.hidden = !this.menuTarget.hidden
  }

  copy() {
    navigator.clipboard.writeText(window.location.href)
      .then(() => alert("링크가 복사되었습니다!"))
      .catch(() => alert("복사 실패"))
  }

  nativeShare() {
    if (navigator.share) {
      navigator.share({
        title: document.title,
        url: window.location.href
      }).catch(() => alert("공유 취소됨"))
    } else {
      alert("이 브라우저는 공유 기능을 지원하지 않습니다.")
    }
  }

  shareToX() {
    const url = encodeURIComponent(window.location.href)
    window.open(`https://x.com/intent/tweet?url=${url}`, "_blank")
  }

  shareToFacebook() {
    const url = encodeURIComponent(window.location.href)
    window.open(`https://www.facebook.com/sharer/sharer.php?u=${url}`, "_blank")
  }

  shareToInstagram() {
    alert("인스타그램은 웹 공유 URL 기능이 제한되어 있습니다.\n스토리에 공유하려면 모바일 앱을 사용해주세요.")
    // 또는 자신의 계정 링크로 이동:
    // window.open("https://www.instagram.com/yourprofile/", "_blank")
  }

  shareToKakao() {
    if (!window.Kakao || !Kakao.isInitialized()) {
      alert("카카오 SDK가 초기화되지 않았습니다.")
      return
    }

    Kakao.Share.sendDefault({
      objectType: 'feed',
      content: {
        title: document.title,
        description: "법안 공유",
        imageUrl: "https://yourdomain.com/share-thumbnail.png",
        link: {
          mobileWebUrl: window.location.href,
          webUrl: window.location.href
        }
      },
      buttons: [
        {
          title: "보러 가기",
          link: {
            mobileWebUrl: window.location.href,
            webUrl: window.location.href
          }
        }
      ]
    })
  }
}

