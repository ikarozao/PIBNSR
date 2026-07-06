(function() {
  const track = document.getElementById('carouselTrack');
  const dots = document.querySelectorAll('.dot');
  const prevBtn = document.getElementById('prevBtn');
  const nextBtn = document.getElementById('nextBtn');
  let currentIndex = 0;
  const totalSlides = dots.length;
  let autoInterval;

  function goToSlide(index) {
    if (index < 0) index = totalSlides - 1;
    if (index >= totalSlides) index = 0;
    currentIndex = index;
    track.style.transform = `translateX(-${currentIndex * 100}%)`;
    dots.forEach((dot, i) => {
      dot.classList.toggle('active', i === currentIndex);
    });
  }

  function nextSlide() {
    goToSlide(currentIndex + 1);
  }

  function prevSlide() {
    goToSlide(currentIndex - 1);
  }

  function startAuto() {
    if (autoInterval) clearInterval(autoInterval);
    autoInterval = setInterval(nextSlide, 5000);
  }

  function stopAuto() {
    if (autoInterval) {
      clearInterval(autoInterval);
      autoInterval = null;
    }
  }

  // Botões
  prevBtn.addEventListener('click', function() {
    stopAuto();
    prevSlide();
    startAuto();
  });

  nextBtn.addEventListener('click', function() {
    stopAuto();
    nextSlide();
    startAuto();
  });

  // Dots
  dots.forEach((dot) => {
    dot.addEventListener('click', function() {
      const index = parseInt(this.dataset.index, 10);
      stopAuto();
      goToSlide(index);
      startAuto();
    });
  });

  // Pausa no hover
  const carousel = document.getElementById('heroCarousel');
  carousel.addEventListener('mouseenter', stopAuto);
  carousel.addEventListener('mouseleave', startAuto);

  // Touch / Swipe
  let touchStartX = 0;
  let touchEndX = 0;
  track.addEventListener('touchstart', (e) => {
    touchStartX = e.changedTouches[0].screenX;
    stopAuto();
  });
  track.addEventListener('touchend', (e) => {
    touchEndX = e.changedTouches[0].screenX;
    const diff = touchStartX - touchEndX;
    if (Math.abs(diff) > 40) {
      if (diff > 0) {
        nextSlide();
      } else {
        prevSlide();
      }
    }
    startAuto();
  });

  // Inicia
  goToSlide(0);
  startAuto();
})();