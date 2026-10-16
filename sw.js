// 离线缓存：添加到主屏幕后断网也能玩。改了任何资源都要把 VERSION 加一，旧缓存才会被换掉。
const VERSION = 'naiwa-v7';
const FILES = [
  './',
  'index.html',
  'manifest.webmanifest',
  'assets/icons/icon-180.png',
  'assets/icons/icon-192.png',
  'assets/icons/icon-512.png',
  'assets/laugh.m4a',
  'assets/laugh.mp3',
  'assets/small/000.webp',
  'assets/small/001.webp',
  'assets/small/002.webp',
  'assets/small/003.webp',
  'assets/small/004.webp',
  'assets/small/005.webp',
  'assets/small/006.webp',
  'assets/small/007.webp',
  'assets/small/008.webp',
  'assets/small/009.webp',
  'assets/small/010.webp',
  'assets/small/011.webp',
  'assets/small/012.webp',
  'assets/small/013.webp',
  'assets/small/014.webp',
  'assets/small/015.webp',
  'assets/small/016.webp',
  'assets/small/017.webp',
  'assets/small/018.webp',
  'assets/small/019.webp',
  'assets/small/020.webp',
  'assets/small/021.webp',
  'assets/small/022.webp',
  'assets/small/023.webp',
  'assets/small/024.webp',
  'assets/small/025.webp',
  'assets/small/026.webp',
  'assets/small/027.webp',
  'assets/small/028.webp',
  'assets/small/029.webp',
  'assets/small/030.webp',
  'assets/small/031.webp',
  'assets/small/032.webp',
  'assets/small/033.webp',
  'assets/small/034.webp',
  'assets/frames/000.webp',
  'assets/frames/001.webp',
  'assets/frames/002.webp',
  'assets/frames/003.webp',
  'assets/frames/004.webp',
  'assets/frames/005.webp',
  'assets/frames/006.webp',
  'assets/frames/007.webp',
  'assets/frames/008.webp',
  'assets/frames/009.webp',
  'assets/frames/010.webp',
  'assets/frames/011.webp',
  'assets/frames/012.webp',
  'assets/frames/013.webp',
  'assets/frames/014.webp',
  'assets/frames/015.webp',
  'assets/frames/016.webp',
  'assets/frames/017.webp',
  'assets/frames/018.webp',
  'assets/frames/019.webp',
  'assets/frames/020.webp',
  'assets/frames/021.webp',
  'assets/frames/022.webp',
  'assets/frames/023.webp',
  'assets/frames/024.webp',
  'assets/frames/025.webp',
  'assets/frames/026.webp',
  'assets/frames/027.webp',
  'assets/frames/028.webp',
  'assets/frames/029.webp',
  'assets/frames/030.webp',
  'assets/frames/031.webp',
  'assets/frames/032.webp',
  'assets/frames/033.webp',
  'assets/frames/034.webp',
];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(VERSION).then(c => c.addAll(FILES)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', e => {
  e.waitUntil(caches.keys()
    .then(keys => Promise.all(keys.filter(k => k !== VERSION).map(k => caches.delete(k))))
    .then(() => self.clients.claim()));
});

// 先用缓存（断网、网慢都能马上打开），缓存里没有的才走网络；?app、?debug 这些参数不影响命中
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET' || new URL(e.request.url).origin !== location.origin) return;
  e.respondWith(caches.open(VERSION).then(async c => {
    const hit = await c.match(e.request, { ignoreSearch: true });
    return hit || fetch(e.request);
  }));
});
