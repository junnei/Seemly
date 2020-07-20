'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "index.html": "d9229ac20f8386767a02d32f48408a0a",
"/": "d9229ac20f8386767a02d32f48408a0a",
"main.dart.js": "fc8d2a04f46da1d4bd5c8321229dcce2",
"favicon_default.png": "5dcef449791fa27946b3d35ad8803796",
"favicon.png": "cc641a501febb3e0db3cfdd30e8c6d41",
"icons/1024.png": "50662a758a4497ee4e75f602754296b3",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/144.png": "efd2a70e59383a7f1022b52f19370fc2",
"icons/152.png": "484f6b5b1f32bd0edda71c745028f534",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "b5e42c9ba63e7307b0099beaa1414b5d",
"assets/images/auth/text_logo.png": "4b1471874689423ae568afb151e80714",
"assets/images/auth/arrow_left.png": "da5bf6d16554676b806de77fed632e9e",
"assets/images/auth/icon_logo.png": "9b70767c0f0bca952af0753e8b6affd6",
"assets/images/auth/text_description.png": "2683cfdbff03813c64d03f0ad36aa2f2",
"assets/images/auth/logo2.png": "0c9bdf5b05d8ae43c28b84fce59b69ac",
"assets/images/auth/text_welcome.png": "da3a1d24769a8993df18e0bc3f5f7430",
"assets/images/shop/item1.png": "880c8583255241d5c9c2eb0935d67bf8",
"assets/images/shop/item2.png": "ae8908d7b297d825c79b75e1af15c8ec",
"assets/images/shop/item3.png": "989b31ae1d5d4c6a631f0ffde19f1d7f",
"assets/images/shop/icon_mask.png": "25861a22543b51e2e89e174a728a92ee",
"assets/images/Group%2520181.png": "28df7dc15f0a91f72e31f1aeeb1cf9ab",
"assets/images/logo.png": "0c71107917669776c425c48200527c80",
"assets/images/unnamed.jpg": "d99babbca6fbb08924871ee6be8be265",
"assets/images/main/main_waiting.png": "ab93abb0367d336c9f90c645fbfb5b79",
"assets/images/main/icon_women.png": "fce16f71821e781d5daa49fa191bac4b",
"assets/images/main/main_logo.png": "cc1353430ec2bfb9f54274f5f1b315f7",
"assets/images/main/icon_random.png": "1fc407a2037944aadee1e1fa1c7c27e8",
"assets/images/main/icon_men.png": "5958ccb2eddac9619e676faf2be862d7",
"assets/AssetManifest.json": "764a6b11581fcb45da2063dc322d0909",
"assets/NOTICES": "2fd7b3aab4652ec392b3170202606c51",
"assets/FontManifest.json": "01700ba55b08a6141f33e168c4a6c22f",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/LICENSE",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      // Provide a no-cache param to ensure the latest version is downloaded.
      return cache.addAll(CORE.map((value) => new Request(value, {'cache': 'no-cache'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');

      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }

      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#')) {
    key = '/';
  }
  // If the URL is not the the RESOURCE list, skip the cache.
  if (!RESOURCES[key]) {
    return event.respondWith(fetch(event.request));
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache. Ensure the resources are not cached
        // by the browser for longer than the service worker expects.
        var modifiedRequest = new Request(event.request, {'cache': 'no-cache'});
        return response || fetch(modifiedRequest).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.message == 'skipWaiting') {
    return self.skipWaiting();
  }

  if (event.message = 'downloadOffline') {
    downloadOffline();
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey in Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.add(resourceKey);
    }
  }
  return Cache.addAll(resources);
}
