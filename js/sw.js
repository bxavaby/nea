// ./js/sw.js

self.addEventListener("fetch", (event) => {
  const ua = event.request.headers.get("user-agent") || "";

  if (/bot|crawl|gptbot|anthropic|o1/i.test(ua)) {
    event.respondWith(new Response("🤖 No", { status: 403 }));
    return;
  }

  event.respondWith(fetch(event.request));
});
