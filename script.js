// Utilidades de optimización
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

function throttle(func, limit) {
    let inThrottle;
    return function(...args) {
        if (!inThrottle) {
            func.apply(this, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

// Smooth scrolling para los enlaces de navegación
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            const nav = document.querySelector('nav');
            const navHeight = nav ? nav.offsetHeight : 0;
            const targetTop = target.getBoundingClientRect().top + window.pageYOffset - navHeight - 12;

            window.scrollTo({
                top: targetTop,
                behavior: 'smooth'
            });
        }
    });
});

// Efecto parallax en hero (throttled para mejor performance)
const handleParallax = throttle(() => {
    const scrolled = window.pageYOffset;
    const hero = document.querySelector('.hero-content');
    if (hero && scrolled < window.innerHeight) {
        requestAnimationFrame(() => {
            hero.style.transform = `translateY(${scrolled * 0.5}px)`;
            hero.style.opacity = 1 - (scrolled / 600);
        });
    }
}, 16); // ~60fps

window.addEventListener('scroll', handleParallax, { passive: true });

// Animación de hover 3D para tarjetas de libros (optimizada)
document.querySelectorAll('.libro-card').forEach(card => {
    let rafId = null;
    
    card.addEventListener('mousemove', (e) => {
        if (rafId) return;
        
        rafId = requestAnimationFrame(() => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            const centerX = rect.width / 2;
            const centerY = rect.height / 2;
            
            const rotateX = (y - centerY) / 10;
            const rotateY = (centerX - x) / 10;
            
            card.style.transform = `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateY(-6px)`;
            rafId = null;
        });
    });
    
    card.addEventListener('mouseleave', () => {
        if (rafId) {
            cancelAnimationFrame(rafId);
            rafId = null;
        }
        card.style.transform = 'perspective(1000px) rotateX(0) rotateY(0) translateY(0)';
    });
});

// Contador animado para premios
function animateCounter(element, target, duration = 2000) {
    let startTime = null;
    const startValue = 0;
    
    function animation(currentTime) {
        if (!startTime) startTime = currentTime;
        const progress = Math.min((currentTime - startTime) / duration, 1);
        
        const value = Math.floor(progress * (target - startValue) + startValue);
        element.textContent = value.toLocaleString();
        
        if (progress < 1) {
            requestAnimationFrame(animation);
        } else {
            element.textContent = target.toLocaleString();
        }
    }
    
    requestAnimationFrame(animation);
}

// Animación de aparición al hacer scroll
const observerOptions = {
    threshold: 0.15,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('animate-in');
            
            // Si es una sección de premios, animar los números
            if (entry.target.classList.contains('premios-section')) {
                const copiesElement = entry.target.querySelector('.premio-desc');
                if (copiesElement && copiesElement.textContent.includes('500,000')) {
                    setTimeout(() => {
                        const tempText = copiesElement.textContent;
                        copiesElement.textContent = '';
                        animateCounter(copiesElement, 500000);
                        setTimeout(() => {
                            copiesElement.textContent = tempText;
                        }, 2000);
                    }, 300);
                }
            }
            
            observer.unobserve(entry.target);
        }
    });
}, observerOptions);

// Observar secciones para animación
document.querySelectorAll('section').forEach(section => {
    observer.observe(section);
});

// Efecto de cursor personalizado solo en elementos interactivos (optimizado)
const cursor = document.createElement('div');
cursor.classList.add('custom-cursor');
document.body.appendChild(cursor);

let mouseX = 0, mouseY = 0;
let cursorX = 0, cursorY = 0;

// Usar throttle para mousemove
const handleMouseMove = throttle((e) => {
    mouseX = e.clientX;
    mouseY = e.clientY;
}, 16);

document.addEventListener('mousemove', handleMouseMove, { passive: true });

function animateCursor() {
    const speed = 0.15;
    
    cursorX += (mouseX - cursorX) * speed;
    cursorY += (mouseY - cursorY) * speed;
    
    cursor.style.transform = `translate(${cursorX}px, ${cursorY}px) scale(${cursorScale || 1})`;
    
    requestAnimationFrame(animateCursor);
}

if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches && 
    !window.matchMedia('(pointer: coarse)').matches) {
    animateCursor();
} else {
    cursor.style.display = 'none';
    document.body.style.cursor = 'auto';
}

// Agrandar cursor en elementos interactivos (optimizado con event delegation)
const interactiveElements = document.querySelectorAll('a, button, .btn');
let cursorScale = 1;

interactiveElements.forEach(element => {
    element.addEventListener('mouseenter', () => {
        cursorScale = 2;
        cursor.style.transform = `translate(${cursorX}px, ${cursorY}px) scale(${cursorScale})`;
    });
    element.addEventListener('mouseleave', () => {
        cursorScale = 1;
        cursor.style.transform = `translate(${cursorX}px, ${cursorY}px) scale(${cursorScale})`;
    });
});

// Mantener navegación clara al hacer scroll (throttled)
const nav = document.querySelector('nav');
let navTicking = false;

const handleNavScroll = throttle(() => {
    const currentScroll = window.pageYOffset;

    if (!nav) return;

    requestAnimationFrame(() => {
        if (currentScroll > 100) {
            nav.style.padding = '0.5rem 0';
            nav.style.background = 'rgba(12, 15, 20, 0.95)';
            nav.style.boxShadow = '0 2px 12px rgba(0, 0, 0, 0.3)';
        } else {
            nav.style.padding = '1rem 0';
            nav.style.background = 'rgba(12, 15, 20, 0.8)';
            nav.style.boxShadow = 'none';
        }
    });
}, 100);

window.addEventListener('scroll', handleNavScroll, { passive: true });

// Efecto de escritura para el título hero
const heroName = document.querySelector('.hero-name');
if (heroName) {
    const text = heroName.textContent;
    heroName.textContent = '';
    heroName.style.opacity = '1';
    
    let i = 0;
    function typeWriter() {
        if (i < text.length) {
            heroName.textContent += text.charAt(i);
            i++;
            setTimeout(typeWriter, 100);
        }
    }
    
    setTimeout(typeWriter, 800);
}

// Partículas flotantes en el fondo
function createParticle() {
    // Respetar preferencia de movimiento reducido
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
        return;
    }
    
    const particle = document.createElement('div');
    particle.classList.add('particle');
    particle.style.left = Math.random() * 100 + '%';
    particle.style.animationDuration = (Math.random() * 3 + 2) + 's';
    particle.style.opacity = Math.random() * 0.5 + 0.1;
    document.body.appendChild(particle);
    
    setTimeout(() => {
        particle.remove();
    }, 5000);
}

// Crear partículas ocasionalmente (con pool para reutilización)
const particlePool = [];
const MAX_PARTICLES = 10;

if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    setInterval(createParticle, 2000);
}

// Cache de selectores para evitar queries repetidas
const cachedElements = {
    nav: document.querySelector('nav'),
    heroContent: document.querySelector('.hero-content'),
    cursor: document.querySelector('.custom-cursor')
};

// Deshabilitar cursor personalizado en dispositivos táctiles al inicio
if (window.matchMedia('(pointer: coarse)').matches) {
    if (cachedElements.cursor) {
        cachedElements.cursor.style.display = 'none';
    }
    document.body.style.cursor = 'auto';
}
