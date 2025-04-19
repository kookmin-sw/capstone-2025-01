export function scrollHotIssue(direction) {
    const container = document.getElementById('hot-issue-slider');
    const scrollAmount = 530;
    if (container) {
      container.scrollBy({ left: direction * scrollAmount, behavior: 'smooth' });
    }
  }
