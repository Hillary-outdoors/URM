import type { MetadataRoute } from 'next';

/** Lets the app be added to a phone's home screen with a proper name and icon. */
export default function manifest(): MetadataRoute.Manifest {
  return {
    name: 'URMA · Hillary Outdoors',
    short_name: 'URMA',
    description: 'Universal Record Management App: intentions, competencies and AMPs.',
    start_url: '/',
    display: 'standalone',
    background_color: '#f4f5f7',
    theme_color: '#1d3557',
    orientation: 'portrait',
    icons: [
      { src: '/icon.svg', sizes: 'any', type: 'image/svg+xml' },
      { src: '/apple-icon.png', sizes: '180x180', type: 'image/png' },
      // Android wants real PNGs; "maskable" stops it drawing a white square behind the icon.
      { src: '/icon-192.png', sizes: '192x192', type: 'image/png' },
      { src: '/icon-512.png', sizes: '512x512', type: 'image/png' },
      { src: '/icon-512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
    ],
  };
}
