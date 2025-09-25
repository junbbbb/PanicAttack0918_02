'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "f393d3c16b631f36852323de8e583132",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"manifest.json": "5ba13352947515e76454219f4d7f6238",
"index.html": "efa3d6f1720cb5f5dbc34ee5d6e196c4",
"/": "efa3d6f1720cb5f5dbc34ee5d6e196c4",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "e16ebb0db94e0eef33da1fae2dac718b",
"assets/assets/icons/navigation/home.svg": "0bec4cc2477b52ac4c50d3645eb4a359",
"assets/assets/icons/navigation/analyis_s.svg": "814df408d30e3ceaad1fde494b28d4e4",
"assets/assets/icons/navigation/mental.svg": "4db7c0b0c7f0325f99cfa49e324dd570",
"assets/assets/icons/navigation/grounding.svg": "50698dd3924ad965284b3162c84b9cab",
"assets/assets/icons/navigation/profile_s.svg": "e9c05b24bc8ce53a992be4b4505b8d48",
"assets/assets/icons/navigation/profile.svg": "ed6e56a08c9edf221c6258f134a2c149",
"assets/assets/icons/navigation/breath.svg": "07c8ef411910217db960528a802e0080",
"assets/assets/icons/navigation/record.svg": "b6ccd8e955853a269e698cfb27f6cc90",
"assets/assets/icons/navigation/home_s.svg": "eb3e14aafa935a8c92dc7f5949fab83b",
"assets/assets/icons/navigation/record_s.svg": "7a7db421aca39cac9fb546632d3ba31d",
"assets/assets/icons/navigation/analyis.svg": "7d5bafcb8c664a616ca0a4ee307c4a61",
"assets/assets/images/characters/bare.png": "49842eaba98d32b56f4c93d9fd7d4c65",
"assets/assets/images/backgrounds/tree_small.svg": "0d99287b9e624b11247fc889e86e81ab",
"assets/assets/images/backgrounds/cloud_small.svg": "8b0e651516ea5e88aeeffc2158985463",
"assets/assets/images/backgrounds/firefly_20250920215741_1_2x.webp": "eb2436ab52632ff2566cb73a03c7f0c6",
"assets/assets/images/backgrounds/cloud_big.svg": "8e4155f9c3fe60ca6feb44603467e11e",
"assets/assets/images/backgrounds/tree_big.svg": "69aa4772d1e815f3210d53d1fce46401",
"assets/assets/images/backgrounds/firefly_20250920215741_1_1x.webp": "f3a61d84d9f915c9251a9814cf9ad3ae",
"assets/assets/images/backgrounds/defaultbg.png": "68024f21cd31c0501235ed2dd1fa8b7b",
"assets/assets/images/backgrounds/firefly_20250920215741_1_4x.webp": "320014cc5bec6a79445dc70e2e8300fc",
"assets/assets/images/backgrounds/breath_bg.png": "27d6a6a0e3ecdf4bba410bcfae70837b",
"assets/assets/images/backgrounds/firefly_20250920215741_1_3x.webp": "e33b4658fd56558e675864c3325971d8",
"assets/fonts/MaterialIcons-Regular.otf": "1ce785e03a21e4256dafbb81131c69c4",
"assets/NOTICES": "e6022087cb68f9c6e747cfcc26296eb6",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin": "b9fffc7f286ea1d7ed64bab48da5ba67",
"assets/AssetManifest.json": "70e7c71c02bd062821ab92472bc22fc5",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter_bootstrap.js": "9760e33ecf14b08284655f2fca81a5c0",
"version.json": "7fac07c650f999b1f0e00769f8b6694a",
"main.dart.js": "bb835a47181661d866de01abfbe2d7b4"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
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
        // Claim client to enable caching on first launch
        self.clients.claim();
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
      // Claim client to enable caching on first launch
      self.clients.claim();
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
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
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
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
