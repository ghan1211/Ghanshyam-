import React from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'
import './index.css'

// vite-plugin-pwa provides a virtual helper for runtime registration
import { registerSW } from 'virtual:pwa-register'

const updateSW = registerSW({
  onNeedRefresh () {
    // You could show a toast prompting the user to refresh
    console.log('New content available, please refresh.');
  },
  onOfflineReady () {
    console.log('App is ready to work offline.');
  }
})

createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)

export { updateSW }
