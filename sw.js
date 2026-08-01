/* Service worker da versão desktop */
const CACHE = 'financeira-web-v4';
const CASCA = ['/', '/index.html', '/manifest.json',
  '/icons/icon-192.png', '/icons/icon-512.png',
  'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2'];
self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c=>c.addAll(CASCA).catch(()=>{})).then(()=>self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(ks=>Promise.all(
    ks.filter(k=>k!==CACHE).map(k=>caches.delete(k)))).then(()=>self.clients.claim()));
});
self.addEventListener('fetch', e => {
  const url=new URL(e.request.url);
  if(url.hostname.endsWith('.supabase.co')) return;
  if(e.request.method!=='GET') return;
  e.respondWith(caches.match(e.request).then(hit=>{
    if(hit){ fetch(e.request).then(r=>{if(r&&r.ok)caches.open(CACHE).then(c=>c.put(e.request,r.clone()))}).catch(()=>{}); return hit; }
    return fetch(e.request).then(r=>{
      if(r&&r.ok&&url.origin===location.origin){const cp=r.clone();caches.open(CACHE).then(c=>c.put(e.request,cp));}
      return r;}).catch(()=>caches.match('/index.html'));
  }));
});
