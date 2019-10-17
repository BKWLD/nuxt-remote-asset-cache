import captureUrls from 'nuxt-remote-asset-cache/dist/capture-urls'
export default (context) => {
  context.$cacheAssets = (data) => captureUrls(data);
}