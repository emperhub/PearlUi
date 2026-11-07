try {
  const saved = localStorage.getItem('pearl-docs-theme');
  document.documentElement.dataset.theme = saved === 'light' ? 'light' : 'dark';
} catch { document.documentElement.dataset.theme = 'dark'; }
