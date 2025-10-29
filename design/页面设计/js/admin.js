const navLinks = Array.from(document.querySelectorAll('nav a[data-page]'));
const adminPages = Array.from(document.querySelectorAll('.admin-page'));
const headerTitle = document.querySelector('header .left h1');
const headerSubtitle = document.querySelector('header .left span');
const quickActions = Array.from(document.querySelectorAll('header .right button[data-jump]'));

const pageMeta = {
    dashboard: { subtitle: '最近更新：2025-10-24 08:30' },
    reports: { subtitle: '导出常用报表示例与订阅设置' },
    schools: { subtitle: '维护院校库数据和校验状态' },
    students: { subtitle: '监控重点高中数据的完整性' },
    'exam-info': { subtitle: '监控考生高考信息完善进度与异常' },
    imports: { subtitle: '查看批量导入任务的进度与日志' },
    model: { subtitle: '分析最新模型版本与实验表现' },
    weights: { subtitle: '管理推荐权重与审批流程' },
    release: { subtitle: '规划灰度发布节奏与回滚策略' },
    feedback: { subtitle: '跟踪考生、家长和老师的反馈处理' },
    roles: { subtitle: '配置角色权限与成员分配' },
    announcement: { subtitle: '发布系统公告并查看历史记录' },
    logs: { subtitle: '审计最新操作日志与变更记录' }
};

function activateAdminPage(target) {
    if (!target) return;

    adminPages.forEach(page => {
        page.classList.toggle('active', page.dataset.page === target);
    });

    navLinks.forEach(link => {
        link.classList.toggle('active', link.dataset.page === target);
    });

    const activeLink = navLinks.find(link => link.dataset.page === target);
    const label = activeLink?.dataset.label || '管理员后台';
    const subtitle = pageMeta[target]?.subtitle || '请选择模块查看详细内容';

    headerTitle.textContent = label;
    headerSubtitle.textContent = subtitle;

    if (window.location.hash.replace('#', '') !== target) {
        window.history.replaceState(null, '', `#${target}`);
    }
}

navLinks.forEach(link => {
    link.addEventListener('click', event => {
        event.preventDefault();
        activateAdminPage(link.dataset.page);
    });
});

quickActions.forEach(button => {
    button.addEventListener('click', () => {
        const target = button.dataset.jump;
        if (!target) return;
        activateAdminPage(target);
    });
});

const initialHash = window.location.hash.replace('#', '');
if (initialHash && adminPages.some(page => page.dataset.page === initialHash)) {
    activateAdminPage(initialHash);
} else {
    activateAdminPage('dashboard');
}