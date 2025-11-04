const authPage = document.getElementById('authPage');
const mainApp = document.getElementById('mainApp');
const authTabs = document.querySelectorAll('.auth-tab');
const loginForm = document.getElementById('loginForm');
const registerForm = document.getElementById('registerForm');
const tabButtons = document.querySelectorAll('.tab-item');
const tabPages = document.querySelectorAll('.mobile-page');
const floatingAction = document.getElementById('floatingAction');
const pageContent = document.querySelector('.page-content');
const tabJumpButtons = document.querySelectorAll('[data-jump-tab]');

// 认证标签切换
authTabs.forEach(tab => {
    tab.addEventListener('click', () => {
    authTabs.forEach(t => t.classList.remove('active'));
    tab.classList.add('active');
    
    if (tab.dataset.authTab === 'login') {
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
    authPage.classList.remove('active');
    authPage.style.display = 'none';
    mainApp.style.display = 'flex';
});

// 注册提交
registerForm.addEventListener('submit', (e) => {
    e.preventDefault();
    alert('注册成功！请登录');
    authTabs[0].click();
});

const quickActionIcons = {
    home: '+',
    exam: '📝',
    recommend: '⚙️',
    college: '🔍',
    profile: '✏️'
};

function showTab(tab) {
    tabPages.forEach(page => {
    page.classList.remove('active');
    if (page.dataset.tab === tab) {
        page.classList.add('active');
    }
    });
    tabButtons.forEach(button => {
    button.classList.remove('active');
    if (button.dataset.tab === tab) {
        button.classList.add('active');
    }
    });
    if (floatingAction) {
    floatingAction.textContent = quickActionIcons[tab] || '+';
    floatingAction.dataset.currentTab = tab;
    }
    if (pageContent) {
    pageContent.scrollTo({ top: 0, behavior: 'smooth' });
    }
}

tabButtons.forEach(button => {
    button.addEventListener('click', () => {
    showTab(button.dataset.tab);
    });
});

tabJumpButtons.forEach(button => {
    button.addEventListener('click', () => {
    const targetTab = button.dataset.jumpTab;
    if (!targetTab) return;
    showTab(targetTab);
    });
});

if (floatingAction) {
    floatingAction.addEventListener('click', () => {
    const tab = floatingAction.dataset.currentTab || 'home';
    const messageMap = {
        home: '模拟：打开成绩录入弹窗',
        exam: '模拟：填写高考信息并保存',
        recommend: '模拟：打开权重设置面板',
        college: '模拟：跳转到院校搜索页',
        profile: '模拟：进入资料编辑模式'
    };
    alert(messageMap[tab]);
    });
}

// 交互按钮
document.querySelectorAll('.chip').forEach(chip => {
    chip.addEventListener('click', () => {
    chip.classList.toggle('active');
    });
});

document.querySelectorAll('.filter-button').forEach(button => {
    button.addEventListener('click', () => {
    button.classList.toggle('active');
    });
});

document.querySelectorAll('.subject-button').forEach(button => {
    button.addEventListener('click', () => {
    button.classList.toggle('active');
    });
});

document.querySelectorAll('.toggle-button').forEach(button => {
    button.addEventListener('click', () => {
    const group = button.parentElement;
    group.querySelectorAll('.toggle-button').forEach(b => b.classList.remove('active'));
    button.classList.add('active');
    });
});

document.querySelectorAll('.category-tab').forEach(button => {
    button.addEventListener('click', () => {
    const group = button.parentElement;
    group.querySelectorAll('.category-tab').forEach(b => b.classList.remove('active'));
    button.classList.add('active');
    });
});