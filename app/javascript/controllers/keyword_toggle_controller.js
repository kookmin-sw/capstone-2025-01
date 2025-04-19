document.addEventListener("turbo:load", () => {
    const trendingBox = document.getElementById("trendingKeywords");
    const urlParams = new URLSearchParams(window.location.search);
    const selectedTab = urlParams.get("tab");
  
    if (trendingBox && selectedTab && selectedTab !== "all") {
      trendingBox.classList.add("show-keywords");
    }
  });  
  