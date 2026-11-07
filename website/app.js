'use strict';
(() => {
  const $ = (s, root = document) => root.querySelector(s);
  const $$ = (s, root = document) => [...root.querySelectorAll(s)];
  const escape = value => String(value).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
  let data, currentPage, observer, toastTimer, searchItems = [], searchIndex = 0, priorFocus;
  const icons = {};
  const icon = name => `<svg aria-hidden="true" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">${icons[name] || icons['file-text'] || ''}</svg>`;
  function paintIcons(root = document) { $$('[data-icon]', root).forEach(el => { el.innerHTML = icon(el.dataset.icon); }); }
  function notify(message) { clearTimeout(toastTimer); $('#toast').textContent = message; $('#toast').classList.add('visible'); toastTimer = setTimeout(() => $('#toast').classList.remove('visible'), 2000); }
  async function copy(text, button) {
    try {
      if (navigator.clipboard?.writeText) await navigator.clipboard.writeText(text);
      else {
        const field = document.createElement('textarea'); field.value = text; field.style.cssText = 'position:fixed;opacity:0'; document.body.append(field); field.select();
        const copied = document.execCommand('copy'); field.remove(); if (!copied) throw new Error('Clipboard unavailable');
      }
      notify('คัดลอกแล้ว');
      if (button?.classList.contains('copy-code')) { const old = button.innerHTML; button.innerHTML = `${icon('check')} Copied`; setTimeout(() => { if (button.isConnected) button.innerHTML = old; }, 1600); }
    } catch { notify('คัดลอกไม่ได้ กรุณาเลือกข้อความแล้วคัดลอก'); }
  }
  function highlight(raw) {
    const tokens = /--\[\[[\s\S]*?\]\]|--[^\n]*|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|\b(?:local|function|end|return|if|then|else|elseif|for|in|do|while|repeat|until|and|or|not|true|false|nil|break|continue)\b|\b\d+(?:\.\d+)?\b|\b[A-Za-z_]\w*(?=\s*\()/g;
    let out = '', last = 0;
    for (const match of raw.matchAll(tokens)) {
      out += escape(raw.slice(last, match.index));
      const value = match[0]; const kind = value.startsWith('--') ? 'comment' : /^['"]/.test(value) ? 'string' : /^\d/.test(value) ? 'number' : /^(local|function|end|return|if|then|else|elseif|for|in|do|while|repeat|until|and|or|not|true|false|nil|break|continue)$/.test(value) ? 'keyword' : 'func';
      out += `<span class="tok-${kind}">${escape(value)}</span>`; last = match.index + value.length;
    }
    return out + escape(raw.slice(last));
  }
  function safeMarkdown(markdown) {
    const parsed = new DOMParser().parseFromString(marked.parse(markdown, {gfm:true}), 'text/html');
    $$('script,style,iframe,object,embed,form,input,button,svg,math,link,meta', parsed).forEach(el => el.remove());
    $$('*', parsed).forEach(el => { for (const attr of [...el.attributes]) if (/^on/i.test(attr.name) || ['style','srcdoc','id'].includes(attr.name)) el.removeAttribute(attr.name); });
    $$('a', parsed).forEach(a => { if (/^\s*(javascript|data|vbscript):/i.test(a.getAttribute('href') || '')) a.removeAttribute('href'); });
    $$('img', parsed).forEach(img => { const src = img.getAttribute('src') || ''; if (!/^https:\/\//i.test(src)) img.remove(); });
    return parsed.body.innerHTML;
  }
  const headingId = text => text.toLowerCase().trim().replace(/[^\p{L}\p{N}\s_-]/gu, '').replace(/[\s_]+/g, '-');
  function enhanceContent(root, page) {
    const seen = new Map();
    $$('h2,h3', root).forEach(el => { if (el.id) return; const base = headingId(el.textContent) || 'section'; const count = seen.get(base) || 0; seen.set(base, count+1); el.id = base + (count ? `-${count}` : ''); });
    $$('table', root).forEach(table => { const wrap = document.createElement('div'); wrap.className = 'table-scroll'; table.before(wrap); wrap.append(table); });
    $$('pre', root).forEach(pre => {
      const raw = pre.textContent.replace(/\n$/, ''); const language = $('code', pre)?.className.replace('language-','') || 'luau';
      const box = document.createElement('div'); box.className = 'code-block';
      const top = document.createElement('div'); top.className = 'code-top'; top.innerHTML = `<span>${icon('code-xml')}${escape(language === 'lua' ? 'luau' : language)}</span>`;
      const button = document.createElement('button'); button.className = 'copy-code'; button.setAttribute('aria-label','คัดลอกโค้ด'); button.innerHTML = `${icon('copy')} Copy`;
      button.addEventListener('click', () => copy(raw, button)); top.append(button);
      const code = document.createElement('code'); code.innerHTML = highlight(raw); pre.replaceChildren(code); pre.before(box); box.append(top, pre);
    });
    $$('a', root).forEach(a => {
      const href = a.getAttribute('href'); if (!href) return;
      if (href.startsWith('#/')) return;
      if (href.startsWith('#')) { a.href = `#/${page.slug}/${encodeURIComponent(href.slice(1))}`; return; }
      if (/^https?:/.test(href)) { a.target = '_blank'; a.rel = 'noopener noreferrer'; return; }
      const path = href.split('#')[0]; const anchor = href.includes('#') ? href.split('#')[1] : '';
      const mapped = data.pages.find(p => p.source && (p.source === path || p.source.split('/').pop() === path.split('/').pop()));
      a.href = mapped ? `#/${mapped.slug}${anchor ? '/'+encodeURIComponent(anchor) : ''}` : `https://github.com/emperhub/PearlUi/blob/main/${path.startsWith('../') ? path.slice(3) : path.startsWith('docs/') ? path : 'docs/'+path}`;
      if (!mapped) { a.target = '_blank'; a.rel = 'noopener noreferrer'; }
    });
  }
  function preview() {
    return `<div class="intro-preview"><div class="mock-window"><div class="mock-bar"><div class="traffic"><i></i><i></i><i></i></div><span class="mock-title">Pearl UI</span><span></span></div><div class="mock-body"><div class="mock-nav"><div class="mock-nav-label">LIBRARY</div><span class="selected">${icon('sliders-horizontal')}General</span><span>${icon('palette')}Appearance</span><span>${icon('keyboard')}Controls</span><span>${icon('layers')}Profiles</span></div><div class="mock-content"><strong>General</strong><p>A calmer space. Made for the way you play.</p><div class="mock-card"><div class="mock-row"><span>Show notifications</span><span class="mini-switch"></span></div><div class="mock-row"><span>Theme</span><span class="mini-field">Forest ⌄</span></div><div class="mock-row"><span>Animation speed</span><span class="mini-slider"></span></div></div></div></div></div><span class="preview-tag">${icon('sparkles')} PEARL / FOREST</span></div><div class="preview-caption"><span>ภาพจำลองประกอบคู่มือ · ตัว UI ใช้งานใน Roblox</span><span>macOS-inspired. Unmistakably Pearl.</span></div><div class="intro-links"><a class="intro-link" href="#/getting-started"><span>${icon('terminal')}</span><div><strong>เริ่มสร้าง UI แรก</strong><p>ติดตั้งและต่อคอนโทรลได้ในไม่กี่ขั้นตอน</p></div><span class="arrow">${icon('arrow-up-right')}</span></a><a class="intro-link" href="#/api"><span>${icon('braces')}</span><div><strong>เปิด API Reference</strong><p>เมธอด ค่าที่รับ และผลลัพธ์จากโค้ดจริง</p></div><span class="arrow">${icon('arrow-up-right')}</span></a></div>`;
  }
  function renderMethods(target, page) {
    const entries = Object.entries(data.api).filter(([key]) => !page.apiPrefixes || page.apiPrefixes.some(prefix => key.startsWith(prefix)));
    if (!entries.length) return;
    const container = document.createElement('section'); container.className = 'method-list';
    if (page.slug === 'api') container.innerHTML = `<div class="api-summary"><span>${entries.length} methods</span><span>Version ${escape(data.version)}</span><span>Luau</span></div><label class="field-search">${icon('search')}<input id="api-filter" aria-label="ค้นหา API" placeholder="ค้นหาเมธอด เช่น SetTheme, Control.Set..."></label><div id="api-empty" class="empty-state" hidden>ไม่พบเมธอดที่ตรงกัน</div>`;
    else container.innerHTML = '<h2 id="api-reference">API Reference</h2>';
    let lastGroup = '';
    entries.forEach(([key, method]) => {
      const group = key.split('.')[0];
      if (page.slug === 'api' && group !== lastGroup) { const h = document.createElement('h2'); h.id = `api-${group.toLowerCase()}`; h.textContent = group; h.dataset.apiGroup = group; container.append(h); lastGroup = group; }
      const card = document.createElement('article'); card.className = 'api-card'; card.dataset.apiText = `${key} ${method.signature} ${method.contract}`.toLowerCase(); card.dataset.group = group;
      card.innerHTML = `<h3 id="api-${key.toLowerCase().replace(/\./g,'-')}" data-outline="false">${escape(key)}</h3><p>${escape(method.contract)}</p><div class="api-return">Returns <span>${escape(method.returns)}</span></div><div class="api-signature"><code>${escape(method.signature)}</code><button aria-label="คัดลอก ${escape(key)}">${icon('copy')}</button></div>`;
      $('button', card).addEventListener('click', () => copy(method.signature)); container.append(card);
    });
    target.append(container);
    $('#api-filter', container)?.addEventListener('input', e => {
      const q = e.target.value.trim().toLowerCase(); let matches = 0;
      $$('.api-card', container).forEach(card => { card.hidden = !card.dataset.apiText.includes(q); if (!card.hidden) matches++; });
      $$('[data-api-group]', container).forEach(h => { h.hidden = !$$('.api-card', container).some(card => card.dataset.group === h.dataset.apiGroup && !card.hidden); });
      $('#api-empty').hidden = matches !== 0;
    });
  }
  function renderIconGallery(target) {
    const container = document.createElement('section'); container.innerHTML = `<h2 id="icon-catalog">คลังไอคอน</h2><label class="field-search">${icon('search')}<input id="icon-filter" aria-label="ค้นหาไอคอน" placeholder="ค้นหาชื่อหรือ alias เช่น shield, settings, home..."></label><div class="icon-toolbar"><span id="icon-count"></span><span>กดไอคอนเพื่อคัดลอกชื่อ</span></div><div class="icon-grid" id="icon-grid"></div><div class="pager"><button class="quiet-button" id="icons-prev">← ก่อนหน้า</button><span id="icon-page" class="loading-label"></span><button class="quiet-button" id="icons-next">ถัดไป →</button></div>`; target.append(container);
    let page = 0, names = data.icons; const pageSize = 40;
    function draw() {
      const start = page * pageSize; $('#icon-grid').replaceChildren();
      for (const name of names.slice(start, start+pageSize)) {
        const button = document.createElement('button'); button.className = 'icon-cell'; button.title = `คัดลอก ${name}`; button.setAttribute('aria-label', `คัดลอกไอคอน ${name}`);
        button.innerHTML = `<img src="./icons/${encodeURIComponent(name)}.svg" alt="" loading="lazy"><span>${escape(name)}</span>`;
        button.addEventListener('click', () => copy(name)); $('#icon-grid').append(button);
      }
      if (!names.length) $('#icon-grid').innerHTML = '<p class="empty-state">ไม่พบไอคอน</p>';
      $('#icon-count').textContent = `${names.length.toLocaleString()} icons`;
      $('#icon-page').textContent = `${names.length ? page+1 : 0} / ${Math.max(1,Math.ceil(names.length/pageSize))}`;
      $('#icons-prev').disabled = page === 0; $('#icons-next').disabled = start+pageSize >= names.length;
    }
    $('#icon-filter').addEventListener('input', e => {
      const q = e.target.value.toLowerCase().replace(/^lucide:/,'').replace(/[^a-z0-9]/g,''); const aliases = new Set(Object.entries(data.aliases).filter(([key]) => key.replace(/[^a-z0-9]/g,'').includes(q)).map(([,value]) => value));
      names = data.icons.filter(name => name.replace(/-/g,'').includes(q) || aliases.has(name)); page = 0; draw();
    });
    $('#icons-prev').addEventListener('click', () => { page--; draw(); }); $('#icons-next').addEventListener('click', () => { page++; draw(); }); draw();
  }
  function renderThemes(target) {
    const container = document.createElement('div'); container.className = 'theme-swatches';
    data.themes.order.forEach(name => { const p = data.themes.palettes[name]; const item = document.createElement('div'); item.className = 'theme-swatch'; item.innerHTML = `<div class="swatch-preview" style="background:${p.Window}"><span class="swatch-sidebar" style="background:${p.Sidebar}"></span><span class="swatch-card" style="background:${p.Card}"><span class="swatch-accent" style="background:${p.Accent}"></span></span></div><div class="swatch-label">${escape(name)}<span>${escape(p.Accent)}</span></div>`; container.append(item); }); target.prepend(container);
  }
  function closeMobile() { $('#sidebar').classList.remove('open'); $('#mobile-backdrop').hidden = true; $('#mobile-menu').setAttribute('aria-expanded','false'); }
  function buildNav() {
    $('#navigation').innerHTML = data.groups.map(group => `<div class="nav-group"><div class="nav-group-label">${escape(group.label)}</div>${data.pages.filter(p => p.group === group.id).map(page => `<a class="nav-link" data-page="${page.slug}" href="#/${page.slug}">${icon(page.icon)}<span>${escape(page.title)}</span>${page.badge ? `<span class="nav-new">${escape(page.badge)}</span>` : ''}</a>`).join('')}</div>`).join('');
    $('#version').textContent = data.version;
  }
  function buildOutline(root, page) {
    observer?.disconnect(); const headings = $$('h2,h3',root).filter(el => el.dataset.outline !== 'false');
    $('#outline').innerHTML = headings.map(h => `<a href="#/${page.slug}/${encodeURIComponent(h.id)}" class="${h.tagName === 'H3' ? 'nested' : ''}" data-heading="${escape(h.id)}">${escape(h.textContent)}</a>`).join('') || '<span class="loading-label">ไม่มีหัวข้อย่อย</span>';
    observer = new IntersectionObserver(entries => { entries.forEach(entry => { if (entry.isIntersecting) { $$('#outline a').forEach(a => a.classList.toggle('active',a.dataset.heading === entry.target.id)); } }); }, {rootMargin:'-90px 0px -65% 0px'});
    headings.forEach(h => observer.observe(h));
  }
  function route() {
    if (!data) return;
    const [requestedSlug, ...rest] = location.hash.replace(/^#\/?/,'').split('/'); const slug=requestedSlug || 'introduction'; let anchor='';try {anchor=rest.length ? decodeURIComponent(rest.join('/')) : '';}catch{}
    const page = data.pages.find(p => p.slug === slug);
    if (!page) { currentPage = undefined;closeMobile();$$('.nav-link').forEach(a=>{a.classList.remove('active');a.removeAttribute('aria-current');});document.title='ไม่พบหน้า — PearlUI Documentation';$('#main').innerHTML = `<div class="breadcrumb">Documentation / 404</div><h1>ไม่พบหน้านี้</h1><p class="page-description">ลิงก์นี้ไม่มีในคู่มือเวอร์ชัน ${escape(data.version)}</p><a class="quiet-button" href="#/introduction">กลับหน้าคู่มือ</a>`; $('#outline').replaceChildren(); return; }
    closeMobile();
    if (currentPage !== page.slug) {
      currentPage = page.slug; document.title = `${page.title} — PearlUI Documentation`;
      const group = data.groups.find(g => g.id === page.group); const index = data.pages.indexOf(page), prev = data.pages[index-1], next = data.pages[index+1];
      $('#main').innerHTML = `<div class="breadcrumb"><a href="#/introduction">Documentation</a>${icon('chevron-right')}<span>${escape(group.label)}</span>${icon('chevron-right')}<span>${escape(page.title)}</span></div><div class="page-eyebrow">${escape(page.eyebrow || group.label)}</div><h1>${escape(page.heading || page.title)}</h1><p class="page-description">${escape(page.description)}</p><div class="page-meta"><span class="version">v${escape(data.version)}</span><span>Roblox · Luau</span><span>${icon('check')} จาก API ของ PearlUI</span></div>${page.slug === 'introduction' ? preview() : ''}<div class="prose" id="page-content">${safeMarkdown(page.markdown || '')}</div><nav class="page-footer" aria-label="หน้าก่อนหน้าและถัดไป">${prev ? `<a href="#/${prev.slug}"><small>← ก่อนหน้า</small><strong>${escape(prev.title)}</strong></a>` : '<span></span>'}${next ? `<a href="#/${next.slug}"><small>ถัดไป →</small><strong>${escape(next.title)}</strong></a>` : '<span></span>'}</nav><div class="bottom-note"><span>PearlUI · Built with intention.</span><a href="https://github.com/emperhub/PearlUi/blob/main/LICENSE" target="_blank" rel="noopener noreferrer">MIT License</a></div>`;
      const content = $('#page-content');
      if (page.slug === 'themes') renderThemes(content);
      if (page.slug === 'icons') renderIconGallery(content);
      if (page.apiPrefixes || page.slug === 'api') renderMethods(content, page);
      enhanceContent(content, page); buildOutline(content, page);
      $$('.nav-link').forEach(a => { const active = a.dataset.page === page.slug; a.classList.toggle('active',active); if (active) a.setAttribute('aria-current','page'); else a.removeAttribute('aria-current'); });
      $('#edit-page').href = `https://github.com/emperhub/PearlUi/blob/main/${page.source || 'tools/build_docs_site.py'}`;
      window.scrollTo({top:0,behavior:'instant'});
    }
    if (anchor) requestAnimationFrame(() => { document.getElementById(anchor)?.scrollIntoView({behavior:matchMedia('(prefers-reduced-motion: reduce)').matches ? 'instant' : 'smooth',block:'start'}); });
  }
  const dialog = $('#search-dialog');
  function setSearchIndex(index) { searchIndex = Math.max(0,Math.min(index,searchItems.length-1)); $$('.search-result').forEach((el,i) => { const selected = i === searchIndex; el.setAttribute('aria-selected', String(selected)); if (selected) { $('#global-search').setAttribute('aria-activedescendant',el.id); el.scrollIntoView({block:'nearest'}); } }); }
  function search() {
    if (!data) return;
    const q = $('#global-search').value.trim().toLowerCase();
    const results = data.pages.map(page => ({title:page.title,description:page.description,slug:page.slug,icon:page.icon,kind:'GUIDE',text:`${page.title} ${page.heading || ''} ${page.description} ${page.markdown}`.toLowerCase()}));
    Object.entries(data.api).forEach(([key,m]) => results.push({title:key,description:m.signature,slug:'api',anchor:`api-${key.toLowerCase().replace(/\./g,'-')}`,icon:'braces',kind:'API',text:`${key} ${m.signature} ${m.contract}`.toLowerCase()}));
    const terms = q.split(/\s+/).filter(Boolean);
    searchItems = (q ? results.filter(item => terms.every(term => item.text.includes(term))).sort((a,b) => Number(b.title.toLowerCase().includes(q))-Number(a.title.toLowerCase().includes(q))) : results.filter(item => ['getting-started','loadstring','window','configs','api'].includes(item.slug) && item.kind === 'GUIDE')).slice(0,18);
    $('#search-results').innerHTML = searchItems.length ? searchItems.map((item,i) => `<div class="search-result" role="option" id="result-${i}" data-result="${i}" aria-selected="${i===0}">${icon(item.icon)}<div><strong>${escape(item.title)}</strong><small>${escape(item.description.slice(0,90))}</small></div><span class="result-kind">${item.kind}</span></div>`).join('') : '<div class="empty-state">ไม่พบผลลัพธ์ ลองค้นหาด้วยชื่อเมธอดหรือชื่อคอนโทรล</div>';
    searchIndex = 0; $('#global-search').removeAttribute('aria-activedescendant'); if (searchItems.length) $('#global-search').setAttribute('aria-activedescendant','result-0');
  }
  function openSearch() { if (dialog.open || !data) return; priorFocus = document.activeElement; dialog.showModal(); $('#global-search').setAttribute('aria-expanded','true');$('#global-search').value=''; search(); $('#global-search').focus(); }
  function closeSearch() { dialog.close();$('#global-search').setAttribute('aria-expanded','false');priorFocus?.focus(); }
  function chooseResult(index) { const item = searchItems[index]; if (!item) return; closeSearch(); const hash = `#/${item.slug}${item.anchor ? '/'+item.anchor : ''}`; if (location.hash === hash) route(); else location.hash = hash; }
  $('#open-search').addEventListener('click',openSearch); $('#close-search').addEventListener('click',closeSearch);
  $('#global-search').setAttribute('role','combobox'); $('#global-search').setAttribute('aria-controls','search-results'); $('#global-search').setAttribute('aria-autocomplete','list');$('#global-search').setAttribute('aria-expanded','false');
  $('#global-search').addEventListener('input',search);
  $('#search-results').addEventListener('click',e => { const row=e.target.closest('[data-result]'); if (row) chooseResult(Number(row.dataset.result)); });
  dialog.addEventListener('click',e => { if (e.target === dialog) { const rect=dialog.getBoundingClientRect(); if (e.clientX<rect.left || e.clientX>rect.right || e.clientY<rect.top || e.clientY>rect.bottom) closeSearch(); } });
  dialog.addEventListener('cancel',e => { e.preventDefault(); closeSearch(); });
  document.addEventListener('keydown',e => {
    if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase()==='k') { e.preventDefault(); dialog.open ? closeSearch() : openSearch(); }
    if (dialog.open && ['ArrowDown','ArrowUp','Enter'].includes(e.key)) { e.preventDefault(); if (e.key==='Enter') chooseResult(searchIndex); else setSearchIndex(searchIndex+(e.key==='ArrowDown'?1:-1)); }
    if (e.key==='Escape') closeMobile();
  });
  $('#theme-toggle').addEventListener('click',() => { const theme=document.documentElement.dataset.theme==='dark'?'light':'dark';document.documentElement.dataset.theme=theme;try {localStorage.setItem('pearl-docs-theme',theme);}catch{}$('#theme-toggle').setAttribute('aria-label',theme==='dark'?'เปลี่ยนเป็นธีมสว่าง':'เปลี่ยนเป็นธีมมืด'); });
  $('#mobile-menu').addEventListener('click',() => { const open=!$('#sidebar').classList.contains('open');$('#sidebar').classList.toggle('open',open);$('#mobile-backdrop').hidden=!open;$('#mobile-menu').setAttribute('aria-expanded',String(open)); });
  $('#mobile-backdrop').addEventListener('click',closeMobile);
  $('.skip-link').addEventListener('click',e=>{e.preventDefault();$('#main').focus();$('#main').scrollIntoView({block:'start'});});
  addEventListener('hashchange',route);
  fetch('./content.json').then(response => { if (!response.ok) throw new Error(`HTTP ${response.status}`);return response.json(); }).then(content => { data=content;Object.assign(icons,data.uiIcons);paintIcons();buildNav();route(); }).catch(error => { console.error(error);$('#main').innerHTML='<h1>โหลดคู่มือไม่สำเร็จ</h1><p class="page-description">ลองโหลดหน้าใหม่ หรืออ่านคู่มือที่ GitHub ระหว่างนี้</p><a class="quiet-button" href="https://github.com/emperhub/PearlUi/tree/main/docs">เปิดคู่มือบน GitHub ↗</a>';$('#navigation').innerHTML='<p class="loading-label">ไม่สามารถโหลดข้อมูลได้</p>'; });
})();
