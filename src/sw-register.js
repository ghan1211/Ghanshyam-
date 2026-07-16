// Optional: manual Workbox registration helper using workbox-window
// You can use this instead of the virtual helper if you prefer Workbox APIs
import { Workbox } from 'workbox-window'

export function registerWorkbox () {
  if ('serviceWorker' in navigator) {
    const wb = new Workbox('/sw.js')

    wb.addEventListener('installed', event => {
      if (event.isUpdate) {
        console.log('New service worker installed — update available.');
      } else {
        console.log('Service worker installed for the first time.');
      }
    })

    wb.register().catch(err => console.error('SW registration failed:', err))
  }
}
