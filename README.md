# nuxt-remote-asset-cache

This stores remote assets, like images, that are referenced in the `asyncData` of a Nuxt page in some local directory that isn't destroyed between successive `generate` calls.  This was written, in particular, for Netlify and it's `NETLIFY_CACHE_DIR`.

## Example

```js
// nuxt.config.js
{
  modules: [
    	'nuxt-remote-asset-cache',
  ]
  
  /**
   * This would download anything in the data returned from asyncData with a
   * URL like http://cms.hostname.com/images/file.jpg to the directory path
   * from $NETLIFY_CACHE_DIR.  In addition, they will be published on every
   * generate into /dist/images/file.jpg (for example)
   */
  remoteAssetCache: {
    cacheDir: process.env.NETLIFY_CACHE_DIR,
    assetRegex: [
      {
        pattern: /https?:\/\/cms\.hostname\.com\/images\/([\w\d-.]+)/gi,
        replacement: '/images/$1'
      }
    ]
  }
}
```