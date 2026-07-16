import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.svg', 'robots.txt', 'icons/*.svg'],
      manifest: {
        name: 'Ghanshyam',
        short_name: 'Ghanshyam',
        description: 'Academic Athlete Deck — personal planner UI',
        theme_color: '#ffffff',
        background_color: '#ffffff',
        display: 'standalone',
        scope: '/',
        start_url: '/',
        icons: [
          { src: '/icons/pwa-192x192.svg', sizes: '192x192', type: 'image/svg+xml' },
          { src: '/icons/pwa-512x512.svg', sizes: '512x512', type: 'image/svg+xml' }
        ]
      }
    })
  ]
})
