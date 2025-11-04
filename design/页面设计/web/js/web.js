// 页面切换逻辑
const authContainer = document.getElementById('authContainer');
const appContainer = document.getElementById('appContainer');
const authTabs = document.querySelectorAll('.auth-tab');
const loginForm = document.getElementById('loginForm');
const registerForm = document.getElementById('registerForm');
const navLinks = document.querySelectorAll('nav a');
const pages = document.querySelectorAll('.page');
const breadcrumb = document.querySelector('.breadcrumb');
const btnImportScore = document.getElementById('btnImportScore');
const btnGenerateReport = document.getElementById('btnGenerateReport');

// 认证标签切换
authTabs.forEach(tab => {
  tab.addEventListener('click', () => {
    authTabs.forEach(t => t.classList.remove('active'));
    tab.classList.add('active');

    if (tab.dataset.tab === 'login') {
      loginForm.style.display = 'flex';
      registerForm.style.display = 'none';
    } else {
      loginForm.style.display = 'none';
      registerForm.style.display = 'flex';
    }
  });
});

// 登录提交
loginForm.addEventListener('submit', (e) => {
  e.preventDefault();
  authContainer.style.display = 'none';
  appContainer.classList.add('active');
});

// 注册提交
registerForm.addEventListener('submit', (e) => {
  e.preventDefault();
  alert('注册成功！请登录');
  authTabs[0].click();
});

// 导航切换
navLinks.forEach(link => {
  link.addEventListener('click', (e) => {
    e.preventDefault();
    navLinks.forEach(l => l.classList.remove('active'));
    link.classList.add('active');

    const pageName = link.dataset.page;
    pages.forEach(page => {
      page.classList.remove('active');
      if (page.dataset.page === pageName) {
        page.classList.add('active');
      }
    });

    // 更新面包屑
    const pageTitle = link.textContent.trim();
    breadcrumb.textContent = `首页 / ${pageTitle}`;
  });
});

// 顶部按钮功能
btnImportScore.addEventListener('click', () => {
  const infoLink = document.querySelector('nav a[data-page="info"]');
  if (infoLink) {
    infoLink.click();
  }
});

btnGenerateReport.addEventListener('click', () => {
  const recommendLink = document.querySelector('nav a[data-page="recommend"]');
  if (recommendLink) {
    recommendLink.click();
  }
});

// 选科芯片交互
document.querySelectorAll('.chip').forEach(chip => {
  chip.addEventListener('click', () => {
    chip.classList.toggle('active');
  });
});

// 筛选按钮交互
document.querySelectorAll('.filter-button').forEach(button => {
  button.addEventListener('click', () => {
    button.classList.toggle('active');
  });
});